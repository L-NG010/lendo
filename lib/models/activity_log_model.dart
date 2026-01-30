class ActivityLog {
  final String id;
  final String userId;
  final String action;
  final String entity;
  final String entityId;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.entity,
    required this.entityId,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      action: json['action'] ?? '',
      entity: json['entity'] ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      oldValue: _convertToString(json['old_value']),
      newValue: _convertToString(json['new_value']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  static String? _convertToString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) return value.toString();
    if (value is List) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'entity': entity,
      'entity_id': entityId,
      'old_value': oldValue,
      'new_value': newValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}