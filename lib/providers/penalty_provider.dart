import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lendo/models/penalty_model.dart';
import 'package:lendo/services/penalty_service.dart';

// Penalty service provider
final penaltyServiceProvider = Provider<PenaltyService>((ref) {
  return PenaltyService();
});

// Async notifier for penalty rules list
class PenaltyRulesNotifier extends AsyncNotifier<List<PenaltyRule>> {
  @override
  Future<List<PenaltyRule>> build() async {
    final penaltyService = ref.read(penaltyServiceProvider);
    return await penaltyService.getAllPenaltyRules();
  }

  // Refresh penalty rules
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final penaltyService = ref.read(penaltyServiceProvider);
      return await penaltyService.getAllPenaltyRules();
    });
  }

  // Add new penalty rule
  Future<void> addPenaltyRule(PenaltyRules rules) async {
    try {
      final penaltyService = ref.read(penaltyServiceProvider);
      final newRule = await penaltyService.createPenaltyRule(rules);
      
      // Update state with new rule
      state.whenData((rulesList) {
        state = AsyncData([...rulesList, newRule]);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }

  // Update existing penalty rule
  Future<void> updatePenaltyRule(String id, PenaltyRules rules) async {
    try {
      final penaltyService = ref.read(penaltyServiceProvider);
      final updatedRule = await penaltyService.updatePenaltyRule(id, rules);
      
      // Update state with updated rule
      state.whenData((rulesList) {
        final updatedList = rulesList.map((rule) => rule.id == id ? updatedRule : rule).toList();
        state = AsyncData(updatedList);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }

  // Delete penalty rule
  Future<void> deletePenaltyRule(String id) async {
    try {
      final penaltyService = ref.read(penaltyServiceProvider);
      await penaltyService.deletePenaltyRule(id);
      
      // Remove rule from state
      state.whenData((rulesList) {
        final updatedList = rulesList.where((rule) => rule.id != id).toList();
        state = AsyncData(updatedList);
      });
    } catch (e) {
      // Error handling can be improved
      rethrow;
    }
  }
}

// Provider for penalty rules list
final penaltyRulesProvider = AsyncNotifierProvider<PenaltyRulesNotifier, List<PenaltyRule>>(PenaltyRulesNotifier.new);