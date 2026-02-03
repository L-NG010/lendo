import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/activity_log_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/providers/activity_log_provider.dart';

class LogActivityScreen extends ConsumerWidget {
  const LogActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityLogsAsync = ref.watch(activityLogsProvider);
    
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
              if (result != 'all') {
                ref.read(activityLogsProvider.notifier).filterByAction(result);
              } else {
                ref.read(activityLogsProvider.notifier).refresh();
              }
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
        ],
      ),
      drawer: CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.read(activityLogsProvider.notifier).refresh();
                },
                child: activityLogsAsync.when(
                  data: (logs) {
                    if (logs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_outlined, size: 48, color: AppColors.gray),
                            const SizedBox(height: 16),
                            Text(
                              'No activity logs found',
                              style: TextStyle(color: AppColors.gray),
                            ),
                          ],
                        ),
                      );
                    }
                                  
                    return ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return _buildActivityItemFromModel(log);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading activity logs: $error',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityItemFromModel(ActivityLog log) {
    String actionText = '';
    IconData actionIcon;
    Color actionColor = AppColors.primary;
    String description = _generateDescription(log);
    
    switch(log.action.toLowerCase()) {
      case 'create':
        actionText = 'Added';
        actionIcon = Icons.add_circle_outline;
        actionColor = AppColors.primary;
        break;
      case 'update':
        actionText = 'Updated';
        actionIcon = Icons.edit_outlined;
        actionColor = AppColors.outline;
        break;
      case 'delete':
        actionText = 'Deleted';
        actionIcon = Icons.delete_outline;
        actionColor = AppColors.red;
        break;
      default:
        actionIcon = Icons.info_outline;
        actionColor = AppColors.gray;
        break;
    }
    
    return Card(
      color: AppColors.secondary,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: actionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            actionIcon,
            color: actionColor,
            size: 18,
          ),
        ),
        title: Text(
          actionText,
          style: TextStyle(
            color: actionColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 12,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Entity:',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.entity,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'ID:',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.entityId,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'User:',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${log.userId.substring(0, 8)}...',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Time:',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDateTime(log.createdAt)} (${log.createdAt.toString().substring(0, 19)})',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (log.oldValue != null || log.newValue != null) ...[
                  const SizedBox(height: 8),
                  if (log.oldValue != null) ...[
                    Text(
                      'Before:',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.oldValue!,
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  if (log.newValue != null) ...[
                    Text(
                      'After:',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.newValue!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _generateDescription(ActivityLog log) {
    String entityName = log.entity;
    
    switch(log.action.toLowerCase()) {
      case 'create':
        return 'Added a new $entityName with ID ${log.entityId}';
      case 'update':
        if (log.oldValue != null && log.newValue != null) {
          return 'Updated $entityName ID ${log.entityId}';
        }
        return 'Updated $entityName ID ${log.entityId}';
      case 'delete':
        return 'Deleted $entityName with ID ${log.entityId}';
      default:
        return '${log.action} operation on $entityName ID ${log.entityId}';
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}