import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/category_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/category_card.dart';
import 'package:lendo/providers/category_provider.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
      
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.white, size: 28),
            onPressed: () {
              _showAddCategoryDialog(context, ref);
            },
          ),
        ],
      ),
      drawer: CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                        category: category,
                        onEdit: () => _showUpdateDialog(context, category, ref),
                        onDelete: () => _showDeleteDialog(context, category, ref),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading categories: $error',
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Add New Category',
            style: TextStyle(color: AppColors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.outline,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter category name',
                      hintStyle: TextStyle(color: AppColors.gray),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a category name'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }
                
                // Don't close the dialog yet, perform the operation first
                try {
                  await ref.read(categoriesProvider.notifier).addCategory(nameController.text.trim());
                  _showSuccessMessage(context, 'Category added successfully');
                  Navigator.of(context).pop();
                } catch (e) {
                  _showErrorMessage(context, 'Failed to add category: $e');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, CategoryModel category, WidgetRef ref) {
    final nameController = TextEditingController(text: category.name);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Update Category',
            style: TextStyle(color: AppColors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.outline,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter category name',
                      hintStyle: TextStyle(color: AppColors.gray),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a category name'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }
                
                // Don't close the dialog yet, perform the operation first
                try {
                  await ref.read(categoriesProvider.notifier).updateCategory(category.id, nameController.text.trim());
                  _showSuccessMessage(context, 'Category updated successfully');
                  Navigator.of(context).pop();
                } catch (e) {
                  _showErrorMessage(context, 'Failed to update category: $e');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, CategoryModel category, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: AppColors.white),
          ),
          content: Text(
            'Are you sure you want to delete category "${category.name}"?',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog (cancel)
              },
              child: Text(
                'No',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                
                try {
                  await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                  _showSuccessMessage(context, 'Category "${category.name}" deleted successfully');
                } catch (e) {
                  _showErrorMessage(context, 'Failed to delete category: $e');
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }
}