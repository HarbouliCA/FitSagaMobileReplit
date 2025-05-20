import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = false;
  String? _error;
  
  // Selected menu item - default to Dashboard
  int _selectedMenuIndex = 0;
  
  // Menu options
  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      screen: const _DashboardContent(),
    ),
    AdminMenuItem(
      title: 'Users',
      icon: Icons.people,
      screen: const _UsersContent(),
    ),
    AdminMenuItem(
      title: 'Tutorials',
      icon: Icons.video_library,
      screen: const _TutorialsContent(),
    ),
    AdminMenuItem(
      title: 'Sessions',
      icon: Icons.event,
      screen: const _SessionsContent(),
    ),
    AdminMenuItem(
      title: 'Credits',
      icon: Icons.monetization_on,
      screen: const _CreditsContent(),
    ),
    AdminMenuItem(
      title: 'Settings',
      icon: Icons.settings,
      screen: const _SettingsContent(),
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Check if user is admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminAccess();
    });
  }
  
  // Check if user has admin privileges
  Future<void> _checkAdminAccess() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    
    if (!authProvider.currentUser!.isAdmin) {
      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to access the admin dashboard'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is authenticated and is admin
    if (!authProvider.isAuthenticated || !authProvider.currentUser!.isAdmin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You do not have admin privileges to access this page.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Admin dashboard layout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show admin notifications
            },
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.accentColor,
            radius: 16,
            child: Text(
              authProvider.currentUser!.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading admin dashboard...')
          : Row(
              children: [
                // Side Navigation
                _buildSideNavigation(),
                
                // Main Content Area
                Expanded(
                  child: _menuItems[_selectedMenuIndex].screen,
                ),
              ],
            ),
    );
  }
  
  Widget _buildSideNavigation() {
    return Container(
      width: 240,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // App Logo
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: const Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                SizedBox(width: 16),
                Text(
                  'FitSAGA Admin',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = _menuItems[index];
                final isSelected = _selectedMenuIndex == index;
                
                return ListTile(
                  leading: Icon(
                    menuItem.icon,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  ),
                  title: Text(
                    menuItem.title,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedMenuIndex = index;
                    });
                  },
                  selected: isSelected,
                  selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                  shape: isSelected
                      ? const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppTheme.borderRadiusRegular),
                            bottomRight: Radius.circular(AppTheme.borderRadiusRegular),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          
          const Divider(),
          
          // Logout Button
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppTheme.errorColor,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
            onTap: _logout,
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Logout function
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await authProvider.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}

// Model for menu items
class AdminMenuItem {
  final String title;
  final IconData icon;
  final Widget screen;
  
