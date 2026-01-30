import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lendo/models/user_model.dart';
import 'package:lendo/config/supabase_config.dart';

class UserService {

  final String _baseUrl = '${SupabaseConfig.supabaseUrl}/functions/v1/manage-users';
  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}', // Ganti dengan SERVICE_ROLE_KEY jika perlu
    'apikey': SupabaseConfig.supabaseAnonKey,
    'Content-Type': 'application/json',
  };

  /// GET: Ambil semua user (aktif & nonaktif)
  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final users = data['users'] as List;
      return users.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode} ${response.body}');
    }
  }

  /// POST: Create user baru
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    final body = json.encode({
      'email': email,
      'password': password,
      'role': role,
      'name': name,
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Failed to create user: ${response.statusCode} ${response.body}');
    }
  }

  /// PUT: Update user
  Future<UserModel> updateUser({
    required String id,
    String? email,
    String? password,
    String? role,
    String? name,
    bool? isActive,
  }) async {
    final body = json.encode({
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'name': name,
      'is_active': isActive,
    });

    final response = await http.put(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Failed to update user: ${response.statusCode} ${response.body}');
    }
  }

  /// DELETE: Soft delete (nonaktifkan user)
  Future<void> deleteUser(String id) async {
    final body = json.encode({'id': id});

    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to deactivate user: ${response.statusCode} ${response.body}');
    }
  }
}
