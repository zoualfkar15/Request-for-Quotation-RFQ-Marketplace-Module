import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/offers_controller.dart';
import '../page/offer_details_page.dart';

class UserOffersTab extends StatefulWidget {
  const UserOffersTab({super.key});

  @override
  State<UserOffersTab> createState() => _UserOffersTabState();
}

class _UserOffersTabState extends State<UserOffersTab> {
  @override
  void initState() {
    super.initState();
    Get.find<OffersController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OffersController>();
    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
      return RefreshIndicator(
        onRefresh: () async => c.load(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: (c.offers.isEmpty ? 1 : c.offers.length) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  const SectionHeader(
                    title: 'Recommended offers',
                    subtitle: 'A feed of active offers. Subscribe to categories to receive realtime notifications.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GradientCard(
                      gradient: AppGradients.warm,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: const [
                          Icon(Icons.bolt, color: Colors.white, size: 36),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tip: Enable categories to get more offers and realtime alerts.',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            if (c.offers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: 'No offers yet',
                  subtitle: 'Subscribe to categories to receive offers in real time.',
                ),
              );
            }

            final o = c.offers[index - 1];
            final catLabel =
                (o.categoryName != null && o.categoryName!.trim().isNotEmpty)
                    ? o.categoryName!
                    : 'Category #${o.categoryId}';
            return Card(
              child: ListTile(
                title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${o.pricePerUnit} / ${o.unit} • $catLabel'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(OfferDetailsPage.route, arguments: o),
              ),
            );
          },
        ),
      );
    });
  }
}


