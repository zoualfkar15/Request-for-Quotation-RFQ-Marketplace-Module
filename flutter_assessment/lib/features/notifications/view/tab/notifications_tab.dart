import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/notifications_controller.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  @override
  void initState() {
    super.initState();
    Get.find<NotificationsController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationsController>();
    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (c.items.isEmpty) {
        return const EmptyState(
          icon: Icons.notifications_none,
          title: 'No notifications',
          subtitle: 'Realtime events will appear here as they happen.',
        );
      }
      return RefreshIndicator(
        onRefresh: () async => c.load(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: c.items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SectionHeader(
                title: 'Your notifications',
                subtitle: 'Realtime events are stored here so you can review them later.',
              );
            }
            final n = c.items[index - 1];
            return Card(
              child: ListTile(
                title: Text(n.type, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(n.payloadJson, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: n.isRead == 1
                    ? const Icon(Icons.done_rounded)
                    : FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () => c.markRead(n.id),
                        child: const Text('Mark read'),
                      ),
              ),
            );
          },
        ),
      );
    });
  }
}


