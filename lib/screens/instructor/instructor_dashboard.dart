import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/demo/session_detail_demo.dart';

class InstructorDashboard extends StatelessWidget {
  final User user;
  
  const InstructorDashboard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
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
            
            // My Sessions Today
            _buildTodaySessions(context),
            
            const SizedBox(height: 24),
            
            // Quick actions
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // My Students
            _buildMyStudents(context),
            
            const SizedBox(height: 24),
            
            // My Tutorials
            _buildMyTutorials(context),
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
                    'You have 3 sessions today',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Notification button
            Badge(
              label: const Text('3'),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // In a real app, this would navigate to notifications
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTodaySessions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'My Sessions Today',
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
        
        // Today's sessions timeline
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final session = demoSessions[index];
            return IntrinsicHeight(
              child: Row(
                children: [
                  // Timeline
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: [
                        Text(
                          session.formattedStartTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: VerticalDivider(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            thickness: 1,
                            width: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Session card
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionDetailDemo(
                                session: session,
                                user: user,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      session.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSessionStatusColor(session).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getSessionStatusColor(session).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      _getSessionStatusText(session),
                                      style: TextStyle(
                                        color: _getSessionStatusColor(session),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${session.durationMinutes} minutes',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.room,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    session.roomName ?? 'Main Gym',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${session.bookedCount}/${session.capacity} participants',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
              icon: Icons.people,
              label: 'My Students',
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View students feature coming soon'),
                  ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.insights,
              label: 'Analytics',
              color: Colors.orange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Analytics feature coming soon'),
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
  
  Widget _buildMyStudents(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'My Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // In a real app, this would navigate to all students
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStudentCard(
                name: 'Jane Cooper',
                sessions: 12,
                imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View student profile feature coming soon'),
                    ),
                  );
                },
              ),
              _buildStudentCard(
                name: 'Robert Fox',
                sessions: 8,
                imageUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View student profile feature coming soon'),
                    ),
                  );
                },
              ),
              _buildStudentCard(
                name: 'Esther Howard',
                sessions: 15,
                imageUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View student profile feature coming soon'),
                    ),
                  );
                },
              ),
              _buildStudentCard(
                name: 'Jacob Jones',
                sessions: 6,
                imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View student profile feature coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStudentCard({
    required String name,
    required int sessions,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
            
            const SizedBox(height: 8),
            
            // Name
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            
            // Sessions count
            Text(
              '$sessions sessions',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMyTutorials(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'My Tutorials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // In a real app, this would navigate to all tutorials
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
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  title: const Text(
                    'Proper Squat Form for Beginners',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '1,245 views • 12 comments',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // In a real app, this would show options
                    },
                  ),
                ),
                
                const Divider(),
                
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.video_library,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  title: const Text(
                    'Beginners Guide to Deadlifts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '842 views • 5 comments',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // In a real app, this would show options
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Create tutorial feature coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Tutorial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getSessionStatusColor(SessionModel session) {
    if (session.hasAvailableSlots) {
      if (session.availableSlots < 3) {
        return Colors.orange;
      }
      return Colors.green;
    }
    return Colors.red;
  }
  
  String _getSessionStatusText(SessionModel session) {
    if (session.hasAvailableSlots) {
      if (session.availableSlots < 3) {
        return 'Almost Full';
      }
      return 'Open';
    }
    return 'Full';
  }
}