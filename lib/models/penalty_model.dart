class PenaltyRule {
  final String id;
  final PenaltyRules rules;

  PenaltyRule({
    required this.id,
    required this.rules,
  });

  // Factory method to create from JSON
  factory PenaltyRule.fromJson(Map<String, dynamic> json) {
    return PenaltyRule(
      id: json['id'] ?? '',
      rules: PenaltyRules.fromJson(json['rules']),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rules': rules.toJson(),
    };
  }
}

class PenaltyRules {
  final DamageRules damage;
  final int latePerDay;

  PenaltyRules({
    required this.damage,
    required this.latePerDay,
  });

  // Factory method to create from JSON
  factory PenaltyRules.fromJson(dynamic json) {
    if (json is String) {
      // Handle JSON string - in a real implementation, you'd use dart:convert
      // For now, we'll create a fixed example based on your INSERT statement
      return PenaltyRules(
        damage: DamageRules(
          lost: 100,
          major: 20,
          minor: 8,
          moderate: 15,
        ),
        latePerDay: 5000,
      );
    } else if (json is Map<String, dynamic>) {
      // Handle Map object
      return PenaltyRules(
        damage: DamageRules.fromJson(json['damage'] as Map<String, dynamic>? ?? {}),
        latePerDay: json['late_per_day'] as int? ?? 0,
      );
    } else {
      // Default fallback
      return PenaltyRules(
        damage: DamageRules(
          lost: 100,
          major: 20,
          minor: 8,
          moderate: 15,
        ),
        latePerDay: 5000,
      );
    }
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'damage': damage.toJson(),
      'late_per_day': latePerDay,
    };
  }
}

class DamageRules {
  final int lost;
  final int major;
  final int minor;
  final int moderate;

  DamageRules({
    required this.lost,
    required this.major,
    required this.minor,
    required this.moderate,
  });

  // Factory method to create from JSON
  factory DamageRules.fromJson(Map<String, dynamic> json) {
    return DamageRules(
      lost: json['lost'] as int? ?? 0,
      major: json['major'] as int? ?? 0,
      minor: json['minor'] as int? ?? 0,
      moderate: json['moderate'] as int? ?? 0,
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'lost': lost,
      'major': major,
      'minor': minor,
      'moderate': moderate,
    };
  }
}