import 'dart:developer' as dev;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lendo/models/user_model.dart';
import 'package:lendo/config/supabase_config.dart';

class UserService {
  final String _baseUrl =
      '${SupabaseConfig.supabaseUrl}/functions/v1/manage-users';

  final Map<String, String> _headers = {
    'Authorization': 'Bearer ${SupabaseConfig.supabaseAnonKey}',
    'apikey': SupabaseConfig.supabaseAnonKey,
    'Content-Type': 'application/json',
  };

  /// FORMAT PHONE +62
  String formatPhone(String phone) {
    phone = phone.trim();

    if (phone.startsWith('0')) {
      return '+62${phone.substring(1)}';
    }
    if (phone.startsWith('8')) {
      return '+62$phone';
    }
    if (!phone.startsWith('+62')) {
      return '+62$phone';
    }
    return phone;
  }

  /// GET USERS
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final users = data['users'] as List;

        final userModels = users.map((u) => UserModel.fromJson(u)).toList();

        for (var user in userModels) {
          dev.log(
            'User: ${user.rawUserMetadata['name']} (${user.email})',
            name: 'UserService.getAllUsers',
          );
        }

        return userModels;
      } else {
        dev.log(
          'Failed with status ${response.statusCode}',
          name: 'UserService.getAllUsers',
        );
        dev.log(
          'Error body: ${response.body}',
          name: 'UserService.getAllUsers',
        );
        throw Exception('Fetch users failed: ${response.body}');
      }
    } catch (e, stackTrace) {
      dev.log('Exception: $e', name: 'UserService.getAllUsers');
      dev.log('StackTrace: $stackTrace', name: 'UserService.getAllUsers');
      rethrow;
    }
  }

  /// CREATE USER
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone,
  }) async {
    final body = json.encode({
      'email': email,
      'password': password,
      'role': role,
      'name': name,
      'phone': formatPhone(phone),
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Create user failed: ${response.body}');
    }
  }

  /// UPDATE USER
  Future<UserModel> updateUser({
    required String id,
    String? email,
    String? password,
    String? role,
    String? name,
    String? phone,
    bool? isActive,
  }) async {
    final body = json.encode({
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'name': name,
      'phone': phone != null ? formatPhone(phone) : null,
      'is_active': isActive,
    });

    final response = await http.put(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data['user']);
    } else {
      throw Exception('Update user failed: ${response.body}');
    }
  }

  /// DELETE USER (SOFT)
  Future<void> deleteUser(String id) async {
    final body = json.encode({'id': id});

    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: _headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Deactivate failed: ${response.body}');
    }
  }
}
