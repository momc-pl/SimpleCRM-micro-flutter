import 'package:simple_crm_flutter/modules/customers/domain/entities/customer.dart';
import 'package:simple_crm_flutter/modules/customers/domain/repositories/customers_repository.dart';

class UpdateCustomerUseCase {
  final CustomersRepository _repository;

  UpdateCustomerUseCase(this._repository);

  Future<Customer> call(Customer customer) async {
    return await _repository.updateCustomer(customer);
  }
}
