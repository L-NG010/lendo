import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/config/app_config.dart';
import 'package:lendo/models/penalty_model.dart';
import 'package:lendo/widgets/sidebar.dart';
import 'package:lendo/providers/penalty_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final penaltyRulesAsync = ref.watch(penaltyRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      drawer: CustomSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Penalty Cards Grid
            Expanded(
              child: penaltyRulesAsync.when(
                data: (rules) {
                  if (rules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            size: 48,
                            color: AppColors.gray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No penalty rules configured',
                            style: TextStyle(color: AppColors.gray),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _showAddPenaltyRuleDialog(context, ref);
                            },
                            child: Text('Add Rule'),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildPenaltyCardsGrid(rules.first, context, ref);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading penalty rules: $error',
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltyCardsGrid(
    PenaltyRule rule,
    BuildContext context,
    WidgetRef ref,
  ) {
    final latePerDayController = TextEditingController(
      text: rule.rules.latePerDay.toString(),
    );
    final minorController = TextEditingController(
      text: rule.rules.damage.minor.toString(),
    );
    final moderateController = TextEditingController(
      text: rule.rules.damage.moderate.toString(),
    );
    final majorController = TextEditingController(
      text: rule.rules.damage.major.toString(),
    );
    final lostController = TextEditingController(
      text: rule.rules.damage.lost.toString(),
    );

    return SingleChildScrollView(
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
                onChanged: (value) {
                  // Controller is already linked to the text field
                },
                controller: lostController,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPenaltyInputCard(
                icon: Icons.warning_amber_rounded,
                label: 'Major Damage',
                value: rule.rules.damage.major.toString(),
                color: AppColors.secondary.withOpacity(0.15),
                iconColor: AppColors.primary,
                onChanged: (value) {
                  // Controller is already linked to the text field
                },
                controller: majorController,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPenaltyInputCard(
                icon: Icons.report_problem_rounded,
                label: 'Moderate Damage',
                value: rule.rules.damage.moderate.toString(),
                color: AppColors.secondary.withOpacity(0.15),
                iconColor: AppColors.primary,
                onChanged: (value) {
                  // Controller is already linked to the text field
                },
                controller: moderateController,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildPenaltyInputCard(
                icon: Icons.flag_rounded,
                label: 'Minor Damage',
                value: rule.rules.damage.minor.toString(),
                color: AppColors.secondary.withOpacity(0.15),
                iconColor: AppColors.primary,
                onChanged: (value) {
                  // Controller is already linked to the text field
                },
                controller: minorController,
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
                onChanged: (value) {
                  // Controller is already linked to the text field
                },
                controller: latePerDayController,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Save Button
          _buildSaveButton(
            context,
            ref,
            rule.id,
            latePerDayController,
            minorController,
            moderateController,
            majorController,
            lostController,
          ),
        ],
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
                child: Icon(icon, size: 20, color: AppColors.primary),
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
    TextEditingController? controller,
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
            child: Icon(icon, size: 18, color: iconColor),
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
                  controller: controller ?? TextEditingController(text: value),
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
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

  Widget _buildSaveButton(
    BuildContext context,
    WidgetRef ref,
    String ruleId,
    TextEditingController latePerDayController,
    TextEditingController minorController,
    TextEditingController moderateController,
    TextEditingController majorController,
    TextEditingController lostController,
  ) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final damageRules = DamageRules(
              lost: int.tryParse(lostController.text) ?? 100,
              major: int.tryParse(majorController.text) ?? 20,
              minor: int.tryParse(minorController.text) ?? 8,
              moderate: int.tryParse(moderateController.text) ?? 15,
            );

            final penaltyRules = PenaltyRules(
              damage: damageRules,
              latePerDay: int.tryParse(latePerDayController.text) ?? 5000,
            );

            await ref
                .read(penaltyRulesProvider.notifier)
                .updatePenaltyRule(ruleId, penaltyRules);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Penalty settings saved successfully'),
                backgroundColor: AppColors.primary,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save penalty settings: $e'),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Save Settings',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  void _showAddPenaltyRuleDialog(BuildContext context, WidgetRef ref) {
    final latePerDayController = TextEditingController(text: '5000');
    final minorController = TextEditingController(text: '8');
    final moderateController = TextEditingController(text: '15');
    final majorController = TextEditingController(text: '20');
    final lostController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.secondary,
          title: Text(
            'Add Penalty Rule',
            style: TextStyle(color: AppColors.white),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                  'Late Fee Per Day (Rp):',
                  latePerDayController,
                ),
                _buildInputField('Minor Damage (%):', minorController),
                _buildInputField('Moderate Damage (%):', moderateController),
                _buildInputField('Major Damage (%):', majorController),
                _buildInputField('Lost Damage (%):', lostController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.gray)),
            ),
            TextButton(
              onPressed: () async {
                if (latePerDayController.text.isEmpty ||
                    minorController.text.isEmpty ||
                    moderateController.text.isEmpty ||
                    majorController.text.isEmpty ||
                    lostController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: AppColors.red,
                    ),
                  );
                  return;
                }

                try {
                  final damageRules = DamageRules(
                    lost: int.tryParse(lostController.text) ?? 100,
                    major: int.tryParse(majorController.text) ?? 20,
                    minor: int.tryParse(minorController.text) ?? 8,
                    moderate: int.tryParse(moderateController.text) ?? 15,
                  );

                  final penaltyRules = PenaltyRules(
                    damage: damageRules,
                    latePerDay: int.tryParse(latePerDayController.text) ?? 5000,
                  );

                  await ref
                      .read(penaltyRulesProvider.notifier)
                      .addPenaltyRule(penaltyRules);
                  _showSuccessMessage(
                    context,
                    'Penalty rule added successfully',
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  _showErrorMessage(context, 'Failed to add penalty rule: $e');
                }
              },
              child: Text('Save', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outline, width: 1),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter value',
                hintStyle: TextStyle(color: AppColors.gray),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }
}
