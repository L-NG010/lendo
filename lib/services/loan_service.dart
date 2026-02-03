import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as dev;
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/models/loan_model.dart';

final loanServiceProvider = Provider<LoanService>((ref) {
  return LoanService();
});

class LoanService {
  final _supabase = SupabaseConfig.client;

  // Get all loans with user information
  Future<List<LoanModel>> getAllLoans() async {
    try {
      dev.log('Fetching all loans...', name: 'LoanService.getAllLoans');

      final response = await _supabase
          .from('loans')
          .select('*')
          .order('id', ascending: false);

      dev.log(
        'Successfully fetched ${response.length} loans',
        name: 'LoanService.getAllLoans',
      );

      return response.map((data) => LoanModel.fromJson(data)).toList();
    } catch (e) {
      dev.log(
        'Error fetching loans: $e',
        name: 'LoanService.getAllLoans',
        error: e,
      );
      throw Exception('Failed to fetch loans: $e');
    }
  }

  // Get loan by ID with details
  Future<LoanModel> getLoanById(String id) async {
    try {
      dev.log('Fetching loan by ID: $id', name: 'LoanService.getLoanById');

      final response = await _supabase
          .from('loans')
          .select('*')
          .eq('id', id)
          .single();

      dev.log(
        'Successfully fetched loan: $id',
        name: 'LoanService.getLoanById',
      );

      return LoanModel.fromJson(response);
    } catch (e) {
      dev.log(
        'Error fetching loan by ID $id: $e',
        name: 'LoanService.getLoanById',
        error: e,
      );
      throw Exception('Failed to fetch loan: $e');
    }
  }

  // Create new loan with loan details
  Future<LoanModel> createLoan({
    required String userId,
    required String status,
    required String dueDate,
    required String loanDate,
    String? reason,
    List<Map<String, dynamic>>? loanDetails,
  }) async {
    try {
      dev.log(
        'Creating new loan for user: $userId, status: $status',
        name: 'LoanService.createLoan',
      );

      // Insert the loan first
      final loanResponse = await _supabase
          .from('loans')
          .insert({
            'user_id': userId,
            'status': status,
            'due_date': dueDate,
            'loan_date': loanDate,
            'reason': reason,
          })
          .select()
          .single();

      final loan = LoanModel.fromJson(loanResponse);

      dev.log(
        'Created loan with ID: ${loan.id}',
        name: 'LoanService.createLoan',
      );

      // If loan details are provided, insert them
      if (loanDetails != null && loanDetails.isNotEmpty) {
        final detailsToInsert = loanDetails.map((detail) {
          return {...detail, 'loan_id': loan.id};
        }).toList();

        dev.log(
          'Inserting ${detailsToInsert.length} loan details for loan: ${loan.id}',
          name: 'LoanService.createLoan',
        );

        await _supabase.from('loan_details').insert(detailsToInsert);
      }

      // Return the complete loan with details
      dev.log(
        'Returning loan with ID: ${loan.id}',
        name: 'LoanService.createLoan',
      );
      return getLoanById(loan.id);
    } catch (e) {
      dev.log(
        'Error creating loan: $e',
        name: 'LoanService.createLoan',
        error: e,
      );
      throw Exception('Failed to create loan: $e');
    }
  }

  // Update loan
  Future<LoanModel> updateLoan({
    required String id,
    String? userId,
    String? status,
    String? dueDate,
    String? returnedAt,
    String? loanDate,
    String? reason,
  }) async {
    try {
      dev.log(
        'Updating loan ID: $id with values: userId=$userId, status=$status, dueDate=$dueDate',
        name: 'LoanService.updateLoan',
      );

      final response = await _supabase
          .from('loans')
          .update({
            if (userId != null) 'user_id': userId,
            if (status != null) 'status': status,
            if (dueDate != null) 'due_date': dueDate,
            if (returnedAt != null) 'returned_at': returnedAt,
            if (loanDate != null) 'loan_date': loanDate,
            if (reason != null) 'reason': reason,
          })
          .eq('id', id)
          .select()
          .single();

      dev.log(
        'Successfully updated loan ID: $id',
        name: 'LoanService.updateLoan',
      );

      return LoanModel.fromJson(response);
    } catch (e) {
      dev.log(
        'Error updating loan ID $id: $e',
        name: 'LoanService.updateLoan',
        error: e,
      );
      throw Exception('Failed to update loan: $e');
    }
  }

