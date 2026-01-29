import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../core/constant/end_points.dart';
import '../../../core/error/api_exception.dart';
import '../../../core/network/request/api_client.dart';
import '../../../core/service/socket/centrifugo_handler.dart';
import '../model/category.dart';

class SubscriptionsController extends GetxController {
  SubscriptionsController({required this.api});

  final ApiClient api;

  final isLoading = false.obs;
  final categories = <Category>[].obs;
  final subscribedCategoryIds = <int>{}.obs;

  Future<void> load() async {
    try {
      isLoading.value = true;
      final cats = await api.get(Endpoints.categories);
      if (cats is List) {
        categories.assignAll(cats
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList());
      } else {
        categories.clear();
      }

      final subs = await api.get(Endpoints.subscriptions);
      if (subs is List) {
        final set = subs
            .map((e) => (e as Map<String, dynamic>)['category_id'])
            .whereType<num>()
            .map((n) => n.toInt())
            .toSet();
        subscribedCategoryIds
          ..clear()
          ..addAll(set);
      } else {
        subscribedCategoryIds.clear();
      }
    } on ApiException catch (e) {
      Fluttertoast.showToast(msg: e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggle(int categoryId) async {
    final wasSubscribed = subscribedCategoryIds.contains(categoryId);

    // Optimistic UI update (instant toggle).
    if (wasSubscribed) {
      subscribedCategoryIds.remove(categoryId);
    } else {
      subscribedCategoryIds.add(categoryId);
    }
    subscribedCategoryIds.refresh();

    try {
      final res = await api.post(Endpoints.subscriptionsToggle,
          data: {'category_id': categoryId});
      if (res is Map<String, dynamic>) {
        final subscribed = res['subscribed'] == true;
        if (subscribed) {
          subscribedCategoryIds.add(categoryId);
          subscribedCategoryIds.refresh();
          await Get.find<CentrifugoHandler>().subscribe('category.$categoryId');
        } else {
          subscribedCategoryIds.remove(categoryId);
          subscribedCategoryIds.refresh();
          await Get.find<CentrifugoHandler>()
              .unsubscribe('category.$categoryId');
        }
      }
    } on ApiException catch (e) {
      // Revert optimistic update on error.
      if (wasSubscribed) {
        subscribedCategoryIds.add(categoryId);
      } else {
        subscribedCategoryIds.remove(categoryId);
      }
      subscribedCategoryIds.refresh();
      Fluttertoast.showToast(msg: e.message);
    } catch (_) {
      // Revert optimistic update on unknown error.
      if (wasSubscribed) {
        subscribedCategoryIds.add(categoryId);
      } else {
        subscribedCategoryIds.remove(categoryId);
      }
      subscribedCategoryIds.refresh();
    }
  }
}
