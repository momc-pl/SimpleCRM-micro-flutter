import 'package:equatable/equatable.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  overdue,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

enum TaskType {
  call,
  email,
  meeting,
  followUp,
  demo,
  proposal,
  contract,
  support,
  research,
  other,
}

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskStatus status;
  final TaskPriority priority;
  final String? customerId;
  final String? contactId;
  final String? dealId;
  final String assignedUserId;
  final String? createdByUserId;
  final DateTime dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final List<String> tags;
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final bool isRecurring;
  final String? recurrencePattern;
  final List<String> attachments;
  final String? location;
  final List<String> participantIds;
  final String? reminderBefore;
  final bool isAllDay;
  final Map<String, dynamic>? customFields;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    this.customerId,
    this.contactId,
    this.dealId,
    required this.assignedUserId,
    this.createdByUserId,
    required this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.tags = const [],
    this.estimatedDuration,
    this.actualDuration,
    this.isRecurring = false,
    this.recurrencePattern,
    this.attachments = const [],
    this.location,
    this.participantIds = const [],
    this.reminderBefore,
    this.isAllDay = false,
    this.customFields,
  });

  bool get isOverdue => status != TaskStatus.completed && dueDate.isBefore(DateTime.now());
  bool get isCompleted => status == TaskStatus.completed;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isPending => status == TaskStatus.pending;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskType? type,
    TaskStatus? status,
    TaskPriority? priority,
    String? customerId,
    String? contactId,
    String? dealId,
    String? assignedUserId,
    String? createdByUserId,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? tags,
    Duration? estimatedDuration,
    Duration? actualDuration,
    bool? isRecurring,
    String? recurrencePattern,
    List<String>? attachments,
    String? location,
    List<String>? participantIds,
    String? reminderBefore,
    bool? isAllDay,
    Map<String, dynamic>? customFields,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      customerId: customerId ?? this.customerId,
      contactId: contactId ?? this.contactId,
      dealId: dealId ?? this.dealId,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      attachments: attachments ?? this.attachments,
      location: location ?? this.location,
      participantIds: participantIds ?? this.participantIds,
      reminderBefore: reminderBefore ?? this.reminderBefore,
      isAllDay: isAllDay ?? this.isAllDay,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        priority,
        customerId,
        contactId,
        dealId,
        assignedUserId,
        createdByUserId,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
        notes,
        tags,
        estimatedDuration,
        actualDuration,
        isRecurring,
        recurrencePattern,
        attachments,
        location,
        participantIds,
        reminderBefore,
        isAllDay,
        customFields,
      ];
}