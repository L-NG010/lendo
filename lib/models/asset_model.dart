class Asset {
  final String id;
  final String name;
  final int category;
  final String code;
  final String status;
  final String? pictureUrl;
  final num? price;

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.code,
    required this.status,
    this.pictureUrl,
    this.price,
  });

  // Factory method to create from JSON
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] is int ? json['category'] : int.tryParse(json['category']?.toString() ?? '0') ?? 0,
      code: json['code'] ?? '',
      status: json['status'] ?? '',
      pictureUrl: json['picture_url'],
      price: json['price'] is num ? json['price'] : num.tryParse(json['price']?.toString() ?? ''),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'code': code,
      'status': status,
      'picture_url': pictureUrl,
      'price': price,
    };
  }
}