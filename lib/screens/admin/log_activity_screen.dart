import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/widgets/sidebar.dart';

class LogActivityScreen extends ConsumerWidget {
  const LogActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.white),
            onSelected: (String result) {
              // Handle filter selection
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'all',
                child: Text('All Activities', style: TextStyle(color: AppColors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'create',
                child: Text('Create', style: TextStyle(color: AppColors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'update',
                child: Text('Update', style: TextStyle(color: AppColors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: AppColors.white),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
      drawer: const CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outline,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView(
                  children: [
                    _buildActivityItem(
                      action: 'create',
                      entity: 'assets',
                      entityName: 'Laptop Dell XPS 13',
                      entityId: '17',
                      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
                      timestamp: '2026-01-23 01:45:17',
                      color: AppColors.primary,
                    ),
                    const Divider(height: AppSpacing.md, color: AppColors.outline),
                    _buildActivityItem(
                      action: 'update',
                      entity: 'users',
                      entityName: 'John Doe',
                      entityId: '25',
                      userId: '1b42bffb-4b4b-5f26-c836-54a2e7c7d6f2',
                      timestamp: '2026-01-23 02:30:45',
                      color: AppColors.white,
                    ),
                    const Divider(height: AppSpacing.md, color: AppColors.outline),
                    _buildActivityItem(
                      action: 'delete',
                      entity: 'loans',
                      entityName: 'Loan #001',
                      entityId: '8',
                      userId: '2c53cggc-5c5c-6g37-d947-65b3f8d8e7g3',
                      timestamp: '2026-01-23 03:15:30',
                      color: Colors.red,
                    ),
                    const Divider(height: AppSpacing.md, color: AppColors.outline),
                    _buildActivityItem(
                      action: 'create',
                      entity: 'categories',
                      entityName: 'Electronics',
                      entityId: '5',
                      userId: '0a31aeea-3a3a-4e15-b725-4391d626c5e1',
                      timestamp: '2026-01-23 04:20:10',
                      color: AppColors.primary,
                    ),
                    const Divider(height: AppSpacing.md, color: AppColors.outline),
                    _buildActivityItem(
                      action: 'update',
                      entity: 'assets',
                      entityName: 'MacBook Pro 16"',
                      entityId: '12',
                      userId: '3d64dhhc-6d6d-7h48-e058-76c4g9e9f8h4',
                      timestamp: '2026-01-23 05:10:22',
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.secondary,
              onSurface: AppColors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildActivityItem({
    required String action,
    required String entity,
    required String entityName,
    required String entityId,
    required String userId,
    required String timestamp,
    required Color color,
  }) {
    String actionText = '';
    IconData actionIcon;
    
    switch(action.toLowerCase()) {
      case 'create':
        actionText = 'Created';
        actionIcon = Icons.add_circle_outline;
        break;
      case 'update':
        actionText = 'Updated';
        actionIcon = Icons.edit_outlined;
        break;
      case 'delete':
        actionText = 'Deleted';
        actionIcon = Icons.delete_outline;
        break;
      default:
        actionIcon = Icons.info_outline;
        break;
    }
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Icon(
          actionIcon,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        '${actionText} $entity "$entityName"',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        'ID: $entityId | User: ${userId.substring(0, 8)}... | $timestamp',
        style: TextStyle(
          color: AppColors.gray,
          fontSize: 11,
        ),
      ),
    );
  }
}