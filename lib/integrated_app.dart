import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screens/sessions/session_detail_screen.dart';
import 'screens/sessions/create_session_screen.dart';
import 'screens/tutorials/enhanced_create_tutorial_screen.dart';

class IntegratedFitSagaApp extends StatelessWidget {
  const IntegratedFitSagaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF0D47A1),
          secondary: const Color(0xFF1976D2),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitSAGA Demo'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and app name
              const Icon(
                Icons.fitness_center,
                size: 80,
                color: Color(0xFF0D47A1),
              ),
              const SizedBox(height: 16),
              const Text(
                'FitSAGA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gym Management System',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              
              const Text(
                'Select a role to explore:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Admin role
              _buildRoleCard(
                context,
                title: 'Admin Dashboard',
                description: 'Manage users, sessions, and view statistics',
                icon: Icons.admin_panel_settings,
                color: Colors.red,
                onTap: () => _navigateToRole(context, 'admin'),
              ),
              
              const SizedBox(height: 16),
              
              // Instructor role
              _buildRoleCard(
                context,
                title: 'Instructor Dashboard',
                description: 'Manage sessions, tutorials, and students',
                icon: Icons.sports,
                color: Colors.green,
                onTap: () => _navigateToRole(context, 'instructor'),
              ),
              
              const SizedBox(height: 16),
              
              // Client role
              _buildRoleCard(
                context,
                title: 'Client View',
                description: 'Book sessions, view tutorials, and manage profile',
                icon: Icons.person,
                color: Colors.blue,
                onTap: () => _navigateToRole(context, 'client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToRole(BuildContext context, String role) {
    Widget screen;
    
    switch (role) {
      case 'admin':
        screen = const AdminDashboardScreen();
        break;
      case 'instructor':
        screen = const InstructorDashboardScreen();
        break;
      case 'client':
        screen = const ClientHomeScreen();
        break;
      default:
        screen = const ClientHomeScreen();
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Tutorials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildAdminDashboard();
      case 1:
        return _buildCalendarView();
      case 2:
        return const TutorialsViewDemo();
      case 3:
        return const ProfileViewDemo(role: 'admin');
      default:
        return _buildAdminDashboard();
    }
  }
  
  Widget _buildAdminDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: const Text(
                      'A',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome, Admin User',
                          style: TextStyle(
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
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats overview
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
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.add_circle,
                label: 'New Session',
                color: Colors.green,
                onTap: () => _navigateToCreateSession(context),
              ),
              _buildActionButton(
                context: context,
                icon: Icons.video_library,
                label: 'New Tutorial',
                color: Colors.blue,
                onTap: () => _navigateToCreateTutorial(context),
              ),
              _buildActionButton(
                context: context,
                icon: Icons.person_add,
                label: 'Add User',
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add user feature coming soon')),
                  );
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.grey,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings feature coming soon')),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent sessions
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
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Session list
          _buildSessionItem(
            context: context,
            title: 'Morning Yoga Flow',
            time: '9:00 AM - 10:00 AM',
            date: 'Today',
            instructor: 'Sara Johnson',
            spotsLeft: 7,
            category: 'Yoga',
          ),
          
          _buildSessionItem(
            context: context,
            title: 'HIIT Circuit Training',
            time: '6:00 PM - 6:45 PM',
            date: 'Today',
            instructor: 'Mike Torres',
            spotsLeft: 0,
            category: 'HIIT',
          ),
          
          _buildSessionItem(
            context: context,
            title: 'Strength Foundations',
            time: '5:00 PM - 6:00 PM',
            date: 'Tomorrow',
            instructor: 'David Clark',
            spotsLeft: 5,
            category: 'Strength',
          ),
        ],
      ),
    );
  }
  
  void _navigateToCreateSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSessionScreen(
          userRole: 'admin',
          onSessionCreated: (sessionData) {
            // In a real app, we would add the session to a state management system
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session created successfully!')),
            );
          },
        ),
      ),
    );
  }
  
  void _navigateToCreateTutorial(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedCreateTutorialScreen(
          userRole: 'admin',
          onTutorialCreated: (tutorialData) {
            // In a real app, we would add the tutorial to a state management system
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tutorial created successfully!')),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildCalendarView() {
    return CalendarViewDemo();
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
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
    );
  }
  
  Widget _buildSessionItem({
    required BuildContext context,
    required String title,
    required String time,
    required String date,
    required String instructor,
    required int spotsLeft,
    required String category,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$date • $time • $instructor',
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
            color: spotsLeft > 0
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: spotsLeft > 0
                  ? Colors.green.withOpacity(0.5)
                  : Colors.red.withOpacity(0.5),
            ),
          ),
          child: Text(
            spotsLeft > 0
                ? '$spotsLeft spots'
                : 'Full',
            style: TextStyle(
              color: spotsLeft > 0
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => _openSessionDetails(context, title, category),
      ),
    );
  }
  
  // Open session details
  void _openSessionDetails(BuildContext context, String title, String category) {
    // Create a session model with demo data
    final session = SessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      instructor: title.contains('Yoga') 
          ? 'Sara Johnson' 
          : (title.contains('HIIT') ? 'Mike Torres' : 'David Clark'),
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      duration: title.contains('HIIT') ? 45 : 60, // Duration in minutes
      location: title.contains('Yoga') 
          ? 'Studio A' 
          : (title.contains('HIIT') ? 'Cardio Room' : 'Weight Room'),
      category: category,
      capacity: 15,
      enrolled: title.contains('HIIT') ? 15 : (title.contains('Yoga') ? 8 : 10),
      creditsRequired: title.contains('HIIT') ? 2 : 1,
      description: 'This $title session is designed for all fitness levels. '
          'You will ${title.contains('Yoga') 
              ? 'improve flexibility and reduce stress through a series of poses and breathing exercises' 
              : (title.contains('HIIT') 
                  ? 'burn calories and improve cardiovascular health through high-intensity exercises' 
                  : 'build strength and muscle tone through progressive resistance training')
          }. Please bring ${title.contains('Yoga') 
              ? 'a yoga mat and comfortable clothing' 
              : (title.contains('HIIT') 
                  ? 'water and a towel' 
                  : 'appropriate workout attire')
          }.',
    );
    
    // Navigate to session detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          session: session,
          userRole: 'admin',
          userGymCredits: 0,
          userIntervalCredits: 0,
        ),
      ),
    );
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Instructor Dashboard Screen
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardScreenState();
}

