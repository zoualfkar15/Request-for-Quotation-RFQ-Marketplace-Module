import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/status_labels.dart';
import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/offers_controller.dart';
import '../page/create_offer_page.dart';
import '../page/offer_details_page.dart';

class CompanyOffersTab extends StatefulWidget {
  const CompanyOffersTab({super.key});

  @override
  State<CompanyOffersTab> createState() => _CompanyOffersTabState();
}

class _CompanyOffersTabState extends State<CompanyOffersTab> {
  bool _history = false;

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
      final all = c.offers;
      final list = _history
          ? all.where((o) => o.status != 'active').toList(growable: false)
          : all.where((o) => o.status == 'active').toList(growable: false);

      return RefreshIndicator(
        onRefresh: () async => c.load(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: (list.isEmpty ? 1 : list.length) + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Your offers',
                    subtitle:
                        'Active offers are visible to users. History contains deactivated offers.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Active'),
                          icon: Icon(Icons.check_circle_outline_rounded),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('History'),
                          icon: Icon(Icons.history_rounded),
                        ),
                      ],
                      selected: <bool>{_history},
                      onSelectionChanged: (s) =>
                          setState(() => _history = s.first),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }

            if (index == 1) return const SizedBox.shrink();

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: _history ? 'No offers in history' : 'No active offers',
                  subtitle: _history
                      ? 'Deactivated offers will appear here.'
                      : 'Create an offer to attract users and get realtime engagement.',
                  action: !_history
                      ? FilledButton(
                          onPressed: () => Get.toNamed(CreateOfferPage.route),
                          child: const Text('Create offer'),
                        )
                      : null,
                ),
              );
            }

            final o = list[index - 2];
            final catLabel =
                (o.categoryName != null && o.categoryName!.trim().isNotEmpty)
                    ? o.categoryName!
                    : 'Category #${o.categoryId}';
            final isActive = o.status == 'active';
            return Card(
              child: ListTile(
                title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${o.pricePerUnit} / ${o.unit} • $catLabel'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                        label: Text(offerStatusLabel(o.status),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800))),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'deactivate') c.deactivateOffer(o.id);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'deactivate', child: Text('Deactivate')),
                        ],
                      ),
                    ],
                  ],
                ),
                onTap: () => Get.toNamed(OfferDetailsPage.route, arguments: o),
              ),
            );
          },
        ),
      );
    });
  }
}


