// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLogModel _$ActivityLogModelFromJson(Map<String, dynamic> json) =>
    ActivityLogModel(
      id: json['id'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      userId: json['userId'] as String,
      customerId: json['customerId'] as String?,
      contactId: json['contactId'] as String?,
      taskId: json['taskId'] as String?,
      dealId: json['dealId'] as String?,
      priority: $enumDecode(_$ActivityPriorityEnumMap, json['priority']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      sessionId: json['sessionId'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      oldValues: json['oldValues'] as Map<String, dynamic>?,
      newValues: json['newValues'] as Map<String, dynamic>?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      notes: json['notes'] as String?,
      isSystemGenerated: json['isSystemGenerated'] as bool? ?? false,
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
      customFields: (json['customFields'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ActivityLogModelToJson(ActivityLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'userId': instance.userId,
      'customerId': instance.customerId,
      'contactId': instance.contactId,
      'taskId': instance.taskId,
      'dealId': instance.dealId,
      'priority': _$ActivityPriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'deviceInfo': instance.deviceInfo,
      'sessionId': instance.sessionId,
      'duration': instance.duration?.inMicroseconds,
      'oldValues': instance.oldValues,
      'newValues': instance.newValues,
      'tags': instance.tags,
      'notes': instance.notes,
      'isSystemGenerated': instance.isSystemGenerated,
      'relatedEntityType': instance.relatedEntityType,
      'relatedEntityId': instance.relatedEntityId,
      'customFields': instance.customFields,
    };

const _$ActivityTypeEnumMap = {
  ActivityType.customerCreated: 'customerCreated',
  ActivityType.customerUpdated: 'customerUpdated',
  ActivityType.customerDeleted: 'customerDeleted',
  ActivityType.contactCreated: 'contactCreated',
  ActivityType.contactUpdated: 'contactUpdated',
  ActivityType.contactDeleted: 'contactDeleted',
  ActivityType.taskCreated: 'taskCreated',
  ActivityType.taskUpdated: 'taskUpdated',
  ActivityType.taskCompleted: 'taskCompleted',
  ActivityType.taskDeleted: 'taskDeleted',
  ActivityType.dealCreated: 'dealCreated',
  ActivityType.dealUpdated: 'dealUpdated',
  ActivityType.dealStageChanged: 'dealStageChanged',
  ActivityType.dealWon: 'dealWon',
  ActivityType.dealLost: 'dealLost',
  ActivityType.dealDeleted: 'dealDeleted',
  ActivityType.emailSent: 'emailSent',
  ActivityType.emailReceived: 'emailReceived',
  ActivityType.callMade: 'callMade',
  ActivityType.callReceived: 'callReceived',
  ActivityType.meetingScheduled: 'meetingScheduled',
  ActivityType.meetingCompleted: 'meetingCompleted',
  ActivityType.noteAdded: 'noteAdded',
  ActivityType.fileUploaded: 'fileUploaded',
  ActivityType.userLogin: 'userLogin',
  ActivityType.userLogout: 'userLogout',
  ActivityType.systemEvent: 'systemEvent',
  ActivityType.customEvent: 'customEvent',
};

const _$ActivityPriorityEnumMap = {
  ActivityPriority.low: 'low',
  ActivityPriority.medium: 'medium',
  ActivityPriority.high: 'high',
  ActivityPriority.critical: 'critical',
};
