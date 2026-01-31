import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/models/activity_log_model.dart';

final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  return ActivityLogService();
});

class ActivityLogService {
  final _supabase = SupabaseConfig.client;

  // Get all activity logs
  Future<List<ActivityLog>> getAllActivityLogs() async {
    try {
      final response = await _supabase
          .from('activity_logs')
          .select('*')
          .order('created_at', ascending: false); // Order by newest first
      
      return response.map((data) {
        final log = data as Map<String, dynamic>;
        return ActivityLog.fromJson(log);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch activity logs: $e');
    }
  }

  // Get activity logs by entity
  Future<List<ActivityLog>> getActivityLogsByEntity(String entity) async {
    try {
      final response = await _supabase
          .from('activity_logs')
          .select('*')
          .eq('entity', entity)
          .order('created_at', ascending: false);
      
      return response.map((data) {
        final log = data as Map<String, dynamic>;
        return ActivityLog.fromJson(log);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch activity logs: $e');
    }
  }

  // Get activity logs by action
  Future<List<ActivityLog>> getActivityLogsByAction(String action) async {
    try {
      final response = await _supabase
          .from('activity_logs')
          .select('*')
          .eq('action', action)
          .order('created_at', ascending: false);
      
      return response.map((data) {
        final log = data as Map<String, dynamic>;
        return ActivityLog.fromJson(log);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch activity logs: $e');
    }
  }

  // Get activity logs by user
  Future<List<ActivityLog>> getActivityLogsByUser(String userId) async {
    try {
      final response = await _supabase
          .from('activity_logs')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((data) {
        final log = data as Map<String, dynamic>;
        return ActivityLog.fromJson(log);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch activity logs: $e');
    }
  }

  // Get latest 5 activity logs
  Future<List<ActivityLog>> getLatestActivityLogs({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('activity_logs')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return response.map((data) {
        final log = data as Map<String, dynamic>;
        return ActivityLog.fromJson(log);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch latest activity logs: $e');
    }
  }
}