import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/format/date_time_helper.dart';
import '../../../../core/ui/gradient.dart';
import '../../../../core/ui/section_header.dart';
import '../../../../core/ui/text_field_widget.dart';
import '../../../../core/validation/validation.dart';
import '../../controller/quotations_controller.dart';

class SubmitQuotationPage extends StatefulWidget {
  const SubmitQuotationPage({super.key});

  static const String route = '/quotations/submit';

  @override
  State<SubmitQuotationPage> createState() => _SubmitQuotationPageState();
}

class _SubmitQuotationPageState extends State<SubmitQuotationPage> {
  final _requestId = TextEditingController(text: '1');
  final _pricePerUnit = TextEditingController(text: '100');
  final _totalPrice = TextEditingController();
  final _deliveryDays = TextEditingController(text: '3');
  final _deliveryCost = TextEditingController(text: '0');
  final _terms = TextEditingController(text: 'Cash');
  final _validUntil = TextEditingController(text: '2026-02-10 12:00:00');
  final _notes = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _lockRequestId = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['requestId'] != null) {
      final id = args['requestId'];
      final parsed = int.tryParse(id.toString());
      if (parsed != null && parsed > 0) {
        _requestId.text = parsed.toString();
        _lockRequestId = true;
      }
    } else if (args is int && args > 0) {
      _requestId.text = args.toString();
      _lockRequestId = true;
    }
  }

  @override
  void dispose() {
    _requestId.dispose();
    _pricePerUnit.dispose();
    _totalPrice.dispose();
    _deliveryDays.dispose();
    _deliveryCost.dispose();
    _terms.dispose();
    _validUntil.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuotationsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Quotation')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SectionHeader(
            title: 'Create a quotation',
            subtitle: 'Send your best offer—users will compare and decide.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GradientCard(
              gradient: AppGradients.primary,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.price_change_outlined,
                      color: Colors.white, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lower total price and faster delivery usually rank higher.',
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
                    TextFieldWidget(
                      controller: _requestId,
                      labelText: 'Request ID',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.numbers_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Request ID'),
                      readOnly: _lockRequestId,
                      enabled: _lockRequestId ? false : null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _pricePerUnit,
                      labelText: 'Price per unit',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Price per unit'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _totalPrice,
                      labelText: 'Total price (optional)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calculate_outlined),
                      validator: (_) => null,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _deliveryDays,
                      labelText: 'Delivery time (days)',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.local_shipping_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Delivery time'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _deliveryCost,
                      labelText: 'Delivery cost',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.delivery_dining_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Delivery cost'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _terms,
                      labelText: 'Payment terms',
                      prefixIcon: const Icon(Icons.receipt_long_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Payment terms'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _validUntil,
                      labelText: 'Valid until (YYYY-MM-DD HH:mm:ss)',
                      prefixIcon: const Icon(Icons.timer_outlined),
                      validator: (v) =>
                          Validation.required(v, fieldName: 'Valid until'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFieldWidget(
                      controller: _notes,
                      labelText: 'Notes (optional)',
                      prefixIcon: const Icon(Icons.notes_outlined),
                      maxLines: 3,
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
                                final validUtc =
                                    DateTimeHelper.localToUtcString(
                                        _validUntil.text.trim());
                                if (validUtc == null) {
                                  Get.snackbar('Invalid date',
                                      'Valid until must be in YYYY-MM-DD HH:mm:ss');
                                  return;
                                }
                                final ok = await c.submitQuotation(
                                  requestId: int.tryParse(_requestId.text) ?? 0,
                                  pricePerUnit:
                                      num.tryParse(_pricePerUnit.text) ?? 0,
                                  totalPrice: _totalPrice.text.trim().isEmpty
                                      ? null
                                      : num.tryParse(_totalPrice.text.trim()),
                                  deliveryTimeDays:
                                      int.tryParse(_deliveryDays.text) ?? 0,
                                  deliveryCost:
                                      num.tryParse(_deliveryCost.text) ?? 0,
                                  paymentTerms: _terms.text.trim(),
                                  validUntil: validUtc,
                                  notes: _notes.text.trim().isEmpty
                                      ? null
                                      : _notes.text.trim(),
                                );
                                if (ok) Get.back();
                              },
                        child: c.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Submit quotation'),
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
