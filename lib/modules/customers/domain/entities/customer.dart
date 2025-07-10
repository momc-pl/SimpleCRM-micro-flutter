import 'package:equatable/equatable.dart';

enum CustomerStatus {
  active,
  inactive,
  potential,
  suspended,
}

enum CustomerType {
  individual,
  business,
  enterprise,
}

class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final CustomerType type;
  final CustomerStatus status;
  final String? companyName;
  final String? website;
  final Map<String, String>? address;
  final String? industry;
  final double? annualRevenue;
  final int? employeeCount;
  final String? description;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedUserId;
  final String? lastContactDate;
  final double? lifetimeValue;
  final int totalDeals;
  final int totalTasks;
  final int totalContacts;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.type,
    required this.status,
    this.companyName,
    this.website,
    this.address,
    this.industry,
    this.annualRevenue,
    this.employeeCount,
    this.description,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.assignedUserId,
    this.lastContactDate,
    this.lifetimeValue,
    this.totalDeals = 0,
    this.totalTasks = 0,
    this.totalContacts = 0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    CustomerType? type,
    CustomerStatus? status,
    String? companyName,
    String? website,
    Map<String, String>? address,
    String? industry,
    double? annualRevenue,
    int? employeeCount,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedUserId,
    String? lastContactDate,
    double? lifetimeValue,
    int? totalDeals,
    int? totalTasks,
    int? totalContacts,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      status: status ?? this.status,
      companyName: companyName ?? this.companyName,
      website: website ?? this.website,
      address: address ?? this.address,
      industry: industry ?? this.industry,
      annualRevenue: annualRevenue ?? this.annualRevenue,
      employeeCount: employeeCount ?? this.employeeCount,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      lastContactDate: lastContactDate ?? this.lastContactDate,
      lifetimeValue: lifetimeValue ?? this.lifetimeValue,
      totalDeals: totalDeals ?? this.totalDeals,
      totalTasks: totalTasks ?? this.totalTasks,
      totalContacts: totalContacts ?? this.totalContacts,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        type,
        status,
        companyName,
        website,
        address,
        industry,
        annualRevenue,
        employeeCount,
        description,
        tags,
        createdAt,
        updatedAt,
        assignedUserId,
        lastContactDate,
        lifetimeValue,
        totalDeals,
        totalTasks,
        totalContacts,
      ];
}