  // Update loan details
  Future<void> updateLoanDetails({
    required String loanId,
    required String assetId,
    String? condBorrow,
    String? condReturn,
  }) async {
    try {
      dev.log(
        'Updating loan details for loanId: $loanId, assetId: $assetId',
        name: 'LoanService.updateLoanDetails',
      );

      final response = await _supabase
          .from('loan_details')
          .update({
            if (condBorrow != null) 'cond_borrow': condBorrow,
            if (condReturn != null) 'cond_return': condReturn,
          })
          .eq('loan_id', loanId)
          .eq('asset_id', assetId);

      if (response.error != null) {
        dev.log(
          'Error updating loan details: ${response.error!.message}',
          name: 'LoanService.updateLoanDetails',
          error: response.error!.message,
        );
        throw Exception(
          'Failed to update loan detail: ${response.error!.message}',
        );
      }

      dev.log(
        'Successfully updated loan details for loanId: $loanId, assetId: $assetId',
        name: 'LoanService.updateLoanDetails',
      );
    } catch (e) {
      dev.log(
        'Error updating loan details for loanId: $loanId, assetId: $assetId: $e',
        name: 'LoanService.updateLoanDetails',
        error: e,
      );
      throw Exception('Failed to update loan detail: $e');
    }
  }

  // Create loan details
  Future<void> createLoanDetails({
    required String loanId,
    required String assetId,
    String? condBorrow,
    String? condReturn,
  }) async {
    try {
      dev.log(
        'Creating loan details for loanId: $loanId, assetId: $assetId',
        name: 'LoanService.createLoanDetails',
      );

      final response = await _supabase.from('loan_details').insert({
        'loan_id': loanId,
        'asset_id': assetId,
        'cond_borrow': condBorrow ?? 'good',
        'cond_return': condReturn,
      });

      if (response.error != null) {
        dev.log(
          'Error creating loan details: ${response.error!.message}',
          name: 'LoanService.createLoanDetails',
          error: response.error!.message,
        );
        throw Exception(
          'Failed to create loan detail: ${response.error!.message}',
        );
      }

      dev.log(
        'Successfully created loan details for loanId: $loanId, assetId: $assetId',
        name: 'LoanService.createLoanDetails',
      );
    } catch (e) {
      dev.log(
        'Error creating loan details for loanId: $loanId, assetId: $assetId: $e',
        name: 'LoanService.createLoanDetails',
        error: e,
      );
      throw Exception('Failed to create loan detail: $e');
    }
  }

  // Delete loan details
  Future<void> deleteLoanDetails({
    required String loanId,
    required String assetId,
  }) async {
    try {
      dev.log(
        'Deleting loan details for loanId: $loanId, assetId: $assetId',
        name: 'LoanService.deleteLoanDetails',
      );

      final response = await _supabase
          .from('loan_details')
          .delete()
          .eq('loan_id', loanId)
          .eq('asset_id', assetId);

      if (response.error != null) {
        dev.log(
          'Error deleting loan details: ${response.error!.message}',
          name: 'LoanService.deleteLoanDetails',
          error: response.error!.message,
        );
        throw Exception(
          'Failed to delete loan detail: ${response.error!.message}',
        );
      }

      dev.log(
        'Successfully deleted loan details for loanId: $loanId, assetId: $assetId',
        name: 'LoanService.deleteLoanDetails',
      );
    } catch (e) {
      dev.log(
        'Error deleting loan details for loanId: $loanId, assetId: $assetId: $e',
        name: 'LoanService.deleteLoanDetails',
        error: e,
      );
      throw Exception('Failed to delete loan detail: $e');
    }
  }

  // Mark loan as returned and update return dates
  Future<LoanModel> markLoanReturned({
    required String id,
    String? returnedAt,
  }) async {
    try {
      dev.log(
        'Marking loan as returned: $id',
        name: 'LoanService.markLoanReturned',
      );

      final response = await _supabase
          .from('loans')
          .update({
            'status': 'returned',
            'returned_at':
                returnedAt ?? DateTime.now().toIso8601String().split('T')[0],
          })
          .eq('id', id)
          .select()
          .single();

      dev.log(
        'Successfully marked loan as returned: $id',
        name: 'LoanService.markLoanReturned',
      );

      return LoanModel.fromJson(response);
    } catch (e) {
      dev.log(
        'Error marking loan as returned $id: $e',
        name: 'LoanService.markLoanReturned',
        error: e,
      );
      throw Exception('Failed to mark loan as returned: $e');
    }
  }

  // Delete loan
  Future<void> deleteLoan(String id) async {
    try {
      dev.log('Deleting loan ID: $id', name: 'LoanService.deleteLoan');

      // Delete loan details first (due to foreign key constraint)
      await _supabase.from('loan_details').delete().eq('loan_id', id);

      // Then delete the loan itself
      await _supabase.from('loans').delete().eq('id', id);

      dev.log(
        'Successfully deleted loan ID: $id',
        name: 'LoanService.deleteLoan',
      );
    } catch (e) {
      dev.log(
        'Error deleting loan ID $id: $e',
        name: 'LoanService.deleteLoan',
        error: e,
      );
      throw Exception('Failed to delete loan: $e');
    }
  }

