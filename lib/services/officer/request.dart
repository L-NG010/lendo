import 'package:lendo/config/supabase_config.dart';
import 'dart:developer' as dev;

class OfficerRequestService {
  final _supabase = SupabaseConfig.client;

  Future<void> rejectLoan({required int loanId, required String reason}) async {
    try {
      dev.log(
        'Rejecting loan ID: $loanId',
        name: 'OfficerRequestService.rejectLoan',
      );

      await _supabase.rpc(
        'reject_loan',
        params: {'p_loan_id': loanId, 'p_officer_reason': reason},
      );

      dev.log(
        'Successfully rejected loan ID: $loanId',
        name: 'OfficerRequestService.rejectLoan',
      );
    } catch (e) {
      dev.log(
        'Error rejecting loan ID $loanId: $e',
        name: 'OfficerRequestService.rejectLoan',
        error: e,
      );
      throw Exception('Failed to reject loan: $e');
    }
  }

  Future<void> rejectReturn({required int loanId}) async {
    try {
      dev.log(
        'Rejecting return for loan ID: $loanId',
        name: 'OfficerRequestService.rejectReturn',
      );

      await _supabase.rpc('reject_return', params: {'p_loan_id': loanId});

      dev.log(
        'Successfully rejected return for loan ID: $loanId',
        name: 'OfficerRequestService.rejectReturn',
      );
    } catch (e) {
      dev.log(
        'Error rejecting return for loan ID $loanId: $e',
        name: 'OfficerRequestService.rejectReturn',
        error: e,
      );
      throw Exception('Failed to reject return: $e');
    }
  }

  Future<void> approveLoan({required int loanId}) async {
    try {
      dev.log(
        'Approving loan ID: $loanId',
        name: 'OfficerRequestService.approveLoan',
      );

      await _supabase.rpc('approve_loan', params: {'p_loan_id': loanId});

      dev.log(
        'Successfully approved loan ID: $loanId',
        name: 'OfficerRequestService.approveLoan',
      );
    } catch (e) {
      dev.log(
        'Error approving loan ID $loanId: $e',
        name: 'OfficerRequestService.approveLoan',
        error: e,
      );
      throw Exception('Failed to approve loan: $e');
    }
  }

  Future<void> approveReturn({required int loanId}) async {
    try {
      dev.log(
        'Approving return for loan ID: $loanId',
        name: 'OfficerRequestService.approveReturn',
      );

      await _supabase.rpc('approve_return', params: {'p_loan_id': loanId});

      dev.log(
        'Successfully approved return for loan ID: $loanId',
        name: 'OfficerRequestService.approveReturn',
      );
    } catch (e) {
      dev.log(
        'Error approving return for loan ID $loanId: $e',
        name: 'OfficerRequestService.approveReturn',
        error: e,
      );
      throw Exception('Failed to approve return: $e');
    }
  }
}
