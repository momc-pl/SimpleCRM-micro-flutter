import 'package:equatable/equatable.dart';

enum DealStatus {
  prospecting,
  qualification,
  needsAnalysis,
  proposalSent,
  negotiation,
  closedWon,
  closedLost,
  onHold,
}

enum DealPriority {
  low,
  medium,
  high,
  critical,
}

enum DealSource {
  website,
  referral,
  coldCall,
  email,
  socialMedia,
  tradeShow,
  partner,
  advertisement,
  other,
}

class Deal extends Equatable {
  final String id;
  final String title;
  final String description;
  final String customerId;
  final String? contactId;
  final String assignedUserId;
  final String? createdByUserId;
  final DealStatus status;
  final DealPriority priority;
  final DealSource source;
  final double value;
  final String currency;
  final double probability;
  final DateTime expectedCloseDate;
  final DateTime? actualCloseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final List<String> tags;
  final String? lossReason;
  final String? competitorName;
  final Map<String, String>? customFields;
  final List<String> attachments;
  final String? nextAction;
  final DateTime? nextActionDate;
  final int totalTasks;
  final int completedTasks;
  final double? discountPercent;
  final double? discountAmount;
  final String? paymentTerms;
  final String? deliveryTerms;
  final List<String> productIds;
  final String? proposalUrl;
  final String? contractUrl;

  const Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.customerId,
    this.contactId,
    required this.assignedUserId,
    this.createdByUserId,
    required this.status,
    required this.priority,
    required this.source,
    required this.value,
    required this.currency,
    required this.probability,
    required this.expectedCloseDate,
    this.actualCloseDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.tags = const [],
    this.lossReason,
    this.competitorName,
    this.customFields,
    this.attachments = const [],
    this.nextAction,
    this.nextActionDate,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.discountPercent,
    this.discountAmount,
    this.paymentTerms,
    this.deliveryTerms,
    this.productIds = const [],
    this.proposalUrl,
    this.contractUrl,
  });

  bool get isWon => status == DealStatus.closedWon;
  bool get isLost => status == DealStatus.closedLost;
  bool get isClosed => isWon || isLost;
  bool get isActive => !isClosed;
  bool get isOverdue => expectedCloseDate.isBefore(DateTime.now()) && !isClosed;
  double get weightedValue => value * (probability / 100);
  double get discountedValue => discountAmount != null ? value - discountAmount! : 
    discountPercent != null ? value * (1 - discountPercent! / 100) : value;
  double get taskCompletionRate => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

  Deal copyWith({
    String? id,
    String? title,
    String? description,
    String? customerId,
    String? contactId,
    String? assignedUserId,
    String? createdByUserId,
    DealStatus? status,
    DealPriority? priority,
    DealSource? source,
    double? value,
    String? currency,
    double? probability,
    DateTime? expectedCloseDate,
    DateTime? actualCloseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? tags,
    String? lossReason,
    String? competitorName,
    Map<String, String>? customFields,
    List<String>? attachments,
    String? nextAction,
    DateTime? nextActionDate,
    int? totalTasks,
    int? completedTasks,
    double? discountPercent,
    double? discountAmount,
    String? paymentTerms,
    String? deliveryTerms,
    List<String>? productIds,
    String? proposalUrl,
    String? contractUrl,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      customerId: customerId ?? this.customerId,
      contactId: contactId ?? this.contactId,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      probability: probability ?? this.probability,
      expectedCloseDate: expectedCloseDate ?? this.expectedCloseDate,
      actualCloseDate: actualCloseDate ?? this.actualCloseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      lossReason: lossReason ?? this.lossReason,
      competitorName: competitorName ?? this.competitorName,
      customFields: customFields ?? this.customFields,
      attachments: attachments ?? this.attachments,
      nextAction: nextAction ?? this.nextAction,
      nextActionDate: nextActionDate ?? this.nextActionDate,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      productIds: productIds ?? this.productIds,
      proposalUrl: proposalUrl ?? this.proposalUrl,
      contractUrl: contractUrl ?? this.contractUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        customerId,
        contactId,
        assignedUserId,
        createdByUserId,
        status,
        priority,
        source,
        value,
        currency,
        probability,
        expectedCloseDate,
        actualCloseDate,
        createdAt,
        updatedAt,
        notes,
        tags,
        lossReason,
        competitorName,
        customFields,
        attachments,
        nextAction,
        nextActionDate,
        totalTasks,
        completedTasks,
        discountPercent,
        discountAmount,
        paymentTerms,
        deliveryTerms,
        productIds,
        proposalUrl,
        contractUrl,
      ];
}