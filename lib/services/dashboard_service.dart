import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lendo/config/supabase_config.dart';

class DashboardService {
  final _supabase = SupabaseConfig.client;

  // Get dashboard KPI data from the view
  Future<Map<String, dynamic>> getDashboardKpi() async {
    try {
      final response = await _supabase
          .from('dashboard_kpi')
          .select('*')
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to fetch dashboard KPI data: $e');
    }
  }
}