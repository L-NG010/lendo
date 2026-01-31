import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/loan_model.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/config/supabase_config.dart';

class LoanCard extends StatefulWidget {
  final LoanModel loan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExpand;
  final Future<List<LoanDetailModel>> Function(String loanId) onLoadDetails;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onEdit,
    required this.onDelete,
    required this.onExpand,
    required this.onLoadDetails,
  });

  @override
  State<LoanCard> createState() => _LoanCardState();
}

class _LoanCardState extends State<LoanCard> {
  bool _isExpanded = false;
  final _supabase = SupabaseConfig.client;
  
  Future<List<LoanDetailModel>> _loadLoanDetails() async {
    return await widget.onLoadDetails(widget.loan.id);
  }
  
  Future<Asset?> _loadAsset(String assetId) async {
    try {
      final response = await _supabase
          .from('assets')
          .select()
          .eq('id', assetId)
          .single();
      
      return Asset.fromJson(response);
    } catch (e) {
      print('Error loading asset $assetId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.loan.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getLoanIcon(widget.loan.status),
            color: _getStatusColor(widget.loan.status),
            size: 18,
          ),
        ),
        title: Text(
          _getStatusText(widget.loan.status),
          style: TextStyle(
            color: _getStatusColor(widget.loan.status),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Loan #${widget.loan.id} - Due: ${_formatDate(widget.loan.dueDate)}',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 12,
          ),
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
            if (_isExpanded) {
              widget.onExpand();
            }
          });
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary, size: 18),
              onPressed: widget.onEdit,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size(32, 32)),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.red, size: 18),
              onPressed: widget.onDelete,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size(32, 32)),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FutureBuilder<List<LoanDetailModel>>(
              future: _loadLoanDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Loading assets...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No assets borrowed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  );
                } else {
                  final details = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Borrowed Assets:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...details.map((detail) => _buildAssetCard(detail)).toList(),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(LoanDetailModel detail) {
    return FutureBuilder<Asset?> (
      future: _loadAsset(detail.assetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline.withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                ),
                SizedBox(width: AppSpacing.sm),
                Text('Loading asset...', style: TextStyle(color: AppColors.gray, fontSize: 12)),
              ],
            ),
          );
        }
        
        final asset = snapshot.data;
        final assetName = asset?.name ?? 'Asset ${detail.assetId}';
        final assetCode = asset?.code ?? detail.assetId;
        final imageUrl = asset?.pictureUrl;
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              // Asset Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, color: AppColors.gray, size: 24);
                          },
                        ),
                      )
                    : const Icon(Icons.image, color: AppColors.gray, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assetName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: $assetCode',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              // Conditions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Borrow: ${detail.condBorrow}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (detail.condReturn != null)
                    const SizedBox(height: 4),
                  if (detail.condReturn != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Return: ${detail.condReturn}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'returned':
        return 'Returned';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.outline;
      case 'approved':
        return AppColors.primary;
      case 'rejected':
        return Colors.red;
      case 'returned':
        return Colors.green;
      default:
        return AppColors.gray;
    }
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