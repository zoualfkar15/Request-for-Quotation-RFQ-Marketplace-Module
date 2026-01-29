import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/date_time_helper.dart';
import '../../../../core/format/status_labels.dart';
import '../../../../core/network/request/api_client.dart';
import '../../../../core/ui/empty_state.dart';
import '../../../quotations/view/page/quotation_details_page.dart';
import '../../../quotations/view/page/submit_quotation_page.dart';

class RequestDetailsPage extends StatefulWidget {
  const RequestDetailsPage({super.key});

  static const String route = '/requests/details';

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  late final int _requestId;
  late final int? _quotationId;
  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is Map) {
      _requestId = (arg['requestId'] as num?)?.toInt() ??
          int.tryParse(arg['requestId']?.toString() ?? '') ??
          0;
      _quotationId = (arg['quotationId'] as num?)?.toInt() ??
          int.tryParse(arg['quotationId']?.toString() ?? '');
    } else {
      _requestId = (arg as int?) ?? 0;
      _quotationId = null;
    }
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = Get.find<ApiClient>();
    final res = await api.get('api/requests/$_requestId');
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request #$_requestId')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load request',
              subtitle: 'Please try again.',
            );
          }

          final r = snap.data ?? const <String, dynamic>{};
          final status = (r['status'] ?? '').toString();
          final title = (r['title'] ?? '').toString();
          final description = (r['description'] ?? '').toString();
          final quantity = r['quantity'];
          final unit = (r['unit'] ?? '').toString();
          final city = (r['delivery_city'] ?? '').toString();
          final requiredDate = (r['required_delivery_date'] ?? '').toString();
          final expiresAt = (r['expires_at'] ?? '').toString();
          final deliveryLat = r['delivery_lat'];
          final deliveryLng = r['delivery_lng'];
          final budgetMin = r['budget_min'];
          final budgetMax = r['budget_max'];

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Card(
                child: ListTile(
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    '${quantity ?? ''} $unit • $city\nStatus: ${requestStatusLabel(status)}',
                  ),
                  trailing: Chip(
                    label: Text(
                      requestStatusLabel(status),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    description,
                    style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Required delivery date',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(DateTimeHelper.formatLocalDate(requiredDate)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Expires at',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle:
                      Text(DateTimeHelper.formatLocalDateTimeFromUtc(expiresAt)),
                ),
              ),
              if (budgetMin != null || budgetMax != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Budget',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(
                      '${budgetMin ?? '-'} → ${budgetMax ?? '-'}',
                    ),
                  ),
                ),
              if (deliveryLat != null || deliveryLng != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.my_location_outlined),
                    title: const Text('Delivery coordinates',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${deliveryLat ?? '-'}, ${deliveryLng ?? '-'}'),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _quotationId == null
                    ? FilledButton.icon(
                        onPressed: () => Get.toNamed(
                          SubmitQuotationPage.route,
                          arguments: {'requestId': _requestId},
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Submit quotation'),
                      )
                    : FilledButton.tonalIcon(
                        onPressed: () => Get.toNamed(
                          QuotationDetailsPage.route,
                          arguments: _quotationId,
                        ),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('View my quotation'),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


