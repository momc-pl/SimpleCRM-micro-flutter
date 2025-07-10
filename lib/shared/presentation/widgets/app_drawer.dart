import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_crm_flutter/core/theme/app_colors.dart';
import 'package:simple_crm_flutter/core/theme/app_text_styles.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.business_center,
                  size: 48,
                  color: AppColors.onPrimary,
                ),
                SizedBox(height: 16),
                Text(
                  'SimpleCRM',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Customer Management',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          DrawerItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            onTap: () {
              context.go('/');
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: Icons.people_outline,
            title: 'Customers',
            onTap: () {
              context.go('/customers');
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: Icons.trending_up_outlined,
            title: 'Sales Pipeline',
            onTap: () {
              // TODO: Implement sales pipeline navigation
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: Icons.contact_phone_outlined,
            title: 'Contacts',
            onTap: () {
              // TODO: Implement contacts navigation
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: Icons.task_outlined,
            title: 'Tasks',
            onTap: () {
              // TODO: Implement tasks navigation
              Navigator.pop(context);
            },
          ),
          const Divider(),
          DrawerItem(
            icon: Icons.analytics_outlined,
            title: 'Reports',
            onTap: () {
              // TODO: Implement reports navigation
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              // TODO: Implement settings navigation
              Navigator.pop(context);
            },
          ),
          const Divider(),
          DrawerItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Implement help navigation
              Navigator.pop(context);
            },
          ),
          DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // TODO: Implement logout
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  
  const DrawerItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 4,
      ),
    );
  }
}