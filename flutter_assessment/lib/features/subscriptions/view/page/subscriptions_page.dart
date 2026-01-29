import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/subscriptions_controller.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  static const String route = '/subscriptions';

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  @override
  void initState() {
    super.initState();
    // Load once (avoids reloading on every rebuild and keeps toggle instant).
    Get.find<SubscriptionsController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SubscriptionsController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: [
          IconButton(onPressed: c.load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async => c.load(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: (c.categories.isEmpty ? 1 : c.categories.length) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const SectionHeader(
                      title: 'Choose categories',
                      subtitle:
                          'You’ll get real-time banners when matching requests/offers are posted.',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientCard(
                        gradient: AppGradients.primary,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: const [
                            Icon(Icons.notifications_active_outlined,
                                color: Colors.white, size: 36),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Enable categories to receive instant in-app notifications.',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (c.categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.category_outlined,
                    title: 'No categories',
                    subtitle:
                        'Pull to refresh or ask admin to create categories.',
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
      }),
    );
  }
}
