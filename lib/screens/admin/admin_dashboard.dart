import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/demo/session_detail_demo.dart';

class AdminDashboard extends StatelessWidget {
  final User user;
  
  const AdminDashboard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            _buildWelcomeCard(),
            
            const SizedBox(height: 24),
            
            // Stats overview
            _buildStatsOverview(),
            
            const SizedBox(height: 24),
            
            // Quick actions
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // Recent sessions
            _buildRecentSessions(context),
            
            const SizedBox(height: 24),
            
            // User management
            _buildUserManagement(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Welcome text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.displayName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have 5 new notifications',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification button
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // In a real app, this would navigate to notifications
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stats Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildStatCard(
              title: 'Active Members',
              value: '124',
              icon: Icons.people,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Sessions Today',
              value: '8',
              icon: Icons.calendar_today,
              color: Colors.orange,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildStatCard(
              title: 'New Sign-ups',
              value: '12',
              icon: Icons.person_add,
              color: Colors.green,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              title: 'Active Instructors',
              value: '6',
              icon: Icons.sports,
              color: Colors.purple,
            ),
          ],
        ),
      ],
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
                  Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: color,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '5%',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildActionButton(
              icon: Icons.add_circle,
              label: 'New Session',
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create session feature coming soon'),
                  ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.video_library,
              label: 'New Tutorial',
              color: Colors.blue,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create tutorial feature coming soon'),
                  ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.person_add,
              label: 'Add User',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add user feature coming soon'),
                  ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.grey,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings feature coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSessions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // In a real app, this would navigate to all sessions
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: demoSessions.take(3).length,
          itemBuilder: (context, index) {
            final session = demoSessions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: session.imageUrl != null
                      ? Image.network(
                          session.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                          ),
                        ),
                ),
                title: Text(
                  session.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${session.formattedDate} • ${session.formattedStartTime}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: session.hasAvailableSlots
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: session.hasAvailableSlots
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    session.hasAvailableSlots
                        ? '${session.availableSlots} spots'
                        : 'Full',
                    style: TextStyle(
                      color: session.hasAvailableSlots
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionDetailDemo(
                        session: session,
                        user: UserModel(
                          id: 'client1',
                          name: 'Client User',
                          gymCredits: 10,
                          intervalCredits: 5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildUserManagement(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'User Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // In a real app, this would navigate to user management
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Users',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // User list
                _buildUserListItem(
                  name: 'Jane Cooper',
                  email: 'jane.cooper@example.com',
                  role: 'Client',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View user profile feature coming soon'),
                      ),
                    );
                  },
                ),
                
                const Divider(),
                
                _buildUserListItem(
                  name: 'Robert Fox',
                  email: 'robert.fox@example.com',
                  role: 'Instructor',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View user profile feature coming soon'),
                      ),
                    );
                  },
                ),
                
                const Divider(),
                
                _buildUserListItem(
                  name: 'Esther Howard',
                  email: 'esther.howard@example.com',
                  role: 'Client',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('View user profile feature coming soon'),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Add user button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add user feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add New User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUserListItem({
    required String name,
    required String email,
    required String role,
    required VoidCallback onTap,
  }) {
    Color roleColor;
    
    switch (role.toLowerCase()) {
      case 'admin':
        roleColor = Colors.red;
        break;
      case 'instructor':
        roleColor = Colors.green;
        break;
      case 'client':
        roleColor = Colors.blue;
        break;
      default:
        roleColor = Colors.grey;
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: roleColor.withOpacity(0.5),
                ),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}