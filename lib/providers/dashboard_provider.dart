import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/services/dashboard_service.dart';
import 'package:lendo/services/activity_log_service.dart';
import 'package:lendo/models/activity_log_model.dart';

// Dashboard service provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

// Async notifier for dashboard KPI data
class DashboardKpiNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final dashboardService = ref.read(dashboardServiceProvider);
    return await dashboardService.getDashboardKpi();
  }

  // Refresh dashboard KPI data
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dashboardService = ref.read(dashboardServiceProvider);
      return await dashboardService.getDashboardKpi();
    });
  }
}

// Provider for dashboard KPI data
final dashboardKpiProvider =
    AsyncNotifierProvider.autoDispose<DashboardKpiNotifier, Map<String, dynamic>>(
      DashboardKpiNotifier.new,
    );

// Async notifier for recent activity logs (latest 5)
class RecentActivityLogsNotifier extends AsyncNotifier<List<ActivityLog>> {
  @override
  Future<List<ActivityLog>> build() async {
    final activityLogService = ref.read(activityLogServiceProvider);
    return await activityLogService.getLatestActivityLogs(limit: 5);
  }

  // Refresh recent activity logs
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activityLogService = ref.read(activityLogServiceProvider);
      return await activityLogService.getLatestActivityLogs(limit: 5);
    });
  }
}

// Provider for recent activity logs (latest 5)
final recentActivityLogsProvider =
    AsyncNotifierProvider.autoDispose<RecentActivityLogsNotifier, List<ActivityLog>>(
      RecentActivityLogsNotifier.new,
    );