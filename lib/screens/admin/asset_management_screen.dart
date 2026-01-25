import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/asset_card.dart';

class AssetManagementScreen extends ConsumerWidget {
  const AssetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample data based on the provided INSERT statement
    final allAssets = [
      Asset(
        id: '1',
        name: 'printer',
        category: '1',
        code: '02892',
        status: 'available',
        pictureUrl: null,
        price: '100000',
      ),
      Asset(
        id: '5',
        name: 'Projector',
        category: '2',
        code: '0289ss',
        status: 'available',
        pictureUrl: null,
        price: null,
      ),
      Asset(
        id: '3',
        name: 'Laptop',
        category: 'Electronics',
        code: 'LAP001',
        status: 'borrowed',
        pictureUrl: null,
        price: '15000000',
      ),
      Asset(
        id: '4',
        name: 'Desk Chair',
        category: 'Furniture',
        code: 'CHA001',
        status: 'maintenance',
        pictureUrl: null,
        price: '500000',
      ),
    ];
    
    // Extract unique categories
    final categories = {'All', ...allAssets.map((asset) => asset.category)};
    
    // State for filtering
    String selectedCategory = 'All';
    String searchQuery = '';
    
    // Filter assets based on category and search query
    final filteredAssets = allAssets.where((asset) {
      final matchesCategory = selectedCategory == 'All' || asset.category == selectedCategory;
      final matchesSearch = asset.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            asset.code.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.white, size: 28),
            onPressed: () {
              _showAddAssetDialog(context);
            },
          ),
        ],
      ),
      drawer: const CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter controls
            Row(
              children: [
                // Search bar
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search assets...',
                        hintStyle: TextStyle(color: AppColors.gray),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: AppColors.gray),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                      },
                    ),
                  ),
                ),
                // Category filter dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      underline: Container(),
                      isExpanded: true,
                      hint: Text('Filter', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                      items: categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category, style: TextStyle(color: AppColors.gray, fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedCategory = newValue ?? 'All';
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: filteredAssets.length,
                itemBuilder: (context, index) {
                  final asset = filteredAssets[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AssetCard(
                      asset: asset,
                      onEdit: () => _showUpdateDialog(context, asset),
                      onDelete: () => _showDeleteDialog(context, asset),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showAddAssetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Add New Asset',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image upload section
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outline, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_outlined, color: AppColors.gray, size: 30),
                      Text('Upload Image', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                      TextButton(
                        onPressed: () {
                          // Handle image selection
                        },
                        child: Text('Choose File', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                _buildAddField('Name:', ''),
                _buildAddField('Code:', ''),
                _buildAddField('Category:', ''),
                _buildAddField('Status:', ''),
                _buildAddField('Price:', ''),
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
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessMessage(context, 'Asset added successfully');
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

  Widget _buildAddField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.outline,
                width: 1,
              ),
            ),
            child: TextFormField(
              initialValue: value.isEmpty ? '' : value,
              decoration: InputDecoration(
                hintText: 'Enter ${label.toLowerCase()}',
                hintStyle: TextStyle(color: AppColors.gray),
                border: InputBorder.none,
              ),
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Update Asset',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image upload section
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outline, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.image_outlined, color: AppColors.gray, size: 30),
                      Text('Current Image', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                      TextButton(
                        onPressed: () {
                          // Handle image selection
                        },
                        child: Text('Change Image', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                _buildAddField('Name:', asset.name),
                _buildAddField('Code:', asset.code),
                _buildAddField('Category:', asset.category),
                _buildAddField('Status:', asset.status),
                _buildAddField('Price:', asset.price ?? ''),
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
              onPressed: () {
                Navigator.of(context).pop();
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

  void _showDeleteDialog(BuildContext context, Asset asset) {
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
            'Are you sure you want to delete asset "${asset.name}"?',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog (cancel)
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform delete action
                Navigator.of(context).pop(); // Close dialog
                _showSuccessMessage(context, 'Asset "${asset.name}" deleted successfully');
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.primary),
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
}