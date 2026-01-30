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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getUserIcon(user.rawUserMetadata['role'] ?? 'borrower'),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.rawUserMetadata['name'] ?? user.email,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'ID: ${user.id}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.primary, size: 18),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(Size(32, 32)),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        (user.rawUserMetadata['is_active'] ?? true) ? Icons.delete : Icons.check_circle,
                        color: (user.rawUserMetadata['is_active'] ?? true) ? AppColors.red : Colors.green,
                        size: 18,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(Size(32, 32)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildDetailRow('Email:', user.email)),
              Expanded(child: _buildDetailRow('Phone:', user.phone?.isNotEmpty == true ? user.phone! : '-')),
            ],
          ),
          _buildRoleRow('Role:', user.rawUserMetadata['role'] ?? 'borrower'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
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

  Widget _buildRoleRow(String label, String role) {
    Color roleColor = AppColors.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: roleColor, width: 1),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 11,
                color: roleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}