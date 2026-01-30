import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static late final SupabaseClient supabase;
  static late String _supabaseUrl;
  static late String _supabaseAnonKey;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    
    _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      throw Exception('Missing Supabase credentials in .env file');
    }

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );

    supabase = Supabase.instance.client;
  }

  static SupabaseClient get client => supabase;
  static String get supabaseUrl => _supabaseUrl;
  static String get supabaseAnonKey => _supabaseAnonKey;
}