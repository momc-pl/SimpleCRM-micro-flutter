import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_crm_flutter/core/theme/app_colors.dart';
import 'package:simple_crm_flutter/shared/presentation/widgets/common_widgets.dart';

class CustomerDetailPage extends ConsumerWidget {
  final String customerId;
  
  const CustomerDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock customer data
    final customer = {
      'id': customerId,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+1 (555) 123-4567',
      'company': 'Tech Corp',
      'position': 'Software Engineer',
      'address': '123 Main Street, Anytown, USA 12345',
      'status': 'active',
      'joinDate': '2024-01-15',
      'lastContact': '2024-01-15',
      'totalOrders': 5,
      'totalSpent': 2450.00,
      'avatar': 'JD',
      'notes': 'Key client interested in our premium services. Very responsive to emails.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/customers/$customerId/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog(context, customer);
                  break;
                case 'share':
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 8),
                    Text('Share'),
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
      body: RefreshWrapper(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(context, customer),
              const SizedBox(height: 24),
              _buildContactSection(context, customer),
              const SizedBox(height: 24),
              _buildStatsSection(context, customer),
              const SizedBox(height: 24),
              _buildNotesSection(context, customer),
              const SizedBox(height: 24),
              _buildActivitySection(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add order or activity
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add activity feature coming soon!')),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, Map<String, dynamic> customer) {
    final isActive = customer['status'] == 'active';
    
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: isActive ? AppColors.primary : AppColors.textSecondary,
                child: Text(
                  customer['avatar'],
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer['name'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatusBadge(
                          text: customer['status'],
                          color: isActive ? AppColors.success : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${customer['position']} at ${customer['company']}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer since ${customer['joinDate']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, Map<String, dynamic> customer) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(
            context,
            Icons.email_outlined,
            'Email',
            customer['email'],
            () {
              // TODO: Open email client
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email client would open here')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            context,
            Icons.phone_outlined,
            'Phone',
            customer['phone'],
            () {
              // TODO: Open phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone dialer would open here')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            context,
            Icons.location_on_outlined,
            'Address',
            customer['address'],
            () {
              // TODO: Open maps
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maps would open here')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, dynamic> customer) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Orders',
                  customer['totalOrders'].toString(),
                  Icons.receipt_long_outlined,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Spent',
                  '\$${customer['totalSpent'].toStringAsFixed(2)}',
                  Icons.attach_money_outlined,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Last Contact',
                  customer['lastContact'],
                  Icons.schedule_outlined,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Customer Since',
                  customer['joinDate'],
                  Icons.calendar_today_outlined,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, Map<String, dynamic> customer) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // TODO: Implement edit notes
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit notes feature coming soon!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customer['notes'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            context,
            'Order #1234 completed',
            '2 days ago',
            Icons.check_circle_outline,
            AppColors.success,
          ),
          const Divider(),
          _buildActivityItem(
            context,
            'Email sent: Follow-up on proposal',
            '5 days ago',
            Icons.email_outlined,
            AppColors.primary,
          ),
          const Divider(),
          _buildActivityItem(
            context,
            'Customer information updated',
            '1 week ago',
            Icons.edit_outlined,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> customer) {
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
              Navigator.pop(context);
              context.go('/customers');
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