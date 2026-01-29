import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/ui/empty_state.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../controller/requests_controller.dart';
import '../../../quotations/controller/quotations_controller.dart';
import '../../../../core/format/status_labels.dart';
import '../page/request_details_page.dart';

class CompanyRequestsTab extends StatefulWidget {
  const CompanyRequestsTab({super.key});

  @override
  State<CompanyRequestsTab> createState() => _CompanyRequestsTabState();
}

class _CompanyRequestsTabState extends State<CompanyRequestsTab> {
  bool _showQuoted = false;

  @override
  void initState() {
    super.initState();
    Get.find<RequestsController>().loadAvailable();
    // Needed to know which requests already have a quotation by this company.
  //  Get.find<QuotationsController>().loadMy();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RequestsController>();
    final qc = Get.find<QuotationsController>();
    return Obx(() {
      if (c.isLoading.value || qc.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Build a map: requestId -> quotation (any status). Backend prevents duplicates anyway.
      final byRequestId = <int, dynamic>{};
      for (final q in qc.quotations) {
        byRequestId[q.requestId] = q;
      }

      final newRequests = c.requests
          .where((r) => !byRequestId.containsKey(r.id))
          .toList(growable: false);
      final quotedRequests = c.requests
          .where((r) => byRequestId.containsKey(r.id))
          .toList(growable: false);

      final list = _showQuoted ? quotedRequests : newRequests;

      if (c.requests.isEmpty) {
        return const EmptyState(
          icon: Icons.list_alt_outlined,
          title: 'No requests found',
          subtitle: 'Subscribe to categories to see matching RFQs.',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([c.loadAvailable(), qc.loadMy()]);
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: (list.isEmpty ? 1 : list.length) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  SectionHeader(
                    title: _showQuoted ? 'Quoted requests' : 'New requests',
                    subtitle: _showQuoted
                        ? 'You already submitted a quotation. Tap to view details.'
                        : 'Tap a request to submit a quotation.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('New'),
                          icon: Icon(Icons.fiber_new_rounded),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Quoted'),
                          icon: Icon(Icons.assignment_turned_in_outlined),
                        ),
                      ],
                      selected: <bool>{_showQuoted},
                      onSelectionChanged: (s) =>
                          setState(() => _showQuoted = s.first),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GradientCard(
                      gradient: AppGradients.primary,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: const [
                          Icon(Icons.bolt, color: Colors.white, size: 36),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Fast response wins. Send a quotation early to rank higher.',
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

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: EmptyState(
                  icon: _showQuoted
                      ? Icons.assignment_turned_in_outlined
                      : Icons.fiber_new_rounded,
                  title: _showQuoted ? 'No quoted requests' : 'No new requests',
                  subtitle: _showQuoted
                      ? 'Requests you quoted will appear here.'
                      : 'You already quoted all currently available requests.',
                ),
              );
            }

            final r = list[index - 1];
            final q = byRequestId[r.id];
            return Card(
              child: ListTile(
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${r.quantity} ${r.unit} • ${r.deliveryCity}'),
                trailing: q == null
                    ? const Icon(Icons.chevron_right)
                    : Chip(
                        label: Text(
                          quotationStatusLabel(q.status),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                onTap: () => Get.toNamed(
                  RequestDetailsPage.route,
                  arguments: {
                    'requestId': r.id,
                    if (q != null) 'quotationId': q.id,
                  },
                ),
              ),
            );
          },
        ),
      );
    });
  }
}


