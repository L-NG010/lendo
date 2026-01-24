import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login.dart';
import 'package:lendo/config/app_config.dart';


class CustomSidebar extends ConsumerWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 70, // Lebar sangat tipis
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Lendo di atas
          SizedBox(height: 30),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/lendo.svg',
                height: 40,
                width: 40,
                colorFilter: ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          
          // Menu items
           Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _SidebarMenuItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isActive: true,
                ),
                _SidebarMenuItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Assets',
                ),
                _SidebarMenuItem(
                  icon: Icons.manage_accounts_outlined,
                  label: 'Users',
                ),
                _SidebarMenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Loans',
                ),
                _SidebarMenuItem(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                ),
                _SidebarMenuItem(
                  icon: Icons.history_outlined,
                  label: 'Logs',
                ),
                _SidebarMenuItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                ),
              ],
            ),
          ),
          
          // Logout button di bawah
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.logout_outlined,
                  color: AppColors.red,
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Apakah Anda yakin ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Ya'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    final authService = ref.read(authServicePod);
                    await authService.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                tooltip: 'Logout',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Tooltip(
        message: label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                icon,
                size: 24,
                color: isActive
                    ? AppColors.primary
                    : AppColors.gray,
              ),
              onPressed: () {
                // Navigation logic
              },
            ),
          ],
        ),
      ),
    );
  }
}