import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = false;
  String? _error;
  
  // Dashboard statistics (these would come from a proper data source)
  final Map<String, int> _stats = {
    'activeUsers': 125,
    'activeSessions': 48,
    'totalBookings': 357,
    'premiumUsers': 43,
  };
  
  // Recent activity (this would come from a proper data source)
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'type': 'booking',
      'message': 'John Smith booked Kickboxing Class',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'type': 'user',
      'message': 'New user registered: Maria Garcia',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'type': 'session',
      'message': 'Session "Yoga Fundamentals" was updated',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'type': 'payment',
      'message': 'Alex Johnson purchased 10 credits',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'type': 'booking',
      'message': 'Sarah Wilson cancelled Spin Class',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    // Ensure only admins can access this page
    if (!authProvider.isAuthenticated || !(user?.isAdmin ?? false)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'You do not have permission to access this page',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'This area is restricted to administrators only',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to main screen
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh dashboard data
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Retry loading data
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildDashboard(),
    );
  }
  
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome back, ${Provider.of<AuthProvider>(context).currentUser?.name}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Here\'s what\'s happening in your gym today',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics cards
          _buildStatisticsGrid(),
          
          const SizedBox(height: 24),
          
          // Quick actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Recent activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildRecentActivity(),
          
          const SizedBox(height: 24),
          
          // Today's sessions
          const Text(
            'Today\'s Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildTodaySessions(),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Active Users',
          value: _stats['activeUsers'] ?? 0,
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Active Sessions',
          value: _stats['activeSessions'] ?? 0,
          icon: Icons.fitness_center,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Total Bookings',
          value: _stats['totalBookings'] ?? 0,
          icon: Icons.calendar_today,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Premium Users',
          value: _stats['premiumUsers'] ?? 0,
          icon: Icons.star,
          color: Colors.purple,
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          label: 'Create Session',
          icon: Icons.add_circle,
          color: Colors.green,
          onTap: () {
            // Navigate to create session screen
          },
        ),
        _buildActionButton(
          label: 'Manage Users',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () {
            // Navigate to user management
          },
        ),
        _buildActionButton(
          label: 'View Bookings',
          icon: Icons.calendar_today,
          color: Colors.orange,
          onTap: () {
            // Navigate to bookings
          },
        ),
        _buildActionButton(
          label: 'Reports',
          icon: Icons.bar_chart,
          color: Colors.purple,
          onTap: () {
            // Navigate to reports
          },
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentActivity.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final activity = _recentActivity[index];
          return ListTile(
            leading: _getActivityIcon(activity['type']),
            title: Text(activity['message']),
            subtitle: Text(
              _formatTimestamp(activity['timestamp']),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show more options
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _getActivityIcon(String type) {
    switch (type) {
      case 'booking':
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          child: Icon(Icons.calendar_today, size: 16),
        );
      case 'user':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: Icon(Icons.person, size: 16),
        );
      case 'session':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.fitness_center, size: 16),
        );
      case 'payment':
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          child: Icon(Icons.attach_money, size: 16),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          child: Icon(Icons.info, size: 16),
        );
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
  
  Widget _buildTodaySessions() {
    // This would come from an actual data source
    final dummySessions = [
      {
        'title': 'Morning Yoga',
        'time': '07:00 - 08:00',
        'instructor': 'Sarah Johnson',
        'bookings': 12,
        'capacity': 15,
      },
      {
        'title': 'HIIT Training',
        'time': '12:30 - 13:30',
        'instructor': 'Mike Torres',
        'bookings': 8,
        'capacity': 10,
      },
      {
        'title': 'Spin Class',
        'time': '17:00 - 18:00',
        'instructor': 'Emma Williams',
        'bookings': 15,
        'capacity': 15,
      },
      {
        'title': 'Kickboxing',
        'time': '19:00 - 20:00',
        'instructor': 'Alex Chen',
        'bookings': 7,
        'capacity': 12,
      },
    ];
    
    return Column(
      children: dummySessions.map((session) {
        final int bookings = session['bookings'] as int;
        final int capacity = session['capacity'] as int;
        final double fillPercentage = bookings / capacity;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session['time'] as String,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Instructor: ${session['instructor']}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: fillPercentage == 1.0
                            ? Colors.red.withOpacity(0.1)
                            : fillPercentage > 0.7
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: fillPercentage == 1.0
                              ? Colors.red
                              : fillPercentage > 0.7
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                      child: Text(
                        '$bookings/$capacity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fillPercentage == 1.0
                              ? Colors.red
                              : fillPercentage > 0.7
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: fillPercentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    fillPercentage == 1.0
                        ? Colors.red
                        : fillPercentage > 0.7
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // View session details
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Edit session
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}