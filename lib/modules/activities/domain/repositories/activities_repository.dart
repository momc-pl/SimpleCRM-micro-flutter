import 'package:simple_crm_flutter/modules/activities/domain/entities/activity_log.dart';

abstract class ActivitiesRepository {
  Future<List<ActivityLog>> getActivities({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? type,
    String? priority,
    String? userId,
    String? customerId,
    String? contactId,
    String? taskId,
    String? dealId,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isSystemGenerated,
  });
  
  Future<ActivityLog> getActivityById(String id);
  
  Future<ActivityLog> createActivity(ActivityLog activity);
  
  Future<ActivityLog> updateActivity(ActivityLog activity);
  
  Future<void> deleteActivity(String id);
  
  Future<List<ActivityLog>> getActivitiesByUser(String userId);
  
  Future<List<ActivityLog>> getActivitiesByCustomer(String customerId);
  
  Future<List<ActivityLog>> getActivitiesByContact(String contactId);
  
  Future<List<ActivityLog>> getActivitiesByTask(String taskId);
  
  Future<List<ActivityLog>> getActivitiesByDeal(String dealId);
  
  Future<List<ActivityLog>> searchActivities(String query);
  
  Future<List<ActivityLog>> getRecentActivities(int limit, String? userId);
  
  Future<List<ActivityLog>> getActivitiesByType(String type, String? userId);
  
  Future<List<ActivityLog>> getSystemActivities(String? userId);
  
  Future<List<ActivityLog>> getUserActivities(String? userId);
  
  Future<Map<String, dynamic>> getActivityStats(String? userId);
  
  Future<List<ActivityLog>> getActivitiesByTags(List<String> tags);
  
  Future<List<ActivityLog>> getActivitiesByDateRange(DateTime start, DateTime end, String? userId);
  
  Future<List<ActivityLog>> getActivitiesByPriority(String priority, String? userId);
  
  Future<void> bulkDeleteActivities(List<String> activityIds);
  
  Future<List<ActivityLog>> getActivitiesWithChanges(String? userId);
  
  Future<List<ActivityLog>> getActivitiesByEntity(String entityType, String entityId);
  
  Future<void> logActivity({
    required String type,
    required String title,
    required String description,
    required String userId,
    String? customerId,
    String? contactId,
    String? taskId,
    String? dealId,
    String? priority,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    List<String>? tags,
    String? notes,
    bool isSystemGenerated = false,
  });
  
  Future<List<ActivityLog>> getAuditTrail(String entityType, String entityId);
  
  Future<List<Map<String, dynamic>>> exportActivities({
    List<String>? activityIds,
    String? format,
    String? userId,
    DateTime? from,
    DateTime? to,
  });
  
  Future<void> archiveOldActivities(DateTime cutoffDate);
  
  Future<Map<String, dynamic>> getActivitySummary(String? userId, {DateTime? from, DateTime? to});
}