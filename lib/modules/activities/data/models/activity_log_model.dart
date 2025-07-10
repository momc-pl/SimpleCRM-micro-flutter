import 'package:json_annotation/json_annotation.dart';
import 'package:simple_crm_flutter/modules/activities/domain/entities/activity_log.dart';

part 'activity_log_model.g.dart';

@JsonSerializable()
class ActivityLogModel extends ActivityLog {
  const ActivityLogModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.userId,
    super.customerId,
    super.contactId,
    super.taskId,
    super.dealId,
    required super.priority,
    required super.createdAt,
    super.metadata,
    super.ipAddress,
    super.userAgent,
    super.deviceInfo,
    super.sessionId,
    super.duration,
    super.oldValues,
    super.newValues,
    super.tags,
    super.notes,
    super.isSystemGenerated,
    super.relatedEntityType,
    super.relatedEntityId,
    super.customFields,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => _$ActivityLogModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ActivityLogModelToJson(this);
  
  factory ActivityLogModel.fromEntity(ActivityLog activityLog) {
    return ActivityLogModel(
      id: activityLog.id,
      type: activityLog.type,
      title: activityLog.title,
      description: activityLog.description,
      userId: activityLog.userId,
      customerId: activityLog.customerId,
      contactId: activityLog.contactId,
      taskId: activityLog.taskId,
      dealId: activityLog.dealId,
      priority: activityLog.priority,
      createdAt: activityLog.createdAt,
      metadata: activityLog.metadata,
      ipAddress: activityLog.ipAddress,
      userAgent: activityLog.userAgent,
      deviceInfo: activityLog.deviceInfo,
      sessionId: activityLog.sessionId,
      duration: activityLog.duration,
      oldValues: activityLog.oldValues,
      newValues: activityLog.newValues,
      tags: activityLog.tags,
      notes: activityLog.notes,
      isSystemGenerated: activityLog.isSystemGenerated,
      relatedEntityType: activityLog.relatedEntityType,
      relatedEntityId: activityLog.relatedEntityId,
      customFields: activityLog.customFields,
    );
  }

  ActivityLog toEntity() {
    return ActivityLog(
      id: id,
      type: type,
      title: title,
      description: description,
      userId: userId,
      customerId: customerId,
      contactId: contactId,
      taskId: taskId,
      dealId: dealId,
      priority: priority,
      createdAt: createdAt,
      metadata: metadata,
      ipAddress: ipAddress,
      userAgent: userAgent,
      deviceInfo: deviceInfo,
      sessionId: sessionId,
      duration: duration,
      oldValues: oldValues,
      newValues: newValues,
      tags: tags,
      notes: notes,
      isSystemGenerated: isSystemGenerated,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      customFields: customFields,
    );
  }
}