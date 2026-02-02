import 'package:supabase_flutter/supabase_flutter.dart';

class LoanService {
  final SupabaseClient client;

  LoanService(this.client);

  Future<void> addLoan({
    required String userId,
    required DateTime loanDate,
    required DateTime dueDate,
    required String reason,
    required List<int> assetIds,
  }) async {
    if (assetIds.isEmpty) throw Exception('Tidak ada asset untuk dipinjam');
    try {
      await client.rpc('add_loan', params: {
        'p_user_id': userId,
        'p_loan_date': loanDate.toIso8601String(),
        'p_due_date': dueDate.toIso8601String(),
        'p_reason': reason,
        'p_asset_ids': assetIds,
      });
    } catch (e) {
      throw Exception('Gagal menambah pinjaman: $e');
    }
  }
}
