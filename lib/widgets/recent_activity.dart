import 'package:flutter/material.dart';
import 'package:lendo/config/app_config.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title: 'Recent Activity'),
        const SizedBox(height: AppSpacing.md),
        _activityItem('Created asset "Laptop"', AppColors.primary),
        const Divider(color: AppColors.outline),
        _activityItem('Updated user "John"', AppColors.white),
        const Divider(color: AppColors.outline),
        _activityItem('Deleted loan #12', AppColors.red),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.bottomRight,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/log-activities');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(0, 30),
            ),
            child: const Text(
              'View More',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _activityItem(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
          ),
        ),
      ],
    );
  }
}