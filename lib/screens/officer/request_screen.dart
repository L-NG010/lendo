import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/officer_sidebar.dart';

class OfficerRequestScreen extends StatelessWidget {
  const OfficerRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for pending loan requests
    final List<Map<String, dynamic>> pendingRequests = [
      {
        'id': '1',
        'loan_code': 'LN001',
        'borrower': 'John Doe',
        'assets': [
          {'name': 'Laptop Dell XPS', 'quantity': 1},
          {'name': 'Mouse Wireless', 'quantity': 1},
        ],
        'request_date': '2024-01-15',
        'pickup_date': '2024-01-16',
        'return_date': '2024-01-30',
        'reason': 'Project work',
      },
      {
        'id': '2',
        'loan_code': 'LN002',
        'borrower': 'Jane Smith',
        'assets': [
          {'name': 'Projector HD', 'quantity': 1},
        ],
        'request_date': '2024-01-15',
        'pickup_date': '2024-01-17',
        'return_date': '2024-01-20',
        'reason': 'Meeting presentation',
      },
    ];

    return Scaffold(
      drawer: const OfficerSidebar(),
      appBar: AppBar(
        title: const Text('Pengajuan'),
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
                itemCount: pendingRequests.length,
                itemBuilder: (context, index) {
                  final request = pendingRequests[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kode: ${request['loan_code']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Peminjam: ${request['borrower']}',
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
                              color: AppColors.outline.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Menunggu',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...request['assets'].map<Widget>((asset) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${asset['name']} (${asset['quantity']} buah)',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Alasan: ${request['reason']}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                  color: AppColors.gray,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Ambil: ${request['pickup_date']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Kembali: ${request['return_date']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Approve logic here
                                        _showApprovalConfirmation(context, request, true);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        'Setujui',
                                        style: TextStyle(color: AppColors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // Reject logic here
                                        _showApprovalConfirmation(context, request, false);
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

  void _showApprovalConfirmation(BuildContext context, Map<String, dynamic> request, bool approved) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(approved ? 'Konfirmasi Persetujuan' : 'Konfirmasi Penolakan'),
          content: Text(
            'Apakah Anda yakin ingin ${approved ? 'menyetujui' : 'menolak'} pengajuan pinjaman kode ${request['loan_code']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Perform approval/rejection action
                Navigator.of(context).pop();
                _showResultDialog(context, approved);
              },
              child: Text(approved ? 'Setujui' : 'Tolak'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, bool approved) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(approved ? 'Berhasil Disetujui' : 'Berhasil Ditolak'),
          content: Text(
            'Pengajuan telah ${approved ? 'disetujui' : 'ditolak'}.',
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
}