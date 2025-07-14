// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DealModel _$DealModelFromJson(Map<String, dynamic> json) => DealModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      customerId: json['customerId'] as String,
      contactId: json['contactId'] as String?,
      assignedUserId: json['assignedUserId'] as String,
      createdByUserId: json['createdByUserId'] as String?,
      status: $enumDecode(_$DealStatusEnumMap, json['status']),
      priority: $enumDecode(_$DealPriorityEnumMap, json['priority']),
      source: $enumDecode(_$DealSourceEnumMap, json['source']),
      value: (json['value'] as num).toDouble(),
      currency: json['currency'] as String,
      probability: (json['probability'] as num).toDouble(),
      expectedCloseDate: DateTime.parse(json['expectedCloseDate'] as String),
      actualCloseDate: json['actualCloseDate'] == null
          ? null
          : DateTime.parse(json['actualCloseDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      lossReason: json['lossReason'] as String?,
      competitorName: json['competitorName'] as String?,
      customFields: (json['customFields'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nextAction: json['nextAction'] as String?,
      nextActionDate: json['nextActionDate'] == null
          ? null
          : DateTime.parse(json['nextActionDate'] as String),
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      paymentTerms: json['paymentTerms'] as String?,
      deliveryTerms: json['deliveryTerms'] as String?,
      productIds: (json['productIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      proposalUrl: json['proposalUrl'] as String?,
      contractUrl: json['contractUrl'] as String?,
    );

Map<String, dynamic> _$DealModelToJson(DealModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'customerId': instance.customerId,
      'contactId': instance.contactId,
      'assignedUserId': instance.assignedUserId,
      'createdByUserId': instance.createdByUserId,
      'status': _$DealStatusEnumMap[instance.status]!,
      'priority': _$DealPriorityEnumMap[instance.priority]!,
      'source': _$DealSourceEnumMap[instance.source]!,
      'value': instance.value,
      'currency': instance.currency,
      'probability': instance.probability,
      'expectedCloseDate': instance.expectedCloseDate.toIso8601String(),
      'actualCloseDate': instance.actualCloseDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'notes': instance.notes,
      'tags': instance.tags,
      'lossReason': instance.lossReason,
      'competitorName': instance.competitorName,
      'customFields': instance.customFields,
      'attachments': instance.attachments,
      'nextAction': instance.nextAction,
      'nextActionDate': instance.nextActionDate?.toIso8601String(),
      'totalTasks': instance.totalTasks,
      'completedTasks': instance.completedTasks,
      'discountPercent': instance.discountPercent,
      'discountAmount': instance.discountAmount,
      'paymentTerms': instance.paymentTerms,
      'deliveryTerms': instance.deliveryTerms,
      'productIds': instance.productIds,
      'proposalUrl': instance.proposalUrl,
      'contractUrl': instance.contractUrl,
    };

const _$DealStatusEnumMap = {
  DealStatus.prospecting: 'prospecting',
  DealStatus.qualification: 'qualification',
  DealStatus.needsAnalysis: 'needsAnalysis',
  DealStatus.proposalSent: 'proposalSent',
  DealStatus.negotiation: 'negotiation',
  DealStatus.closedWon: 'closedWon',
  DealStatus.closedLost: 'closedLost',
  DealStatus.onHold: 'onHold',
};

const _$DealPriorityEnumMap = {
  DealPriority.low: 'low',
  DealPriority.medium: 'medium',
  DealPriority.high: 'high',
  DealPriority.critical: 'critical',
};

const _$DealSourceEnumMap = {
  DealSource.website: 'website',
  DealSource.referral: 'referral',
  DealSource.coldCall: 'coldCall',
  DealSource.email: 'email',
  DealSource.socialMedia: 'socialMedia',
  DealSource.tradeShow: 'tradeShow',
  DealSource.partner: 'partner',
  DealSource.advertisement: 'advertisement',
  DealSource.other: 'other',
};
