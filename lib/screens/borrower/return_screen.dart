import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/return_card.dart';

class BorrowerReturnScreen extends StatefulWidget {
  const BorrowerReturnScreen({super.key});

  @override
  State<BorrowerReturnScreen> createState() => _BorrowerReturnScreenState();
}

class _BorrowerReturnScreenState extends State<BorrowerReturnScreen> {
  // Mock data for approved loans
  final List<Map<String, dynamic>> _approvedLoans = [
    {
      'id': '1',
      'loanDate': '2026-01-20',
      'dueDate': '2026-02-20',
      'status': 'active',
      'assets': [
        {
          'id': '1',
          'name': 'Laptop Dell XPS 13',
          'condition_borrow': 'good',
        },
        {
          'id': '2',
          'name': 'Mouse Wireless',
          'condition_borrow': 'good',
        }
      ]
    },
    {
      'id': '2',
      'loanDate': '2026-01-15',
      'dueDate': '2026-02-15',
      'status': 'active',
      'assets': [
        {
          'id': '3',
          'name': 'Proyektor',
          'condition_borrow': 'good',
        }
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Items', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _approvedLoans.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  // Simulate refresh
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  itemCount: _approvedLoans.length,
                  itemBuilder: (context, index) {
                    final loan = _approvedLoans[index];
                    return ReturnCard(
                      loan: loan,
                      onConfirmReturn: (loan, conditions, reason) {
                        _showConfirmationDialog(loan, conditions, reason);
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Loans',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no active loans to return',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(Map<String, dynamic> loan, Map<String, String> conditions, String reason) {
    // Collect all asset return conditions for this loan
    List<Map<String, dynamic>> returnAssets = [];
    
    for (var asset in loan['assets']) {
      String key = '${loan['id']}_${asset['id']}';
      String condition = conditions[key] ?? 'good';
      
      returnAssets.add({
        'id': asset['id'],
        'name': asset['name'],
        'borrow_condition': asset['condition_borrow'],
        'return_condition': condition,
      });
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Return'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to return these items?'),
              const SizedBox(height: AppSpacing.sm),
              ...returnAssets.map((asset) => 
                Text(
                  '- ${asset['name']}: ${asset['return_condition']}',
                  style: const TextStyle(fontSize: 14),
                )
              ).toList(),
              if (reason.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Reason: $reason',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform return action here
                Navigator.of(context).pop();
                _showSuccessDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Successful'),
          content: const Text('Your items have been marked for return. Staff will review them shortly.'),
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