class _InstructorDashboardScreenState extends State<InstructorDashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Tutorials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildInstructorDashboard();
      case 1:
        return CalendarViewDemo();
      case 2:
        return const TutorialsViewDemo();
      case 3:
        return const ProfileViewDemo(role: 'instructor');
      default:
        return _buildInstructorDashboard();
    }
  }
  
  Widget _buildInstructorDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: const Text(
                      'I',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome, Instructor User',
                          style: TextStyle(
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
                  Badge(
                    label: const Text('3'),
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Today's sessions
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
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sessions timeline
          _buildSessionTimelineItem(
            time: '9:00 AM',
            title: 'Morning Yoga Flow',
            location: 'Studio A',
            duration: '60 min',
            status: 'Open',
          ),
          
          _buildSessionTimelineItem(
            time: '12:00 PM',
            title: 'Spin Class',
            location: 'Spin Studio',
            duration: '45 min',
            status: 'Almost Full',
          ),
          
          _buildSessionTimelineItem(
            time: '5:00 PM',
            title: 'Strength Foundations',
            location: 'Weight Room',
            duration: '60 min',
            status: 'Open',
          ),
          
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
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                context: context,
                icon: Icons.add_circle,
                label: 'New Session',
                color: Colors.green,
                onTap: () => _navigateToCreateSession(context),
              ),
              _buildActionButton(
                context: context,
                icon: Icons.video_library,
                label: 'New Tutorial',
                color: Colors.blue,
                onTap: () => _navigateToCreateTutorial(context),
              ),
              _buildActionButton(
                context: context,
                icon: Icons.people,
                label: 'My Students',
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Students feature coming soon')),
                  );
                },
              ),
              _buildActionButton(
                context: context,
                icon: Icons.insights,
                label: 'Analytics',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics feature coming soon')),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // My students
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
                onPressed: () {},
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
                _buildStudentCard(name: 'Jane Cooper', sessions: 12),
                _buildStudentCard(name: 'Robert Fox', sessions: 8),
                _buildStudentCard(name: 'Esther Howard', sessions: 15),
                _buildStudentCard(name: 'Jacob Jones', sessions: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToCreateSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSessionScreen(
          userRole: 'instructor',
          onSessionCreated: (sessionData) {
            // In a real app, we would add the session to a state management system
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session created successfully!')),
            );
          },
        ),
      ),
    );
  }
  
  void _navigateToCreateTutorial(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedCreateTutorialScreen(
          userRole: 'instructor',
          onTutorialCreated: (tutorialData) {
            // In a real app, we would add the tutorial to a state management system
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tutorial created successfully!')),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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
    );
  }
  
  Widget _buildSessionTimelineItem({
    required String time,
    required String title,
    required String location,
    required String duration,
    required String status,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'almost full':
        statusColor = Colors.orange;
        break;
      case 'full':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: VerticalDivider(
                    color: const Color(0xFF0D47A1).withOpacity(0.5),
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
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
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
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
                          duration,
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
                          location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentCard({required String name, required int sessions}) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
    );
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Client Dashboard Screen
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitSAGA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Tutorials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return CalendarViewDemo();
      case 1:
        return const TutorialsViewDemo();
      case 2:
        return const ProfileViewDemo(role: 'client');
      default:
        return CalendarViewDemo();
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// SHARED VIEWS
class CalendarViewDemo extends StatelessWidget {
  CalendarViewDemo({Key? key}) : super(key: key);

  // Get the current date
  final now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Generate weekdays starting from Monday
    final weekDays = List.generate(7, (index) {
      final dayOfWeek = now.weekday;
      final startOfWeek = now.subtract(Duration(days: dayOfWeek - 1));
      return startOfWeek.add(Duration(days: index));
    });
    
    return Column(
      children: [
        // Calendar header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays.map((day) {
              final isSelected = day.day == now.day;
              final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
              
              return Container(
                width: 40,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF0D47A1).withOpacity(0.2) 
                      : (isToday ? Colors.amber.shade200 : Colors.transparent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(day).toLowerCase().substring(0, 2),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0D47A1) : Colors.black,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        // Filter chips
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('All Classes', true),
              _buildFilterChip('HIIT', false),
              _buildFilterChip('Yoga', false),
              _buildFilterChip('Strength', false),
              _buildFilterChip('Instructors', false),
            ],
          ),
        ),
        
        // Session list or empty state
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _openSessionDetails(context, 'Morning Yoga Flow', 'Yoga'),
                  child: _buildSessionCard(
                    title: 'Morning Yoga Flow',
                    time: '9:00 AM',
                    instructor: 'Sara Johnson',
                    spots: 7,
                    total: 15,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openSessionDetails(context, 'HIIT Circuit Training', 'HIIT'),
                  child: _buildSessionCard(
                    title: 'HIIT Circuit Training',
                    time: '6:00 PM',
                    instructor: 'Mike Torres',
                    spots: 0,
                    total: 15,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openSessionDetails(context, 'Strength Foundations', 'Strength'),
                  child: _buildSessionCard(
                    title: 'Strength Foundations',
                    time: '5:00 PM',
                    instructor: 'David Clark',
                    spots: 5,
                    total: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {},
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFF0D47A1).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0D47A1) : Colors.transparent,
            width: 1,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSessionCard({
    required String title,
    required String time,
    required String instructor,
    required int spots,
    required int total,
  }) {
    final bool isFull = spots <= 0;
    final Color statusColor = isFull ? Colors.red : Colors.green;
    
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
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    isFull ? 'Full' : '$spots spots',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  instructor,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (total - spots) / total,
                    backgroundColor: Colors.grey[200],
                    color: statusColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${total - spots}/$total',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _openSessionDetails(BuildContext context, String title, String category) {
    // Create a session model with demo data
    final session = SessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      instructor: title.contains('Yoga') 
          ? 'Sara Johnson' 
          : (title.contains('HIIT') ? 'Mike Torres' : 'David Clark'),
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      duration: title.contains('HIIT') ? 45 : 60, // Duration in minutes
      location: title.contains('Yoga') 
          ? 'Studio A' 
          : (title.contains('HIIT') ? 'Cardio Room' : 'Weight Room'),
      category: category,
      capacity: 15,
      enrolled: title.contains('HIIT') ? 15 : (title.contains('Yoga') ? 8 : 10),
      creditsRequired: title.contains('HIIT') ? 2 : 1,
      description: 'This $title session is designed for all fitness levels. '
          'You will ${title.contains('Yoga') 
              ? 'improve flexibility and reduce stress through a series of poses and breathing exercises' 
              : (title.contains('HIIT') 
                  ? 'burn calories and improve cardiovascular health through high-intensity exercises' 
                  : 'build strength and muscle tone through progressive resistance training')
          }. Please bring ${title.contains('Yoga') 
              ? 'a yoga mat and comfortable clothing' 
              : (title.contains('HIIT') 
                  ? 'water and a towel' 
                  : 'appropriate workout attire')
          }.',
    );
    
    // Navigate to session detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          session: session,
          userRole: 'client',
          userGymCredits: 10,
          userIntervalCredits: 2,
        ),
      ),
    );
  }
}

