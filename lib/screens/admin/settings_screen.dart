import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/penalty_model.dart';
import 'package:lendo/widgets/sidebar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample penalty rule data based on your INSERT statement
    final penaltyRule = PenaltyRule(
      id: '1',
      rules: PenaltyRules(
        damage: DamageRules(
          lost: 100,
          major: 20,
          minor: 8,
          moderate: 15,
        ),
        latePerDay: 5000,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      drawer: const CustomSidebar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penalty Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPenaltySettingsCard(penaltyRule, context),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltySettingsCard(PenaltyRule rule, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Damage Penalties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPenaltyInputRow(
            icon: Icons.sentiment_dissatisfied,
            label: 'Lost Item',
            value: rule.rules.damage.lost.toString(),
            onChanged: (value) {
              // TODO: Implement update logic
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPenaltyInputRow(
            icon: Icons.warning,
            label: 'Major Damage',
            value: rule.rules.damage.major.toString(),
            onChanged: (value) {
              // TODO: Implement update logic
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPenaltyInputRow(
            icon: Icons.report_problem,
            label: 'Moderate Damage',
            value: rule.rules.damage.moderate.toString(),
            onChanged: (value) {
              // TODO: Implement update logic
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildPenaltyInputRow(
            icon: Icons.flag,
            label: 'Minor Damage',
            value: rule.rules.damage.minor.toString(),
            onChanged: (value) {
              // TODO: Implement update logic
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Late Return Penalties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPenaltyInputRow(
            icon: Icons.access_time,
            label: 'Per Day Late Fee',
            value: rule.rules.latePerDay.toString(),
            suffixText: 'Rp',
            onChanged: (value) {
              // TODO: Implement update logic
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              // TODO: Save settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Penalty settings saved successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyInputRow({
    required IconData icon,
    required String label,
    required String value,
    required Function(String) onChanged,
    String? suffixText,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: TextEditingController(text: value),
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                      color: AppColors.gray.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    suffixText: suffixText,
                    suffixStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.secondary,
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}