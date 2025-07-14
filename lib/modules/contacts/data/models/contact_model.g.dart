// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactModel _$ContactModelFromJson(Map<String, dynamic> json) => ContactModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      mobilePhone: json['mobilePhone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      department: json['department'] as String?,
      type: $enumDecode(_$ContactTypeEnumMap, json['type']),
      status: $enumDecode(_$ContactStatusEnumMap, json['status']),
      linkedInUrl: json['linkedInUrl'] as String?,
      twitterHandle: json['twitterHandle'] as String?,
      address: (json['address'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      notes: json['notes'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      assignedUserId: json['assignedUserId'] as String?,
      lastContactDate: json['lastContactDate'] as String?,
      preferredContactMethod: json['preferredContactMethod'] as String?,
      isDecisionMaker: json['isDecisionMaker'] as bool? ?? false,
      totalInteractions: (json['totalInteractions'] as num?)?.toInt() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ContactModelToJson(ContactModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'mobilePhone': instance.mobilePhone,
      'jobTitle': instance.jobTitle,
      'department': instance.department,
      'type': _$ContactTypeEnumMap[instance.type]!,
      'status': _$ContactStatusEnumMap[instance.status]!,
      'linkedInUrl': instance.linkedInUrl,
      'twitterHandle': instance.twitterHandle,
      'address': instance.address,
      'notes': instance.notes,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'assignedUserId': instance.assignedUserId,
      'lastContactDate': instance.lastContactDate,
      'preferredContactMethod': instance.preferredContactMethod,
      'isDecisionMaker': instance.isDecisionMaker,
      'totalInteractions': instance.totalInteractions,
      'totalTasks': instance.totalTasks,
    };

const _$ContactTypeEnumMap = {
  ContactType.primaryContact: 'primaryContact',
  ContactType.technicalContact: 'technicalContact',
  ContactType.billingContact: 'billingContact',
  ContactType.generalContact: 'generalContact',
};

const _$ContactStatusEnumMap = {
  ContactStatus.active: 'active',
  ContactStatus.inactive: 'inactive',
  ContactStatus.unresponsive: 'unresponsive',
  ContactStatus.doNotContact: 'doNotContact',
};
