import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/theme_config.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConfig.paddingL),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: ThemeConfig.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.paddingM),
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: ThemeConfig.paddingS),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeConfig.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: ThemeConfig.paddingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.paddingM,
                      vertical: ThemeConfig.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                    ),
                    child: Text(
                      user.role,
                      style: const TextStyle(
                        color: ThemeConfig.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.paddingXL),
                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.person_outlined,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    onTap: () {
                      // TODO: Navigate to payment methods
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: 'Favorites',
                    onTap: () {
                      // TODO: Navigate to favorites
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const SizedBox(height: ThemeConfig.paddingL),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeConfig.errorColor,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await authProvider.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeConfig.errorColor,
                        side: const BorderSide(
                          color: ThemeConfig.errorColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: ThemeConfig.paddingM,
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConfig.paddingM),
      child: ListTile(
        leading: Icon(icon, color: ThemeConfig.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
