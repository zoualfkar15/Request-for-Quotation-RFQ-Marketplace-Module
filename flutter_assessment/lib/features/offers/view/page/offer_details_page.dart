import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/request/api_client.dart';
import '../../../../core/format/status_labels.dart';
import '../../../../core/format/date_time_helper.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../model/offer.dart';

class OfferDetailsPage extends StatefulWidget {
  const OfferDetailsPage({super.key});

  static const String route = '/offers/details';

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  Offer? _offer;
  Map<String, dynamic>? _company;
  Map<String, dynamic>? _category;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is Offer) {
      _offer = arg;
    } else if (arg is int) {
      _fetch(arg);
    } else if (arg is Map && arg['id'] != null) {
      final id = int.tryParse(arg['id'].toString());
      if (id != null) _fetch(id);
    }
  }

  Future<void> _fetch(int id) async {
    setState(() => _loading = true);
    try {
      final api = Get.find<ApiClient>();
      final res = await api.get('api/offers/$id');
      if (res is Map<String, dynamic>) {
        // Supports both:
        // - old format: { offer fields... }
        // - new format: { offer: {...}, company: {...}, category: {...} }
        if (res['offer'] is Map<String, dynamic>) {
          final offerMap = res['offer'] as Map<String, dynamic>;
          setState(() {
            _offer = Offer.fromJson(offerMap);
            _company = res['company'] as Map<String, dynamic>?;
            _category = res['category'] as Map<String, dynamic>?;
          });
        } else {
          setState(() => _offer = Offer.fromJson(res));
        }
      }
    } catch (_) {
      // ignore (toast handled by ApiClient caller layers)
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = _offer;
    final company = _company;
    final category = _category;
    return Scaffold(
      appBar: AppBar(title: const Text('Offer details')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (o == null && !_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Offer not found'),
              ),
            )
          else if (o != null) ...[
            SectionHeader(
              title: o.title,
              subtitle: (category != null && category['name'] != null)
                  ? '${category['name']} • Offer #${o.id}'
                  : ((o.categoryName != null &&
                          o.categoryName!.trim().isNotEmpty)
                      ? '${o.categoryName} • Offer #${o.id}'
                      : 'Category #${o.categoryId} • Offer #${o.id}'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientCard(
                gradient: AppGradients.warm,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${o.pricePerUnit} / ${o.unit}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (company != null || category != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (company != null)
                        Chip(
                          avatar: const Icon(Icons.apartment_outlined, size: 18),
                          label: Text(
                            '${company['company_name'] ?? 'Company'} • ★ ${(company['rating'] ?? 0).toString()}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      if (category != null)
                        Chip(
                          avatar: const Icon(Icons.category_outlined, size: 18),
                          label: Text(
                            '${category['name'] ?? 'Category'}${category['slug'] != null ? ' • ${category['slug']}' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      Chip(
                        avatar: const Icon(Icons.verified_outlined, size: 18),
                        label: Text(
                          offerStatusLabel(o.status),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Category',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  (category != null && category['name'] != null)
                      ? '${category['name']}${category['slug'] != null ? ' • ${category['slug']}' : ''}'
                      : ((o.categoryName != null &&
                              o.categoryName!.trim().isNotEmpty)
                          ? '${o.categoryName}${(o.categorySlug != null && o.categorySlug!.trim().isNotEmpty) ? ' • ${o.categorySlug}' : ''}'
                          : 'Category #${o.categoryId}'),
                ),
              ),
            ),
            if (o.minQuantity != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.production_quantity_limits_outlined),
                  title: const Text('Min quantity',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${o.minQuantity}'),
                ),
              ),
            if (o.deliveryCity != null && o.deliveryCity!.trim().isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text('Delivery city',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(o.deliveryCity!),
                ),
              ),
            if (o.availableFrom != null || o.availableUntil != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('Availability window',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(
                    '${DateTimeHelper.formatLocalDateTimeFromUtc(o.availableFrom)}'
                    '${o.availableUntil != null ? ' → ${DateTimeHelper.formatLocalDateTimeFromUtc(o.availableUntil)}' : ''}',
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  o.description,
                  style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


