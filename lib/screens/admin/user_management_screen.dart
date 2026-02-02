import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/user_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/widgets/admin/user_card.dart';
import 'package:lendo/providers/user_provider.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final filteredUsers = ref.watch(filteredUsersProvider);
    final filterState = ref.watch(roleFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _showAddUserDialog(context, ref),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final searchQuery = ref
                            .watch(roleFilterProvider)
                            .searchQuery;
                        return TextField(
                          key: ValueKey(searchQuery),
                          controller: TextEditingController(text: searchQuery)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: searchQuery.length),
                            ),
                          onChanged: (value) {
                            // Improved debouncing with 800ms delay to prevent performance issues
                            ref
                                .read(roleFilterProvider.notifier)
                                .debouncedSetSearchQuery(value, 800);
                          },
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            hintStyle: const TextStyle(
                              color: AppColors.gray,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (searchQuery.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.gray.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(roleFilterProvider.notifier)
                                          .setSearchQuery('');
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints.tight(
                                      const Size(36, 36),
                                    ),
                                    tooltip: 'Clear search',
                                  ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.search,
                                  color: AppColors.gray.withOpacity(0.7),
                                  size: 22,
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Role filter dropdown
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
                      value: filterState.selectedRole,
                      isExpanded: true,

                      // 🔥 INI YANG MEMPERBAIKI GARIS BAWAH
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),

                      items: ['All', 'admin', 'officer', 'borrower'].map((
                        role,
                      ) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),

                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          ref
                              .read(roleFilterProvider.notifier)
                              .setSelectedRole(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Search results counter
            if (filterState.searchQuery.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  '${filteredUsers.length} user${filteredUsers.length != 1 ? 's' : ''} found',
                  style: const TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ),
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  if (filteredUsers.isEmpty &&
                      filterState.searchQuery.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: AppColors.gray,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No users found',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No users match "${filterState.searchQuery}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.gray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: UserCard(
                          user: user,
                          onEdit: () => _showUpdateDialog(context, user, ref),
                          onDelete: () => _toggleUserStatus(context, user, ref),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(usersProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
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

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    String selectedRole = 'borrower';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Add New User',
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddField('Email', emailController),
              _buildAddField('Password', passwordController, isPassword: true),
              _buildAddField('Name', nameController),
              _buildPhoneField(phoneController),
              _buildRoleDropdown(
                'Role',
                selectedRole,
                (value) => setState(() => selectedRole = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    nameController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  _showErrorMessage(context, 'All fields are required');
                  return;
                }

                try {
                  await ref
                      .read(usersProvider.notifier)
                      .addUser(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        name: nameController.text.trim(), // ✅ FIX
                        phone:
                            phoneController.text.trim(), // ✅ FIX PREFIX
                        role: selectedRole,
                      );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.read(usersProvider.notifier).quickRefresh();
                    _showSuccessMessage(context, 'User created successfully');
                  }
                } catch (e) {
                  _showErrorMessage(context, e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Create',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, UserModel user, WidgetRef ref) {
    final emailController = TextEditingController(text: user.email);
    final nameController = TextEditingController(
      text: user.rawUserMetadata['name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: user.phone?.replaceFirst('+62', '') ?? '',
    );

    String selectedRole = user.rawUserMetadata['role'] ?? 'borrower';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Update User',
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddField('Email', emailController),
              _buildAddField('Name', nameController),
              _buildPhoneField(phoneController), // ✅ ADD PHONE
              _buildRoleDropdown(
                'Role',
                selectedRole,
                (value) => setState(() => selectedRole = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(usersProvider.notifier)
                      .updateUser(
                        id: user.id,
                        email: emailController.text.trim(),
                        name: nameController.text.trim(),
                        role: selectedRole,
                        phone: '+62${phoneController.text.trim()}',
                      );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.read(usersProvider.notifier).quickRefresh();
                    _showSuccessMessage(context, 'User updated successfully');
                  }
                } catch (e) {
                  _showErrorMessage(context, e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleUserStatus(BuildContext context, UserModel user, WidgetRef ref) {
    final isActive = user.rawUserMetadata['is_active'] ?? true;
    final action = isActive ? 'deactivate' : 'activate';
    final userName = user.rawUserMetadata['name'] ?? user.email;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${action[0].toUpperCase()}${action.substring(1)} User',
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.secondary,
        content: Text(
          'Are you sure you want to ${action} $userName?',
          style: const TextStyle(color: AppColors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(usersProvider.notifier)
                    .updateUser(
                      id: user.id,
                      name: user.rawUserMetadata['name'],
                      role: user.rawUserMetadata['role'],
                      isActive: !isActive,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.read(usersProvider.notifier).quickRefresh();
                  _showSuccessMessage(context, 'User ${action}d successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  _showErrorMessage(context, e.toString());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.red : Colors.green,
            ),
            child: Text(
              action[0].toUpperCase() + action.substring(1),
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.gray),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(
    String label,
    String currentValue,
    Function(String) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        dropdownColor: AppColors.secondary,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.gray),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        items: ['admin', 'officer', 'borrower'].map((String role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role, style: const TextStyle(color: AppColors.white)),
          );
        }).toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        style: const TextStyle(color: AppColors.white),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12),
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) return newValue;
            if (!newValue.text.startsWith('8')) return oldValue;
            return newValue;
          }),
        ],
        decoration: InputDecoration(
          labelText: 'Phone Number',
          labelStyle: const TextStyle(color: AppColors.gray),

          prefixText: '+62 ',
          prefixStyle: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
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
}
