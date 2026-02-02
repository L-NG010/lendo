import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/services/borrower/asset.dart';
import 'package:lendo/services/borrower/loan.dart';
import 'package:lendo/config/supabase_config.dart';

// Asset Stock Providers
final assetStockServiceProvider = Provider<AssetStockService>((ref) {
  return AssetStockService();
});

final assetStockProvider = FutureProvider<List<AssetStock>>((ref) async {
  final service = ref.read(assetStockServiceProvider);
  return await service.getAssetStock();
});

// Loan Service Provider
final loanServiceProvider = Provider<LoanService>((ref) {
  return LoanService(SupabaseConfig.client);
});
