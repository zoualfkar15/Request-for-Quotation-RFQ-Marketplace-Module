import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../core/constant/end_points.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/network/request/api_client.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/rfq_request.dart';
import '../model/rfq_request_history_item.dart';
import '../../quotations/model/rfq_quotation.dart';

class RequestsController extends GetxController {
  RequestsController({required this.api});

  final ApiClient api;

  final isLoading = false.obs;
  final requests = <RfqRequest>[].obs;

  final isHistoryLoading = false.obs;
  final history = <RfqRequestHistoryItem>[].obs;

  bool get isCompany =>
      (Get.find<AuthController>().storage.userRole ?? '') == 'company';

  Future<void> load() async {
    return isCompany ? loadAvailable() : loadMy();
  }

  Future<void> loadMy() async {
    await _loadList(Endpoints.myRequests);
  }

  Future<void> loadAvailable() async {
    await _loadList(Endpoints.availableRequests);
  }

  Future<void> loadHistory() async {
    try {
      isHistoryLoading.value = true;
      final res = await api.get(Endpoints.requestsHistory);
      if (res is List) {
        final items = <RfqRequestHistoryItem>[];
        for (final e in res) {
          if (e is Map<String, dynamic> &&
              e['request'] is Map<String, dynamic>) {
            // company shape: { request: {...}, quotation: {...} }
            final req =
                RfqRequest.fromJson(e['request'] as Map<String, dynamic>);
            final qJson = e['quotation'];
            final quotation = qJson is Map<String, dynamic>
                ? RfqQuotation.fromJson(qJson)
                : null;
            items
                .add(RfqRequestHistoryItem(request: req, quotation: quotation));
          } else if (e is Map<String, dynamic>) {
            // user shape: request object
            final req = RfqRequest.fromJson(e);
            items.add(RfqRequestHistoryItem(request: req));
          }
        }
        history.assignAll(items);
      } else {
        history.clear();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<bool> createRequest({
    required int categoryId,
    required String title,
    required String description,
    required num quantity,
    required String unit,
    required String deliveryCity,
    required String requiredDeliveryDate,
    required String expiresAt,
    num? deliveryLat,
    num? deliveryLng,
    num? budgetMin,
    num? budgetMax,
  }) async {
    try {
      isLoading.value = true;
      await api.post(Endpoints.requests, data: {
        'category_id': categoryId,
        'title': title,
        'description': description,
        'quantity': quantity,
        'unit': unit,
        'delivery_city': deliveryCity,
        if (deliveryLat != null) 'delivery_lat': deliveryLat,
        if (deliveryLng != null) 'delivery_lng': deliveryLng,
        'required_delivery_date': requiredDeliveryDate, // YYYY-MM-DD
        'expires_at': expiresAt, // YYYY-MM-DD HH:mm:ss
        if (budgetMin != null) 'budget_min': budgetMin,
        if (budgetMax != null) 'budget_max': budgetMax,
      });
      await loadMy();
      Fluttertoast.showToast(msg: 'Request created');
      return true;
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancel(int id) async {
    try {
      await api.post('${Endpoints.requests}/$id/cancel');
      await load();
    } catch (_) {}
  }

  Future<void> close(int id) async {
    try {
      await api.post('${Endpoints.requests}/$id/close');
      await load();
    } catch (_) {}
  }

  Future<void> _loadList(String endpoint) async {
    try {
      isLoading.value = true;
      final res = await api.get(endpoint);
      if (res is List) {
        requests.assignAll(res
            .map((e) => RfqRequest.fromJson(e as Map<String, dynamic>))
            .toList());
      } else {
        requests.clear();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isLoading.value = false;
    }
  }
}
