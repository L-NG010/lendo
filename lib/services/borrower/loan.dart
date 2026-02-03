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
    // Validasi input
    if (userId.isEmpty) {
      throw Exception('User ID tidak boleh kosong');
    }
    if (assetIds.isEmpty) {
      throw Exception('Tidak ada asset untuk dipinjam');
    }
    
    try {
      final response = await client.rpc('add_loan', params: {
        'p_user_id': userId,
        'p_loan_date': loanDate.toIso8601String(),
        'p_due_date': dueDate.toIso8601String(),
        'p_reason': reason.trim(),
        'p_asset_ids': assetIds,
      });
      return response;
    } on PostgrestException catch (e) {
      if (e.code == 'P0001') {
        String errorMessage = e.message;
        if (errorMessage.contains('ERROR:')) {
          errorMessage = errorMessage.split('ERROR:')[1].trim();
        }
        throw Exception(errorMessage);
      }
      throw Exception('Gagal menambah pinjaman: ${e.message}');
    } on SocketException catch (_) {
      throw Exception('Koneksi internet bermasalah. Silakan coba lagi.');
    } on TimeoutException catch (_) {
      throw Exception('Waktu koneksi habis. Silakan coba lagi.');
    } catch (e) {
      throw Exception('Gagal menambah pinjaman: $e');
    }
  }
}
