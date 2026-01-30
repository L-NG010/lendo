import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/expandable_card.dart';

class BorrowerOwnSubmissionsScreen extends StatefulWidget {
  const BorrowerOwnSubmissionsScreen({super.key});

  @override
  State<BorrowerOwnSubmissionsScreen> createState() => _BorrowerOwnSubmissionsScreenState();
}

class _BorrowerOwnSubmissionsScreenState extends State<BorrowerOwnSubmissionsScreen> {
  // Mock data for pending submissions based on the provided structure
  final List<Map<String, dynamic>> _pendingSubmissions = [
    {
      'id': '14',
      'loanDate': '2026-01-19',
      'dueDate': '2026-01-20',
      'returnedAt': '2026-01-22',
      'lateDays': 2,
      'createdAt': '2026-01-18 13:50:47.726446+00',
      'status': 'pending',
      'reason': 'Needed for presentation',
      'assets': [
        {
          'id': '5',
          'loan_id': '14',
          'asset_id': '1',
          'cond_borrow': 'good',
          'cond_return': 'minor',
          'asset_name': 'Laptop Dell XPS 13',
          'quantity': 1,
        }
      ]
    },
    {
      'id': '15',
      'loanDate': '2026-01-22',
      'dueDate': '2026-02-05',
      'returnedAt': null,
      'lateDays': 0,
      'createdAt': '2026-01-21 10:30:15.123456+00',
      'status': 'pending',
      'reason': 'For project work',
      'assets': [
        {
          'id': '6',
          'loan_id': '15',
          'asset_id': '3',
          'cond_borrow': 'good',
          'cond_return': null,
          'asset_name': 'Proyektor',
          'quantity': 1,
        },
        {
          'id': '7',
          'loan_id': '15',
          'asset_id': '7',
          'cond_borrow': 'good',
          'cond_return': null,
          'asset_name': 'Kabel HDMI',
          'quantity': 2,
        }
      ]
    },
    {
      'id': '16',
      'loanDate': '2026-01-23',
      'dueDate': '2026-02-10',
      'returnedAt': null,
      'lateDays': 0,
      'createdAt': '2026-01-23 14:20:30.789012+00',
      'status': 'approved',
      'reason': 'Conference preparation',
      'assets': [
        {
          'id': '8',
          'loan_id': '16',
          'asset_id': '12',
          'cond_borrow': 'good',
          'cond_return': null,
          'asset_name': 'Speaker Bluetooth',
          'quantity': 1,
        }
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submissions', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _pendingSubmissions.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  // Simulate refresh
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  itemCount: _pendingSubmissions.length,
                  itemBuilder: (context, index) {
                    final submission = _pendingSubmissions[index];
                    Color statusColor = AppColors.gray;
                    String statusText = 'Unknown';
                    
                    if (submission['status'] == 'pending') {
                      statusColor = AppColors.outline; // Yellow/orange for pending
                      statusText = 'Pending';
                    } else if (submission['status'] == 'approved') {
                      statusColor = AppColors.primary; // Blue for approved
                      statusText = 'Approved';
                    } else if (submission['status'] == 'rejected') {
                      statusColor = AppColors.red; // Red for rejected
                      statusText = 'Rejected';
                    } else if (submission['status'] == 'active') {
                      statusColor = Colors.green; // Green for active loan
                      statusText = 'Active';
                    } else if (submission['status'] == 'returned') {
                      statusColor = Colors.grey; // Grey for returned
                      statusText = 'Returned';
                    }

                    // Create expanded content for the card
                    List<Widget> expandedContent = [
                      _buildDetailRow('Submitted:', submission['createdAt'].split(' ')[0]),
                      _buildDetailRow('Loan Date:', submission['loanDate']),
                      _buildDetailRow('Due Date:', submission['dueDate']),
                      
                      if (submission['reason'] != null && submission['reason'].isNotEmpty)
                        _buildDetailRow('Reason:', submission['reason']),
                      
                      const SizedBox(height: AppSpacing.sm),
                      
                      const Text(
                        'Assets Requested:',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      
                      ...submission['assets'].map<Widget>((asset) {
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
                                '• ${asset['asset_name']}',
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
                      
                      const SizedBox(height: AppSpacing.sm),
                      
                      // Conditional display of return info if the loan has been returned
                      if (submission['returnedAt'] != null)
                        _buildDetailRow('Returned At:', submission['returnedAt'].split(' ')[0]),
                        
                      if (submission['lateDays'] != null && submission['lateDays'] > 0)
                        _buildDetailRow('Late Days:', '${submission['lateDays']} days'),
                    ];

                    return ExpandableCard(
                      title: 'Submission #${submission['id']}',
                      subtitle: 'Status: ${submission['status']}',
                      statusColor: statusColor,
                      statusText: statusText,
                      icon: Icons.assignment,
                      expandedContent: expandedContent,
                      initiallyExpanded: index == 0, // First item expanded by default
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
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No Submissions',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no pending submissions',
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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}