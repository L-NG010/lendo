import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import '../../services/auth_service.dart';
import '../auth/login.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class BorrowerProfileScreen extends ConsumerWidget {
  const BorrowerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final authService = ref.watch(authServicePod);
    final supabaseUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: currentUserAsync.when(
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card Section
                _buildProfileCard(user, supabaseUser),

                const SizedBox(height: AppSpacing.lg),

                // Personal Information Section
                _buildPersonalInformationSection(user),

                const SizedBox(height: AppSpacing.lg),

                // Logout Button
                _buildLogoutButton(context, authService),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading profile: \$error')),
      ),
    );
  }

  Widget _buildProfileCard(UserModel? user, dynamic supabaseUser) {
    String displayName = user != null && user.rawUserMetadata['name'] != null
        ? user.rawUserMetadata['name']
        : (supabaseUser != null
              ? supabaseUser.email?.split('@')[0] ?? 'User'
              : 'User');
    String role = user != null && user.rawUserMetadata['role'] != null
        ? user.rawUserMetadata['role']
        : (supabaseUser != null &&
                  supabaseUser.userMetadata != null &&
                  supabaseUser.userMetadata?['role'] != null
              ? supabaseUser.userMetadata!['role']
              : 'borrower');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // Dark green background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person, size: 40, color: AppColors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationSection(UserModel? user) {
    String email = user != null ? user.email : 'email@example.com';
    String phone = user != null && user.phone != null && user.phone!.isNotEmpty
        ? user.phone!
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondary, // Darker background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary, // Green border
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email,
              ),
              const Divider(
                color: AppColors.outline,
                height: 30,
                thickness: 0.5,
              ),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: phone,
              ),
              // Removed Location field as requested
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.secondary,
            title: const Text(
              'Konfirmasi Logout',
              style: TextStyle(color: AppColors.white),
            ),
            content: const Text(
              'Apakah Anda yakin ingin logout?',
              style: TextStyle(color: AppColors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.gray),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Ya',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await authService.signOut();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.red, width: 1),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(Icons.logout, size: 20, color: AppColors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
