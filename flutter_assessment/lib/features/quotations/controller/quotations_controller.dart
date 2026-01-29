import 'package:flutter_assessment/features/offers/controller/offers_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../core/constant/end_points.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/network/request/api_client.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/rfq_quotation.dart';

class QuotationsController extends GetxController {
  QuotationsController({required this.api});

  final ApiClient api;

  final isLoading = false.obs;
  final quotations = <RfqQuotation>[].obs;

  bool get isCompany =>
      (Get.find<AuthController>().storage.userRole ?? '') == 'company';

  Future<void> loadMy() async {
    try {
      isLoading.value = true;
      final res = await api.get(Endpoints.quotations);
      if (res is List) {
        quotations.assignAll(res
            .map((e) => RfqQuotation.fromJson(e as Map<String, dynamic>))
            .toList());
      } else {
        quotations.clear();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadByRequest(int requestId) async {
    try {
      isLoading.value = true;
      final res = await api.get(Endpoints.quotationsByRequest(requestId));
      if (res is Map<String, dynamic> && res['quotations'] is List) {
        final list = res['quotations'] as List;
        quotations.assignAll(
          list
              .map((e) => RfqQuotation.fromJson(
                  (e as Map<String, dynamic>)['quotation']
                      as Map<String, dynamic>))
              .toList(),
        );
      } else {
        quotations.clear();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitQuotation({
    required int requestId,
    required num pricePerUnit,
    required int deliveryTimeDays,
    required num deliveryCost,
    required String paymentTerms,
    required String validUntil,
    num? totalPrice,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      await api.post(Endpoints.quotations, data: {
        'request_id': requestId,
        'price_per_unit': pricePerUnit,
        'delivery_time_days': deliveryTimeDays,
        'delivery_cost': deliveryCost,
        if (totalPrice != null) 'total_price': totalPrice,
        'payment_terms': paymentTerms,
        'valid_until': validUntil,
        if (notes != null) 'notes': notes,
      });
      Fluttertoast.showToast(msg: 'Quotation submitted');
      await loadMy();
      return true;
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> accept(int quotationId) async {
    await _decide(quotationId, true);
  }

  Future<void> reject(int quotationId) async {
    await _decide(quotationId, false);
  }

  Future<void> cancelByCompany(int quotationId) async {
    try {
      // Backend route name is /withdraw but it maps to cancelled_by_company.
      await api.post('${Endpoints.quotations}/$quotationId/withdraw');
      Fluttertoast.showToast(msg: 'Quotation cancelled');
      await loadMy();
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    }
  }

  Future<void> _decide(int quotationId, bool accept) async {
    try {
      await api.post(
          '${Endpoints.quotations}/$quotationId/${accept ? 'accept' : 'reject'}');
      Fluttertoast.showToast(msg: accept ? 'Accepted' : 'Rejected');
      Get.back();
      Get.find<OffersController>().refresh();
    } catch (_) {}
  }
}
