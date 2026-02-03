import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/providers/borrower/return_provider.dart';

class BorrowerReturnScreen extends ConsumerStatefulWidget {
  const BorrowerReturnScreen({super.key});

  @override
  ConsumerState<BorrowerReturnScreen> createState() =>
      _BorrowerReturnScreenState();
}

class _BorrowerReturnScreenState extends ConsumerState<BorrowerReturnScreen> {
  @override
  Widget build(BuildContext context) {
    final approvedLoansAsync = ref.watch(userApprovedLoansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Return Items',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: approvedLoansAsync.when(
          data: (loans) {
            if (loans.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userApprovedLoansProvider);
              },
              child: ListView.builder(
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return _buildLoanCard(loan);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading loans: $error',
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanCard(loan) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan #${loan.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Loan Date: ${loan.loanDate}',
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due Date: ${loan.dueDate}',
                      style: const TextStyle(
                        color: AppColors.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.undo, color: AppColors.white),
                onPressed: () => _showReturnForm(loan),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Approved',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray),
          const SizedBox(height: 16),
          const Text(
            'No Approved Loans',
            style: TextStyle(fontSize: 18, color: AppColors.gray),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no approved loans to return',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showReturnForm(loan) async {
    // Fetch loan details first
    final loanService = ref.read(loanServiceProvider);
    List<dynamic> loanDetails = [];

    try {
      loanDetails = await loanService.getLoanDetails(loan.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading loan details: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    final Map<String, String> returnConditions = {};
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Return Loan #${loan.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.white),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Set return condition for each asset:',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: ListView.builder(
                        itemCount: loanDetails.length,
                        itemBuilder: (context, index) {
                          final detail = loanDetails[index];
                          String key = detail.id;
                          String currentCondition =
                              returnConditions[key] ?? 'good';

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.assetName ??
                                      'Asset #${detail.assetId}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Borrowed Condition: ${detail.condBorrow}',
                                  style: const TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                const Text(
                                  'Return Condition:',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                DropdownButtonFormField<String>(
                                  value: currentCondition,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ),
                                  dropdownColor: AppColors.background,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'good',
                                      child: Text(
                                        'Good',
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'minor',
                                      child: Text(
                                        'Minor Damage',
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'major',
                                      child: Text(
                                        'Major Damage',
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setDialogState(() {
                                        returnConditions[key] = newValue;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Reason for return:',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: reasonController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter reason for returning these items...',
                        hintStyle: TextStyle(
                          color: AppColors.gray.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _confirmReturn(
                          dialogContext,
                          loan,
                          loanDetails,
                          returnConditions,
                          reasonController.text,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm Return',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmReturn(
    BuildContext dialogContext,
    loan,
    List<dynamic> loanDetails,
    Map<String, String> returnConditions,
    String reason,
  ) async {
    Navigator.of(dialogContext).pop();

    try {
      // Build the details array for the RPC call
      final details = loanDetails.map((detail) {
        final detailId = int.tryParse(detail.id) ?? 0;
        final condition = returnConditions[detail.id] ?? 'good';

        return {'detail_id': detailId, 'cond': condition};
      }).toList();

      final loanIdInt = int.tryParse(loan.id) ?? 0;
      if (loanIdInt == 0) {
        throw Exception('Invalid loan ID');
      }

      await ref
          .read(returnServiceProvider)
          .returnLoan(loanId: loanIdInt, details: details, reason: reason);

      // Refresh the approved loans list
      ref.invalidate(userApprovedLoansProvider);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: const Text(
            'Return Successful',
            style: TextStyle(color: AppColors.white),
          ),
          content: const Text(
            'Your items have been marked for return.',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
