import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
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
            child: Builder(
              builder: (context) {
                final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
                
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _SidebarMenuItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      isActive: currentRoute == '/admin-dashboard',
                      onTap: () => Navigator.of(context).pushNamed('/admin-dashboard'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Assets',
                      isActive: currentRoute == '/assets',
                      onTap: () => Navigator.of(context).pushNamed('/assets'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.manage_accounts_outlined,
                      label: 'Users',
                      isActive: currentRoute == '/users',
                      onTap: () => Navigator.of(context).pushNamed('/users'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Loans',
                      isActive: currentRoute == '/loans',
                      onTap: () => Navigator.of(context).pushNamed('/loans'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.category_outlined,
                      label: 'Categories',
                      isActive: currentRoute == '/categories',
                      onTap: () => Navigator.of(context).pushNamed('/categories'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.history_outlined,
                      label: 'Logs',
                      isActive: currentRoute == '/log-activities',
                      onTap: () => Navigator.of(context).pushNamed('/log-activities'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isActive: currentRoute == '/settings',
                      onTap: () => Navigator.of(context).pushNamed('/settings'),
                    ),
                    _SidebarMenuItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      isActive: currentRoute == '/profile',
                      onTap: () => Navigator.of(context).pushNamed('/profile'),
                    ),
                  ],
                );
              }
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
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
  final VoidCallback onTap;
  final bool isActive;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
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
                color: isActive ? AppColors.primary : AppColors.gray,
              ),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}