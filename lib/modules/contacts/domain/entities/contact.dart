import 'package:equatable/equatable.dart';

enum ContactType {
  primaryContact,
  technicalContact,
  billingContact,
  generalContact,
}

enum ContactStatus {
  active,
  inactive,
  unresponsive,
  doNotContact,
}

class Contact extends Equatable {
  final String id;
  final String customerId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? mobilePhone;
  final String? jobTitle;
  final String? department;
  final ContactType type;
  final ContactStatus status;
  final String? linkedInUrl;
  final String? twitterHandle;
  final Map<String, String>? address;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedUserId;
  final String? lastContactDate;
  final String? preferredContactMethod;
  final bool isDecisionMaker;
  final int totalInteractions;
  final int totalTasks;

  const Contact({
    required this.id,
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.mobilePhone,
    this.jobTitle,
    this.department,
    required this.type,
    required this.status,
    this.linkedInUrl,
    this.twitterHandle,
    this.address,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.assignedUserId,
    this.lastContactDate,
    this.preferredContactMethod,
    this.isDecisionMaker = false,
    this.totalInteractions = 0,
    this.totalTasks = 0,
  });

  String get fullName => '$firstName $lastName';

  Contact copyWith({
    String? id,
    String? customerId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? mobilePhone,
    String? jobTitle,
    String? department,
    ContactType? type,
    ContactStatus? status,
    String? linkedInUrl,
    String? twitterHandle,
    Map<String, String>? address,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedUserId,
    String? lastContactDate,
    String? preferredContactMethod,
    bool? isDecisionMaker,
    int? totalInteractions,
    int? totalTasks,
  }) {
    return Contact(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      type: type ?? this.type,
      status: status ?? this.status,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      isDecisionMaker: isDecisionMaker ?? this.isDecisionMaker,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      totalTasks: totalTasks ?? this.totalTasks,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        firstName,
        lastName,
        email,
        phone,
        mobilePhone,
        jobTitle,
        department,
        type,
        status,
        linkedInUrl,
        twitterHandle,
        address,
        notes,
        tags,
        createdAt,
        updatedAt,
        assignedUserId,
        lastContactDate,
        preferredContactMethod,
        isDecisionMaker,
        totalInteractions,
        totalTasks,
      ];
}