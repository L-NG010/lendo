import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lendo/services/borrower/loan.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final loanServiceProvider = Provider<LoanService>((ref) {
  final client = ref.read(supabaseClientProvider);
  return LoanService(client);
});
