import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../core/constant/end_points.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/network/request/api_client.dart';
import '../../auth/controller/auth_controller.dart';
import '../model/offer.dart';

class OffersController extends GetxController {
  OffersController({required this.api});

  final ApiClient api;

  final isLoading = false.obs;
  final offers = <Offer>[].obs;

  bool get isCompany => (Get.find<AuthController>().storage.userRole ?? '') == 'company';

  Future<void> load() async {
    try {
      isLoading.value = true;
      final endpoint = isCompany ? Endpoints.myOffers : Endpoints.availableOffers;
      final res = await api.get(endpoint);
      if (res is List) {
        offers.assignAll(res.map((e) => Offer.fromJson(e as Map<String, dynamic>)).toList());
      } else {
        offers.clear();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async => load();

  Future<void> deactivateOffer(int offerId) async {
    try {
      await api.post('${Endpoints.offers}/$offerId/deactivate');
      Fluttertoast.showToast(msg: 'Offer deactivated');
      await load();
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    }
  }

  Future<bool> createOffer({
    required int categoryId,
    required String title,
    required String description,
    required String unit,
    required num pricePerUnit,
    num? minQuantity,
    String? deliveryCity,
    String? availableFromUtc,
    String? availableUntilUtc,
  }) async {
    try {
      isLoading.value = true;
      await api.post(Endpoints.offers, data: {
        'category_id': categoryId,
        'title': title,
        'description': description,
        'unit': unit,
        if (minQuantity != null) 'min_quantity': minQuantity,
        'price_per_unit': pricePerUnit,
        if (deliveryCity != null && deliveryCity.trim().isNotEmpty)
          'delivery_city': deliveryCity.trim(),
        if (availableFromUtc != null) 'available_from': availableFromUtc,
        if (availableUntilUtc != null) 'available_until': availableUntilUtc,
      });
      await load();
      Fluttertoast.showToast(msg: 'Offer created');
      return true;
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}


