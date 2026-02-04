import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/loan_card.dart';
import 'package:lendo/providers/loan_provider.dart';
import 'package:lendo/providers/user_provider.dart';
import 'package:lendo/widgets/themed_date_picker.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/providers/asset_provider.dart';
import 'dart:developer' as dev;

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
                  child: Container(
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
                SizedBox(width: AppSpacing.md),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final filterState = ref.watch(loanFilterProvider);
                      return PopupMenuButton<String>(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
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
    final usersAsync = ref.watch(usersProvider);
    String? selectedUserId;
    String selectedStatus = 'pending';
    final dueDateController = TextEditingController();
    final loanDateController = TextEditingController();
    final reasonController = TextEditingController();
    List<Asset> selectedAssets = [];

    // Log user data for debugging
    usersAsync.whenData((users) {
      dev.log(
        'Loaded ${users.length} users from edge function',
        name: 'LoanManagement',
      );
      for (var user in users) {
        dev.log(
          'User: ${user.rawUserMetadata['name']} (${user.email})',
          name: 'LoanManagement.Users',
        );
      }
    });

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
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User dropdown
                      _buildDropdownField(
                        label: 'User:',
                        child: Consumer(
                          builder: (context, ref, child) {
                            final usersAsync = ref.watch(usersProvider);
                            return usersAsync.when(
                              data: (users) {
                                return DropdownButtonFormField<String>(
                                  initialValue: selectedUserId,
                                  dropdownColor: AppColors.secondary,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
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
                                  items: users.map((user) {
                                    final userName =
                                        user.rawUserMetadata['name'] ??
                                        user.email;
                                    return DropdownMenuItem(
                                      value: user.id,
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
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
                            );
                          },
                        ),
                      ),
                      // Status dropdown
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
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
                      _buildDateField(
                        label: 'Due Date:',
                        controller: dueDateController,
                        context: context,
                      ),
                      _buildDateField(
                        label: 'Loan Date:',
                        controller: loanDateController,
                        context: context,
                      ),
                      _buildAddField('Reason:', reasonController),
                      const SizedBox(height: 16),
                      // Asset Selection Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Assets:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedAssets.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outline),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            children: selectedAssets.map((asset) {
                              return ListTile(
                                dense: true,
                                title: Text(
                                  asset.name,
                                  style: TextStyle(color: AppColors.white),
                                ),
                                subtitle: Text(
                                  asset.code,
                                  style: TextStyle(color: AppColors.gray),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedAssets.remove(asset);
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Add Asset Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            final result = await _showAssetSelectionDialog(
                              context,
                              ref,
                              selectedAssets,
                            );
                            if (result != null) {
                              setState(() {
                                selectedAssets = result;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.add_circle,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Add Assets',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ),
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
                            loanDetails: selectedAssets
                                .map(
                                  (asset) => {
                                    'asset_id': asset.id,
                                    'cond_borrow': 'good', // Default condition
                                  },
                                )
                                .toList(),
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

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
  }) {
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
          GestureDetector(
            onTap: () async {
              final DateTime? picked =
                  await ThemedDatePicker.showThemedDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
              if (picked != null) {
                controller.text =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? 'Select date' : controller.text,
                      style: TextStyle(
                        color: controller.text.isEmpty
                            ? AppColors.gray
                            : AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today, size: 16, color: AppColors.gray),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, LoanModel loan) {
    // usersProvider moved to Consumer
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
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Manage Loan Assets',
                              style: TextStyle(color: AppColors.white),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Close Update Dialog
                                _showLoanDetailsDialog(
                                  context,
                                  ref,
                                  loan,
                                ); // Open Details Dialog
                              },
                              child: Text('View Details'),
                            ),
                          ],
                        ),
                      ),
                      // User dropdown
                      _buildDropdownField(
                        label: 'User:',
                        child: Consumer(
                          builder: (context, ref, child) {
                            final usersAsync = ref.watch(usersProvider);
                            return usersAsync.when(
                              data: (users) {
                                return DropdownButtonFormField<String>(
                                  initialValue: selectedUserId,
                                  dropdownColor: AppColors.secondary,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
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
                                  items: users.map((user) {
                                    final userName =
                                        user.rawUserMetadata['name'] ??
                                        user.email;
                                    return DropdownMenuItem(
                                      value: user.id,
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
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
                            );
                          },
                        ),
                      ),
                      // Status dropdown
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
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
                      _buildDateField(
                        label: 'Due Date:',
                        controller: dueDateController,
                        context: context,
                      ),
                      _buildDateField(
                        label: 'Loan Date:',
                        controller: loanDateController,
                        context: context,
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

  Future<List<Asset>?> _showAssetSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    List<Asset> alreadySelected,
  ) async {
    final assetsAsync = ref.read(assetsProvider);
    // Ensure assets are loaded
    if (!assetsAsync.hasValue) {
      await ref.refresh(assetsProvider.future);
    }

    List<Asset> tempSelected = List.from(alreadySelected);

    return showDialog<List<Asset>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final assetsAsync = ref.watch(assetsProvider);
            return AlertDialog(
              backgroundColor: AppColors.secondary,
              title: Text(
                'Select Assets',
                style: TextStyle(color: AppColors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: assetsAsync.when(
                  data: (assets) {
                    final availableAssets = assets
                        .where(
                          (a) =>
                              a.status == 'available' ||
                              tempSelected.any((s) => s.id == a.id),
                        )
                        .toList();

                    if (availableAssets.isEmpty) {
                      return Center(
                        child: Text(
                          'No available assets',
                          style: TextStyle(color: AppColors.gray),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: availableAssets.length,
                      itemBuilder: (context, index) {
                        final asset = availableAssets[index];
                        final isSelected = tempSelected.any(
                          (a) => a.id == asset.id,
                        );
                        return CheckboxListTile(
                          title: Text(
                            asset.name,
                            style: TextStyle(color: AppColors.white),
                          ),
                          subtitle: Text(
                            'Code: ${asset.code} - ${asset.status}',
                            style: TextStyle(color: AppColors.gray),
                          ),
                          value: isSelected,
                          activeColor: AppColors.primary,
                          checkColor: AppColors.white,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                tempSelected.add(asset);
                              } else {
                                tempSelected.removeWhere(
                                  (a) => a.id == asset.id,
                                );
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(
                    child: Text(
                      'Error: $e',
                      style: TextStyle(color: AppColors.red),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: Text(
                    'Confirm',
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
                content: SizedBox(
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
                          dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              return AppColors.background;
                            },
                          ),
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
                        onPressed: () async {
                          final selectedAssets =
                              await _showAssetSelectionDialog(context, ref, []);
                          if (selectedAssets != null &&
                              selectedAssets.isNotEmpty) {
                            for (final asset in selectedAssets) {
                              try {
                                await ref
                                    .read(loansProvider.notifier)
                                    .createLoanDetails(
                                      loanId: loan.id,
                                      assetId: asset
                                          .id, // Using asset ID (code or id?) check model. details uses assetId (FK to asset table presumably, or is it code?)
                                      // LoanDetailModel has assetId. LoanService uses `asset_id`.
                                      // AssetModel has String `id`.
                                      // So passing asset.id is correct.
                                      condBorrow: 'good',
                                    );
                              } catch (e) {
                                // ignore individual errors, maybe show toast
                                print('Error adding asset ${asset.name}: $e');
                              }
                            }
                            Navigator.pop(context);
                            _showLoanDetailsDialog(
                              context,
                              ref,
                              loan,
                            ); // Refresh
                            _showSuccessMessage(
                              context,
                              'Assets added to loan',
                            );
                          }
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
          content: SizedBox(
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
