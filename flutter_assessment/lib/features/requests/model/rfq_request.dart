class RfqRequest {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final String unit;
  final num quantity;
  final String deliveryCity;
  final num? deliveryLat;
  final num? deliveryLng;
  final String requiredDeliveryDate;
  final num? budgetMin;
  final num? budgetMax;
  final String expiresAt;
  final String status;
  final int? awardedQuotationId;

  RfqRequest({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.unit,
    required this.quantity,
    required this.deliveryCity,
    this.deliveryLat,
    this.deliveryLng,
    required this.requiredDeliveryDate,
    this.budgetMin,
    this.budgetMax,
    required this.expiresAt,
    required this.status,
    this.awardedQuotationId,
  });

  factory RfqRequest.fromJson(Map<String, dynamic> json) {
    return RfqRequest(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      unit: (json['unit'] ?? '') as String,
      quantity: (json['quantity'] as num?) ?? 0,
      deliveryCity: (json['delivery_city'] ?? '') as String,
      deliveryLat: json['delivery_lat'] as num?,
      deliveryLng: json['delivery_lng'] as num?,
      requiredDeliveryDate: (json['required_delivery_date'] ?? '') as String,
      budgetMin: json['budget_min'] as num?,
      budgetMax: json['budget_max'] as num?,
      expiresAt: (json['expires_at'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      awardedQuotationId: (json['awarded_quotation_id'] as num?)?.toInt(),
    );
  }
}


