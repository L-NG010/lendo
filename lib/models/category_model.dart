class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  // Factory method to create from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
