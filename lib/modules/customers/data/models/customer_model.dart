import 'package:json_annotation/json_annotation.dart';
import 'package:simple_crm_flutter/modules/customers/domain/entities/customer.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    required super.type,
    required super.status,
    super.companyName,
    super.website,
    super.address,
    super.industry,
    super.annualRevenue,
    super.employeeCount,
    super.description,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.assignedUserId,
    super.lastContactDate,
    super.lifetimeValue,
    super.totalDeals,
    super.totalTasks,
    super.totalContacts,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);
  
  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      type: customer.type,
      status: customer.status,
      companyName: customer.companyName,
      website: customer.website,
      address: customer.address,
      industry: customer.industry,
      annualRevenue: customer.annualRevenue,
      employeeCount: customer.employeeCount,
      description: customer.description,
      tags: customer.tags,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      assignedUserId: customer.assignedUserId,
      lastContactDate: customer.lastContactDate,
      lifetimeValue: customer.lifetimeValue,
      totalDeals: customer.totalDeals,
      totalTasks: customer.totalTasks,
      totalContacts: customer.totalContacts,
    );
  }

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      email: email,
      phone: phone,
      type: type,
      status: status,
      companyName: companyName,
      website: website,
      address: address,
      industry: industry,
      annualRevenue: annualRevenue,
      employeeCount: employeeCount,
      description: description,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      assignedUserId: assignedUserId,
      lastContactDate: lastContactDate,
      lifetimeValue: lifetimeValue,
      totalDeals: totalDeals,
      totalTasks: totalTasks,
      totalContacts: totalContacts,
    );
  }
}