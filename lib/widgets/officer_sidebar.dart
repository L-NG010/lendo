import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/auth_service.dart';
import 'package:lendo/config/app_config.dart';

class OfficerSidebar extends ConsumerWidget {
  const OfficerSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      width: 70, // Lebar sangat tipis
      child: SafeArea(
        child: Column(
          children: [
            // Logo Lendo di atas
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
                        isActive: currentRoute == '/officer-dashboard',
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/officer-dashboard', (route) => false);
                        },
                      ),
                      _SidebarMenuItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Requests',
                        isActive: currentRoute == '/officer/requests',
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/officer/requests', (route) => false);
                        },
                      ),
                      _SidebarMenuItem(
                        icon: Icons.undo_outlined,
                        label: 'Returns',
                        isActive: currentRoute == '/officer/returns',
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/officer/returns', (route) => false);
                        },
                      ),
                      _SidebarMenuItem(
                        icon: Icons.history,
                        label: 'History',
                        isActive: currentRoute == '/officer/history',
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/officer/history', (route) => false);
                        },
                      ),
                      _SidebarMenuItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        isActive: currentRoute == '/officer/profile',
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/officer/profile', (route) => false);
                        },
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
                    color: AppColors.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.logout_outlined,
                    color: AppColors.red,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout Confirmation'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      final authService = ref.read(authServicePod);
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
                  },
                  tooltip: 'Logout',
                ),
              ),
            ),
          ],
        ),
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
        color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
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