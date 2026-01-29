import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/date_time_helper.dart';
import '../../../../core/format/status_labels.dart';
import '../../../../core/network/request/api_client.dart';
import '../../../../core/ui/empty_state.dart';

class QuotationDetailsPage extends StatefulWidget {
  const QuotationDetailsPage({super.key});

  static const String route = '/quotations/details';

  @override
  State<QuotationDetailsPage> createState() => _QuotationDetailsPageState();
}

class _QuotationDetailsPageState extends State<QuotationDetailsPage> {
  late final int _quotationId;
  late final Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _quotationId = (Get.arguments as int?) ?? 0;
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final api = Get.find<ApiClient>();
    final res = await api.get('api/quotations/$_quotationId');
    return (res as Map).cast<String, dynamic>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quotation #$_quotationId')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load details',
              subtitle: 'Please try again.',
            );
          }

          final data = snap.data ?? const <String, dynamic>{};
          final q = (data['quotation'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          final req = (data['request'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          final company = (data['company'] as Map?)?.cast<String, dynamic>();

          final status = (q['status'] ?? '').toString();
          final pricePerUnit = q['price_per_unit'];
          final total = q['total_price'];
          final deliveryDays = q['delivery_time_days'];
          final deliveryCost = q['delivery_cost'];
          final terms = (q['payment_terms'] ?? '').toString();
          final notes = (q['notes'] ?? '').toString();
          final validUntil = q['valid_until'] as String?;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Card(
                child: ListTile(
                  title: Text('Total: $total',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    'Status: ${quotationStatusLabel(status)}\nValid until: ${DateTimeHelper.formatLocalDateTimeFromUtc(validUntil)}',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Pricing & delivery',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    'Price/unit: $pricePerUnit\nDelivery: $deliveryDays days • Cost: $deliveryCost',
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Payment terms',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(terms),
                ),
              ),
              if (notes.trim().isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notes_outlined),
                    title: const Text('Notes',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(notes),
                  ),
                ),
              Card(
                child: ListTile(
                  title: Text('Request #${req['id']}',
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${req['title'] ?? ''}'),
                ),
              ),
              if (company != null)
                Card(
                  child: ListTile(
                    title: Text(
                      company['company_name']?.toString().isNotEmpty == true
                          ? company['company_name'].toString()
                          : 'Company',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      'Email: ${company['email'] ?? ''}\nPhone: ${company['phone'] ?? ''}',
                    ),
                    trailing: Chip(
                      label: Text(
                        '⭐ ${company['rating'] ?? 0}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                )
              else
                const EmptyState(
                  icon: Icons.lock_outline,
                  title: 'Company contact hidden',
                  subtitle: 'Company contact becomes available after acceptance.',
                ),
            ],
          );
        },
      ),
    );
  }
}


