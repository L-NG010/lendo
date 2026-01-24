import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/widgets/kpi_card.dart';
import 'package:lendo/widgets/quick_action.dart';
import 'package:lendo/widgets/recent_activity.dart';
import 'package:lendo/config/app_config.dart';
import '../../widgets/sidebar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      drawer: const CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Assets',
                    value: '247',
                    icon: const Icon(Icons.inventory),
                    iconColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: KpiCard(
                    title: 'Users',
                    value: '128',
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
                    value: '104',
                    icon: const Icon(Icons.receipt_long),
                    iconColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: KpiCard(
                    title: 'Categories',
                    value: '24',
                    icon: const Icon(Icons.category),
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
                          // TODO: Implement add asset action
                        },
                      ),
                      QuickAction(
                        icon: Icons.person_add_alt_1_outlined,
                        label: 'Add User',
                        onPressed: () {
                          // TODO: Implement add user action
                        },
                      ),
                      QuickAction(
                        icon: Icons.request_quote_outlined,
                        label: 'New Loan',
                        onPressed: () {
                          // TODO: Implement new loan action
                        },
                      ),
                      QuickAction(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        onPressed: () {
                          // TODO: Implement category action
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _sectionContainer(
              child: const RecentActivity(),
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
}
