import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getLoanIcon(loan.status),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan #${loan.id}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'User ID: ${loan.userId.substring(0, 8)}...',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.primary, size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(Size(32, 32)),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppColors.red, size: 18),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints.tight(Size(32, 32)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildStatusRow('Status:', loan.status)),
              Expanded(child: _buildDateRow('Due Date:', loan.dueDate)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildDateRow('Loan Date:', loan.loanDate)),
              if (loan.lateDays != null && loan.lateDays != '0') Expanded(child: _buildLateDaysRow('Late Days:', loan.lateDays!)),
            ],
          ),
          if (loan.reason != null) _buildDetailRow('Reason:', loan.reason!),
        ],
      ),
    );
  }

  IconData _getLoanIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'returned':
        return Icons.restore;
      default:
        return Icons.help;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    Color statusColor = AppColors.gray;
    if (status.toLowerCase() == 'pending') {
      statusColor = AppColors.outline;
    } else if (status.toLowerCase() == 'approved') {
      statusColor = AppColors.primary;
    } else if (status.toLowerCase() == 'rejected') {
      statusColor = Colors.red;
    } else if (status.toLowerCase() == 'returned') {
      statusColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLateDaysRow(String label, String days) {
    Color lateColor = AppColors.outline;
    if (int.tryParse(days) != null && int.parse(days) > 3) {
      lateColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: lateColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: lateColor, width: 1),
            ),
            child: Text(
              '$days days',
              style: TextStyle(
                fontSize: 11,
                color: lateColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      // Handle different date formats
      if (dateString.contains(' ')) {
        // Full datetime format
        return dateString.split(' ')[0];
      } else if (dateString.contains('T')) {
        // ISO format
        return dateString.split('T')[0];
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }
}