import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/widgets/kpi_card.dart';
import 'package:lendo/widgets/sidebar.dart';

class OfficerDashboardScreen extends ConsumerWidget {
  const OfficerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLoansAsync = ref.watch(loansProvider);

    return Scaffold(
      drawer: CustomSidebar(),
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
        child: allLoansAsync.when(
          data: (loans) {
            // Calculate KPIs
            final totalLoans = loans.length;
            final pendingLoans = loans.where((l) => l.status == 'pending').length;
            
            // "Returned but pending approval" - based on user def: approved AND returned_at not null
            // Assuming this means the officer approved the LOAN, it was active, then user returned it, 
            // and now it's "returned" waiting for final check/approval (which changes status to returned/completed)
            // Wait, usually when user returns, we might update status to 'returned' or keep 'approved' and set 'returned_at'.
            // Based on previous ReturnScreen logic: we filtered loans where returnedAt != null.
            // Let's stick to: Status 'approved' AND returnedAt != null. 
            // OR Status 'returned' (if that's what the system uses for pending return check).
            // Let's assume 'returned' status is what we look for in Return Screen, so we count those.
            // But user specifically said: "status approved tapi returned_at nya udah ada nilai".
            final returnPending = loans.where((l) => l.status == 'approved' && l.returnedAt != null).length;
            
            final loansWithFines = loans.where((l) => (l.penaltyAmount ?? 0) > 0).length;

            // Recent Requests: Pending loans sorted by date desc
            final recentRequests = loans
                .where((l) => l.status == 'pending')
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Assuming createdAt is sortable string or we parse it
            
            final topRecent = recentRequests.take(5).toList();

            return ListView(
              children: [
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        title: 'Total Loans',
                        value: totalLoans.toString(),
                        icon: const Icon(Icons.inventory_2_outlined),
                        iconColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiCard(
                        title: 'Pending Approval',
                        value: pendingLoans.toString(),
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
                        value: returnPending.toString(),
                        icon: const Icon(Icons.undo_outlined),
                        iconColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: KpiCard(
                        title: 'With Fines',
                        value: loansWithFines.toString(),
                        icon: const Icon(Icons.monetization_on_outlined),
                        iconColor: AppColors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                _sectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(title: 'Recent Request'),
                      const SizedBox(height: AppSpacing.md),
                      if (topRecent.isEmpty)
                         const Text('No recent requests', style: TextStyle(color: AppColors.gray))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topRecent.length,
                          itemBuilder: (context, index) {
                            return _buildActivityCard(context, ref, topRecent[index]);
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.red))),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, WidgetRef ref, LoanModel loan) {
    // Calculate time ago
    String timeAgo = '';
    try {
      final created = DateTime.parse(loan.createdAt); // timestampz usually parseable
      final diff = DateTime.now().difference(created);
      if (diff.inMinutes < 60) {
        timeAgo = '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        timeAgo = '${diff.inHours} hours ago';
      } else {
        timeAgo = '${diff.inDays} days ago';
      }
    } catch (e) {
      timeAgo = '-';
    }

    return FutureBuilder<List<LoanDetailModel>>(
      future: ref.read(loanServiceProvider).getLoanDetails(loan.id),
      builder: (context, snapshot) {
        String assetNamesString = '...';
        if (snapshot.hasData) {
          final assetNames = snapshot.data!
              .map((d) => d.assetName ?? d.assetId)
              .join(', ');
          assetNamesString = assetNames;
        }

        return Card(
          color: AppColors.secondary,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
            ),
            title: Text(
              '${loan.userName ?? loan.userId} requesting loan for $assetNamesString',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              timeAgo,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.gray,
              ),
              onPressed: () {
                // Navigate to requests and highlight/open this loan
                Navigator.of(context).pushNamed(
                  '/officer/requests',
                  arguments: {'highlightLoanId': loan.id},
                );
              },
            ),
          ),
        );
      },
    );
  }
}