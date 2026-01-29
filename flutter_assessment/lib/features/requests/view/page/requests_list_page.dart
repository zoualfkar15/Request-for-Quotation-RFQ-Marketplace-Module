import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/status_labels.dart';
import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/requests_controller.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../quotations/view/page/quotations_by_request_page.dart';
import 'create_request_page.dart';

class RequestsListPage extends StatelessWidget {
  const RequestsListPage({super.key});

  static const String route = '/requests';

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RequestsController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(c.isCompany ? 'Available Requests' : 'My Requests'),
        actions: [
          IconButton(onPressed: c.load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: c.isCompany
          ? null
          : FloatingActionButton(
              onPressed: () => Get.toNamed(CreateRequestPage.route),
              child: const Icon(Icons.add),
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
            itemCount: (c.requests.isEmpty ? 1 : c.requests.length) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SectionHeader(
                  title: c.isCompany
                      ? 'Requests matching your categories'
                      : 'Your posted requests',
                  subtitle: c.isCompany
                      ? 'Tap a request to quote it.'
                      : 'Tap a request to view quotations.',
                );
              }

              if (c.requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.list_alt_outlined,
                    title: 'No requests yet',
                    subtitle: 'Pull to refresh.',
                  ),
                );
              }

              final r = c.requests[index - 1];
              return Card(
                child: ListTile(
                  title: Text(r.title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${r.quantity} ${r.unit} • ${r.deliveryCity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(requestStatusLabel(r.status),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      if ((auth.storage.userRole ?? '') == 'user')
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'cancel') c.cancel(r.id);
                            if (v == 'close') c.close(r.id);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'close', child: Text('Close')),
                            PopupMenuItem(
                                value: 'cancel', child: Text('Cancel')),
                          ],
                        )
                      else
                        const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    if ((auth.storage.userRole ?? '') == 'user') {
                      Get.toNamed(QuotationsByRequestPage.route,
                          arguments: r.id);
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}


