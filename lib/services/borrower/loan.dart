import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

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
    // Log input parameters
    print('=== LOAN SUBMISSION START ===');
    print('User ID: $userId');
    print('Loan Date: ${loanDate.toIso8601String()}');
    print('Due Date: ${dueDate.toIso8601String()}');
    print('Reason: $reason');
    print('Asset IDs: $assetIds');
    
    // Validasi input
    if (userId.isEmpty) {
      print('ERROR: User ID kosong');
      throw Exception('User ID tidak boleh kosong');
    }
    if (assetIds.isEmpty) {
      print('ERROR: Tidak ada asset');
      throw Exception('Tidak ada asset untuk dipinjam');
    }
    
    print('Starting RPC call...');
    
    try {
      print('Calling add_loan RPC function...');
      final response = await client.rpc('add_loan', params: {
        'p_user_id': userId,
        'p_loan_date': loanDate.toIso8601String(),
        'p_due_date': dueDate.toIso8601String(),
        'p_reason': reason.trim(),
        'p_asset_ids': assetIds,
      });
      
      print('RPC call successful. Response: $response');
      print('=== LOAN SUBMISSION END SUCCESS ===');
      
    } on PostgrestException catch (e) {
      print('POSTGREST EXCEPTION CAUGHT:');
      print('Error code: ${e.code}');
      print('Error message: ${e.message}');
      print('Error details: ${e.details}');
      print('Error hint: ${e.hint}');
      
      // Handle specific Supabase RPC errors
      if (e.code == 'P0001') { // RAISE EXCEPTION from PostgreSQL
        // Extract the actual error message from the PostgreSQL exception
        String errorMessage = e.message ?? 'Unknown error';
        print('PostgreSQL RAISE EXCEPTION: $errorMessage');
        // Remove the PostgreSQL error code prefix if present
        if (errorMessage.contains('ERROR:')) {
          errorMessage = errorMessage.split('ERROR:')[1].trim();
        }
        throw Exception(errorMessage);
      } else if (e.code == '42501') { // Insufficient privileges
        print('Insufficient privileges error');
        throw Exception('Tidak memiliki hak akses untuk melakukan peminjaman');
      } else if (e.code == '23503') { // Foreign key violation
        print('Foreign key violation error');
        throw Exception('Data tidak valid. Pastikan user dan asset tersedia.');
      } else if (e.code == '23505') { // Unique violation
        print('Unique violation error');
        throw Exception('Peminjaman sudah pernah diajukan');
      }
      print('Other PostgrestException');
      throw Exception('Gagal menambah pinjaman: ${e.message}');
    } on SocketException catch (e) {
      print('SOCKET EXCEPTION: ${e.message}');
      throw Exception('Koneksi internet bermasalah. Silakan coba lagi.');
    } on TimeoutException catch (e) {
      print('TIMEOUT EXCEPTION: ${e.message}');
      throw Exception('Waktu koneksi habis. Silakan coba lagi.');
    } catch (e, stackTrace) {
      print('UNEXPECTED ERROR:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Gagal menambah pinjaman: $e');
    }
  }
}
