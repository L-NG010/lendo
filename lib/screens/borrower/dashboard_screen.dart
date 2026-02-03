import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/bottom_navigation.dart';
import 'profile_screen.dart';
import 'submission_screen.dart';
import 'package:lendo/services/auth_service.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/models/loan_model.dart';

class BorrowerDashboardScreen extends ConsumerStatefulWidget {
  const BorrowerDashboardScreen({super.key});

  @override
  ConsumerState<BorrowerDashboardScreen> createState() =>
      _BorrowerDashboardScreenState();
}

class _BorrowerDashboardScreenState
    extends ConsumerState<BorrowerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(),
    const BorrowerSubmissionScreen(),
    const BorrowerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check if we came from a successful submission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'loan_success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan request submitted successfully!'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BorrowerBottomNavigation(
        selectedIndex: _selectedIndex,
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServicePod);
    final user = authService.getCurrentUser();
    final loansAsync = ref.watch(loansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: RefreshIndicator(
          onRefresh: () async {
            return ref.refresh(loansProvider);
          },
          child: loansAsync.when(
            data: (allLoans) {
              if (user == null) {
                return const Center(child: Text('User not found'));
              }
              // Filter loans for current user
              final myLoans = allLoans
                  .where((l) => l.userId == user.id)
                  .toList();

              // KPIs
              final totalLoans = myLoans.length;
              final pendingLoans = myLoans
                  .where((l) => l.status == 'pending')
                  .length;
              final penaltiesCount = myLoans
                  .where((l) => (l.penaltyAmount ?? 0) > 0)
                  .length;

              // Recent Requests (Top 5 latest)
              final recentLoans = [...myLoans]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final topRecent = recentLoans.take(5).toList();

              return ListView(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Stats Cards
                  _buildStatsSection(totalLoans, pendingLoans, penaltiesCount),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: AppSpacing.lg),

                  // Recent Request
                  _buildRecentRequests(context, ref, topRecent),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(int total, int pending, int penalties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Loans',
                value: total.toString(),
                icon: Icons.inventory,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                title: 'Pending',
                value: pending.toString(),
                icon: Icons.pending_actions,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                title: 'Penalties',
                value: penalties.toString(),
                icon: Icons.warning,
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            children: [
              _buildActionButton(
                icon: Icons.list_alt,
                label: 'My Submissions',
                onTap: () {
                  Navigator.pushNamed(context, '/borrower/own-submissions');
                },
              ),
              _buildActionButton(
                icon: Icons.history,
                label: 'History',
                onTap: () {
                  Navigator.pushNamed(context, '/borrower/history');
                },
              ),
              _buildActionButton(
                icon: Icons.undo,
                label: 'Return Items',
                onTap: () {
                  Navigator.pushNamed(context, '/borrower/return');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequests(
    BuildContext context,
    WidgetRef ref,
    List<LoanModel> loans,
  ) {
    if (loans.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Request',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...loans.map((loan) => _buildActivityCard(context, ref, loan)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
  ) {
    Color statusColor = AppColors.gray;
    if (loan.status == 'approved') {
      statusColor = AppColors.primary;
    } else if (loan.status == 'pending') {
      statusColor = AppColors.outline;
    } else if (loan.status == 'returned') {
      statusColor = Colors.green;
    }

    // Calculate time ago
    String timeAgo = '';
    try {
      final created = DateTime.parse(loan.createdAt);
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
        String title = 'Loan Request';
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final names = snapshot.data!
              .map((d) => d.assetName ?? 'Unknown')
              .join(', ');
          title = names;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loan.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: AppColors.gray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Removed _PendingLoansContent class - now using BorrowerSubmissionScreen
