import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/config/constants.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;
  
  const CustomDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);
    
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, authProvider, creditProvider),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  route: '/home',
                  isSelected: currentRoute == '/home',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event_available,
                  title: 'Sessions',
                  route: '/sessions',
                  isSelected: currentRoute == '/sessions',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.play_circle_filled,
                  title: 'Tutorials',
                  route: '/tutorials',
                  isSelected: currentRoute == '/tutorials',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.credit_card,
                  title: 'Credits',
                  route: '/credits',
                  isSelected: currentRoute == '/credits',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  route: '/profile',
                  isSelected: currentRoute == '/profile',
                ),
                
                const Divider(),
                
                // Only show for admin and instructor roles
                if (authProvider.currentUser != null && 
                    (authProvider.currentUser!.isAdmin || authProvider.currentUser!.isInstructor)) ...[
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      top: 16,
                      bottom: 8,
                    ),
                    child: Text(
                      'MANAGEMENT',
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.event,
                    title: 'Manage Sessions',
                    route: '/admin/sessions',
                    isSelected: currentRoute == '/admin/sessions',
                  ),
                  
                  if (authProvider.currentUser!.isAdmin)
                    _buildDrawerItem(
                      context,
                      icon: Icons.people,
                      title: 'Manage Users',
                      route: '/admin/users',
                      isSelected: currentRoute == '/admin/users',
                    ),
                    
                  _buildDrawerItem(
                    context,
                    icon: Icons.video_library,
                    title: 'Manage Tutorials',
                    route: '/admin/tutorials',
                    isSelected: currentRoute == '/admin/tutorials',
                  ),
                  
                  if (authProvider.currentUser!.isAdmin)
                    _buildDrawerItem(
                      context,
                      icon: Icons.stars,
                      title: 'Manage Credits',
                      route: '/admin/credits',
                      isSelected: currentRoute == '/admin/credits',
                    ),
                    
                  const Divider(),
                ],
                
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: '/settings',
                  isSelected: currentRoute == '/settings',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  route: '/help',
                  isSelected: currentRoute == '/help',
                ),
              ],
            ),
          ),
          _buildFooter(context, authProvider),
        ],
      ),
    );
  }
  
  Widget _buildHeader(
    BuildContext context,
    AuthProvider authProvider,
    CreditProvider creditProvider,
  ) {
    final user = authProvider.currentUser;
    
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
      ),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (user != null) ...[
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  user.name != null && user.name!.isNotEmpty
                      ? user.name![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.name ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeMedium,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: AppTheme.fontSizeSmall,
                ),
              ),
              if (!creditProvider.loading) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRound),
                  ),
                  child: Text(
                    _getRoleText(user.role),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSizeExtraSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Not logged in
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome to FitSAGA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeMedium,
                ),
              ),
              Text(
                'Login to access all features',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: AppTheme.fontSizeSmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textLightColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close the drawer
        if (route != currentRoute) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
  
  Widget _buildFooter(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (authProvider.isAuthenticated) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close drawer
                  _showLogoutConfirmation(context, authProvider);
                },
                icon: const Icon(
                  Icons.logout,
                  size: 18,
                ),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: AppTheme.textColor,
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text('Register'),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.instructor:
        return 'INSTRUCTOR';
      case UserRole.client:
        return 'CLIENT';
      default:
        return 'USER';
    }
  }
}