import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
import 'package:lendo/config/app_config.dart';

class CustomSidebar extends ConsumerWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServicePod);
    final userRole = authService.getUserRole();
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Container(
      width: 70, // Ultra thin width
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          const SizedBox(height: 30),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/lendo.svg',
                height: 40,
                width: 40,
                colorFilter: const ColorFilter.mode(
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
              children: _buildMenuItems(context, userRole ?? '', currentRoute),
            ),
          ),

          // Logout button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.logout_outlined, color: AppColors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppColors.outline,
                          width: 1,
                        ),
                      ),
                      title: const Text(
                        'Logout Confirmation',
                        style: TextStyle(color: AppColors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to logout?',
                        style: TextStyle(color: AppColors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await authService.signOut(ref);
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
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

  List<Widget> _buildMenuItems(
    BuildContext context,
    String role,
    String currentRoute,
  ) {
    // Admin Items
    if (role == 'admin') {
      return [
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
      ];
    } else if (role == 'officer') {
      return [
        _SidebarMenuItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          isActive: currentRoute == '/officer-dashboard',
          onTap: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/officer-dashboard', (route) => false),
        ),
        _SidebarMenuItem(
          icon: Icons.inventory_2_outlined,
          label: 'Requests',
          isActive: currentRoute == '/officer/requests',
          onTap: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/officer/requests', (route) => false),
        ),
        _SidebarMenuItem(
          icon: Icons.undo_outlined,
          label: 'Returns',
          isActive: currentRoute == '/officer/returns',
          onTap: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/officer/returns', (route) => false),
        ),
        _SidebarMenuItem(
          icon: Icons.history,
          label: 'History',
          isActive: currentRoute == '/officer/history',
          onTap: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/officer/history', (route) => false),
        ),
        _SidebarMenuItem(
          icon: Icons.person_outline,
          label: 'Profile',
          isActive: currentRoute == '/officer/profile',
          onTap: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/officer/profile', (route) => false),
        ),
      ];
    }

    // Default or other roles
    return [];
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
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
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
