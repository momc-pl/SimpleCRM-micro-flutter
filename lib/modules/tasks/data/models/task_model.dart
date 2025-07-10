import 'package:json_annotation/json_annotation.dart';
import 'package:simple_crm_flutter/modules/tasks/domain/entities/task.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.status,
    required super.priority,
    super.customerId,
    super.contactId,
    super.dealId,
    required super.assignedUserId,
    super.createdByUserId,
    required super.dueDate,
    super.completedAt,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    super.tags,
    super.estimatedDuration,
    super.actualDuration,
    super.isRecurring,
    super.recurrencePattern,
    super.attachments,
    super.location,
    super.participantIds,
    super.reminderBefore,
    super.isAllDay,
    super.customFields,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
  
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      type: task.type,
      status: task.status,
      priority: task.priority,
      customerId: task.customerId,
      contactId: task.contactId,
      dealId: task.dealId,
      assignedUserId: task.assignedUserId,
      createdByUserId: task.createdByUserId,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      notes: task.notes,
      tags: task.tags,
      estimatedDuration: task.estimatedDuration,
      actualDuration: task.actualDuration,
      isRecurring: task.isRecurring,
      recurrencePattern: task.recurrencePattern,
      attachments: task.attachments,
      location: task.location,
      participantIds: task.participantIds,
      reminderBefore: task.reminderBefore,
      isAllDay: task.isAllDay,
      customFields: task.customFields,
    );
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      type: type,
      status: status,
      priority: priority,
      customerId: customerId,
      contactId: contactId,
      dealId: dealId,
      assignedUserId: assignedUserId,
      createdByUserId: createdByUserId,
      dueDate: dueDate,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notes: notes,
      tags: tags,
      estimatedDuration: estimatedDuration,
      actualDuration: actualDuration,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      attachments: attachments,
      location: location,
      participantIds: participantIds,
      reminderBefore: reminderBefore,
      isAllDay: isAllDay,
      customFields: customFields,
    );
  }
}