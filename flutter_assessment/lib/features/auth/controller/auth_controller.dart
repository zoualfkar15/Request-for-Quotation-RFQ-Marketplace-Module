import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../core/constant/end_points.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/network/request/api_client.dart';
import '../../../core/service/socket/centrifugo_handler.dart';
import '../../../core/service/storage/local_storage_service.dart';
import '../../offers/controller/offers_controller.dart';
import '../../requests/controller/requests_controller.dart';
import '../../quotations/controller/quotations_controller.dart';
import '../../subscriptions/controller/subscriptions_controller.dart';
import '../../notifications/controller/notifications_controller.dart';
import '../model/auth_user.dart';
import '../view/page/reset_password_page.dart';
import '../view/page/verify_account_page.dart';

class AuthController extends GetxController {
  AuthController({required this.api, required this.storage});

  final ApiClient api;
  final LocalStorageService storage;

  final isLoading = false.obs;
  final user = Rxn<AuthUser>();

  bool get isLoggedIn => (storage.accessToken ?? '').isNotEmpty;

  Future<void> _applyTokens(Map<String, dynamic> map) async {
    final u = AuthUser.fromJson(map['user'] as Map<String, dynamic>);
    await storage.setAuth(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      role: u.role,
      userId: u.id,
    );
    user.value = u;
    // Ensure websocket starts/restarts after auth changes.
    try {
      await Get.find<CentrifugoHandler>().connect(force: true);
    } catch (_) {}

    // Warm up initial data so first landing screens are not empty until manual refresh.
    // Best-effort only (do not block navigation on failures).
    try {
      if (Get.isRegistered<OffersController>()) {
        await Get.find<OffersController>().load();
      }
      if (u.role == 'company') {
        if (Get.isRegistered<RequestsController>()) {
          await Get.find<RequestsController>().loadAvailable();
        }
        if (Get.isRegistered<QuotationsController>()) {
          await Get.find<QuotationsController>().loadMy();
        }
      } else {
        if (Get.isRegistered<RequestsController>()) {
          await Get.find<RequestsController>().loadMy();
        }
        if (Get.isRegistered<SubscriptionsController>()) {
          await Get.find<SubscriptionsController>().load();
        }
      }
      if (Get.isRegistered<NotificationsController>()) {
        await Get.find<NotificationsController>().load();
      }
    } catch (_) {}
  }

  Future<void> login({required String login, required String password}) async {
    try {
      isLoading.value = true;
      final res = await api.post(Endpoints.login, data: {
        'login': login,
        'password': password,
      });

      final map = res as Map<String, dynamic>;
      await _applyTokens(map);
      Get.offAllNamed('/home');
    } on ApiException catch (e) {
      // If backend says the account is not verified, send user to OTP verify flow.
      if (e.statusCode == 403 &&
          e.message.toLowerCase().contains('not verified')) {
        Get.toNamed(VerifyAccountPage.route,
            arguments: {'email': login.trim()});
        Fluttertoast.showToast(
            msg: 'Please verify your account with OTP (123456).');
      } else {
        Fluttertoast.showToast(msg: e.message);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser({
    required String email,
    required String username,
    required String password,
    required String role,
    String? companyName,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      final payload = <String, dynamic>{
        'email': email,
        'username': username,
        'password': password,
        'role': role,
      };
      if (role == 'company') {
        payload['company_name'] = companyName ?? '';
        payload['phone'] = phone ?? '';
      }

      await api.post(Endpoints.register, data: payload);
      // Registration requires verification before login.
      Get.offAllNamed(VerifyAccountPage.route, arguments: {'email': email});
      Fluttertoast.showToast(msg: 'OTP sent. Use code 123456 to verify.');
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp({required String email, required String purpose}) async {
    await api.post(Endpoints.otpSend, data: {
      'email': email,
      'purpose': purpose,
    });
  }

  Future<void> verifyOtp(
      {required String email,
      required String purpose,
      required String code}) async {
    final res = await api.post(Endpoints.otpVerify, data: {
      'email': email,
      'purpose': purpose,
      'code': code,
    });

    // For purpose=verify backend returns tokens like login, so we can go Home directly.
    if (purpose == 'verify' &&
        res is Map<String, dynamic> &&
        res['access_token'] != null) {
      await _applyTokens(res);
      Get.offAllNamed('/home');
    }
  }

  Future<void> resetPassword(
      {required String email,
      required String code,
      required String newPassword}) async {
    await api.post(Endpoints.passwordReset, data: {
      'email': email,
      'code': code,
      'new_password': newPassword,
    });
  }

  void goToResetPassword({String? email}) {
    Get.toNamed(ResetPasswordPage.route, arguments: {'email': email});
  }

  Future<void> logout() async {
    final refresh = storage.refreshToken;
    // best-effort revoke on backend
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await api.post(Endpoints.logout, data: {'refresh_token': refresh});
      } catch (_) {}
    }
    await storage.clearAuth();
    user.value = null;
    // Stop websocket and clear subscriptions after logout.
    try {
      await Get.find<CentrifugoHandler>().disconnect(clearSubscriptions: true);
    } catch (_) {}
    Get.offAllNamed('/login');
  }
}
