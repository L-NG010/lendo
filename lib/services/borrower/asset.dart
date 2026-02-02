import 'package:lendo/config/supabase_config.dart';

class AssetStock {
  final int id; // ID unik untuk setiap asset
  final String name; // Nama aset
  final int total; // Total stok dari view
  final String? pictureUrl; // Gambar aset opsional

  AssetStock({
    required this.id,
    required this.name,
    required this.total,
    this.pictureUrl,
  });
}

class AssetStockService {
  final _supabase = SupabaseConfig.client;

  /// Ambil stok dari view
  Future<List<AssetStock>> getAssetStock() async {
    final data = await _supabase.from('asset_stock_detail').select('*');
    return (data as List).map((row) {
      return AssetStock(
        id: row['id'] ?? 0, // ID dari view
        name: row['name'] ?? '',
        total: int.tryParse('${row['total_available']}') ?? 0,
        pictureUrl: row['picture_url'],
      );
    }).toList();
  }

  /// Ambil ID asset terkecil yang available untuk nama tertentu
  Future<List<int>> getAvailableAssetIds(String name, int quantity) async {
    final data = await _supabase
        .from('assets')
        .select('id')
        .eq('name', name)
        .eq('status', 'available')
        .order('id', ascending: true)
        .limit(quantity);

    return (data as List).map((e) => e['id'] as int).toList();
  }
}
