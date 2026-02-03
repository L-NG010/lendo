import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/providers/officer/request_provider.dart';
import 'package:lendo/widgets/officer_sidebar.dart';

class OfficerRequestScreen extends ConsumerWidget {
  const OfficerRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLoansAsync = ref.watch(loansProvider);

    return Scaffold(
      drawer: const OfficerSidebar(),
      appBar: AppBar(
        title: const Text('Requests'),
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
                  // Filter for pending loans only
                  final pendingLoans = loans
                      .where((loan) => loan.status == 'pending')
                      .toList();

                  if (pendingLoans.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pending requests',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: pendingLoans.length,
                    itemBuilder: (context, index) {
                      final loan = pendingLoans[index];
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
                        'Error loading requests: $error',
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
                loan.status,
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
                // Fetch and display details
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
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Asset: ${detail.assetName ?? detail.assetId}',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Reason: ${loan.reason ?? "-"}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Borrow: ${loan.loanDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Return: ${loan.dueDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showApprovalConfirmation(context, ref, loan, true);
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
                          _showApprovalConfirmation(context, ref, loan, false);
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

  void _showApprovalConfirmation(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
    bool approved,
  ) {
    if (!approved) {
      _showRejectionDialog(context, ref, loan);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approval Confirmation'),
          content: Text(
            'Are you sure you want to approve loan request code ${loan.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // Ensure loan.id is parsed to int for the RPC call
                  final loanIdInt = int.tryParse(loan.id) ?? 0;
                  if (loanIdInt == 0) {
                    throw Exception('Invalid Loan ID format');
                  }

                  await ref
                      .read(officerRequestServiceProvider)
                      .approveLoan(loanId: loanIdInt);

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
              child: const Text('Approve'),
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
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rejection Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to reject loan request code ${loan.id}?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason',
                  hintText: 'Enter reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
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
                  // Ensure loan.id is parsed to int for the RPC call
                  final loanIdInt = int.tryParse(loan.id) ?? 0;
                  if (loanIdInt == 0) {
                    throw Exception('Invalid Loan ID format');
                  }

                  await ref
                      .read(officerRequestServiceProvider)
                      .rejectLoan(
                        loanId: loanIdInt,
                        reason: reasonController.text,
                      );

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
          title: Text(approved ? 'Approved Successfully' : 'Rejected Successfully'),
          content: Text(
            'Request has been ${approved ? 'approved' : 'rejected'}.',
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
