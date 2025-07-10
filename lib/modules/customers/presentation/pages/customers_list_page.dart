import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_crm_flutter/core/theme/app_colors.dart';
import 'package:simple_crm_flutter/shared/presentation/widgets/common_widgets.dart';

class CustomersListPage extends ConsumerStatefulWidget {
  const CustomersListPage({super.key});

  @override
  ConsumerState<CustomersListPage> createState() => _CustomersListPageState();
}

class _CustomersListPageState extends ConsumerState<CustomersListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _customers = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+1 (555) 123-4567',
      'company': 'Tech Corp',
      'status': 'active',
      'lastContact': '2024-01-15',
      'avatar': 'JD',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'phone': '+1 (555) 987-6543',
      'company': 'Design Studio',
      'status': 'inactive',
      'lastContact': '2024-01-10',
      'avatar': 'JS',
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'email': 'bob.johnson@example.com',
      'phone': '+1 (555) 456-7890',
      'company': 'Marketing Inc',
      'status': 'active',
      'lastContact': '2024-01-12',
      'avatar': 'BJ',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((customer) {
      final query = _searchQuery.toLowerCase();
      return customer['name'].toString().toLowerCase().contains(query) ||
          customer['email'].toString().toLowerCase().contains(query) ||
          customer['company'].toString().toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _refreshCustomers() async {
    setState(() => _isLoading = true);
    // TODO: Implement actual refresh logic
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshWrapper(
        onRefresh: _refreshCustomers,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SearchField(
                    controller: _searchController,
                    hintText: 'Search customers...',
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_filteredCustomers.length} customers found',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list_outlined),
                        onPressed: () {
                          // TODO: Implement filter functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Filter feature coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Customers List
            Expanded(
              child: _isLoading
                  ? const LoadingWidget(message: 'Loading customers...')
                  : _filteredCustomers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = _filteredCustomers[index];
                            return _buildCustomerCard(customer);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/customers/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      title: _searchQuery.isEmpty ? 'No customers yet' : 'No customers found',
      subtitle: _searchQuery.isEmpty
          ? 'Start by adding your first customer'
          : 'Try adjusting your search terms',
      icon: Icons.people_outline,
      action: _searchQuery.isEmpty
          ? ElevatedButton.icon(
              onPressed: () => context.go('/customers/create'),
              icon: const Icon(Icons.add),
              label: const Text('Add Customer'),
            )
          : null,
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final isActive = customer['status'] == 'active';
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.go('/customers/${customer['id']}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isActive ? AppColors.primary : AppColors.textSecondary,
                child: Text(
                  customer['avatar'],
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer['name'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        StatusBadge(
                          text: customer['status'],
                          color: isActive ? AppColors.success : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer['company'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.go('/customers/${customer['id']}/edit');
                      break;
                    case 'delete':
                      _showDeleteDialog(customer);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer['email'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer['phone'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Last contact: ${customer['lastContact']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${customer['name']} deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}