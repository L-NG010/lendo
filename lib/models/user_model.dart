class UserModel {
  final String id;
  final String email;
  final String? phone;
  final Map<String, dynamic> rawUserMetadata;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.rawUserMetadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      rawUserMetadata: json['raw_user_meta_data'] ?? {},
    );
  }
}
