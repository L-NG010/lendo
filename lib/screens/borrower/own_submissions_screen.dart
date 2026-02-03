import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/borrower/expandable_card.dart';
import 'package:lendo/services/auth_service.dart';
import 'package:lendo/services/loan_service.dart';

class BorrowerOwnSubmissionsScreen extends ConsumerStatefulWidget {
  const BorrowerOwnSubmissionsScreen({super.key});

  @override
  ConsumerState<BorrowerOwnSubmissionsScreen> createState() =>
      _BorrowerOwnSubmissionsScreenState();
}

class _BorrowerOwnSubmissionsScreenState
    extends ConsumerState<BorrowerOwnSubmissionsScreen> {
  late final AuthService _authService;
  late final LoanService _loanService;

  @override
  void initState() {
    super.initState();
    _authService = ref.read(authServicePod);
    _loanService = ref.read(loanServiceProvider);
  }

  Future<List<Map<String, dynamic>>> _fetchUserLoans() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return [];

    try {
      final allLoans = await _loanService.getLoansForUserWithDetails(
        currentUser.id,
      );
      // Filter to only show pending loans
      return allLoans.where((loan) => loan['status'] == 'pending').toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Submissions',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchUserLoans(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading submissions',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            }

            final submissions = snapshot.data ?? [];

            if (submissions.isEmpty) return _buildEmptyState();

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView.builder(
                itemCount: submissions.length,
                itemBuilder: (context, index) {
                  final submission = submissions[index];

                  Color statusColor = AppColors.gray;
                  String statusText = submission['status'] ?? 'Unknown';

                  switch (statusText) {
                    case 'pending':
                      statusColor = AppColors.outline;
                      break;
                    case 'approved':
                      statusColor = AppColors.primary;
                      break;
                    case 'rejected':
                      statusColor = AppColors.red;
                      break;
                    case 'active':
                      statusColor = Colors.green;
                      break;
                    case 'returned':
                      statusColor = Colors.grey;
                      break;
                  }

                  final loanDetails =
                      submission['loan_details'] as List<dynamic>? ?? [];

                  final expandedContent = <Widget>[
                    _buildDetailRow(
                      'Submitted:',
                      submission['created_at']?.toString(),
                    ),
                    _buildDetailRow(
                      'Loan Date:',
                      submission['loan_date']?.toString(),
                    ),
                    _buildDetailRow(
                      'Due Date:',
                      submission['due_date']?.toString(),
                    ),
                    if (submission['reason'] != null &&
                        submission['reason'].toString().isNotEmpty)
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
                    ...loanDetails.map((detailData) {
                      final asset = detailData['assets'];
                      final assetName =
                          asset?['name']?.toString() ?? 'Unknown Asset';

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '• $assetName',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'x1',
                              style: TextStyle(
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
                    title: 'Submission #${submission['id']}',
                    subtitle: 'Status: $statusText',
                    statusColor: statusColor,
                    statusText: statusText,
                    icon: Icons.assignment,
                    expandedContent: expandedContent,
                    initiallyExpanded: index == 0,
                  );
                },
              ),
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
        children: const [
          Icon(Icons.assignment_outlined, size: 64, color: AppColors.gray),
          SizedBox(height: 16),
          Text(
            'No Submissions',
            style: TextStyle(fontSize: 18, color: AppColors.gray),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
