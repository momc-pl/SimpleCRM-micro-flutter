import 'package:flutter/material.dart';
import 'package:simple_crm_flutter/shared/presentation/widgets/widgets.dart';
import 'package:simple_crm_flutter/core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Dashboard Overview',
              subtitle: 'Welcome to SimpleCRM',
            ),
            
            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Customers',
                    value: '1,234',
                    icon: Icons.people,
                    iconColor: AppColors.primary,
                    subtitle: '+12% from last month',
                    onTap: () {
                      // TODO: Navigate to customers
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MetricCard(
                    title: 'Active Deals',
                    value: '87',
                    icon: Icons.trending_up,
                    iconColor: AppColors.success,
                    subtitle: '+5% from last week',
                    onTap: () {
                      // TODO: Navigate to deals
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Revenue',
                    value: '\$125,430',
                    icon: Icons.attach_money,
                    iconColor: AppColors.warning,
                    subtitle: '+8% from last month',
                    onTap: () {
                      // TODO: Navigate to revenue
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MetricCard(
                    title: 'Conversion Rate',
                    value: '23.5%',
                    icon: Icons.analytics,
                    iconColor: AppColors.info,
                    subtitle: '+2.1% from last week',
                    onTap: () {
                      // TODO: Navigate to analytics
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const SectionHeader(
              title: 'Recent Activities',
              subtitle: 'Latest updates and actions',
            ),
            
            // Recent Activities
            ActivityCard(
              title: 'New customer added',
              description: 'John Doe from Acme Corp has been added to the system',
              timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
              icon: Icons.person_add,
              iconColor: AppColors.success,
            ),
            
            ActivityCard(
              title: 'Deal updated',
              description: 'Enterprise Software deal moved to negotiation stage',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              icon: Icons.handshake,
              iconColor: AppColors.warning,
            ),
            
            ActivityCard(
              title: 'Meeting scheduled',
              description: 'Follow-up meeting with ABC Company scheduled for tomorrow',
              timestamp: DateTime.now().subtract(const Duration(hours: 4)),
              icon: Icons.calendar_today,
              iconColor: AppColors.primary,
            ),
            
            const SizedBox(height: 24),
            
            const SectionHeader(
              title: 'Quick Actions',
              subtitle: 'Common tasks and shortcuts',
            ),
            
            // Quick Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                FeatureCard(
                  title: 'Add Customer',
                  description: 'Create a new customer profile',
                  icon: Icons.person_add,
                  onTap: () {
                    // TODO: Navigate to add customer
                  },
                ),
                FeatureCard(
                  title: 'Create Deal',
                  description: 'Start a new sales opportunity',
                  icon: Icons.add_business,
                  onTap: () {
                    // TODO: Navigate to create deal
                  },
                ),
                FeatureCard(
                  title: 'Schedule Meeting',
                  description: 'Book a meeting with customers',
                  icon: Icons.event_available,
                  onTap: () {
                    // TODO: Navigate to schedule meeting
                  },
                ),
                FeatureCard(
                  title: 'View Reports',
                  description: 'Analyze sales performance',
                  icon: Icons.bar_chart,
                  onTap: () {
                    // TODO: Navigate to reports
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const SectionHeader(
              title: 'Top Customers',
              subtitle: 'Most valuable customers',
            ),
            
            // Customer Summary Cards
            CustomerSummaryCard(
              customerName: 'John Doe',
              email: 'john.doe@example.com',
              phone: '+1 (555) 123-4567',
              company: 'Acme Corporation',
              status: 'Active',
              lastContact: DateTime.now().subtract(const Duration(days: 2)),
              onTap: () {
                // TODO: Navigate to customer details
              },
              onCall: () {
                // TODO: Initiate call
              },
              onEmail: () {
                // TODO: Send email
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomerSummaryCard(
              customerName: 'Jane Smith',
              email: 'jane.smith@techcorp.com',
              phone: '+1 (555) 987-6543',
              company: 'TechCorp Solutions',
              status: 'Active',
              lastContact: DateTime.now().subtract(const Duration(days: 1)),
              onTap: () {
                // TODO: Navigate to customer details
              },
              onCall: () {
                // TODO: Initiate call
              },
              onEmail: () {
                // TODO: Send email
              },
            ),
          ],
        ),
      ),
    );
  }
}