import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/asset_card.dart';
import 'package:lendo/providers/asset_provider.dart';

class AssetManagementScreen extends ConsumerWidget {
  const AssetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final assetsAsync = ref.watch(assetsProvider);
    final filterState = ref.watch(filterProvider);
    final filteredAssets = ref.watch(filteredAssetsProvider);
    
    // Extract unique categories
    final categories = {'All'};
    assetsAsync.whenData((assets) {
      categories.addAll(assets.map((asset) => asset.category.toString()));
    });

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
              _showAddAssetDialog(context, ref);
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
                        ref.read(filterProvider.notifier).setSearchQuery(value);
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
                      value: filterState.selectedCategory,
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
                        ref.read(filterProvider.notifier).setSelectedCategory(newValue ?? 'All');
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: assetsAsync.when(
                data: (assets) {
                  if (filteredAssets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, 
                               size: 64, 
                               color: AppColors.gray),
                          const SizedBox(height: 16),
                          Text('No assets found', 
                               style: TextStyle(color: AppColors.gray)),
                          const SizedBox(height: 8),
                          Text('Try adjusting your search or filter', 
                               style: TextStyle(color: AppColors.gray.withOpacity(0.7))),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: filteredAssets.length,
                    itemBuilder: (context, index) {
                      final asset = filteredAssets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AssetCard(
                          asset: asset,
                          onEdit: () => _showUpdateDialog(context, ref, asset),
                          onDelete: () => _showDeleteDialog(context, ref, asset),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, 
                           size: 64, 
                           color: AppColors.red),
                      const SizedBox(height: 16),
                      Text('Error loading assets', 
                           style: TextStyle(color: AppColors.red)),
                      const SizedBox(height: 8),
                      Text(error.toString(), 
                           style: TextStyle(color: AppColors.gray)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(assetsProvider),
                        child: const Text('Retry'),
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

  void _showAddAssetDialog(BuildContext context, WidgetRef ref) {
    // Controllers for form fields
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final categoryController = TextEditingController();
    final statusController = TextEditingController();
    final priceController = TextEditingController();
    
    // For image upload - store the file locally until save
    File? selectedImage;
    String? imageUrl;
    
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
            child: SingleChildScrollView(
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
                          onPressed: () async {
                            try {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                selectedImage = File(image.path);
                                print('Image selected: ' + image.path);
                                // Don't upload yet - just store the file locally
                                // Upload will happen when user clicks Save
                              }
                            } catch (e) {
                              // Handle specific platform errors
                              String errorMessage = e.toString();
                              if (errorMessage.contains('channel-error') || errorMessage.contains('file_selector')) {
                                errorMessage = 'Image selection not supported on this platform. Please use another device.';
                              }
                              print('Error picking image: ' + errorMessage);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Image selection failed: ' + errorMessage),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text('Choose File', style: TextStyle(color: AppColors.primary, fontSize: 12)), 
                        ),
                      ],
                    ),
                  ),
                  _buildTextField('Name:', nameController),
                  _buildTextField('Code:', codeController),
                  _buildTextField('Category (ID):', categoryController),
                  _buildTextField('Status:', statusController),
                  _buildTextField('Price:', priceController),
                ],
              ),
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
                try {
                  // Upload image first if one is selected
                  if (selectedImage != null) {
                    final assetService = ref.read(assetServiceProvider);
                    final fileName = 'asset_' + DateTime.now().millisecondsSinceEpoch.toString() + '_' + nameController.text.replaceAll(' ', '_').toLowerCase() + '.jpg';
                    imageUrl = await assetService.uploadImage(selectedImage!, fileName);
                    print('Image uploaded successfully: ' + imageUrl!);
                  }
                  
                  final assetsNotifier = ref.read(assetsProvider.notifier);
                  await assetsNotifier.addAsset(
                    name: nameController.text,
                    category: int.tryParse(categoryController.text) ?? 0,
                    code: codeController.text,
                    status: statusController.text,
                    pictureUrl: imageUrl,
                    price: priceController.text.isEmpty ? null : priceController.text,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Asset added successfully'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add asset: \$e'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
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

  Widget _buildTextField(String label, TextEditingController controller) {
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
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter ' + label.toLowerCase(),
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

  void _showUpdateDialog(BuildContext context, WidgetRef ref, Asset asset) {
    // Controllers for form fields with initial values
    final nameController = TextEditingController(text: asset.name);
    final codeController = TextEditingController(text: asset.code);
    final categoryController = TextEditingController(text: asset.category.toString());
    final statusController = TextEditingController(text: asset.status);
    final priceController = TextEditingController(text: asset.price?.toString() ?? '');
    
    // For image upload
    File? selectedImage;
    String? imageUrl;
    
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
            child: SingleChildScrollView(
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
                          onPressed: () async {
                            try {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                selectedImage = File(image.path);
                                print('Image selected: ' + image.path);
                                // Don't upload yet - just store the file locally
                                // Upload will happen when user clicks Save
                              }
                            } catch (e) {
                              // Handle specific platform errors
                              String errorMessage = e.toString();
                              if (errorMessage.contains('channel-error') || errorMessage.contains('file_selector')) {
                                errorMessage = 'Image selection not supported on this platform. Please use another device.';
                              }
                              print('Error picking image: ' + errorMessage);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Image selection failed: ' + errorMessage),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text('Change Image', style: TextStyle(color: AppColors.primary, fontSize: 12)), 
                        ),
                      ],
                    ),
                  ),
                  _buildTextField('Name:', nameController),
                  _buildTextField('Code:', codeController),
                  _buildTextField('Category (ID):', categoryController),
                  _buildTextField('Status:', statusController),
                  _buildTextField('Price:', priceController),
                ],
              ),
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
                try {
                  // Upload image first if one is selected
                  if (selectedImage != null) {
                    final assetService = ref.read(assetServiceProvider);
                    final fileName = 'asset_' + DateTime.now().millisecondsSinceEpoch.toString() + '_' + nameController.text.replaceAll(' ', '_').toLowerCase() + '.jpg';
                    imageUrl = await assetService.uploadImage(selectedImage!, fileName);
                    print('Image uploaded successfully: ' + imageUrl!);
                  }
                  
                  final assetsNotifier = ref.read(assetsProvider.notifier);
                  await assetsNotifier.updateAsset(
                    id: asset.id,
                    name: nameController.text,
                    category: int.tryParse(categoryController.text),
                    code: codeController.text,
                    status: statusController.text,
                    pictureUrl: imageUrl, // Use new image URL if provided
                    price: priceController.text.isEmpty ? null : priceController.text,
                  );
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Asset "\${asset.name}" updated successfully'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update asset: \$e'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Asset asset) {
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
            'Are you sure you want to delete asset "' + asset.name + '"?',
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
                _deleteAsset(context, ref, asset);
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

  void _deleteAsset(BuildContext context, WidgetRef ref, Asset asset) async {
    try {
      final assetsNotifier = ref.read(assetsProvider.notifier);
      await assetsNotifier.deleteAsset(asset.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asset "${asset.name}" deleted successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete asset: ${e.toString()}'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }
}