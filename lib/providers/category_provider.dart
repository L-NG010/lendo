import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/models/category_model.dart';
import 'package:lendo/services/category_service.dart';

// Category service provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

// Async notifier for categories list
class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    final categoryService = ref.read(categoryServiceProvider);
    return await categoryService.getAllCategories();
  }

  // Refresh categories
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final categoryService = ref.read(categoryServiceProvider);
      return await categoryService.getAllCategories();
    });
  }

  // Add new category
  Future<void> addCategory(String name) async {
    try {
      final categoryService = ref.read(categoryServiceProvider);
      final newCategory = await categoryService.createCategory(name);
      
      // Update state with new category
      state.whenData((categories) {
        state = AsyncData([...categories, newCategory]);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }

  // Update existing category
  Future<void> updateCategory(String id, String name) async {
    try {
      final categoryService = ref.read(categoryServiceProvider);
      final updatedCategory = await categoryService.updateCategory(id, name);
      
      // Update state with updated category
      state.whenData((categories) {
        final updatedList = categories.map((category) => category.id == id ? updatedCategory : category).toList();
        state = AsyncData(updatedList);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      final categoryService = ref.read(categoryServiceProvider);
      await categoryService.deleteCategory(id);
      
      // Remove category from state
      state.whenData((categories) {
        final updatedList = categories.where((category) => category.id != id).toList();
        state = AsyncData(updatedList);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }
}

// Provider for categories list
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(CategoriesNotifier.new);