import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/models/penalty_model.dart';

final penaltyServiceProvider = Provider<PenaltyService>((ref) {
  return PenaltyService();
});

class PenaltyService {
  final _supabase = SupabaseConfig.client;

  // Get all penalty rules
  Future<List<PenaltyRule>> getAllPenaltyRules() async {
    try {
      final response = await _supabase
          .from('penalty_rules')
          .select('*')
          .order('id', ascending: true);
      
      return response.map((data) {
        final rule = data as Map<String, dynamic>;
        return PenaltyRule(
          id: rule['id'].toString(),
          rules: PenaltyRules.fromJson(rule['rules']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch penalty rules: $e');
    }
  }

  // Get penalty rule by ID
  Future<PenaltyRule?> getPenaltyRuleById(String id) async {
    try {
      final response = await _supabase
          .from('penalty_rules')
          .select('*')
          .eq('id', id)
          .single();
      
      final rule = response as Map<String, dynamic>;
      return PenaltyRule(
        id: rule['id'].toString(),
        rules: PenaltyRules.fromJson(rule['rules']),
      );
    } catch (e) {
      return null;
    }
  }

  // Create new penalty rule
  Future<PenaltyRule> createPenaltyRule(PenaltyRules rules) async {
    try {
      final response = await _supabase
          .from('penalty_rules')
          .insert({'rules': rules.toJson()})
          .select()
          .single();
      
      final rule = response as Map<String, dynamic>;
      return PenaltyRule(
        id: rule['id'].toString(),
        rules: PenaltyRules.fromJson(rule['rules']),
      );
    } catch (e) {
      throw Exception('Failed to create penalty rule: $e');
    }
  }

  // Update penalty rule
  Future<PenaltyRule> updatePenaltyRule(String id, PenaltyRules rules) async {
    try {
      final response = await _supabase
          .from('penalty_rules')
          .update({'rules': rules.toJson()})
          .eq('id', id)
          .select()
          .single();
      
      final rule = response as Map<String, dynamic>;
      return PenaltyRule(
        id: rule['id'].toString(),
        rules: PenaltyRules.fromJson(rule['rules']),
      );
    } catch (e) {
      throw Exception('Failed to update penalty rule: $e');
    }
  }

  // Delete penalty rule
  Future<void> deletePenaltyRule(String id) async {
    try {
      await _supabase
          .from('penalty_rules')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete penalty rule: $e');
    }
  }
}