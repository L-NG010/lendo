import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final role = user.rawUserMetadata['role'] ?? 'borrower';
    final name = user.rawUserMetadata['name'] ?? user.email;
    final isActive = user.rawUserMetadata['is_active'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ================= LEFT USER INFO =================
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getUserIcon(role),
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // NAME + ROLE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.outline.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= ACTION BUTTONS =================
          Row(
            children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: AppColors.primary,
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(32, 32)),
                ),

              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    isActive ? Icons.delete : Icons.check_circle,
                    size: 18,
                  ),
                  color: isActive ? AppColors.red : Colors.green,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(32, 32)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getUserIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'officer':
        return Icons.badge;
      case 'borrower':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }
}
