import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/asset_card.dart';
import 'package:lendo/providers/asset_provider.dart';
import 'package:lendo/providers/category_provider.dart';

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
      drawer: CustomSidebar(),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: AppColors.secondary,
                      value: filterState.selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        ref
                            .read(filterProvider.notifier)
                            .setSelectedCategory(newValue ?? 'All');
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
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppColors.gray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No assets found',
                            style: TextStyle(color: AppColors.gray),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filter',
                            style: TextStyle(
                              color: AppColors.gray.withOpacity(0.7),
                            ),
                          ),
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
                          onDelete: () =>
                              _showDeleteDialog(context, ref, asset),
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
                      Icon(Icons.error_outline, size: 64, color: AppColors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading assets',
                        style: TextStyle(color: AppColors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(color: AppColors.gray),
                      ),
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    int? selectedCategory;
    String selectedStatus = 'available';
    final priceController = TextEditingController();
    File? selectedImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.outline,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (selectedImage != null)
                              Image.file(
                                selectedImage!,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            else
                              Icon(
                                Icons.image_outlined,
                                color: AppColors.gray,
                                size: 30,
                              ),
                            Text(
                              'Upload Image',
                              style: TextStyle(
                                color: AppColors.gray,
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      selectedImage = File(image.path);
                                    });
                                  }
                                } catch (e) {
                                  print('Error picking image: ' + e.toString());
                                }
                              },
                              child: Text(
                                'Choose File',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTextField('Name:', nameController),
                      _buildTextField('Code:', codeController),
                      _buildDropdownField(
                        label: 'Category:',
                        child: categoriesAsync.when(
                          data: (categories) {
                            return DropdownButtonFormField<int>(
                              value: selectedCategory,
                              dropdownColor: AppColors.secondary,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.secondary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: TextStyle(color: AppColors.white),
                              hint: Text(
                                'Select category',
                                style: TextStyle(color: AppColors.gray),
                              ),
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                            );
                          },
                          loading: () => CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          error: (_, __) => Text(
                            'Error loading categories',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                      ),
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          style: TextStyle(color: AppColors.white),
                          items: ['available', 'borrowed', 'damaged', 'lost']
                              .map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status[0].toUpperCase() +
                                        status.substring(1),
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      _buildTextField('Price:', priceController),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedCategory == null) {
                      _showErrorMessage(context, 'Please select a category');
                      return;
                    }
                    try {
                      String? uploadedUrl;
                      if (selectedImage != null) {
                        final fileName =
                            'asset_' +
                            DateTime.now().millisecondsSinceEpoch.toString() +
                            '.jpg';
                        uploadedUrl = await ref
                            .read(assetServiceProvider)
                            .uploadImage(selectedImage!, fileName);
                      }

                      await ref
                          .read(assetsProvider.notifier)
                          .addAsset(
                            name: nameController.text,
                            code: codeController.text,
                            category: selectedCategory!,
                            status: selectedStatus,
                            price: num.tryParse(priceController.text),
                            pictureUrl: uploadedUrl,
                          );
                      Navigator.of(context).pop();
                      _showSuccessMessage(context, 'Asset added successfully');
                    } catch (e) {
                      _showErrorMessage(
                        context,
                        'Failed to add asset: ${e.toString()}',
                      );
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
      },
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, Asset asset) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final nameController = TextEditingController(text: asset.name);
    final codeController = TextEditingController(text: asset.code);
    int selectedCategory = asset.category;
    String selectedStatus = asset.status;
    final priceController = TextEditingController(
      text: asset.price?.toString() ?? '',
    );
    File? selectedImage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.outline,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (selectedImage != null)
                              Image.file(
                                selectedImage!,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            else if (asset.pictureUrl != null)
                              Image.network(
                                asset.pictureUrl!,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            else
                              Icon(
                                Icons.image_outlined,
                                color: AppColors.gray,
                                size: 30,
                              ),
                            Text(
                              'Update Image',
                              style: TextStyle(
                                color: AppColors.gray,
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      selectedImage = File(image.path);
                                    });
                                  }
                                } catch (e) {
                                  print('Error picking image: ' + e.toString());
                                }
                              },
                              child: Text(
                                'Change Image',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTextField('Name:', nameController),
                      _buildTextField('Code:', codeController),
                      _buildDropdownField(
                        label: 'Category:',
                        child: categoriesAsync.when(
                          data: (categories) {
                            return DropdownButtonFormField<int>(
                              value: selectedCategory,
                              dropdownColor: AppColors.secondary,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.secondary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: TextStyle(color: AppColors.white),
                              hint: Text(
                                'Select category',
                                style: TextStyle(color: AppColors.gray),
                              ),
                              items: categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                });
                              },
                            );
                          },
                          loading: () => CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                          error: (_, __) => Text(
                            'Error loading categories',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ),
                      ),
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.secondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          style: TextStyle(color: AppColors.white),
                          items: ['available', 'borrowed', 'damaged', 'lost']
                              .map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status[0].toUpperCase() +
                                        status.substring(1),
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      _buildTextField('Price:', priceController),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      String? finalUrl = asset.pictureUrl;
                      if (selectedImage != null) {
                        final fileName =
                            'asset_' +
                            DateTime.now().millisecondsSinceEpoch.toString() +
                            '.jpg';
                        finalUrl = await ref
                            .read(assetServiceProvider)
                            .uploadImage(selectedImage!, fileName);
                      }

                      await ref
                          .read(assetsProvider.notifier)
                          .updateAsset(
                            id: asset.id,
                            name: nameController.text,
                            code: codeController.text,
                            category: selectedCategory,
                            status: selectedStatus,
                            price: num.tryParse(priceController.text),
                            pictureUrl: finalUrl,
                          );
                      Navigator.of(context).pop();
                      _showSuccessMessage(
                        context,
                        'Asset updated successfully',
                      );
                    } catch (e) {
                      _showErrorMessage(
                        context,
                        'Failed to update asset: ${e.toString()}',
                      );
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
            'Are you sure you want to delete asset "${asset.name}"?',
            style: TextStyle(color: AppColors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.gray)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAsset(context, ref, asset);
              },
              child: Text('Delete', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAsset(BuildContext context, WidgetRef ref, Asset asset) async {
    try {
      await ref.read(assetsProvider.notifier).deleteAsset(asset.id);
      _showSuccessMessage(
        context,
        'Asset "${asset.name}" deleted successfully',
      );
    } catch (e) {
      _showErrorMessage(context, 'Failed to delete asset: ${e.toString()}');
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
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
              border: Border.all(color: AppColors.outline, width: 1),
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

  Widget _buildDropdownField({required String label, required Widget child}) {
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
          child,
        ],
      ),
    );
  }
}
