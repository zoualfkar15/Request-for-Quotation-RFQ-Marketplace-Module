import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/date_time_helper.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../controller/offers_controller.dart';
import '../../../subscriptions/controller/subscriptions_controller.dart';
import '../../../subscriptions/model/category.dart';

class CreateOfferPage extends StatefulWidget {
  const CreateOfferPage({super.key});

  static const String route = '/offers/create';

  @override
  State<CreateOfferPage> createState() => _CreateOfferPageState();
}

class _CreateOfferPageState extends State<CreateOfferPage> {
  int? _selectedCategoryId;
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _unit = TextEditingController(text: 'piece');
  final _price = TextEditingController(text: '100');
  final _minQuantity = TextEditingController();
  final _deliveryCity = TextEditingController();
  final _availableFrom = TextEditingController();
  final _availableUntil = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final subs = Get.find<SubscriptionsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    _unit.dispose();
    _price.dispose();
    _minQuantity.dispose();
    _deliveryCity.dispose();
    _availableFrom.dispose();
    _availableUntil.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OffersController>();
    final subs = Get.find<SubscriptionsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('New Offer')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader(
            title: 'Create an offer',
            subtitle:
                'Publish a company offer and notify subscribed users instantly.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GradientCard(
              gradient: AppGradients.primary,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.apartment_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Keep it clear: title, unit and price per unit are the key decision factors.',
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
                      controller: _unit,
                      labelText: 'Unit',
                      prefixIcon: const Icon(Icons.straighten_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Unit'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _minQuantity,
                      labelText: 'Min quantity (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon:
                          const Icon(Icons.production_quantity_limits_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _price,
                      labelText: 'Price per unit',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Price per unit'),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _deliveryCity,
                      labelText: 'Delivery city (optional)',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _availableFrom,
                      labelText:
                          'Available from (optional, YYYY-MM-DD HH:mm:ss)',
                      prefixIcon: const Icon(Icons.event_available_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _availableUntil,
                      labelText:
                          'Available until (optional, YYYY-MM-DD HH:mm:ss)',
                      prefixIcon: const Icon(Icons.event_busy_outlined),
                      validator: (_) => null,
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
                                final fromUtc =
                                    _availableFrom.text.trim().isEmpty
                                        ? null
                                        : DateTimeHelper.localToUtcString(
                                            _availableFrom.text.trim());
                                final untilUtc =
                                    _availableUntil.text.trim().isEmpty
                                        ? null
                                        : DateTimeHelper.localToUtcString(
                                            _availableUntil.text.trim());
                                if (_availableFrom.text.trim().isNotEmpty &&
                                    fromUtc == null) {
                                  Get.snackbar('Invalid date',
                                      'Available from must be in YYYY-MM-DD HH:mm:ss');
                                  return;
                                }
                                if (_availableUntil.text.trim().isNotEmpty &&
                                    untilUtc == null) {
                                  Get.snackbar('Invalid date',
                                      'Available until must be in YYYY-MM-DD HH:mm:ss');
                                  return;
                                }
                                final ok = await c.createOffer(
                                  categoryId: _selectedCategoryId ?? 0,
                                  title: _title.text.trim(),
                                  description: _description.text.trim(),
                                  unit: _unit.text.trim(),
                                  minQuantity: _minQuantity.text.trim().isEmpty
                                      ? null
                                      : num.tryParse(_minQuantity.text.trim()),
                                  pricePerUnit: num.tryParse(_price.text) ?? 0,
                                  deliveryCity: _deliveryCity.text.trim(),
                                  availableFromUtc: fromUtc,
                                  availableUntilUtc: untilUtc,
                                );
                                if (ok) Get.back();
                              },
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Publish offer'),
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
