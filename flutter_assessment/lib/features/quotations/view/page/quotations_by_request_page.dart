import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/section_header.dart';
import '../../controller/quotations_controller.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../../core/format/status_labels.dart';

class QuotationsByRequestPage extends StatelessWidget {
  const QuotationsByRequestPage({super.key});

  static const String route = '/quotations/by-request';

  @override
  Widget build(BuildContext context) {
    final requestId = (Get.arguments as int?) ?? 0;
    final c = Get.find<QuotationsController>();
    final auth = Get.find<AuthController>();

    if (requestId > 0) {
      // fire and forget
      c.loadByRequest(requestId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quotations (Request #$requestId)'),
        actions: [
          IconButton(
              onPressed: () => c.loadByRequest(requestId),
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.quotations.isEmpty) {
          return const Center(child: Text('No quotations'));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: c.quotations.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const SectionHeader(
                title: 'Compare offers',
                subtitle:
                    'Sorted by best offer on the backend (price + delivery + rating).',
              );
            }
            final q = c.quotations[index - 1];
            return Card(
              child: ListTile(
                title: Text('Total: ${q.totalPrice}',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  'Delivery: ${q.deliveryTimeDays} days • Cost: ${q.deliveryCost}\nTerms: ${q.paymentTerms}',
                ),
                trailing: (auth.storage.userRole ?? '') == 'user'
                    ? Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () => c.accept(q.id),
                            child: const Text('Accept'),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () => c.reject(q.id),
                            child: const Text('Reject'),
                          ),
                        ],
                      )
                    : Chip(
                        label: Text(quotationStatusLabel(q.status),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ),
              ),
            );
          },
        );
      }),
    );
  }
}
