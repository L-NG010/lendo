import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/models/category_model.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService();
});

class CategoryService {
  final _supabase = SupabaseConfig.client;

  // Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('*')
          .order('id', ascending: true);
      
      return response.map((data) {
        final category = data as Map<String, dynamic>;
        return CategoryModel(
          id: category['id'].toString(),
          name: category['name'] as String,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final response = await _supabase
          .from('categories')
          .select('*')
          .eq('id', id)
          .single();
      
      final category = response as Map<String, dynamic>;
      return CategoryModel(
        id: category['id'].toString(),
        name: category['name'] as String,
      );
    } catch (e) {
      return null;
    }
  }

  // Create new category
  Future<CategoryModel> createCategory(String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .insert({'name': name})
          .select()
          .single();
      
      final category = response as Map<String, dynamic>;
      return CategoryModel(
        id: category['id'].toString(),
        name: category['name'] as String,
      );
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Update category
  Future<CategoryModel> updateCategory(String id, String name) async {
    try {
      final response = await _supabase
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();
      
      final category = response as Map<String, dynamic>;
      return CategoryModel(
        id: category['id'].toString(),
        name: category['name'] as String,
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}