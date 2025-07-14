// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$TaskTypeEnumMap, json['type']),
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      customerId: json['customerId'] as String?,
      contactId: json['contactId'] as String?,
      dealId: json['dealId'] as String?,
      assignedUserId: json['assignedUserId'] as String,
      createdByUserId: json['createdByUserId'] as String?,
      dueDate: DateTime.parse(json['dueDate'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      estimatedDuration: json['estimatedDuration'] == null
          ? null
          : Duration(microseconds: (json['estimatedDuration'] as num).toInt()),
      actualDuration: json['actualDuration'] == null
          ? null
          : Duration(microseconds: (json['actualDuration'] as num).toInt()),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrencePattern: json['recurrencePattern'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String?,
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reminderBefore: json['reminderBefore'] as String?,
      isAllDay: json['isAllDay'] as bool? ?? false,
      customFields: json['customFields'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$TaskTypeEnumMap[instance.type]!,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'customerId': instance.customerId,
      'contactId': instance.contactId,
      'dealId': instance.dealId,
      'assignedUserId': instance.assignedUserId,
      'createdByUserId': instance.createdByUserId,
      'dueDate': instance.dueDate.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'notes': instance.notes,
      'tags': instance.tags,
      'estimatedDuration': instance.estimatedDuration?.inMicroseconds,
      'actualDuration': instance.actualDuration?.inMicroseconds,
      'isRecurring': instance.isRecurring,
      'recurrencePattern': instance.recurrencePattern,
      'attachments': instance.attachments,
      'location': instance.location,
      'participantIds': instance.participantIds,
      'reminderBefore': instance.reminderBefore,
      'isAllDay': instance.isAllDay,
      'customFields': instance.customFields,
    };

const _$TaskTypeEnumMap = {
  TaskType.call: 'call',
  TaskType.email: 'email',
  TaskType.meeting: 'meeting',
  TaskType.followUp: 'followUp',
  TaskType.demo: 'demo',
  TaskType.proposal: 'proposal',
  TaskType.contract: 'contract',
  TaskType.support: 'support',
  TaskType.research: 'research',
  TaskType.other: 'other',
};

const _$TaskStatusEnumMap = {
  TaskStatus.pending: 'pending',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
  TaskStatus.overdue: 'overdue',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
};
