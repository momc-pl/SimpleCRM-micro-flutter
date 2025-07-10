import 'package:simple_crm_flutter/modules/deals/domain/entities/deal.dart';

abstract class DealsRepository {
  Future<List<Deal>> getDeals({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? priority,
    String? source,
    String? assignedUserId,
    String? customerId,
    String? contactId,
    DateTime? expectedCloseDateFrom,
    DateTime? expectedCloseDateTo,
    double? valueFrom,
    double? valueTo,
    double? probabilityFrom,
    double? probabilityTo,
  });
  
  Future<Deal> getDealById(String id);
  
  Future<Deal> createDeal(Deal deal);
  
  Future<Deal> updateDeal(Deal deal);
  
  Future<void> deleteDeal(String id);
  
  Future<List<Deal>> getDealsByAssignedUser(String userId);
  
  Future<List<Deal>> getDealsByCustomer(String customerId);
  
  Future<List<Deal>> getDealsByContact(String contactId);
  
  Future<List<Deal>> searchDeals(String query);
  
  Future<Deal> assignDealToUser(String dealId, String userId);
  
  Future<Deal> updateDealStatus(String dealId, String status);
  
  Future<Deal> updateDealStage(String dealId, String stage);
  
  Future<Deal> updateDealProbability(String dealId, double probability);
  
  Future<Deal> updateDealValue(String dealId, double value);
  
  Future<Deal> closeDeal(String dealId, String status, {String? notes, String? lossReason});
  
  Future<List<Deal>> getActiveDealsByUser(String userId);
  
  Future<List<Deal>> getClosedDeals(String? userId, {DateTime? from, DateTime? to});
  
  Future<List<Deal>> getOverdueDeals(String? userId);
  
  Future<List<Deal>> getDealsClosingThisWeek(String? userId);
  
  Future<List<Deal>> getDealsClosingThisMonth(String? userId);
  
  Future<List<Deal>> getHighValueDeals(double threshold, String? userId);
  
  Future<List<Deal>> getHighProbabilityDeals(double threshold, String? userId);
  
  Future<List<Deal>> getRecentDeals(int limit, String? userId);
  
  Future<Map<String, dynamic>> getDealStats(String? userId);
  
  Future<Map<String, dynamic>> getSalesPipelineStats(String? userId);
  
  Future<List<Deal>> getDealsByTags(List<String> tags);
  
  Future<Deal> updateDealPriority(String dealId, String priority);
  
  Future<void> bulkUpdateDeals(List<String> dealIds, Map<String, dynamic> updates);
  
  Future<void> bulkDeleteDeals(List<String> dealIds);
  
  Future<List<Deal>> getWonDeals(String? userId, {DateTime? from, DateTime? to});
  
  Future<List<Deal>> getLostDeals(String? userId, {DateTime? from, DateTime? to});
  
  Future<Map<String, dynamic>> getConversionRates(String? userId);
  
  Future<Map<String, dynamic>> getRevenueReport(String? userId, {DateTime? from, DateTime? to});
  
  Future<List<Deal>> getDealsByDateRange(DateTime start, DateTime end, String? userId);
  
  Future<List<Deal>> importDeals(List<Map<String, dynamic>> dealsData);
  
  Future<List<Map<String, dynamic>>> exportDeals({
    List<String>? dealIds,
    String? format,
    String? userId,
  });
}