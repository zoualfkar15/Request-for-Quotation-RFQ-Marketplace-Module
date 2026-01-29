class RfqQuotation {
  final int id;
  final int requestId;
  final int companyId;
  final num pricePerUnit;
  final num totalPrice;
  final int deliveryTimeDays;
  final num deliveryCost;
  final String paymentTerms;
  final String? notes;
  final String validUntil;
  final String status;

  RfqQuotation({
    required this.id,
    required this.requestId,
    required this.companyId,
    required this.pricePerUnit,
    required this.totalPrice,
    required this.deliveryTimeDays,
    required this.deliveryCost,
    required this.paymentTerms,
    required this.validUntil,
    required this.status,
    this.notes,
  });

  factory RfqQuotation.fromJson(Map<String, dynamic> json) {
    return RfqQuotation(
      id: (json['id'] as num).toInt(),
      requestId: (json['request_id'] as num).toInt(),
      companyId: (json['company_id'] as num).toInt(),
      pricePerUnit: (json['price_per_unit'] as num?) ?? 0,
      totalPrice: (json['total_price'] as num?) ?? 0,
      deliveryTimeDays: (json['delivery_time_days'] as num?)?.toInt() ?? 0,
      deliveryCost: (json['delivery_cost'] as num?) ?? 0,
      paymentTerms: (json['payment_terms'] ?? '') as String,
      notes: json['notes'] as String?,
      validUntil: (json['valid_until'] ?? '') as String,
      status: (json['status'] ?? '') as String,
    );
  }
}
