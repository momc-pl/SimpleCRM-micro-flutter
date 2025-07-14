import 'package:simple_crm_flutter/modules/customers/domain/repositories/customers_repository.dart';

class DeleteCustomerUseCase {
  final CustomersRepository _repository;

  DeleteCustomerUseCase(this._repository);

  Future<void> call(String customerId) async {
    return await _repository.deleteCustomer(customerId);
  }
}
