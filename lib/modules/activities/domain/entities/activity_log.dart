import 'package:equatable/equatable.dart';

enum ActivityType {
  customerCreated,
  customerUpdated,
  customerDeleted,
  contactCreated,
  contactUpdated,
  contactDeleted,
  taskCreated,
  taskUpdated,
  taskCompleted,
  taskDeleted,
  dealCreated,
  dealUpdated,
  dealStageChanged,
  dealWon,
  dealLost,
  dealDeleted,
  emailSent,
  emailReceived,
  callMade,
  callReceived,
  meetingScheduled,
  meetingCompleted,
  noteAdded,
  fileUploaded,
  userLogin,
  userLogout,
  systemEvent,
  customEvent,
}

enum ActivityPriority {
  low,
  medium,
  high,
  critical,
}

class ActivityLog extends Equatable {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String userId;
  final String? customerId;
  final String? contactId;
  final String? taskId;
  final String? dealId;
  final ActivityPriority priority;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceInfo;
  final String? sessionId;
  final Duration? duration;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final List<String> tags;
  final String? notes;
  final bool isSystemGenerated;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final Map<String, String>? customFields;

  const ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.userId,
    this.customerId,
    this.contactId,
    this.taskId,
    this.dealId,
    required this.priority,
    required this.createdAt,
    this.metadata,
    this.ipAddress,
    this.userAgent,
    this.deviceInfo,
    this.sessionId,
    this.duration,
    this.oldValues,
    this.newValues,
    this.tags = const [],
    this.notes,
    this.isSystemGenerated = false,
    this.relatedEntityType,
    this.relatedEntityId,
    this.customFields,
  });

  bool get hasChanges => oldValues != null || newValues != null;
  bool get isCustomerRelated => customerId != null;
  bool get isContactRelated => contactId != null;
  bool get isTaskRelated => taskId != null;
  bool get isDealRelated => dealId != null;
  bool get isUserAction => !isSystemGenerated;

  ActivityLog copyWith({
    String? id,
    ActivityType? type,
    String? title,
    String? description,
    String? userId,
    String? customerId,
    String? contactId,
    String? taskId,
    String? dealId,
    ActivityPriority? priority,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
    String? deviceInfo,
    String? sessionId,
    Duration? duration,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    List<String>? tags,
    String? notes,
    bool? isSystemGenerated,
    String? relatedEntityType,
    String? relatedEntityId,
    Map<String, String>? customFields,
  }) {
    return ActivityLog(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      contactId: contactId ?? this.contactId,
      taskId: taskId ?? this.taskId,
      dealId: dealId ?? this.dealId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      sessionId: sessionId ?? this.sessionId,
      duration: duration ?? this.duration,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isSystemGenerated: isSystemGenerated ?? this.isSystemGenerated,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        userId,
        customerId,
        contactId,
        taskId,
        dealId,
        priority,
        createdAt,
        metadata,
        ipAddress,
        userAgent,
        deviceInfo,
        sessionId,
        duration,
        oldValues,
        newValues,
        tags,
        notes,
        isSystemGenerated,
        relatedEntityType,
        relatedEntityId,
        customFields,
      ];
}