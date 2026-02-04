import 'package:lendo/config/supabase_config.dart';

class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? role;

  UserProfile({required this.id, required this.name, this.email, this.role});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}

class ProfileService {
  final supabase = SupabaseConfig.client;

  // Get all user profiles
  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id, name, email, role')
          .order('name');

      return (response as List)
          .map((profile) => UserProfile.fromJson(profile))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch profiles: $e');
    }
  }
}
