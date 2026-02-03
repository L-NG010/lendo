import 'package:lendo/config/supabase_config.dart';
import 'dart:developer' as dev;

class ReturnService {
  final _supabase = SupabaseConfig.client;

  Future<void> returnLoan({
    required int loanId,
    required List<Map<String, dynamic>> details,
    required String reason,
  }) async {
    try {
      dev.log('Returning loan ID: $loanId', name: 'ReturnService.returnLoan');

      await _supabase.rpc(
        'return_loan',
        params: {
          'p_loan_id': loanId,
          'p_details': details, // JSONB array of {detail_id, cond}
          'p_reason': reason,
        },
      );

      dev.log(
        'Successfully returned loan ID: $loanId',
        name: 'ReturnService.returnLoan',
      );
    } catch (e) {
      dev.log(
        'Error returning loan ID $loanId: $e',
        name: 'ReturnService.returnLoan',
        error: e,
      );
      throw Exception('Failed to return loan: $e');
    }
  }
}
