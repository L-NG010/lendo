import 'package:lendo/config/supabase_config.dart';

class AssetStock {
  final int id; // ID unik untuk setiap asset
  final String name; // Nama aset
  final int total; // Total stok dari view
  final int available; // Available count dari view
  final String? pictureUrl; // Gambar aset opsional

  AssetStock({
    required this.id,
    required this.name,
    required this.total,
    required this.available,
    this.pictureUrl,
  });
}

class AssetStockService {
  final _supabase = SupabaseConfig.client;

  Future<List<AssetStock>> getAssetStock() async {
    final data = await _supabase.from('asset_stock_detail').select('*');
    return (data as List).map((row) {
      return AssetStock(
        id: row['id'] ?? 0,
        name: row['name'] ?? '',
        total: int.tryParse('${row['total']}') ?? 0,
        available: int.tryParse('${row['available']}') ?? 0,
        pictureUrl: row['picture_url'],
      );
    }).toList();
  }

  Future<List<int>> getAvailableAssetIds(String name, int quantity) async {
    final data = await _supabase
        .from('assets')
        .select('id')
        .eq('name', name)
        .eq('status', 'available')
        .order('id', ascending: true)
        .limit(quantity);

    final result = (data as List).map((e) => e['id'] as int).toList();
    
    if (result.length < quantity) {
      final allAvailable = await _supabase
          .from('assets')
          .select('id')
          .eq('name', name)
          .eq('status', 'available');
      
      final availableCount = (allAvailable as List).length;
      throw Exception('Tidak cukup stok untuk $name. Tersedia: $availableCount, Dibutuhkan: $quantity');
    }
    
    return result;
  }

  Future<List<int>> getAssetIdsForCartItems(List<Map<String, dynamic>> cartItems) async {
    List<int> allAssetIds = [];
    
    for (var item in cartItems) {
      String assetName = item['name'] as String;
      int quantity = item['quantity'] as int;
      
      try {
        List<int> assetIds = await getAvailableAssetIds(assetName, quantity);
        
        if (assetIds.length < quantity) {
          throw Exception('Tidak cukup stok untuk ${assetName}. Tersedia: ${assetIds.length}, Dibutuhkan: $quantity');
        }
        
        allAssetIds.addAll(assetIds);
      } catch (e) {
        rethrow;
      }
    }
    return allAssetIds;
  }
}
