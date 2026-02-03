import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/expandable_card.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/services/auth_service.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:intl/intl.dart';

class BorrowerHistoryScreen extends ConsumerWidget {
  const BorrowerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServicePod);
    final user = authService.getCurrentUser();
    final loansAsync = ref.watch(loansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Loan History',
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
              // Filter all loans for current user
              final myLoans = allLoans
                  .where((l) => l.userId == user.id)
                  .toList();

              if (myLoans.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: myLoans.length,
                itemBuilder: (context, index) {
                  final loan = myLoans[index];
                  Color statusColor = AppColors.gray;

                  if (loan.status == 'approved') {
                    statusColor = AppColors.primary;
                  } else if (loan.status == 'returned') {
                    statusColor = Colors.green;
                  } else if (loan.status == 'rejected') {
                    statusColor = AppColors.red;
                  } else if (loan.status == 'pending') {
                    statusColor = AppColors.outline;
                  }

                  // Calculate status text properly
                  String statusText =
                      loan.status[0].toUpperCase() + loan.status.substring(1);
                  if (loan.status == 'approved' && loan.returnedAt != null) {
                    statusText = 'Pending Return Confirmation';
                    statusColor = Colors.orange;
                  }

                  return _buildLoanCard(
                    context,
                    ref,
                    loan,
                    statusColor,
                    statusText,
                  );
                },
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

  Widget _buildLoanCard(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
    Color statusColor,
    String statusText,
  ) {
    return FutureBuilder<List<LoanDetailModel>>(
      future: ref.read(loanServiceProvider).getLoanDetails(loan.id),
      builder: (context, snapshot) {
        List<Widget> expandedContent = [
          _buildDetailRow('Loan Date:', loan.loanDate),
          _buildDetailRow('Due Date:', loan.dueDate),
          if (loan.returnedAt != null)
            _buildDetailRow('Returned Date:', loan.returnedAt!),
          if ((loan.penaltyAmount ?? 0) > 0)
            _buildDetailRow(
              'Penalty:',
              'Rp ${NumberFormat('#,###').format(loan.penaltyAmount)}',
            ),
          if (loan.reason != null && loan.reason!.isNotEmpty)
            _buildDetailRow('Reason:', loan.reason!),

          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Assets Borrowed:',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ];

        if (snapshot.connectionState == ConnectionState.waiting) {
          expandedContent.add(
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          expandedContent.addAll(
            snapshot.data!.map((detail) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• ${detail.assetName ?? 'Asset #${detail.assetId}'}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        }

        return ExpandableCard(
          title:
              'Loan #${loan.id.length > 8 ? loan.id.substring(0, 8) + '...' : loan.id}',
          subtitle: 'Status: $statusText',
          statusColor: statusColor,
          statusText: statusText,
          icon: Icons.history,
          expandedContent: expandedContent,
          initiallyExpanded: false,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_outlined, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          const Text(
            'No History',
            style: TextStyle(fontSize: 18, color: AppColors.gray),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no loan history yet',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.gray, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
