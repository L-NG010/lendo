import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/models/activity_log_model.dart';
import 'package:lendo/services/activity_log_service.dart';

// Activity log service provider
final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  return ActivityLogService();
});

// Async notifier for activity logs list
class ActivityLogsNotifier extends AsyncNotifier<List<ActivityLog>> {
  @override
  Future<List<ActivityLog>> build() async {
    final activityLogService = ref.read(activityLogServiceProvider);
    return await activityLogService.getAllActivityLogs();
  }

  // Refresh activity logs
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activityLogService = ref.read(activityLogServiceProvider);
      return await activityLogService.getAllActivityLogs();
    });
  }

  // Filter activity logs by entity
  Future<void> filterByEntity(String entity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activityLogService = ref.read(activityLogServiceProvider);
      return await activityLogService.getActivityLogsByEntity(entity);
    });
  }

  // Filter activity logs by action
  Future<void> filterByAction(String action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activityLogService = ref.read(activityLogServiceProvider);
      return await activityLogService.getActivityLogsByAction(action);
    });
  }
}

// Provider for activity logs list
final activityLogsProvider = AsyncNotifierProvider<ActivityLogsNotifier, List<ActivityLog>>(ActivityLogsNotifier.new);