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

  /// Ambil stok dari view asset_stock_detail
  /// Digunakan untuk menampilkan daftar aset dengan stok teragregasi
  Future<List<AssetStock>> getAssetStock() async {
    final data = await _supabase.from('asset_stock_detail').select('*');
    return (data as List).map((row) {
      return AssetStock(
        id: row['id'] ?? 0, // ID dari view (bukan ID asset sebenarnya)
        name: row['name'] ?? '',
        total: int.tryParse('${row['total']}') ?? 0,
        available: int.tryParse('${row['available']}') ?? 0,
        pictureUrl: row['picture_url'],
      );
    }).toList();
  }

  /// Ambil ID asset terkecil yang available untuk nama tertentu
  /// Digunakan untuk memilih asset spesifik saat peminjaman
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
      // Get count for better error message
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

  /// Ambil semua asset IDs available berdasarkan cart items
  /// Digunakan saat submit peminjaman untuk mendapatkan ID asset sebenarnya
  Future<List<int>> getAssetIdsForCartItems(List<Map<String, dynamic>> cartItems) async {
    print('=== GET ASSET IDS FOR CART ITEMS START ===');
    print('Cart items: $cartItems');
    
    List<int> allAssetIds = [];
    
    for (var item in cartItems) {
      String assetName = item['name'] as String;
      int quantity = item['quantity'] as int;
      
      print('Processing item: $assetName, quantity: $quantity');
      
      try {
        List<int> assetIds = await getAvailableAssetIds(assetName, quantity);
        print('Got asset IDs for $assetName: $assetIds');
        
        if (assetIds.length < quantity) {
          print('ERROR: Not enough stock for $assetName. Available: ${assetIds.length}, Needed: $quantity');
          throw Exception('Tidak cukup stok untuk ${assetName}. Tersedia: ${assetIds.length}, Dibutuhkan: $quantity');
        }
        
        allAssetIds.addAll(assetIds);
      } catch (e) {
        print('ERROR getting asset IDs for $assetName: $e');
        rethrow;
      }
    }
    
    print('All asset IDs collected: $allAssetIds');
    print('=== GET ASSET IDS FOR CART ITEMS END ===');
    
    return allAssetIds;
  }
}
