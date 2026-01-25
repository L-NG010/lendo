import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/loan_card.dart';

class LoanManagementScreen extends ConsumerWidget {
  const LoanManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample loan data based on your INSERT statement
    final loans = [
      LoanModel(
        id: '14',
        userId: 'c691fc60-2e5d-46d4-af6d-e2e9594048e6',
        status: 'pending',
        dueDate: '2026-01-20',
        returnedAt: '2026-01-22',
        lateDays: '2',
        createdAt: '2026-01-18 13:50:47.726446+00',
        loanDate: '2026-01-19',
        reason: null,
      ),
      LoanModel(
        id: '15',
        userId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        status: 'approved',
        dueDate: '2026-01-25',
        returnedAt: null,
        lateDays: null,
        createdAt: '2026-01-20 09:30:15.123456+00',
        loanDate: '2026-01-21',
        reason: 'Project presentation',
      ),
      LoanModel(
        id: '16',
        userId: 'f7g8h9i0-j1k2-3456-lmno-pq7890123456',
        status: 'returned',
        dueDate: '2026-01-15',
        returnedAt: '2026-01-14',
        lateDays: '0',
        createdAt: '2026-01-10 14:22:33.456789+00',
        loanDate: '2026-01-11',
        reason: 'Team meeting',
      ),
      LoanModel(
        id: '17',
        userId: 'b2c3d4e5-f6g7-8901-hijk-lm9012345678',
        status: 'rejected',
        dueDate: '2026-01-30',
        returnedAt: null,
        lateDays: null,
        createdAt: '2026-01-22 11:45:22.789012+00',
        loanDate: '2026-01-23',
        reason: 'Insufficient budget',
      ),
    ];

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
              _showAddLoanDialog(context);
            },
          ),
        ],
      ),
      drawer: const CustomSidebar(),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
                    ),
                  ),
                ),
                // Status filter dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: DropdownButton<String>(
                      value: 'All',
                      underline: Container(),
                      isExpanded: true,
                      hint: Text('Filter', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                      items: ['All', 'pending', 'approved', 'returned', 'rejected'].map((String status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status, style: TextStyle(color: AppColors.white, fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Handle status change
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  final loan = loans[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: LoanCard(
                      loan: loan,
                      onEdit: () => _showUpdateDialog(context, loan),
                      onDelete: () => _showDeleteDialog(context, loan),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLoanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Add New Loan',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddField('User ID:', ''),
                _buildAddField('Status:', ''),
                _buildAddField('Due Date:', ''),
                _buildAddField('Loan Date:', ''),
                _buildAddField('Reason:', ''),
              ],
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
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessMessage(context, 'Loan added successfully');
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
  }

  Widget _buildAddField(String label, String value) {
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
              border: Border.all(
                color: AppColors.outline,
                width: 1,
              ),
            ),
            child: TextFormField(
              initialValue: value.isEmpty ? '' : value,
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

  void _showUpdateDialog(BuildContext context, LoanModel loan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Update Loan',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddField('User ID:', loan.userId),
                _buildAddField('Status:', loan.status),
                _buildAddField('Due Date:', _formatDate(loan.dueDate)),
                _buildAddField('Loan Date:', _formatDate(loan.loanDate)),
                _buildAddField('Reason:', loan.reason ?? ''),
              ],
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
              onPressed: () {
                Navigator.of(context).pop();
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
  }

  void _showDeleteDialog(BuildContext context, LoanModel loan) {
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
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform delete action
                Navigator.of(context).pop(); // Close dialog
                _showSuccessMessage(context, 'Loan #${loan.id} deleted successfully');
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
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