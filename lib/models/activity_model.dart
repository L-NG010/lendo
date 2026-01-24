class Activity {
  final String id;
  final String action;
  final String entity;
  final String entityName;
  final String entityId;
  final String userId;
  final String userName;
  final String timestamp;
  final String description;
  final DateTime dateTime;

  Activity({
    required this.id,
    required this.action,
    required this.entity,
    required this.entityName,
    required this.entityId,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.description,
    required this.dateTime,
  });

  // Factory method to create dummy data
  factory Activity.createDummy({
    required String id,
    required String action,
    required String entity,
    required String entityName,
    required String entityId,
    required String userId,
    required String userName,
    required String timestamp,
    required String description,
    required DateTime dateTime,
  }) {
    return Activity(
      id: id,
      action: action,
      entity: entity,
      entityName: entityName,
      entityId: entityId,
      userId: userId,
      userName: userName,
      timestamp: timestamp,
      description: description,
      dateTime: dateTime,
    );
  }
}