class TutorialsViewDemo extends StatelessWidget {
  const TutorialsViewDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tutorials...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          
          // Tab bar
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Cardio'),
              Tab(text: 'Strength'),
              Tab(text: 'Flexibility'),
            ],
            labelColor: Color(0xFF0D47A1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0D47A1),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildTutorialGrid(const [
                  TutorialInfo(
                    title: 'Proper Squat Form for Beginners',
                    instructor: 'David Clark',
                    category: 'Strength',
                    duration: '7:30',
                  ),
                  TutorialInfo(
                    title: 'HIIT Workout: 20 Minute Fat Burner',
                    instructor: 'Lisa Wong',
                    category: 'Cardio',
                    duration: '20:00',
                  ),
                  TutorialInfo(
                    title: 'Full Body Stretch Routine',
                    instructor: 'Sara Johnson',
                    category: 'Flexibility',
                    duration: '15:00',
                  ),
                  TutorialInfo(
                    title: 'Beginners Guide to Deadlifts',
                    instructor: 'Mike Torres',
                    category: 'Strength',
                    duration: '12:00',
                  ),
                  TutorialInfo(
                    title: 'Morning Yoga Flow for Energy',
                    instructor: 'Sara Johnson',
                    category: 'Flexibility',
                    duration: '25:00',
                  ),
                  TutorialInfo(
                    title: '30 Minute Treadmill Interval Workout',
                    instructor: 'Mike Torres',
                    category: 'Cardio',
                    duration: '30:00',
                  ),
                ]),
                _buildTutorialGrid(const [
                  TutorialInfo(
                    title: 'HIIT Workout: 20 Minute Fat Burner',
                    instructor: 'Lisa Wong',
                    category: 'Cardio',
                    duration: '20:00',
                  ),
                  TutorialInfo(
                    title: '30 Minute Treadmill Interval Workout',
                    instructor: 'Mike Torres',
                    category: 'Cardio',
                    duration: '30:00',
                  ),
                ]),
                _buildTutorialGrid(const [
                  TutorialInfo(
                    title: 'Proper Squat Form for Beginners',
                    instructor: 'David Clark',
                    category: 'Strength',
                    duration: '7:30',
                  ),
                  TutorialInfo(
                    title: 'Beginners Guide to Deadlifts',
                    instructor: 'Mike Torres',
                    category: 'Strength',
                    duration: '12:00',
                  ),
                ]),
                _buildTutorialGrid(const [
                  TutorialInfo(
                    title: 'Full Body Stretch Routine',
                    instructor: 'Sara Johnson',
                    category: 'Flexibility',
                    duration: '15:00',
                  ),
                  TutorialInfo(
                    title: 'Morning Yoga Flow for Energy',
                    instructor: 'Sara Johnson',
                    category: 'Flexibility',
                    duration: '25:00',
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialInfo {
  final String title;
  final String instructor;
  final String category;
  final String duration;
  
  const TutorialInfo({
    required this.title,
    required this.instructor,
    required this.category,
    required this.duration,
  });
}

Widget _buildTutorialGrid(List<TutorialInfo> tutorials) {
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    ),
    itemCount: tutorials.length,
    itemBuilder: (context, index) {
      return _buildTutorialCard(tutorials[index], context);
    },
  );
}

Widget _buildTutorialCard(TutorialInfo tutorial, BuildContext context) {
  Color categoryColor;
  
  switch (tutorial.category.toLowerCase()) {
    case 'cardio':
      categoryColor = Colors.red;
      break;
    case 'strength':
      categoryColor = Colors.blue;
      break;
    case 'flexibility':
      categoryColor = Colors.green;
      break;
    default:
      categoryColor = Colors.grey;
  }
  
  return Card(
    clipBehavior: Clip.antiAlias,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder for thumbnail
              Container(
                color: Colors.grey[300],
              ),
              
              // Play button overlay
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              
              // Duration badge
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tutorial.duration,
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
        ),
        
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                tutorial.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Instructor
              Text(
                tutorial.instructor,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  tutorial.category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ProfileViewDemo extends StatelessWidget {
  final String role;
  
  const ProfileViewDemo({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    role == 'admin' 
                        ? 'A'
                        : (role == 'instructor' ? 'I' : 'C'),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // User name
                Text(
                  role == 'admin'
                      ? 'Admin User'
                      : (role == 'instructor' ? 'Instructor User' : 'Client User'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRoleColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRoleColor().withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(),
                        size: 16,
                        color: _getRoleColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        role == 'admin'
                            ? 'Admin'
                            : (role == 'instructor' ? 'Instructor' : 'Client'),
                        style: TextStyle(
                          color: _getRoleColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Credits section (only for client role)
          if (role == 'client') ...[
            _buildCreditsSection(),
            const SizedBox(height: 24),
          ],
          
          // Account information section
          _buildAccountInfoSection(),
          
          const SizedBox(height: 24),
          
          // Personal information section
          _buildPersonalInfoSection(),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.lock),
                label: const Text('Change Password'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.credit_card,
                  color: Color(0xFF0D47A1),
                ),
                SizedBox(width: 8),
                Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text('View History',
                  style: TextStyle(
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Credit types
            Row(
              children: [
                // Gym credits
                Expanded(
                  child: _buildCreditCard(
                    'Gym Credits',
                    '15',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Interval credits
                Expanded(
                  child: _buildCreditCard(
                    'Interval Credits',
                    '5',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Purchase credits button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Purchase Credits'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreditCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.account_circle,
                  color: Color(0xFF0D47A1),
                ),
                SizedBox(width: 8),
                Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Email
            _buildInfoRow(
              'Email',
              role == 'admin'
                  ? 'admin@test.com'
                  : (role == 'instructor' ? 'instructor@test.com' : 'client@test.com'),
              Icons.email,
            ),
            
            const Divider(),
            
            // Phone
            _buildInfoRow(
              'Phone',
              '+1 (555) 123-4567',
              Icons.phone,
            ),
            
            const Divider(),
            
            // Member since
            _buildInfoRow(
              'Member Since',
              'January 2023',
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.person,
                  color: Color(0xFF0D47A1),
                ),
                SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Birthday
            _buildInfoRow(
              'Birthday',
              'Not set',
              Icons.cake,
            ),
            
            const Divider(),
            
            // Address
            _buildInfoRow(
              'Address',
              'Not set',
              Icons.home,
            ),
            
            const Divider(),
            
            // Emergency contact
            _buildInfoRow(
              'Emergency Contact',
              'Not set',
              Icons.emergency,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Color _getRoleColor() {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'instructor':
        return Colors.green;
      case 'client':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getRoleIcon() {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'instructor':
        return Icons.sports;
      case 'client':
        return Icons.person;
      default:
        return Icons.person;
    }
  }
}