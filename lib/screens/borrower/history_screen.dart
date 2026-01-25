import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/expandable_card.dart';

class BorrowerHistoryScreen extends StatefulWidget {
  const BorrowerHistoryScreen({super.key});

  @override
  State<BorrowerHistoryScreen> createState() => _BorrowerHistoryScreenState();
}

class _BorrowerHistoryScreenState extends State<BorrowerHistoryScreen> {
  // Mock data for loan history
  final List<Map<String, dynamic>> _loanHistory = [
    {
      'id': '1',
      'loanDate': '2026-01-20',
      'dueDate': '2026-02-20',
      'returnedDate': null,
      'status': 'active',
      'assets': [
        {'name': 'Laptop Dell XPS 13', 'quantity': 1},
        {'name': 'Mouse Wireless', 'quantity': 1},
      ]
    },
    {
      'id': '2',
      'loanDate': '2026-01-15',
      'dueDate': '2026-01-25',
      'returnedDate': '2026-01-24',
      'status': 'returned',
      'assets': [
        {'name': 'Proyektor', 'quantity': 1},
      ]
    },
    {
      'id': '3',
      'loanDate': '2026-01-10',
      'dueDate': '2026-01-20',
      'returnedDate': '2026-01-19',
      'status': 'returned',
      'assets': [
        {'name': 'Kabel HDMI', 'quantity': 2},
      ]
    },
    {
      'id': '4',
      'loanDate': '2026-01-05',
      'dueDate': '2026-01-15',
      'returnedDate': '2026-01-14',
      'status': 'returned',
      'assets': [
        {'name': 'Speaker Bluetooth', 'quantity': 1},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan History', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _loanHistory.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: _loanHistory.length,
                itemBuilder: (context, index) {
                  final loan = _loanHistory[index];
                  Color statusColor = AppColors.gray;
                  String statusText = 'Unknown';
                  
                  if (loan['status'] == 'active') {
                    statusColor = AppColors.primary;
                    statusText = 'Active';
                  } else if (loan['status'] == 'returned') {
                    statusColor = Colors.green;
                    statusText = 'Returned';
                  } else if (loan['status'] == 'overdue') {
                    statusColor = AppColors.red;
                    statusText = 'Overdue';
                  }

                  // Create expanded content for the card
                  List<Widget> expandedContent = [
                    _buildDetailRow('Loan Date:', loan['loanDate']),
                    _buildDetailRow('Due Date:', loan['dueDate']),
                    if (loan['returnedDate'] != null) 
                      _buildDetailRow('Returned Date:', loan['returnedDate']),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    const Text(
                      'Assets Borrowed:',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    ...loan['assets'].map<Widget>((asset) {
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
                            Text(
                              '• ${asset['name']}',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'x${asset['quantity']}',
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ];

                  return ExpandableCard(
                    title: 'Loan #${loan['id']}',
                    subtitle: 'Status: ${loan['status']}',
                    statusColor: statusColor,
                    statusText: statusText,
                    icon: Icons.history,
                    expandedContent: expandedContent,
                    initiallyExpanded: index == 0, // First item expanded by default
                  );
                },
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
            Icons.history_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No History',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no loan history yet',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray.withOpacity(0.7),
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
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}