import 'package:json_annotation/json_annotation.dart';
import 'package:simple_crm_flutter/modules/contacts/domain/entities/contact.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    required super.customerId,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.mobilePhone,
    super.jobTitle,
    super.department,
    required super.type,
    required super.status,
    super.linkedInUrl,
    super.twitterHandle,
    super.address,
    super.notes,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.assignedUserId,
    super.lastContactDate,
    super.preferredContactMethod,
    super.isDecisionMaker,
    super.totalInteractions,
    super.totalTasks,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => _$ContactModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
  
  factory ContactModel.fromEntity(Contact contact) {
    return ContactModel(
      id: contact.id,
      customerId: contact.customerId,
      firstName: contact.firstName,
      lastName: contact.lastName,
      email: contact.email,
      phone: contact.phone,
      mobilePhone: contact.mobilePhone,
      jobTitle: contact.jobTitle,
      department: contact.department,
      type: contact.type,
      status: contact.status,
      linkedInUrl: contact.linkedInUrl,
      twitterHandle: contact.twitterHandle,
      address: contact.address,
      notes: contact.notes,
      tags: contact.tags,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
      assignedUserId: contact.assignedUserId,
      lastContactDate: contact.lastContactDate,
      preferredContactMethod: contact.preferredContactMethod,
      isDecisionMaker: contact.isDecisionMaker,
      totalInteractions: contact.totalInteractions,
      totalTasks: contact.totalTasks,
    );
  }

  Contact toEntity() {
    return Contact(
      id: id,
      customerId: customerId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      mobilePhone: mobilePhone,
      jobTitle: jobTitle,
      department: department,
      type: type,
      status: status,
      linkedInUrl: linkedInUrl,
      twitterHandle: twitterHandle,
      address: address,
      notes: notes,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      assignedUserId: assignedUserId,
      lastContactDate: lastContactDate,
      preferredContactMethod: preferredContactMethod,
      isDecisionMaker: isDecisionMaker,
      totalInteractions: totalInteractions,
      totalTasks: totalTasks,
    );
  }
}