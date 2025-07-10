import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_crm_flutter/modules/auth/presentation/pages/login_page.dart';
import 'package:simple_crm_flutter/modules/auth/presentation/providers/auth_provider.dart';
import 'package:simple_crm_flutter/modules/dashboard/presentation/pages/dashboard_page.dart';
import 'package:simple_crm_flutter/modules/customers/presentation/pages/customers_list_page.dart';
import 'package:simple_crm_flutter/modules/customers/presentation/pages/customer_detail_page.dart';
import 'package:simple_crm_flutter/modules/customers/presentation/pages/customer_form_page.dart';
import 'package:simple_crm_flutter/shared/presentation/pages/not_found_page.dart';
import 'package:simple_crm_flutter/shared/presentation/widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );
      
      final isLoginPage = state.matchedLocation == '/login';
      
      if (!isAuthenticated && !isLoginPage) {
        return '/login';
      }
      
      if (isAuthenticated && isLoginPage) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/customers',
            name: 'customers',
            builder: (context, state) => const CustomersListPage(),
            routes: [
              GoRoute(
                path: '/create',
                name: 'customer-create',
                builder: (context, state) => const CustomerFormPage(),
              ),
              GoRoute(
                path: '/:id',
                name: 'customer-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomerDetailPage(customerId: id);
                },
              ),
              GoRoute(
                path: '/:id/edit',
                name: 'customer-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CustomerFormPage(customerId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
