import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/notifications_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const String route = '/notifications';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Get.find<NotificationsController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationsController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: c.load,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());

        return RefreshIndicator(
          onRefresh: () async => c.load(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: (c.items.isEmpty ? 1 : c.items.length) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionHeader(
                  title: 'Your notifications',
                  subtitle:
                      'Real-time events are stored here so you can review them later.',
                );
              }

              if (c.items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications',
                    subtitle: 'Pull to refresh.',
                  ),
                );
              }

              final n = c.items[index - 1];
              return Card(
                child: ListTile(
                  title: Text(n.type,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(n.payloadJson,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
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
      }),
    );
  }
}


