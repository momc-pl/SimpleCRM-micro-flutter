import 'package:simple_crm_flutter/modules/tasks/domain/entities/task.dart';

abstract class TasksRepository {
  Future<List<Task>> getTasks({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? priority,
    String? type,
    String? assignedUserId,
    String? customerId,
    String? contactId,
    String? dealId,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool? isOverdue,
  });
  
  Future<Task> getTaskById(String id);
  
  Future<Task> createTask(Task task);
  
  Future<Task> updateTask(Task task);
  
  Future<void> deleteTask(String id);
  
  Future<List<Task>> getTasksByAssignedUser(String userId);
  
  Future<List<Task>> getTasksByCustomer(String customerId);
  
  Future<List<Task>> getTasksByContact(String contactId);
  
  Future<List<Task>> getTasksByDeal(String dealId);
  
  Future<List<Task>> searchTasks(String query);
  
  Future<Task> assignTaskToUser(String taskId, String userId);
  
  Future<Task> updateTaskStatus(String taskId, String status);
  
  Future<Task> completeTask(String taskId, {String? notes, Duration? actualDuration});
  
  Future<List<Task>> getOverdueTasks(String? userId);
  
  Future<List<Task>> getTasksDueToday(String? userId);
  
  Future<List<Task>> getTasksDueThisWeek(String? userId);
  
  Future<List<Task>> getRecentTasks(int limit, String? userId);
  
  Future<Map<String, dynamic>> getTaskStats(String? userId);
  
  Future<List<Task>> getTasksByTags(List<String> tags);
  
  Future<Task> updateTaskPriority(String taskId, String priority);
  
  Future<void> bulkUpdateTasks(List<String> taskIds, Map<String, dynamic> updates);
  
  Future<void> bulkDeleteTasks(List<String> taskIds);
  
  Future<List<Task>> getRecurringTasks(String? userId);
  
  Future<Task> createRecurringTask(Task task, String recurrencePattern);
  
  Future<void> snoozeTask(String taskId, DateTime newDueDate);
  
  Future<List<Task>> getTasksByDateRange(DateTime start, DateTime end, String? userId);
  
  Future<List<Task>> importTasks(List<Map<String, dynamic>> tasksData);
  
  Future<List<Map<String, dynamic>>> exportTasks({
    List<String>? taskIds,
    String? format,
    String? userId,
  });
}