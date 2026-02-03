import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/providers/officer/request_provider.dart';
import 'package:lendo/widgets/sidebar.dart';

class OfficerReturnScreen extends ConsumerStatefulWidget {
  const OfficerReturnScreen({super.key});

  @override
  ConsumerState<OfficerReturnScreen> createState() =>
      _OfficerReturnScreenState();
}

class _OfficerReturnScreenState extends ConsumerState<OfficerReturnScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh loans data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(loansProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allLoansAsync = ref.watch(loansProvider);

    return Scaffold(
      drawer: CustomSidebar(),
      appBar: AppBar(
        title: const Text('Returns'),
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
                  // Filter for loans that have been returned (returnedAt is not null)
                  // AND have 'returned' status (pending approval).
                  // If approved, status changes to something else (e.g. approved),
                  // or we assume successful approval removes 'returned' status or similar.
                  // Based on typical flows, we only show items needing action.
                  final returnedLoans = loans
                      .where(
                        (loan) =>
                            loan.returnedAt != null &&
                            loan.status == 'returned',
                      )
                      .toList();

                  // Sort by returned date descending (most recent first)
                  returnedLoans.sort((a, b) {
                    final dateA = a.returnedAt ?? '';
                    final dateB = b.returnedAt ?? '';
                    return dateB.compareTo(dateA);
                  });

                  if (returnedLoans.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pending returns',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(loansProvider);
                      await ref.read(loansProvider.future);
                    },
                    child: ListView.builder(
                      itemCount: returnedLoans.length,
                      itemBuilder: (context, index) {
                        final loan = returnedLoans[index];
                        return _buildLoanCard(context, ref, loan);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading returns: $error',
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
                color: AppColors.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Returned: ${loan.returnedAt}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error loading assets: ${snapshot.error}',
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

                if (loan.penaltyAmount != null && loan.penaltyAmount! > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (loan.lateDays != null &&
                            int.tryParse(loan.lateDays!) != null &&
                            int.parse(loan.lateDays!) > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_off_outlined,
                                  color: AppColors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Late ${loan.lateDays} days',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_outlined,
                              color: AppColors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total Penalty: Rp ${loan.penaltyAmount!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showApprovalDialog(context, ref, loan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showRejectionDialog(context, ref, loan);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: AppColors.red),
                        ),
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
                'Borrow: ${detail.condBorrow}',
                style: const TextStyle(color: AppColors.gray, fontSize: 12),
              ),
              if (detail.condReturn != null)
                Text(
                  'Return: ${detail.condReturn}',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Approval'),
          content: Text(
            'Are you sure you want to approve the return for loan code ${loan.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                try {
                  final loanIdInt = int.tryParse(loan.id) ?? 0;
                  if (loanIdInt == 0) {
                    throw Exception('Invalid Loan ID format');
                  }

                  await ref
                      .read(officerRequestServiceProvider)
                      .approveReturn(loanId: loanIdInt);

                  // Refresh the list
                  ref.invalidate(loansProvider);

                  if (context.mounted) {
                    _showResultDialog(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text(
                'Approve',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRejectionDialog(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Rejection'),
          content: Text(
            'Are you sure you want to reject the return for loan code ${loan.id}? Status will be reverted to "borrowed".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                try {
                  final loanIdInt = int.tryParse(loan.id) ?? 0;
                  if (loanIdInt == 0) {
                    throw Exception('Invalid Loan ID format');
                  }

                  await ref
                      .read(officerRequestServiceProvider)
                      .rejectReturn(loanId: loanIdInt);

                  // Refresh the list
                  ref.invalidate(loansProvider);

                  if (context.mounted) {
                    _showResultDialog(context, false);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text(
                'Reject',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, bool approved) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            approved ? 'Approved Successfully' : 'Rejected Successfully',
          ),
          content: Text(
            approved
                ? 'Return has been approved.'
                : 'Return has been rejected and status reverted to borrowed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
