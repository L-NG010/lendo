import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/officer_sidebar.dart';

class OfficerReturnScreen extends StatelessWidget {
  const OfficerReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for return confirmations
    final List<Map<String, dynamic>> returnRequests = [
      {
        'id': '1',
        'loan_code': 'LN001',
        'borrower': 'John Doe',
        'assets': [
          {
            'name': 'Laptop Dell XPS',
            'condition_borrow': 'good',
            'condition_return': 'minor damage',
            'return_notes': 'Scratch on the lid'
          },
          {
            'name': 'Mouse Wireless',
            'condition_borrow': 'good',
            'condition_return': 'good',
            'return_notes': ''
          },
        ],
        'return_date': '2024-01-30',
        'request_date': '2024-01-29',
        'status': 'pending',
        'late_days': 0,
      },
      {
        'id': '2',
        'loan_code': 'LN003',
        'borrower': 'Alice Johnson',
        'assets': [
          {
            'name': 'Projector HD',
            'condition_borrow': 'good',
            'condition_return': 'major damage',
            'return_notes': 'Broken lens cover'
          },
        ],
        'return_date': '2024-01-20',
        'request_date': '2024-01-20',
        'status': 'pending',
        'late_days': 0,
      },
      {
        'id': '3',
        'loan_code': 'LN004',
        'borrower': 'Bob Wilson',
        'assets': [
          {
            'name': 'Camera DSLR',
            'condition_borrow': 'good',
            'condition_return': 'good',
            'return_notes': ''
          },
        ],
        'return_date': '2024-01-15',
        'actual_return_date': '2024-01-16',
        'request_date': '2024-01-16',
        'status': 'confirmed',
        'late_days': 1,
        'fine_amount': 50000,
      },
    ];

    return Scaffold(
      drawer: const OfficerSidebar(),
      appBar: AppBar(
        title: const Text('Pengembalian'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        leading: Builder(
          builder: (context) => 
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: returnRequests.length,
                itemBuilder: (context, index) {
                  final returnRequest = returnRequests[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: returnRequest['status'] == 'confirmed' 
                          ? AppColors.gray.withOpacity(0.5) 
                          : AppColors.outline,
                        width: returnRequest['status'] == 'confirmed' ? 2 : 1,
                      ),
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kode Pinjam: ${returnRequest['loan_code']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Peminjam: ${returnRequest['borrower']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: returnRequest['status'] == 'confirmed' 
                                ? AppColors.red.withOpacity(0.2)
                                : AppColors.outline.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              returnRequest['status'] == 'confirmed' 
                                ? 'Denda' 
                                : 'Perlu Konfirmasi',
                              style: TextStyle(
                                fontSize: 12,
                                color: returnRequest['status'] == 'confirmed' 
                                  ? AppColors.red 
                                  : AppColors.gray,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md, 
                            0, 
                            AppSpacing.md, 
                            AppSpacing.md
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aset yang Dikembalikan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...returnRequest['assets'].map<Widget>((asset) => 
                                _buildAssetCard(asset)
                              ).toList(),
                              
                              const SizedBox(height: AppSpacing.md),
                              
                              // Late return information
                              if (returnRequest['late_days'] > 0) ...[
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: AppColors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Terlambat ${returnRequest['late_days']} hari - Denda: Rp ${returnRequest['fine_amount']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              
                              // Action buttons
                              if (returnRequest['status'] == 'pending') ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Confirm return logic here
                                          _showReturnConfirmation(context, returnRequest, true);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: const Text(
                                          'Konfirmasi',
                                          style: TextStyle(color: AppColors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // Reject return logic here
                                          _showReturnConfirmation(context, returnRequest, false);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: AppColors.red),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        child: Text(
                                          'Tolak',
                                          style: TextStyle(color: AppColors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                // Match the width of the late return info container above
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Payment confirmation logic here
                                      _showPaymentConfirmation(context, returnRequest);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Konfirmasi Pembayaran',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            asset['name'],
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kondisi Saat Pinjam:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      asset['condition_borrow'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.outline.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kondisi Saat Kembali:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      asset['condition_return'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (asset['return_notes'].isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppColors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Catatan: ${asset['return_notes']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReturnConfirmation(BuildContext context, Map<String, dynamic> returnRequest, bool confirmed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(confirmed ? 'Konfirmasi Pengembalian' : 'Tolak Pengembalian'),
          content: Text(
            'Apakah Anda yakin ingin ${confirmed ? 'mengonfirmasi' : 'menolak'} pengembalian untuk kode pinjam ${returnRequest['loan_code']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Perform confirmation/rejection action
                Navigator.of(context).pop();
                _showResultDialog(context, confirmed);
              },
              child: Text(confirmed ? 'Konfirmasi' : 'Tolak'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentConfirmation(BuildContext context, Map<String, dynamic> returnRequest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Text(
            'Apakah Anda yakin ingin mengonfirmasi pembayaran denda untuk kode pinjam ${returnRequest['loan_code']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Perform payment confirmation action
                Navigator.of(context).pop();
                _showPaymentResultDialog(context);
              },
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, bool confirmed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(confirmed ? 'Berhasil Dikonfirmasi' : 'Berhasil Ditolak'),
          content: Text(
            'Pengembalian telah ${confirmed ? 'dikonfirmasi' : 'ditolak'}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pembayaran Dikonfirmasi'),
          content: const Text('Pembayaran denda telah dikonfirmasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}