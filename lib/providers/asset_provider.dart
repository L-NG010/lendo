import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/services/asset_service.dart';

// Asset service provider
final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService();
});

// Async notifier for assets list
class AssetsNotifier extends AsyncNotifier<List<Asset>> {
  @override
  Future<List<Asset>> build() async {
    final assetService = ref.read(assetServiceProvider);
    return await assetService.getAllAssets();
  }

  // Refresh assets
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final assetService = ref.read(assetServiceProvider);
      return await assetService.getAllAssets();
    });
  }

  // Add new asset
  Future<void> addAsset({
    required String name,
    required int category,
    required String code,
    required String status,
    String? pictureUrl,
    String? price,
  }) async {
    try {
      final assetService = ref.read(assetServiceProvider);
      final newAsset = await assetService.createAsset(
        name: name,
        category: category,
        code: code,
        status: status,
        pictureUrl: pictureUrl,
        price: price,
      );
      
      // Update state with new asset
      state.whenData((assets) {
        state = AsyncData([...assets, newAsset]);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }

  // Update existing asset
  Future<void> updateAsset({
    required String id,
    String? name,
    int? category,
    String? code,
    String? status,
    String? pictureUrl,
    String? price,
  }) async {
    try {
      final assetService = ref.read(assetServiceProvider);
      final updatedAsset = await assetService.updateAsset(
        id: id,
        name: name,
        category: category,
        code: code,
        status: status,
        pictureUrl: pictureUrl,
        price: price,
      );
      
      // Update state with modified asset
      state.whenData((assets) {
        final index = assets.indexWhere((asset) => asset.id == id);
        if (index != -1) {
          final updatedAssets = [...assets];
          updatedAssets[index] = updatedAsset;
          state = AsyncData(updatedAssets);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete asset
  Future<void> deleteAsset(String id) async {
    try {
      final assetService = ref.read(assetServiceProvider);
      await assetService.deleteAsset(id);
      
      // Remove asset from state
      state.whenData((assets) {
        state = AsyncData(assets.where((asset) => asset.id != id).toList());
      });
    } catch (e) {
      rethrow;
    }
  }

  // Search assets
  Future<void> searchAssets(String query) async {
    if (query.isEmpty) {
      refresh();
      return;
    }
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final assetService = ref.read(assetServiceProvider);
      return await assetService.searchAssets(query);
    });
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    if (category == 'All') {
      refresh();
      return;
    }
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final assetService = ref.read(assetServiceProvider);
      return await assetService.getAssetsByCategory(category);
    });
  }
}

// Main assets provider
final assetsProvider = AsyncNotifierProvider<AssetsNotifier, List<Asset>>(() {
  return AssetsNotifier();
});

// Simple state management using Notifier pattern
class FilterState {
  final String selectedCategory;
  final String searchQuery;
  
  FilterState({
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });
  
  FilterState copyWith({
    String? selectedCategory,
    String? searchQuery,
  }) {
    return FilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() {
    return FilterState();
  }
  
  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
  
  void reset() {
    state = FilterState();
  }
}

// Filter notifier provider
final filterProvider = NotifierProvider<FilterNotifier, FilterState>(FilterNotifier.new);

// Filtered assets provider
final filteredAssetsProvider = Provider<List<Asset>>((ref) {
  final assetsAsync = ref.watch(assetsProvider);
  final filterState = ref.watch(filterProvider);
  
  return assetsAsync.when(
    data: (assets) {
      // Apply category filter
      List<Asset> filtered = assets;
      if (filterState.selectedCategory != 'All') {
        filtered = assets.where((asset) => asset.category == filterState.selectedCategory).toList();
      }
      
      // Apply search filter
      if (filterState.searchQuery.isNotEmpty) {
        filtered = filtered.where((asset) => 
          asset.name.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
          asset.code.toLowerCase().contains(filterState.searchQuery.toLowerCase())
        ).toList();
      }
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});