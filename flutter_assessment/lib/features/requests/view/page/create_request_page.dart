import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/date_time_helper.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../../subscriptions/controller/subscriptions_controller.dart';
import '../../../subscriptions/model/category.dart';
import '../../controller/requests_controller.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  static const String route = '/requests/create';

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  int? _selectedCategoryId;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _unit = TextEditingController(text: 'piece');
  final _city = TextEditingController(text: 'Riyadh');
  final _deliveryLat = TextEditingController();
  final _deliveryLng = TextEditingController();
  final _budgetMin = TextEditingController();
  final _budgetMax = TextEditingController();
  final _requiredDate = TextEditingController(text: '2026-01-31');
  final _expiresAt = TextEditingController(text: '2026-02-02 12:00:00');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final subs = Get.find<SubscriptionsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load categories so we can show them in the dropdown.
      await subs.load();
      if (!mounted) return;
      if (_selectedCategoryId == null && subs.categories.isNotEmpty) {
        setState(() => _selectedCategoryId = subs.categories.first.id);
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _quantity.dispose();
    _unit.dispose();
    _city.dispose();
    _deliveryLat.dispose();
    _deliveryLng.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    _requiredDate.dispose();
    _expiresAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RequestsController>();
    final subs = Get.find<SubscriptionsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('New Request')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader(
            title: 'Create a request',
            subtitle: 'Post what you need and receive quotations in real time.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GradientCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.campaign_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Add clear quantity, unit and delivery city to get better offers.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Obx(() {
                      final cats = subs.categories;
                      final isCatsLoading =
                          subs.isLoading.value && cats.isEmpty;

                      return DropdownButtonFormField<int>(
                        value: cats.any((c) => c.id == _selectedCategoryId)
                            ? _selectedCategoryId
                            : (cats.isNotEmpty ? cats.first.id : null),
                        items: cats
                            .map((Category c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                ))
                            .toList(),
                        onChanged: isCatsLoading
                            ? null
                            : (v) => setState(() => _selectedCategoryId = v),
                        validator: (v) =>
                            v == null ? 'Please select a category' : null,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category_outlined),
                          helperText:
                              isCatsLoading ? 'Loading categories...' : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _title,
                      labelText: 'Title',
                      prefixIcon: const Icon(Icons.title_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Title'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _description,
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.notes_outlined),
                      maxLines: 3,
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Description'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _quantity,
                      labelText: 'Quantity',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Quantity'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _unit,
                      labelText: 'Unit (kg/ton/piece/...)',
                      prefixIcon: const Icon(Icons.straighten_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Unit'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _city,
                      labelText: 'Delivery city',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Delivery city'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _deliveryLat,
                      labelText: 'Delivery latitude (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.my_location_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _deliveryLng,
                      labelText: 'Delivery longitude (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.my_location_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _requiredDate,
                      labelText: 'Required delivery date (YYYY-MM-DD)',
                      prefixIcon: const Icon(Icons.event_outlined),
                      validator: (v) => Validation.required(v,
                          fieldName: 'Required delivery date'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _budgetMin,
                      labelText: 'Budget min (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _budgetMax,
                      labelText: 'Budget max (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _expiresAt,
                      labelText: 'Expires at (YYYY-MM-DD HH:mm:ss)',
                      prefixIcon: const Icon(Icons.timer_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Expires at'),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      return FilledButton(
                        onPressed: c.isLoading.value
                            ? null
                            : () async {
                                if (!(_formKey.currentState?.validate() ??
                                    false)) return;
                                final expiresUtc =
                                    DateTimeHelper.localToUtcString(
                                        _expiresAt.text.trim());
                                if (expiresUtc == null) {
                                  Get.snackbar('Invalid date',
                                      'Expires at must be in YYYY-MM-DD HH:mm:ss');
                                  return;
                                }
                                final ok = await c.createRequest(
                                  categoryId: _selectedCategoryId ?? 0,
                                  title: _title.text.trim(),
                                  description: _description.text.trim(),
                                  quantity: num.tryParse(_quantity.text) ?? 0,
                                  unit: _unit.text.trim(),
                                  deliveryCity: _city.text.trim(),
                                  deliveryLat: _deliveryLat.text.trim().isEmpty
                                      ? null
                                      : num.tryParse(_deliveryLat.text.trim()),
                                  deliveryLng: _deliveryLng.text.trim().isEmpty
                                      ? null
                                      : num.tryParse(_deliveryLng.text.trim()),
                                  requiredDeliveryDate:
                                      _requiredDate.text.trim(),
                                  budgetMin: _budgetMin.text.trim().isEmpty
                                      ? null
                                      : num.tryParse(_budgetMin.text.trim()),
                                  budgetMax: _budgetMax.text.trim().isEmpty
                                      ? null
                                      : num.tryParse(_budgetMax.text.trim()),
                                  expiresAt: expiresUtc,
                                );
                                if (ok) Get.back();
                              },
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Publish request'),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
