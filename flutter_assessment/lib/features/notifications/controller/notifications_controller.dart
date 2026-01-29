import 'package:get/get.dart';

import '../../../core/constant/end_points.dart';
import '../../../core/network/request/api_client.dart';
import '../model/app_notification.dart';

class NotificationsController extends GetxController {
  NotificationsController({required this.api});

  final ApiClient api;

  final isLoading = false.obs;
  final items = <AppNotification>[].obs;

  Future<void> load() async {
    try {
      isLoading.value = true;
      final res = await api.get(Endpoints.notifications);
      if (res is List) {
        items.assignAll(res.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList());
      } else {
        items.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(int id) async {
    try {
      await api.post(Endpoints.notificationRead(id));
      await load();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      // Best-effort: mark unread items only, then reload once.
      final unread = items.where((n) => n.isRead != 1).toList(growable: false);
      if (unread.isEmpty) return;
      for (final n in unread) {
        try {
          await api.post(Endpoints.notificationRead(n.id));
        } catch (_) {}
      }
      await load();
    } catch (_) {}
  }
}


