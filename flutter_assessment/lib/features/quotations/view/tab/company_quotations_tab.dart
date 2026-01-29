import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/format/status_labels.dart';
import '../../controller/quotations_controller.dart';

class CompanyQuotationsTab extends StatefulWidget {
  const CompanyQuotationsTab({super.key});

  @override
  State<CompanyQuotationsTab> createState() => _CompanyQuotationsTabState();
}

class _CompanyQuotationsTabState extends State<CompanyQuotationsTab> {
  bool _history = false;

  @override
  void initState() {
    super.initState();
    Get.find<QuotationsController>().loadMy();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuotationsController>();
    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
      final all = c.quotations;
      final list = _history
          ? all.where((q) => q.status != 'created').toList(growable: false)
          : all.where((q) => q.status == 'created').toList(growable: false);

      return RefreshIndicator(
        onRefresh: () async => c.loadMy(),
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
                    title: 'Your quotations',
                    subtitle: 'Track your submitted quotations and their status.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Active'),
                          icon: Icon(Icons.pending_actions_rounded),
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
                ],
              );
            }

            if (index == 1) return const SizedBox.shrink();

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.price_change_outlined,
                  title:
                      _history ? 'No history yet' : 'No active quotations yet',
                  subtitle: _history
                      ? 'Accepted, rejected, and cancelled quotations appear here.'
                      : 'Open a request from Home and submit your first quotation.',
                ),
              );
            }

            final q = list[index - 2];
            final isCreated = q.status == 'created';
            return Card(
              child: ListTile(
                title: Text(
                  'Request #${q.requestId} • Total ${q.totalPrice}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  'Delivery ${q.deliveryTimeDays} days • Cost ${q.deliveryCost}\nTerms: ${q.paymentTerms}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                        label: Text(quotationStatusLabel(q.status),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800))),
                    if (isCreated) ...[
                      const SizedBox(width: 6),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'cancel') c.cancelByCompany(q.id);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'cancel', child: Text('Cancel quotation')),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}


