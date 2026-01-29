class Offer {
  final int id;
  final int companyId;
  final int categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String title;
  final String description;
  final String unit;
  final num? minQuantity;
  final num pricePerUnit;
  final String? deliveryCity;
  final String? availableFrom;
  final String? availableUntil;
  final String status;

  Offer({
    required this.id,
    required this.companyId,
    required this.categoryId,
    this.categoryName,
    this.categorySlug,
    required this.title,
    required this.description,
    required this.unit,
    this.minQuantity,
    required this.pricePerUnit,
    this.deliveryCity,
    this.availableFrom,
    this.availableUntil,
    required this.status,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: (json['id'] as num).toInt(),
      companyId: (json['company_id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      categoryName: json['category_name'] as String?,
      categorySlug: json['category_slug'] as String?,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      unit: (json['unit'] ?? '') as String,
      minQuantity: (json['min_quantity'] as num?),
      pricePerUnit: (json['price_per_unit'] as num?) ?? 0,
      deliveryCity: json['delivery_city'] as String?,
      availableFrom: json['available_from'] as String?,
      availableUntil: json['available_until'] as String?,
      status: (json['status'] ?? '') as String,
    );
  }
}
