import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/penalty_model.dart';
import 'package:lendo/widgets/sidebar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Penalty Cards Grid
            _buildPenaltyCardsGrid(penaltyRule, context),
          ],
        ),
      ),
    );
  }



  Widget _buildPenaltyCardsGrid(PenaltyRule rule, BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Damage Penalties Card
            _buildModernCard(
              title: 'Damage Penalties',
              icon: Icons.dangerous_rounded,
              children: [
                _buildPenaltyInputCard(
                  icon: Icons.search_off_rounded,
                  label: 'Lost Item',
                  value: rule.rules.damage.lost.toString(),
                  color: AppColors.secondary.withOpacity(0.15),
                  iconColor: AppColors.primary,
                  onChanged: (value) {},
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPenaltyInputCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Major Damage',
                  value: rule.rules.damage.major.toString(),
                  color: AppColors.secondary.withOpacity(0.15),
                  iconColor: AppColors.primary,
                  onChanged: (value) {},
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPenaltyInputCard(
                  icon: Icons.report_problem_rounded,
                  label: 'Moderate Damage',
                  value: rule.rules.damage.moderate.toString(),
                  color: AppColors.secondary.withOpacity(0.15),
                  iconColor: AppColors.primary,
                  onChanged: (value) {},
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPenaltyInputCard(
                  icon: Icons.flag_rounded,
                  label: 'Minor Damage',
                  value: rule.rules.damage.minor.toString(),
                  color: AppColors.secondary.withOpacity(0.15),
                  iconColor: AppColors.primary,
                  onChanged: (value) {},
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Late Return Penalties Card
            _buildModernCard(
              title: 'Late Return Penalties',
              icon: Icons.timer_rounded,
              children: [
                _buildPenaltyInputCard(
                  icon: Icons.access_time_filled_rounded,
                  label: 'Per Day Late Fee',
                  value: rule.rules.latePerDay.toString(),
                  suffixText: 'Rp',
                  color: AppColors.secondary.withOpacity(0.15),
                  iconColor: AppColors.primary,
                  onChanged: (value) {},
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Save Button
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPenaltyInputCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
    required Function(String) onChanged,
    String? suffixText,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: TextEditingController(text: value),
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.secondary,
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                      color: AppColors.gray.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    suffixText: suffixText,
                    suffixStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
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
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Save Settings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}