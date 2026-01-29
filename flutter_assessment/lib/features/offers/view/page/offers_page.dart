import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/status_labels.dart';
import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/offers_controller.dart';
import 'create_offer_page.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  static const String route = '/offers';

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  @override
  void initState() {
    super.initState();
    Get.find<OffersController>().load();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OffersController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(c.isCompany ? 'My Offers' : 'Available Offers'),
        actions: [IconButton(onPressed: c.load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: c.isCompany
          ? FloatingActionButton(
              onPressed: () => Get.toNamed(CreateOfferPage.route),
              child: const Icon(Icons.add),
            )
          : null,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

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
                    SectionHeader(
                      title: c.isCompany
                          ? 'Your offers'
                          : 'Offers in your categories',
                      subtitle: c.isCompany
                          ? 'Create offers to attract users.'
                          : 'Subscribe to categories to see more.',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GradientCard(
                        gradient: AppGradients.warm,
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: const [
                            Icon(Icons.local_offer_outlined,
                                color: Colors.white, size: 36),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Premium tip: Set a competitive price per unit and clear unit to rank better.',
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

              if (c.offers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.local_offer_outlined,
                    title: 'No offers',
                    subtitle: 'Pull to refresh.',
                    action: c.isCompany
                        ? FilledButton(
                            onPressed: () => Get.toNamed(CreateOfferPage.route),
                            child: const Text('Create offer'),
                          )
                        : null,
                  ),
                );
              }

              final offer = c.offers[index - 1];
              return Card(
                child: ListTile(
                  title: Text(offer.title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${offer.pricePerUnit} / ${offer.unit}'),
                  trailing: Chip(
                    label: Text(offerStatusLabel(offer.status),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
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


