import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/navigation/app_router.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/tutorial_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh data
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 24),
                  
                  _buildCreditSummary(),
                  const SizedBox(height: 24),
                  
                  // Quick actions
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  
                  // Upcoming sessions
                  _buildSectionHeader('Upcoming Sessions', 'View All', () {
                    Navigator.of(context).pushNamed(AppRouter.sessions);
                  }),
                  const SizedBox(height: 12),
                  _buildUpcomingSessions(),
                  const SizedBox(height: 24),
                  
                  // Featured tutorials
                  _buildSectionHeader('Featured Tutorials', 'View All', () {
                    Navigator.of(context).pushNamed(AppRouter.tutorials);
                  }),
                  const SizedBox(height: 12),
                  _buildFeaturedTutorials(),
                  const SizedBox(height: 24),
                  
                  // Notifications
                  _buildSectionHeader('Latest Updates', 'View All', () {
                    // Navigate to all notifications
                  }),
                  const SizedBox(height: 12),
                  _buildNotifications(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.firstName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready for your next fitness session?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.profile);
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
            child: user?.photoUrl == null
                ? Text(
                    user?.initials ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreditSummary() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final gymCredits = user?.credits.gymCredits ?? 0;
    final intervalCredits = user?.credits.intervalCredits ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Credits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to buy credits screen
                  },
                  child: const Text('Buy More'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gym credits
                _buildCreditDisplay(
                  'Gym Credits',
                  gymCredits.toString(),
                  Icons.fitness_center,
                  Colors.blue,
                ),
                
                // Divider
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                ),
                
                // Interval credits
                _buildCreditDisplay(
                  'Interval Credits',
                  intervalCredits.toString(),
                  Icons.timer,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditDisplay(
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Book Session',
        'icon': Icons.event_available,
        'color': Colors.blue,
        'route': AppRouter.sessions,
      },
      {
        'title': 'My Bookings',
        'icon': Icons.calendar_today,
        'color': Colors.orange,
        'route': AppRouter.userBookings,
      },
      {
        'title': 'Tutorials',
        'icon': Icons.video_library,
        'color': Colors.green,
        'route': AppRouter.tutorials,
      },
      {
        'title': 'Profile',
        'icon': Icons.person,
        'color': Colors.purple,
        'route': AppRouter.profile,
      },
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return _buildQuickActionButton(
          title: action['title'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          onTap: () {
            Navigator.of(context).pushNamed(action['route'] as String);
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionText),
        ),
      ],
    );
  }
  
  Widget _buildUpcomingSessions() {
    // Get sample sessions for demo
    final sessions = SessionModel.getSampleSessions();
    
    // Filter for upcoming sessions
    final upcomingSessions = sessions.where((session) => session.isUpcoming).toList();
    
    if (upcomingSessions.isEmpty) {
      return _buildEmptyState(
        'No upcoming sessions',
        'Browse available sessions to book your next workout',
        Icons.event_busy,
      );
    }
    
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: upcomingSessions.length,
        itemBuilder: (context, index) {
          final session = upcomingSessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }
  
  Widget _buildSessionCard(SessionModel session) {
    final hasAvailableSlots = session.hasAvailableSlots;
    
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and tags
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    session.imageUrl ?? 'https://via.placeholder.com/280x120?text=Fitness+Session',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.fitness_center,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasAvailableSlots ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasAvailableSlots
                          ? '${session.availableSlots} spots left'
                          : 'Full',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.formattedTimeRange,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSessionTag(session.sessionType, AppTheme.accentColor),
                      const SizedBox(width: 8),
                      _buildSessionTag('${session.creditsRequired} credits', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildFeaturedTutorials() {
    // In a real app, we would get tutorials from a provider
    // For demo purposes, we'll use hard-coded tutorials
    final tutorials = _getSampleTutorials();
    
    if (tutorials.isEmpty) {
      return _buildEmptyState(
        'No tutorials available',
        'Check back later for new tutorials',
        Icons.video_library,
      );
    }
    
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tutorials.length,
        itemBuilder: (context, index) {
          final tutorial = tutorials[index];
          return _buildTutorialCard(tutorial);
        },
      ),
    );
  }
  
  Widget _buildTutorialCard(TutorialDay tutorial) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                tutorial.imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.video_library,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorial.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutorial.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSessionTag(tutorial.difficulty, _getDifficultyColor(tutorial.difficulty)),
                      const SizedBox(width: 8),
                      _buildSessionTag('${tutorial.estimatedMinutes} min', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  Widget _buildNotifications() {
    // In a real app, we would get notifications from a provider
    // For demo purposes, we'll use hard-coded notifications
    final notifications = _getSampleNotifications();
    
    if (notifications.isEmpty) {
      return _buildEmptyState(
        'No notifications',
        'You\'re all caught up!',
        Icons.notifications_off,
      );
    }
    
    return Column(
      children: notifications.map((notification) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: notification['color'] as Color,
              child: Icon(
                notification['icon'] as IconData,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(notification['title'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['message'] as String),
                const SizedBox(height: 4),
                Text(
                  notification['time'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () {
              // Handle notification tap
            },
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Sample data methods
  List<Map<String, dynamic>> _getSampleNotifications() {
    return [
      {
        'title': 'Session Reminder',
        'message': 'Your HIIT Training session is tomorrow at 6:00 PM',
        'time': '2 hours ago',
        'icon': Icons.event_note,
        'color': Colors.blue,
      },
      {
        'title': 'New Tutorial Available',
        'message': 'Check out our new strength training tutorial',
        'time': '1 day ago',
        'icon': Icons.video_library,
        'color': Colors.green,
      },
      {
        'title': 'Credits Added',
        'message': 'Your monthly 10 gym credits have been added',
        'time': '2 days ago',
        'icon': Icons.credit_card,
        'color': Colors.orange,
      },
    ];
  }
  
  List<TutorialDay> _getSampleTutorials() {
    // Create sample tutorial data
    return [
      TutorialDay(
        id: 'tutorial1',
        title: 'Morning Yoga Routine',
        subtitle: 'Start your day energized',
        description: 'A gentle yoga routine to start your day with energy and focus.',
        dayNumber: 1,
        difficulty: 'beginner',
        estimatedMinutes: 30,
        imageUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
        exercises: [],
        tags: ['yoga', 'morning', 'beginner'],
      ),
      TutorialDay(
        id: 'tutorial2',
        title: 'HIIT Cardio Blast',
        subtitle: 'Intensive fat burning',
        description: 'High-intensity interval training for maximum calorie burn.',
        dayNumber: 2,
        difficulty: 'intermediate',
        estimatedMinutes: 45,
        imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798',
        exercises: [],
        tags: ['cardio', 'hiit', 'intermediate'],
      ),
      TutorialDay(
        id: 'tutorial3',
        title: 'Full Body Strength',
        subtitle: 'Build muscle and power',
        description: 'A complete strength workout targeting all major muscle groups.',
        dayNumber: 3,
        difficulty: 'advanced',
        estimatedMinutes: 60,
        imageUrl: 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5',
        exercises: [],
        tags: ['strength', 'full body', 'advanced'],
      ),
      TutorialDay(
        id: 'tutorial4',
        title: 'Core Stability',
        subtitle: 'Strengthen your foundation',
        description: 'Focus on building a strong core and improving posture.',
        dayNumber: 4,
        difficulty: 'intermediate',
        estimatedMinutes: 35,
        imageUrl: 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712',
        exercises: [],
        tags: ['core', 'stability', 'intermediate'],
      ),
    ];
  }
}