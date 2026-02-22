import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/kitchen_provider.dart';

class KitchenSettingsScreen extends StatelessWidget {
  const KitchenSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<AuthProvider, KitchenProvider>(
        builder: (context, authProvider, kitchenProvider, _) {
          final user = authProvider.currentUser;
          final kitchen = kitchenProvider.myKitchen;

          return ListView(
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(16),
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: ThemeConfig.primaryColor,
                      child: Text(
                        user?.firstName.substring(0, 1).toUpperCase() ?? 'K',
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kitchen?.name ?? user?.fullName ?? 'Kitchen Owner',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Kitchen Settings
              _buildSectionHeader('Kitchen Settings'),
              _buildSettingsTile(
                icon: Icons.store,
                title: 'Kitchen Profile',
                subtitle: 'Edit kitchen information',
                onTap: () => context.push('/kitchen/profile'),
              ),
              _buildSettingsTile(
                icon: Icons.schedule,
                title: 'Operating Hours',
                subtitle: 'Set your working hours',
                onTap: () => context.push('/kitchen/hours'),
              ),
              _buildSettingsTile(
                icon: Icons.location_on,
                title: 'Location',
                subtitle: 'Update delivery area',
                onTap: () => context.push('/kitchen/location'),
              ),

              const SizedBox(height: 16),

              // Notifications
              _buildSectionHeader('Notifications'),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Order Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {},
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: ThemeConfig.primaryColor,
                ),
              ),
              _buildSettingsTile(
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Order alert sounds',
                onTap: () {},
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: ThemeConfig.primaryColor,
                ),
              ),

              const SizedBox(height: 16),

              // Account
              _buildSectionHeader('Account'),
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Account Settings',
                subtitle: 'Update your account details',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {},
              ),

              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

