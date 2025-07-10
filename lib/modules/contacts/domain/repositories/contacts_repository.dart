import 'package:simple_crm_flutter/modules/contacts/domain/entities/contact.dart';

abstract class ContactsRepository {
  Future<List<Contact>> getContacts({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? type,
    String? customerId,
    String? assignedUserId,
  });
  
  Future<Contact> getContactById(String id);
  
  Future<Contact> createContact(Contact contact);
  
  Future<Contact> updateContact(Contact contact);
  
  Future<void> deleteContact(String id);
  
  Future<List<Contact>> getContactsByCustomer(String customerId);
  
  Future<List<Contact>> getContactsByAssignedUser(String userId);
  
  Future<List<Contact>> searchContacts(String query);
  
  Future<Contact> assignContactToUser(String contactId, String userId);
  
  Future<List<Contact>> getRecentContacts(int limit);
  
  Future<Map<String, dynamic>> getContactStats();
  
  Future<List<Contact>> getContactsByTags(List<String> tags);
  
  Future<Contact> updateContactStatus(String contactId, String status);
  
  Future<void> bulkUpdateContacts(List<String> contactIds, Map<String, dynamic> updates);
  
  Future<void> bulkDeleteContacts(List<String> contactIds);
  
  Future<List<Contact>> importContacts(List<Map<String, dynamic>> contactsData);
  
  Future<List<Map<String, dynamic>>> exportContacts({
    List<String>? contactIds,
    String? format,
  });
  
  Future<List<Contact>> getDecisionMakers(String customerId);
  
  Future<List<Contact>> getContactsByDepartment(String department);
  
  Future<Contact> updateLastContactDate(String contactId, DateTime date);
}