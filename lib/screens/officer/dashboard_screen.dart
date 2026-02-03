import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/kpi_card.dart';
import 'package:lendo/widgets/officer_sidebar.dart';

class OfficerDashboardScreen extends ConsumerWidget {
  const OfficerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Scaffold(
      drawer: const OfficerSidebar(),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        leading: Builder(
          builder: (context) => 
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Total Requests',
                    value: '24',
                    icon: const Icon(Icons.inventory_2_outlined),
                    iconColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: KpiCard(
                    title: 'Pending Approval',
                    value: '8',
                    icon: const Icon(Icons.pending_outlined),
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
                    title: 'Pending Returns',
                    value: '5',
                    icon: const Icon(Icons.undo_outlined),
                    iconColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: KpiCard(
                    title: 'Completed Today',
                    value: '12',
                    icon: const Icon(Icons.check_circle_outline),
                    iconColor: AppColors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            _sectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(title: 'Recent Activity'),
                  const SizedBox(height: AppSpacing.md),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildActivityCard('New loan request submitted by John Doe', '2 min ago', Icons.notifications_outlined),
                      _buildActivityCard('Asset returned by Jane Smith', '15 min ago', Icons.check_circle),
                      _buildActivityCard('Loan request approved by admin', '1 hour ago', Icons.done_all),
                      _buildActivityCard('New asset added to inventory', '3 hours ago', Icons.add_box_outlined),
                    ],
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

  Widget _buildActivityCard(String title, String time, IconData icon) {
    return Card(
      color: AppColors.secondary,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.gray,
        ),
      ),
    );
  }
}