import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/user_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/user_card.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample user data
    final users = [
      UserModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+628123456789',
        role: 'admin',
        status: 'active',
      ),
      UserModel(
        id: '2',
        name: 'Masum',
        email: 'jane@example.com',
        phoneNumber: '+628987654321',
        role: 'officer',
        status: 'active',
      ),
      UserModel(
        id: '3',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        phoneNumber: '+628555123456',
        role: 'borrower',
        status: 'inactive',
      ),
      UserModel(
        id: '4',
        name: 'Sarah Wilson',
        email: 'sarah@example.com',
        phoneNumber: '+628777987654',
        role: 'officer',
        status: 'active',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.white, size: 28),
            onPressed: () {
              _showAddUserDialog(context);
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
                        hintText: 'Search users...',
                        hintStyle: TextStyle(color: AppColors.gray),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: AppColors.gray),
                      ),
                    ),
                  ),
                ),
                // Role filter dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: DropdownButton<String>(
                      value: 'All',
                      underline: Container(),
                      isExpanded: true,
                      hint: Text('Filter', style: TextStyle(color: AppColors.gray, fontSize: 12)),
                      items: ['All', 'admin', 'officer', 'borrower'].map((String role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role, style: TextStyle(color: AppColors.white, fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Handle role change
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: UserCard(
                      user: user,
                      onEdit: () => _showUpdateDialog(context, user),
                      onDelete: () => _showDeleteDialog(context, user),
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

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Add New User',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                _buildAddField('Name:', ''),
                _buildAddField('Email:', ''),
                _buildAddField('Phone Number:', ''),
                _buildRoleDropdown('Role:', ''),
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
                _showSuccessMessage(context, 'User added successfully');
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

  Widget _buildRoleDropdown(String label, String currentValue) {
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue.isEmpty ? null : currentValue,
                hint: Text('Select role', style: TextStyle(color: AppColors.gray)),
                isExpanded: true,
                items: ['admin', 'officer', 'borrower'].map((String role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role, style: TextStyle(color: AppColors.white)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  // Handle role change
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Update User',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                _buildAddField('Name:', user.name),
                _buildAddField('Email:', user.email),
                _buildAddField('Phone Number:', user.phoneNumber),
                _buildRoleDropdown('Role:', user.role),
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

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UserModel user) {
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
            'Are you sure you want to delete user "${user.name}"?',
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
                _showSuccessMessage(context, 'User "${user.name}" deleted successfully');
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