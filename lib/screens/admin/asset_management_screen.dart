import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/asset_model.dart';
import 'package:lendo/models/category_model.dart';
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
    final categoriesAsync = ref.watch(categoriesProvider); // ✅ Watch categories
    final filterState = ref.watch(filterProvider);
    final filteredAssets = ref.watch(filteredAssetsProvider);

    // Extract unique category IDs present in assets
    final assetCategoryIds = <String>{};
    assetsAsync.whenData((assets) {
      assetCategoryIds.addAll(assets.map((asset) => asset.category.toString()));
    });

    // Prepare Dropdown Items
    // We want to show "All" + Categories that exist (or all categories)
    // Let's rely on categoriesProvider to get Names
    // Categories and Assets are already watched above.
    // PopupMenu will handle item generation dynamically.
    // If categories are loading/error, we might still have just "All" or raw IDs
    // But since we are inside build, we can just use what we have.
    // If categories isn't loaded yet, we can't map names.
    // A better approach might be to show raw IDs until categories load, or just show "Loading..."
    // Simpler: Just map what we can.

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
                // Category filter popup menu
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: PopupMenuButton<String>(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    color: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.outline),
                    ),
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        // Safe access to category name for display
                        Builder(
                          builder: (context) {
                            String displayName = 'All Categories';
                            if (filterState.selectedCategory != 'All') {
                              displayName =
                                  'Category ${filterState.selectedCategory}';
                              if (categoriesAsync.hasValue) {
                                final cat = categoriesAsync.value!
                                    .cast<CategoryModel?>()
                                    .firstWhere(
                                      (c) =>
                                          c?.id.toString() ==
                                          filterState.selectedCategory,
                                      orElse: () => null,
                                    );
                                if (cat != null) displayName = cat.name;
                              }
                            }

                            return Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    onSelected: (String result) {
                      ref
                          .read(filterProvider.notifier)
                          .setSelectedCategory(result);
                    },
                    itemBuilder: (BuildContext context) {
                      final List<PopupMenuEntry<String>> items = [
                        const PopupMenuItem<String>(
                          value: 'All',
                          child: Text(
                            'All Categories',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ];

                      if (categoriesAsync.hasValue && assetsAsync.hasValue) {
                        final categories = categoriesAsync.value!;
                        final assets = assetsAsync.value!;
                        final assetCategoryIds = assets
                            .map((asset) => asset.category.toString())
                            .toSet();
                        final categoryMap = {
                          for (var c in categories) c.id.toString(): c.name,
                        };
                        final sortedIds = assetCategoryIds.toList()..sort();

                        for (var id in sortedIds) {
                          final name = categoryMap[id] ?? 'Category $id';
                          items.add(
                            PopupMenuItem<String>(
                              value: id,
                              child: Text(
                                name,
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          );
                        }
                      }
                      return items;
                    },
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
                      // Find category name
                      String categoryName = 'Unknown';
                      if (categoriesAsync.hasValue) {
                        final category = categoriesAsync.value!.firstWhere(
                          (c) => c.id == asset.category,
                          orElse: () => CategoryModel(id: -1, name: 'Unknown'),
                        );
                        categoryName = category.name;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AssetCard(
                          asset: asset,
                          categoryName: categoryName,
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
    // categoriesProvider moved to Consumer
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    int? selectedCategory;
    String selectedStatus = 'available';
    final priceController = TextEditingController();
    Uint8List? selectedImageBytes;

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
              content: SizedBox(
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
                            if (selectedImageBytes != null)
                              Image.memory(
                                selectedImageBytes!,
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
                                    final bytes = await image.readAsBytes();
                                    setState(() {
                                      selectedImageBytes = bytes;
                                    });
                                  }
                                } catch (e) {
                                  print('Error picking image: $e');
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
                        child: Consumer(
                          builder: (context, ref, child) {
                            final categoriesAsync = ref.watch(
                              categoriesProvider,
                            );
                            return categoriesAsync.when(
                              data: (categories) {
                                return DropdownButtonFormField<int>(
                                  initialValue: selectedCategory,
                                  dropdownColor: AppColors.secondary,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
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
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
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
                            );
                          },
                        ),
                      ),
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.primary),
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
                      if (selectedImageBytes != null) {
                        final fileName =
                            'asset_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        // Use the bytes upload method
                        uploadedUrl = await ref
                            .read(assetServiceProvider)
                            .uploadImageBytes(selectedImageBytes!, fileName);
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
    // categoriesProvider moved to Consumer
    final nameController = TextEditingController(text: asset.name);
    final codeController = TextEditingController(text: asset.code);
    int selectedCategory = asset.category;
    String selectedStatus = asset.status;
    final priceController = TextEditingController(
      text: asset.price?.toString() ?? '',
    );
    Uint8List? selectedImageBytes;

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
              content: SizedBox(
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
                            if (selectedImageBytes != null)
                              Image.memory(
                                selectedImageBytes!,
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
                                    final bytes = await image.readAsBytes();
                                    setState(() {
                                      selectedImageBytes = bytes;
                                    });
                                  }
                                } catch (e) {
                                  print('Error picking image: $e');
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
                        child: Consumer(
                          builder: (context, ref, child) {
                            final categoriesAsync = ref.watch(
                              categoriesProvider,
                            );
                            return categoriesAsync.when(
                              data: (categories) {
                                return DropdownButtonFormField<int>(
                                  initialValue: selectedCategory,
                                  dropdownColor: AppColors.secondary,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
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
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
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
                            );
                          },
                        ),
                      ),
                      _buildDropdownField(
                        label: 'Status:',
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          dropdownColor: AppColors.secondary,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: AppColors.primary),
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
                      if (selectedImageBytes != null) {
                        final fileName =
                            'asset_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        finalUrl = await ref
                            .read(assetServiceProvider)
                            .uploadImageBytes(selectedImageBytes!, fileName);
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
    // Add capitalization for Name field only
    final isNameField = label.toLowerCase().contains('name');

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
          TextField(
            controller: controller,
            inputFormatters: isNameField
                ? [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;

                      final text = newValue.text;
                      // Capitalize first letter if it's lowercase
                      if (text[0] == text[0].toLowerCase() &&
                          text[0] != text[0].toUpperCase()) {
                        final capitalized =
                            text[0].toUpperCase() + text.substring(1);
                        return TextEditingValue(
                          text: capitalized,
                          selection: newValue.selection,
                        );
                      }
                      return newValue;
                    }),
                  ]
                : null,
            decoration: InputDecoration(
              hintText: 'Enter ${label.toLowerCase()}',
              hintStyle: TextStyle(color: AppColors.gray),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            style: TextStyle(color: AppColors.white),
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
