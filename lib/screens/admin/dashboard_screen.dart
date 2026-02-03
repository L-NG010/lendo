import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/widgets/kpi_card.dart';
import 'package:lendo/widgets/quick_action.dart';
import 'package:lendo/config/app_config.dart';
import '../../widgets/sidebar.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/activity_log_model.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardKpiAsync = ref.watch(dashboardKpiProvider);
    final recentActivityLogsAsync = ref.watch(recentActivityLogsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      drawer: CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.md),

            dashboardKpiAsync.when(
              data: (kpiData) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Assets',
                            value: kpiData['total_assets']?.toString() ?? '0',
                            icon: const Icon(Icons.inventory),
                            iconColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: KpiCard(
                            title: 'Users',
                            value: kpiData['total_users']?.toString() ?? '0',
                            icon: const Icon(Icons.people),
                            iconColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: KpiCard(
                            title: 'Loans',
                            value: kpiData['total_loans']?.toString() ?? '0',
                            icon: const Icon(Icons.receipt_long),
                            iconColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: KpiCard(
                            title: 'Categories',
                            value: kpiData['total_categories']?.toString() ?? '0',
                            icon: const Icon(Icons.category),
                            iconColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading KPI data: $error',
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    children: [
                      QuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'Add Asset',
                        onPressed: () {
                          Navigator.pushNamed(context, '/assets');
                        },
                      ),
                      QuickAction(
                        icon: Icons.person_add_alt_1_outlined,
                        label: 'Add User',
                        onPressed: () {
                          Navigator.pushNamed(context, '/users');
                        },
                      ),
                      QuickAction(
                        icon: Icons.request_quote_outlined,
                        label: 'New Loan',
                        onPressed: () {
                          Navigator.pushNamed(context, '/loans');
                        },
                      ),
                      QuickAction(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        onPressed: () {
                          Navigator.pushNamed(context, '/categories');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(title: 'Recent Activity'),
                  const SizedBox(height: AppSpacing.md),
                  recentActivityLogsAsync.when(
                    data: (logs) {
                      if (logs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No recent activity',
                            style: TextStyle(color: AppColors.gray),
                          ),
                        );
                      }
                      
                      return Column(
                        children: List.generate(logs.length, (index) {
                          final log = logs[index];
                          return Column(
                            children: [
                              _buildActivityItem(log),
                              if (index < logs.length - 1)
                                const Divider(color: AppColors.outline),
                            ],
                          );
                        }),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error loading activity logs: $error',
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/log-activities');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text(
                        'View More',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  static Widget _sectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }

  static Widget _sectionHeader({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  static Widget _buildActivityItem(ActivityLog log) {
    String description = _generateDescription(log);
    Color color = _getActionColor(log.action);
    
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ),
      ],
    );
  }

  static String _generateDescription(ActivityLog log) {
    String entityName = log.entity;
    
    switch(log.action.toLowerCase()) {
      case 'create':
        return 'Added a new $entityName with ID ${log.entityId}';
      case 'update':
        return 'Updated $entityName ID ${log.entityId}';
      case 'delete':
        return 'Deleted $entityName with ID ${log.entityId}';
      default:
        return '${log.action} operation on $entityName ID ${log.entityId}';
    }
  }

  static Color _getActionColor(String action) {
    switch(action.toLowerCase()) {
      case 'create':
        return AppColors.primary;
      case 'update':
        return AppColors.white;
      case 'delete':
        return AppColors.red;
      default:
        return AppColors.gray;
    }
  }
}
