import 'package:simple_crm_flutter/modules/customers/domain/entities/customer.dart';
import 'package:simple_crm_flutter/modules/customers/domain/repositories/customers_repository.dart';

class GetCustomersUseCase {
  final CustomersRepository _repository;

  GetCustomersUseCase(this._repository);

  Future<List<Customer>> call() async {
    return await _repository.getCustomers();
  }
}
