import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/widgets/sidebar.dart';

class OfficerHistoryScreen extends ConsumerWidget {
  const OfficerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLoansAsync = ref.watch(loansProvider);

    return Scaffold(
      drawer: CustomSidebar(),
      appBar: AppBar(
        title: const Text('Loan History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: allLoansAsync.when(
                data: (loans) {
                  if (loans.isEmpty) {
                    return const Center(
                      child: Text(
                        'No loan history found',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      final loan = loans[index];
                      return _buildLoanCard(context, ref, loan);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading history: $error',
                        style: const TextStyle(color: AppColors.red),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () => ref.refresh(loansProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, WidgetRef ref, LoanModel loan) {
    Color statusColor = AppColors.gray;
    switch (loan.status) {
      case 'approved':
        statusColor = AppColors.primary;
        break;
      case 'rejected':
        statusColor = AppColors.red;
        break;
      case 'returned':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code: ${loan.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Borrower: ${loan.userName ?? loan.userId}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loan.status.toUpperCase(),
                style: TextStyle(fontSize: 12, color: statusColor),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<LoanDetailModel>>(
                  future: ref.read(loanServiceProvider).getLoanDetails(loan.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error loading assets',
                        style: const TextStyle(color: AppColors.red),
                      );
                    }
                    final details = snapshot.data ?? [];
                    if (details.isEmpty) {
                      return const Text(
                        'No assets linked',
                        style: TextStyle(color: AppColors.gray),
                      );
                    }
                    return Column(
                      children: details
                          .map(
                            (detail) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildAssetRow(detail),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loan Date: ${loan.loanDate}',
                      style: const TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                    Text(
                      'Due Date: ${loan.dueDate}',
                      style: const TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ],
                ),
                if (loan.returnedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Returned At: ${loan.returnedAt}',
                      style: const TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ),
                if (loan.penaltyAmount != null && loan.penaltyAmount! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Penalty: Rp ${loan.penaltyAmount!.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(LoanDetailModel detail) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.assetName ?? 'Asset ${detail.assetId}',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cond (Borrow): ${detail.condBorrow}',
                style: const TextStyle(color: AppColors.gray, fontSize: 12),
              ),
              if (detail.condReturn != null)
                Text(
                  'Cond (Return): ${detail.condReturn}',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
            ],
          )
        ],
      ),
    );
  }
}
