// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      type: $enumDecode(_$CustomerTypeEnumMap, json['type']),
      status: $enumDecode(_$CustomerStatusEnumMap, json['status']),
      companyName: json['companyName'] as String?,
      website: json['website'] as String?,
      address: (json['address'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      industry: json['industry'] as String?,
      annualRevenue: (json['annualRevenue'] as num?)?.toDouble(),
      employeeCount: (json['employeeCount'] as num?)?.toInt(),
      description: json['description'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      assignedUserId: json['assignedUserId'] as String?,
      lastContactDate: json['lastContactDate'] as String?,
      lifetimeValue: (json['lifetimeValue'] as num?)?.toDouble(),
      totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      totalContacts: (json['totalContacts'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'type': _$CustomerTypeEnumMap[instance.type]!,
      'status': _$CustomerStatusEnumMap[instance.status]!,
      'companyName': instance.companyName,
      'website': instance.website,
      'address': instance.address,
      'industry': instance.industry,
      'annualRevenue': instance.annualRevenue,
      'employeeCount': instance.employeeCount,
      'description': instance.description,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'assignedUserId': instance.assignedUserId,
      'lastContactDate': instance.lastContactDate,
      'lifetimeValue': instance.lifetimeValue,
      'totalDeals': instance.totalDeals,
      'totalTasks': instance.totalTasks,
      'totalContacts': instance.totalContacts,
    };

const _$CustomerTypeEnumMap = {
  CustomerType.individual: 'individual',
  CustomerType.business: 'business',
  CustomerType.enterprise: 'enterprise',
};

const _$CustomerStatusEnumMap = {
  CustomerStatus.active: 'active',
  CustomerStatus.inactive: 'inactive',
  CustomerStatus.potential: 'potential',
  CustomerStatus.suspended: 'suspended',
};