  const AdminMenuItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

// Dashboard content widget
class _DashboardContent extends StatelessWidget {
  const _DashboardContent({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: AppTheme.fontSizeTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Stats Cards
          Row(
            children: [
              _buildStatCard(
                title: 'Total Users',
                value: '156',
                icon: Icons.people,
                color: AppTheme.primaryColor,
              ),
              _buildStatCard(
                title: 'Active Sessions',
                value: '24',
                icon: Icons.event_available,
                color: AppTheme.accentColor,
              ),
              _buildStatCard(
                title: 'Tutorials',
                value: '38',
                icon: Icons.video_library,
                color: AppTheme.infoColor,
              ),
              _buildStatCard(
                title: 'Revenue',
                value: '\$2,450',
                icon: Icons.attach_money,
                color: AppTheme.successColor,
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Recent Activity and Charts
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Activity
                Expanded(
                  flex: 2,
                  child: _buildRecentActivity(),
                ),
                
                const SizedBox(width: AppTheme.spacingMedium),
                
                // Stats & Charts
                Expanded(
                  flex: 3,
                  child: _buildUserCharts(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: AppTheme.elevationSmall,
        margin: const EdgeInsets.only(right: AppTheme.spacingMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    icon,
                    color: color.withOpacity(0.8),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: AppTheme.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+12% from last month',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: AppTheme.fontSizeSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    final activities = [
      {
        'user': 'John Doe',
        'action': 'Created a new session',
        'time': '10 minutes ago',
        'icon': Icons.event_available,
        'color': AppTheme.accentColor,
      },
      {
        'user': 'Sarah Johnson',
        'action': 'Booked a personal training session',
        'time': '25 minutes ago',
        'icon': Icons.fitness_center,
        'color': AppTheme.primaryColor,
      },
      {
        'user': 'Admin',
        'action': 'Added a new tutorial',
        'time': '1 hour ago',
        'icon': Icons.video_library,
        'color': AppTheme.infoColor,
      },
      {
        'user': 'Michael Brown',
        'action': 'Purchased 10 credits',
        'time': '2 hours ago',
        'icon': Icons.monetization_on,
        'color': AppTheme.successColor,
      },
      {
        'user': 'Lisa Williams',
        'action': 'Completed a tutorial',
        'time': '3 hours ago',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'user': 'Admin',
        'action': 'Updated gym schedule',
        'time': '5 hours ago',
        'icon': Icons.update,
        'color': AppTheme.warningColor,
      },
    ];
    
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (activity['color'] as Color).withOpacity(0.2),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: activity['color'] as Color,
                      size: 20,
                    ),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppTheme.textPrimaryColor,
                        fontSize: AppTheme.fontSizeRegular,
                      ),
                      children: [
                        TextSpan(
                          text: '${activity['user']} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: activity['action'] as String),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    activity['time'] as String,
                    style: const TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // View activity details
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          TextButton(
            onPressed: () {
              // View all activity
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: const Text('View All Activity'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserCharts() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Growth & Engagement',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: _buildPlaceholderChart(),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            const Text(
              'User Registration by Role',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: _buildRoleDistributionChart(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderChart() {
    // This would be implemented with a real chart library like fl_chart
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: const Center(
        child: Text(
          'User Growth Chart\n(This would use a proper chart library)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleDistributionChart() {
    // This would be implemented with a real chart library
    return Row(
      children: [
        _buildRolePercentage(
          role: 'Clients',
          percentage: 0.85,
          color: AppTheme.primaryColor,
        ),
        _buildRolePercentage(
          role: 'Instructors',
          percentage: 0.12,
          color: AppTheme.accentColor,
        ),
        _buildRolePercentage(
          role: 'Admins',
          percentage: 0.03,
          color: AppTheme.errorColor,
        ),
      ],
    );
  }
  
  Widget _buildRolePercentage({
    required String role,
    required double percentage,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 12,
              ),
            ),
            child: Center(
              child: Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Users management content
class _UsersContent extends StatelessWidget {
  const _UsersContent({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and add button
          Row(
            children: [
              const Text(
                'User Management',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Search field
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Add user button
              ElevatedButton.icon(
                onPressed: () {
                  // Show add user dialog
                },
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingSmall,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Filter options
          Row(
            children: [
              _buildFilterChip(
                label: 'All Users',
                isSelected: true,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Clients',
                isSelected: false,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Instructors',
                isSelected: false,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Admins',
                isSelected: false,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Inactive',
                isSelected: false,
                onSelected: (selected) {},
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Users table
          Expanded(
            child: Card(
              elevation: AppTheme.elevationSmall,
              child: _buildUsersTable(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required void Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primaryLightColor,
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildUsersTable() {
    // Sample users data for illustration
    final users = [
      {
        'id': '1',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'Client',
        'status': 'Active',
        'joined': '12/05/2023',
        'credits': '15',
      },
      {
        'id': '2',
        'name': 'Sarah Johnson',
        'email': 'sarah.johnson@example.com',
        'role': 'Instructor',
        'status': 'Active',
        'joined': '08/10/2023',
        'credits': '20',
      },
      {
        'id': '3',
        'name': 'Michael Brown',
        'email': 'michael.brown@example.com',
        'role': 'Client',
        'status': 'Active',
        'joined': '22/11/2023',
        'credits': '8',
      },
      {
        'id': '4',
        'name': 'Lisa Williams',
        'email': 'lisa.williams@example.com',
        'role': 'Client',
        'status': 'Inactive',
        'joined': '15/03/2023',
        'credits': '0',
      },
      {
        'id': '5',
        'name': 'Robert Taylor',
        'email': 'robert.taylor@example.com',
        'role': 'Admin',
        'status': 'Active',
        'joined': '04/01/2023',
        'credits': '50',
      },
      {
        'id': '6',
        'name': 'Emily Davis',
        'email': 'emily.davis@example.com',
        'role': 'Instructor',
        'status': 'Active',
        'joined': '30/07/2023',
        'credits': '25',
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              _buildTableHeaderCell('User', flex: 3),
              _buildTableHeaderCell('Role'),
              _buildTableHeaderCell('Status'),
              _buildTableHeaderCell('Joined'),
              _buildTableHeaderCell('Credits'),
              _buildTableHeaderCell('Actions', flex: 2),
            ],
          ),
        ),
        
        // Table rows
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserRow(user);
            },
          ),
        ),
        
        // Pagination
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Showing 1-${users.length} of ${users.length}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: null,
                disabledColor: Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: null,
                disabledColor: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTableHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
  
  Widget _buildUserRow(Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: Row(
        children: [
          // User info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(user['role']!).withOpacity(0.2),
                  child: Text(
                    user['name']![0],
                    style: TextStyle(
                      color: _getRoleColor(user['role']!),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user['email']!,
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Role
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(user['role']!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                user['role']!,
                style: TextStyle(
                  color: _getRoleColor(user['role']!),
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeSmall,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Status
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: user['status'] == 'Active'
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user['status']!,
                  style: TextStyle(
                    color: user['status'] == 'Active'
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Joined date
          Expanded(
            child: Text(
              user['joined']!,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Credits
          Expanded(
            child: Text(
              user['credits']!,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: AppTheme.primaryColor,
                  tooltip: 'Edit User',
                  onPressed: () {
                    // Edit user
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.credit_card),
                  color: AppTheme.accentColor,
                  tooltip: 'Manage Credits',
                  onPressed: () {
                    // Manage credits
                  },
                ),
                IconButton(
                  icon: Icon(
                    user['status'] == 'Active' ? Icons.block : Icons.check_circle,
                  ),
                  color: user['status'] == 'Active'
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                  tooltip: user['status'] == 'Active' ? 'Deactivate' : 'Activate',
                  onPressed: () {
                    // Toggle status
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: AppTheme.errorColor,
                  tooltip: 'Delete User',
                  onPressed: () {
                    // Delete user
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return AppTheme.errorColor;
      case 'Instructor':
        return AppTheme.accentColor;
      case 'Client':
      default:
        return AppTheme.primaryColor;
    }
  }
}

// Tutorials management content
class _TutorialsContent extends StatelessWidget {
  const _TutorialsContent({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Tutorial Management',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tutorials',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/tutorials/create');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Tutorial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingSmall,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Filter options
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                label: 'All Tutorials',
                isSelected: true,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Premium',
                isSelected: false,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Free',
                isSelected: false,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Active',
                isSelected: false,
                onSelected: (selected) {},
              ),
              _buildFilterChip(
                label: 'Inactive',
                isSelected: false,
                onSelected: (selected) {},
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Tutorials list (placeholder)
          Expanded(
            child: Center(
              child: Text(
                'Tutorial list would be displayed here',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required void Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppTheme.primaryLightColor,
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

// Sessions management content
class _SessionsContent extends StatelessWidget {
  const _SessionsContent({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sessions Management'),
    );
  }
}

// Credits management content
class _CreditsContent extends StatelessWidget {
  const _CreditsContent({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Credits Management'),
    );
  }
}

// Settings content
class _SettingsContent extends StatelessWidget {
  const _SettingsContent({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings'),
    );
  }
}