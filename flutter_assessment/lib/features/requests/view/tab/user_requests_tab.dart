import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/format/status_labels.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/requests_controller.dart';
import '../page/create_request_page.dart';
import '../../../quotations/view/page/quotations_by_request_page.dart';
import '../page/requests_history_page.dart';

class UserRequestsTab extends StatefulWidget {
  const UserRequestsTab({super.key});

  @override
  State<UserRequestsTab> createState() => _UserRequestsTabState();
}

class _UserRequestsTabState extends State<UserRequestsTab> {
  @override
  void initState() {
    super.initState();
    Get.find<RequestsController>().loadMy();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RequestsController>();
    return Obx(() {
      if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
      return RefreshIndicator(
        onRefresh: () async => c.loadMy(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: (c.requests.isEmpty ? 1 : c.requests.length) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Your requests',
                    subtitle: 'Tap a request to review quotations.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => Get.toNamed(RequestsHistoryPage.route),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('History'),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (c.requests.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'No requests yet',
                  subtitle:
                      'Create a request and companies will send quotations.',
                  action: FilledButton(
                    onPressed: () => Get.toNamed(CreateRequestPage.route),
                    child: const Text('Create request'),
                  ),
                ),
              );
            }
            final r = c.requests[index - 1];
            return Card(
              child: ListTile(
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${r.quantity} ${r.unit} • ${r.deliveryCity}'),
                trailing: Chip(
                    label: Text(requestStatusLabel(r.status),
                        style: const TextStyle(fontWeight: FontWeight.w800))),
                onTap: () => Get.toNamed(QuotationsByRequestPage.route, arguments: r.id),
              ),
            );
          },
        ),
      );
    });
  }
}


