import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/subscriptions_controller.dart';

class SubscriptionsTab extends StatefulWidget {
  const SubscriptionsTab({super.key});

  @override
  State<SubscriptionsTab> createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends State<SubscriptionsTab> {
  @override
  void initState() {
    super.initState();
    Get.find<SubscriptionsController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SubscriptionsController>();
    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
      return RefreshIndicator(
        onRefresh: () async => c.load(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: (c.categories.isEmpty ? 1 : c.categories.length) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SectionHeader(
                title: 'Choose categories',
                subtitle: 'You’ll get realtime banners when matching offers/requests are posted.',
              );
            }
            if (c.categories.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.bookmark_add_outlined,
                  title: 'No categories',
                  subtitle: 'Pull to refresh or ask admin to create categories.',
                ),
              );
            }
            final cat = c.categories[index - 1];
            return Card(
              child: Obx(() {
                final isSub = c.subscribedCategoryIds.contains(cat.id);
                return SwitchListTile(
                  title: Text(cat.name,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(cat.slug),
                  value: isSub,
                  onChanged: (_) => c.toggle(cat.id),
                );
              }),
            );
          },
        ),
      );
    });
  }
}


