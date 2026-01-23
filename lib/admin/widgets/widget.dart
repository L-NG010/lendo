import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSidebar extends StatelessWidget {
  const CustomSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, // Lebar sangat tipis
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Lendo di atas
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                  Theme.of(context).colorScheme.primary,
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
                  icon: Icons.book_outlined,
                  label: 'Books',
                ),
                _SidebarMenuItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                ),
                _SidebarMenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
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
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.logout_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  // Logout logic
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
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
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
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
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