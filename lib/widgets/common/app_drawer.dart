import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/navigation/app_router.dart';

/// A shared drawer widget for navigation that adapts based on user role
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = authProvider.isAdmin;
    final isInstructor = authProvider.isInstructor;
    final isClient = authProvider.isClient;
    
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, user?.displayName ?? 'Guest', user?.email ?? 'guest@fitsaga.com', user?.photoUrl),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Common items for all users
                _buildListTile(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.initial),
                ),
                
                // Client-specific items
                if (isClient) ...[
                  _buildListTile(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Sessions',
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.sessions),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.list_alt,
                    title: 'My Bookings',
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.bookings),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.video_library,
                    title: 'Tutorials',
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.tutorials),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.credit_card,
                    title: 'Credits',
                    onTap: () {
                      // Navigate to credits screen
                      Navigator.pop(context);
                    },
                  ),
                ],
                
                // Instructor-specific items
                if (isInstructor) ...[
                  _buildListTile(
                    context,
                    icon: Icons.event_available,
                    title: 'My Sessions',
                    onTap: () {
                      // Navigate to instructor sessions
                      Navigator.pop(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.people,
                    title: 'My Clients',
                    onTap: () {
                      // Navigate to instructor clients
                      Navigator.pop(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.assessment,
                    title: 'Analytics',
                    onTap: () {
                      // Navigate to instructor analytics
                      Navigator.pop(context);
                    },
                  ),
                ],
                
                // Admin-specific items
                if (isAdmin) ...[
                  _buildListTile(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.adminDashboard),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.people,
                    title: 'Manage Users',
                    onTap: () {
                      // Navigate to manage users
                      Navigator.pop(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.event,
                    title: 'Manage Sessions',
                    onTap: () {
                      // Navigate to manage sessions
                      Navigator.pop(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.video_collection,
                    title: 'Manage Tutorials',
                    onTap: () {
                      // Navigate to manage tutorials
                      Navigator.pop(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    onTap: () {
                      // Navigate to reports
                      Navigator.pop(context);
                    },
                  ),
                ],
                
                const Divider(),
                
                // Common items for all users
                _buildListTile(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.profile),
                ),
                _buildListTile(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    // Navigate to settings
                    Navigator.pop(context);
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {
                    // Navigate to help & support
                    Navigator.pop(context);
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    // Sign out
                    authProvider.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build drawer header with user info
  Widget _buildHeader(BuildContext context, String name, String email, String? photoUrl) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(email),
      currentAccountPicture: CircleAvatar(
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        backgroundColor: photoUrl == null ? AppTheme.primaryColor : null,
        child: photoUrl == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'G',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
      ),
    );
  }
  
  // Build a list tile for the drawer
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}