import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/status_labels.dart';
import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/requests_controller.dart';
import '../../../quotations/view/page/quotation_details_page.dart';

class RequestsHistoryPage extends StatelessWidget {
  const RequestsHistoryPage({super.key});

  static const String route = '/requests/history';

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RequestsController>();

    // fire and forget
    c.loadHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            onPressed: () => c.loadHistory(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isHistoryLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.history.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No history yet',
            subtitle: 'Finished requests will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: c.history.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SectionHeader(
                title: 'Requests history',
                subtitle: 'Accepted/rejected/closed requests are stored here.',
              );
            }
            final item = c.history[index - 1];
            final r = item.request;
            final q = item.quotation;
            return Card(
              child: ListTile(
                title: Text(
                  r.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  q == null
                      ? '${r.quantity} ${r.unit} • ${r.deliveryCity}'
                      : '${r.quantity} ${r.unit} • ${r.deliveryCity}\nYour quotation total: ${q.totalPrice}',
                ),
                trailing: Chip(
                  label: Text(
                    q == null
                        ? requestStatusLabel(r.status)
                        : quotationStatusLabel(q.status),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                onTap: () {
                  if (r.awardedQuotationId != null) {
                    Get.toNamed(QuotationDetailsPage.route,
                        arguments: r.awardedQuotationId);
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }
}


