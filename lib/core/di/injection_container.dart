import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_crm_flutter/core/network/dio_client.dart';
import 'package:simple_crm_flutter/core/network/interceptors/auth_interceptor.dart';
import 'package:simple_crm_flutter/core/storage/secure_storage.dart';
import 'package:simple_crm_flutter/modules/auth/data/datasources/auth_remote_datasource.dart';
import 'package:simple_crm_flutter/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:simple_crm_flutter/modules/auth/domain/repositories/auth_repository.dart';
import 'package:simple_crm_flutter/modules/auth/domain/usecases/login_usecase.dart';
import 'package:simple_crm_flutter/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:simple_crm_flutter/modules/customers/data/datasources/customers_remote_datasource.dart';
import 'package:simple_crm_flutter/modules/customers/data/repositories/customers_repository_impl.dart';
import 'package:simple_crm_flutter/modules/customers/domain/repositories/customers_repository.dart';
import 'package:simple_crm_flutter/modules/customers/domain/usecases/get_customers_usecase.dart';
import 'package:simple_crm_flutter/modules/customers/domain/usecases/create_customer_usecase.dart';
import 'package:simple_crm_flutter/modules/customers/domain/usecases/update_customer_usecase.dart';
import 'package:simple_crm_flutter/modules/customers/domain/usecases/delete_customer_usecase.dart';
import 'package:simple_crm_flutter/core/services/health_check_service.dart';
import 'package:simple_crm_flutter/core/services/microservices_coordinator.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core dependencies
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage(sl()),
  );
  
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl()),
  );
  
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.interceptors.add(sl<AuthInterceptor>());
    return dio;
  });
  
  sl.registerLazySingleton<DioClient>(
    () {
      final client = DioClient(sl());
      client.addAuthInterceptor(sl<AuthInterceptor>());
      return client;
    },
  );
  
  // Microservices coordination
  sl.registerLazySingleton<HealthCheckService>(
    () => HealthCheckService(sl()),
  );
  
  sl.registerLazySingleton<MicroservicesCoordinator>(
    () => MicroservicesCoordinator(sl()),
  );
  
  // Auth module
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl()),
  );
  
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl()),
  );
  
  // Customers module
  sl.registerLazySingleton<CustomersRemoteDataSource>(
    () => CustomersRemoteDataSource(sl()),
  );
  
  sl.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(sl()),
  );
  
  sl.registerLazySingleton<GetCustomersUseCase>(
    () => GetCustomersUseCase(sl()),
  );
  
  sl.registerLazySingleton<CreateCustomerUseCase>(
    () => CreateCustomerUseCase(sl()),
  );
  
  sl.registerLazySingleton<UpdateCustomerUseCase>(
    () => UpdateCustomerUseCase(sl()),
  );
  
  sl.registerLazySingleton<DeleteCustomerUseCase>(
    () => DeleteCustomerUseCase(sl()),
  );
}