  // Search loans
  Future<List<LoanModel>> searchLoans(String query) async {
    try {
      dev.log(
        'Searching loans with query: $query',
        name: 'LoanService.searchLoans',
      );

      final response = await _supabase
          .from('loans')
          .select('*')
          .ilike('id', '%$query%')
          .order('id', ascending: false);

      dev.log(
        'Search returned ${response.length} results for query: $query',
        name: 'LoanService.searchLoans',
      );

      return response.map((data) => LoanModel.fromJson(data)).toList();
    } catch (e) {
      dev.log(
        'Error searching loans with query $query: $e',
        name: 'LoanService.searchLoans',
        error: e,
      );
      throw Exception('Failed to search loans: $e');
    }
  }

  // Filter loans by status
  Future<List<LoanModel>> getLoansByStatus(String status) async {
    try {
      dev.log(
        'Getting loans by status: $status',
        name: 'LoanService.getLoansByStatus',
      );

      final response = await _supabase
          .from('loans')
          .select('*')
          .eq('status', status)
          .order('id', ascending: false);

      dev.log(
        'Retrieved ${response.length} loans with status: $status',
        name: 'LoanService.getLoansByStatus',
      );

      return response.map((data) => LoanModel.fromJson(data)).toList();
    } catch (e) {
      dev.log(
        'Error getting loans by status $status: $e',
        name: 'LoanService.getLoansByStatus',
        error: e,
      );
      throw Exception('Failed to filter loans: $e');
    }
  }

  // Get loan details for a specific loan
  Future<List<LoanDetailModel>> getLoanDetails(String loanId) async {
    try {
      dev.log(
        'Fetching loan details for loan ID: $loanId',
        name: 'LoanService.getLoanDetails',
      );

      final response = await _supabase
          .from('loan_details')
          .select('*, assets(name)')
          .eq('loan_id', loanId)
          .order('id', ascending: false);

      dev.log(
        'Retrieved ${response.length} loan details for loan ID: $loanId',
        name: 'LoanService.getLoanDetails',
      );

      return response.map((data) => LoanDetailModel.fromJson(data)).toList();
    } catch (e) {
      dev.log(
        'Error fetching loan details for loan ID $loanId: $e',
        name: 'LoanService.getLoanDetails',
        error: e,
      );
      throw Exception('Failed to fetch loan details: $e');
    }
  }

  // Get pending loans for current user
  Future<List<LoanModel>> getPendingLoansForUser(String userId) async {
    try {
      dev.log(
        'Fetching pending loans for user ID: $userId',
        name: 'LoanService.getPendingLoansForUser',
      );

      final response = await _supabase
          .from('loans')
          .select('*, loan_details(*, assets(name))')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      dev.log(
        'Retrieved ${response.length} pending loans for user ID: $userId',
        name: 'LoanService.getPendingLoansForUser',
      );

      return response.map((data) => LoanModel.fromJson(data)).toList();
    } catch (e) {
      dev.log(
        'Error fetching pending loans for user ID $userId: $e',
        name: 'LoanService.getPendingLoansForUser',
        error: e,
      );
      throw Exception('Failed to fetch pending loans: $e');
    }
  }

  // Get all loans for current user (pending, approved, etc.)
  Future<List<Map<String, dynamic>>> getLoansForUserWithDetails(
    String userId,
  ) async {
    try {
      dev.log(
        'Fetching all loans with details for user ID: $userId',
        name: 'LoanService.getLoansForUserWithDetails',
      );

      final response = await _supabase
          .from('loans')
          .select('*, loan_details(*, assets(name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      dev.log(
        'Retrieved ${response.length} loans for user ID: $userId',
        name: 'LoanService.getLoansForUserWithDetails',
      );

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      dev.log(
        'Error fetching loans for user ID $userId: $e',
        name: 'LoanService.getLoansForUserWithDetails',
        error: e,
      );
      throw Exception('Failed to fetch loans: $e');
    }
  }

  // Get all loans for current user (pending, approved, etc.)
  Future<List<LoanModel>> getLoansForUser(String userId) async {
    try {
      dev.log(
        'Fetching all loans for user ID: $userId',
        name: 'LoanService.getLoansForUser',
      );

      final response = await _supabase
          .from('loans')
          .select('*, loan_details(*, assets(name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      dev.log(
        'Retrieved ${response.length} loans for user ID: $userId',
        name: 'LoanService.getLoansForUser',
      );

      return response.map((data) => LoanModel.fromJson(data)).toList();
    } catch (e) {
      dev.log(
        'Error fetching loans for user ID $userId: $e',
        name: 'LoanService.getLoansForUser',
        error: e,
      );
      throw Exception('Failed to fetch loans: $e');
    }
  }
}
