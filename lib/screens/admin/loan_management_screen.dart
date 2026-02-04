import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/loan_card.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/providers/profile_provider.dart';

class LoanManagementScreen extends ConsumerWidget {
  const LoanManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLoansAsync = ref.watch(loansProvider);
    final filteredLoans = ref.watch(filteredLoansProvider);
    final filterState = ref.watch(loanFilterProvider);

    ref.listen<LoanFilterState>(loanFilterProvider, (previous, next) {
      if (previous?.searchQuery != next.searchQuery) {
        if (next.searchQuery.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (next.searchQuery != filterState.searchQuery) return;
            ref.read(loansProvider.notifier).searchLoans(next.searchQuery);
          });
        } else {
          ref.read(loansProvider.notifier).filterByStatus(next.selectedStatus);
        }
      } else if (previous?.selectedStatus != next.selectedStatus) {
        ref.read(loansProvider.notifier).filterByStatus(next.selectedStatus);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.white, size: 28),
            onPressed: () {
              _showAddLoanDialog(context, ref);
            },
          ),
        ],
      ),
      drawer: CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter controls
            Row(
              children: [
                // Search bar
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search loans...',
                        hintStyle: TextStyle(color: AppColors.gray),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: AppColors.gray),
                      ),
                      onChanged: (value) {
                        ref
                            .read(loanFilterProvider.notifier)
                            .setSearchQuery(value);
                      },
                    ),
                  ),
                ),
                // Status filter popup menu with background
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final filterState = ref.watch(loanFilterProvider);
                      return PopupMenuButton<String>(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: AppColors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              filterState.selectedStatus == 'All'
                                  ? 'All Status'
                                  : filterState.selectedStatus,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ],
                        ),
                        color: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: AppColors.outline),
                        ),
                        onSelected: (String result) {
                          ref
                              .read(loanFilterProvider.notifier)
                              .setSelectedStatus(result);
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'All',
                                child: Text(
                                  'All Status',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'pending',
                                child: Text(
                                  'Pending',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'approved',
                                child: Text(
                                  'Approved',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'returned',
                                child: Text(
                                  'Returned',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'rejected',
                                child: Text(
                                  'Rejected',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                            ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Search results counter
            if (filterState.searchQuery.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  '${filteredLoans.length} loan${filteredLoans.length != 1 ? 's' : ''} found',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ),
            Expanded(
              child: allLoansAsync.when(
                data: (_) {
                  // Use filtered loans for display
                  if (filteredLoans.isEmpty) {
                    return const Center(
                      child: Text(
                        'No loans found',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredLoans.length,
                    itemBuilder: (context, index) {
                      final loan = filteredLoans[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LoanCard(
                          loan: loan,
                          onExpand: () {},
                          onEdit: () => _showUpdateDialog(context, ref, loan),
                          onDelete: () => _showDeleteDialog(context, ref, loan),
                          onLoadDetails: (loanId) => ref
                              .read(loanServiceProvider)
                              .getLoanDetails(loanId),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading loans: ${error.toString()}',
                        style: TextStyle(color: AppColors.red),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(loansProvider.notifier).refresh();
                        },
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

  void _showAddLoanDialog(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    String? selectedUserId;
    String selectedStatus = 'pending';
    final dueDateController = TextEditingController();
    final loanDateController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.secondary,
              title: Text(
                'Add New Loan',
                style: TextStyle(color: AppColors.white),
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User dropdown
                      _buildDropdownField(
                        label: 'User:',
                        child: profilesAsync.when(
                          data: (profiles) {
                            return DropdownButtonFormField<String>(
                              value: selectedUserId,
                              dropdownColor: AppColors.secondary,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.secondary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: TextStyle(color: AppColors.white),
                              hint: Text(
                                'Select user',
                                style: TextStyle(color: AppColors.gray),
                              ),
                              items: profiles.map((profile) {
                                return DropdownMenuItem(
                                  value: profile.id,
                                  child: Text(
                                    profile.name,
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedUserId = value;
                                });
                              },
                            );
                          },
                          loading: () => CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          error: (_, __) => Text(
                            'Error loading users',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                      ),
                      // Status dropdown
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          style: TextStyle(color: AppColors.white),
                          items: ['pending', 'approved', 'returned', 'rejected']
                              .map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status[0].toUpperCase() +
                                        status.substring(1),
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      _buildAddField(
                        'Due Date (YYYY-MM-DD):',
                        dueDateController,
                      ),
                      _buildAddField(
                        'Loan Date (YYYY-MM-DD):',
                        loanDateController,
                      ),
                      _buildAddField('Reason:', reasonController),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedUserId == null) {
                      _showErrorMessage(context, 'Please select a user');
                      return;
                    }
                    try {
                      await ref
                          .read(loansProvider.notifier)
                          .addLoan(
                            userId: selectedUserId!,
                            status: selectedStatus,
                            dueDate: dueDateController.text,
                            loanDate: loanDateController.text,
                            reason: reasonController.text.isEmpty
                                ? null
                                : reasonController.text,
                          );
                      Navigator.of(context).pop();
                      _showSuccessMessage(context, 'Loan added successfully');
                    } catch (e) {
                      _showErrorMessage(
                        context,
                        'Failed to add loan: ${e.toString()}',
                      );
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAddField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outline, width: 1),
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()}',
                hintStyle: TextStyle(color: AppColors.gray),
                border: InputBorder.none,
              ),
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, LoanModel loan) {
    final profilesAsync = ref.watch(profilesProvider);
    String? selectedUserId = loan.userId;
    String selectedStatus = loan.status;
    final dueDateController = TextEditingController(
      text: _formatDate(loan.dueDate),
    );
    final loanDateController = TextEditingController(
      text: _formatDate(loan.loanDate),
    );
    final reasonController = TextEditingController(text: loan.reason ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.secondary,
              title: Text(
                'Update Loan',
                style: TextStyle(color: AppColors.white),
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User dropdown
                      _buildDropdownField(
                        label: 'User:',
                        child: profilesAsync.when(
                          data: (profiles) {
                            return DropdownButtonFormField<String>(
                              value: selectedUserId,
                              dropdownColor: AppColors.secondary,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.secondary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: TextStyle(color: AppColors.white),
                              hint: Text(
                                'Select user',
                                style: TextStyle(color: AppColors.gray),
                              ),
                              items: profiles.map((profile) {
                                return DropdownMenuItem(
                                  value: profile.id,
                                  child: Text(
                                    profile.name,
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedUserId = value;
                                });
                              },
                            );
                          },
                          loading: () => CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          error: (_, __) => Text(
                            'Error loading users',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                      ),
                      // Status dropdown
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          style: TextStyle(color: AppColors.white),
                          items: ['pending', 'approved', 'returned', 'rejected']
                              .map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status[0].toUpperCase() +
                                        status.substring(1),
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      _buildAddField(
                        'Due Date (YYYY-MM-DD):',
                        dueDateController,
                      ),
                      _buildAddField(
                        'Loan Date (YYYY-MM-DD):',
                        loanDateController,
                      ),
                      _buildAddField('Reason:', reasonController),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedUserId == null) {
                      _showErrorMessage(context, 'Please select a user');
                      return;
                    }
                    try {
                      await ref
                          .read(loansProvider.notifier)
                          .updateLoan(
                            id: loan.id,
                            userId: selectedUserId!,
                            status: selectedStatus,
                            dueDate: dueDateController.text,
                            loanDate: loanDateController.text,
                            reason: reasonController.text.isEmpty
                                ? null
                                : reasonController.text,
                          );
                      Navigator.of(context).pop();
                      _showSuccessMessage(context, 'Loan updated successfully');
                    } catch (e) {
                      _showErrorMessage(
                        context,
                        'Failed to update loan: ${e.toString()}',
                      );
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, LoanModel loan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: AppColors.white),
          ),
          content: Text(
            'Are you sure you want to delete loan #${loan.id}?',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog (cancel)
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.gray)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(loansProvider.notifier).deleteLoan(loan.id);
                  Navigator.of(context).pop(); // Close dialog
                  _showSuccessMessage(
                    context,
                    'Loan #${loan.id} deleted successfully',
                  );
                } catch (e) {
                  _showErrorMessage(
                    context,
                    'Failed to delete loan: ${e.toString()}',
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showLoanDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
  ) {
    // Load loan details
    ref
        .read(loanServiceProvider)
        .getLoanDetails(loan.id)
        .then((loanDetails) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: AppColors.secondary,
                title: Text(
                  'Loan #${loan.id} Details',
                  style: TextStyle(color: AppColors.white),
                ),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loanDetails.isNotEmpty)
                        DataTable(
                          headingTextStyle: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          dataRowColor:
                              MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                return AppColors.background;
                              }),
                          dataTextStyle: const TextStyle(
                            color: AppColors.white,
                          ),
                          dividerThickness: 1,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Asset ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Condition Borrow',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Condition Return',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: loanDetails.map((detail) {
                            return DataRow(
                              cells: [
                                DataCell(Text(detail.assetId)),
                                DataCell(Text(detail.condBorrow)),
                                DataCell(Text(detail.condReturn ?? 'N/A')),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pop(); // Close current dialog
                                          _showEditLoanDetailDialog(
                                            context,
                                            ref,
                                            loan,
                                            detail,
                                          );
                                        },
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: AppColors.red,
                                        ),
                                        onPressed: () async {
                                          try {
                                            await ref
                                                .read(loansProvider.notifier)
                                                .deleteLoanDetails(
                                                  loanId: loan.id,
                                                  assetId: detail.assetId,
                                                );
                                            Navigator.of(
                                              context,
                                            ).pop(); // Close current dialog
                                            _showLoanDetailsDialog(
                                              context,
                                              ref,
                                              loan,
                                            ); // Reopen to refresh
                                            _showSuccessMessage(
                                              context,
                                              'Loan detail deleted successfully',
                                            );
                                          } catch (e) {
                                            _showErrorMessage(
                                              context,
                                              'Failed to delete loan detail: ${e.toString()}',
                                            );
                                          }
                                        },
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        )
                      else
                        const Text(
                          'No details available',
                          style: TextStyle(color: AppColors.gray),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // We'll add add functionality later
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Detail'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              );
            },
          );
        })
        .catchError((error) {
          _showErrorMessage(
            context,
            'Failed to load loan details: ${error.toString()}',
          );
        });
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  void _showEditLoanDetailDialog(
    BuildContext context,
    WidgetRef ref,
    LoanModel loan,
    LoanDetailModel detail,
  ) {
    final assetIdController = TextEditingController(text: detail.assetId);
    final condBorrowController = TextEditingController(text: detail.condBorrow);
    final condReturnController = TextEditingController(
      text: detail.condReturn ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Edit Loan Detail',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAddField('Asset ID:', assetIdController),
                  _buildAddField('Condition Borrow:', condBorrowController),
                  _buildAddField('Condition Return:', condReturnController),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.gray)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(loansProvider.notifier)
                      .addLoanDetails(
                        loanId: loan.id,
                        assetId: assetIdController.text,
                        condBorrow: condBorrowController.text,
                        condReturn: condReturnController.text.isEmpty
                            ? null
                            : condReturnController.text,
                      );
                  Navigator.of(context).pop(); // Close edit dialog
                  _showLoanDetailsDialog(
                    context,
                    ref,
                    loan,
                  ); // Reopen details to refresh
                  _showSuccessMessage(
                    context,
                    'Loan detail updated successfully',
                  );
                } catch (e) {
                  _showErrorMessage(
                    context,
                    'Failed to update loan detail: ${e.toString()}',
                  );
                }
              },
              child: Text('Save', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      if (dateString.contains(' ')) {
        return dateString.split(' ')[0];
      } else if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
}
