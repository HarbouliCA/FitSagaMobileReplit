import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleApp());
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
        title: const Text('FitSAGA'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'FitSAGA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gym Management App',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Select Your Role',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildRoleButton(
              context,
              'Admin',
              Icons.admin_panel_settings,
              Colors.red,
              () => _navigateToRole(context, 'admin'),
            ),
            const SizedBox(height: 16),
            _buildRoleButton(
              context,
              'Instructor',
              Icons.sports,
              Colors.green,
              () => _navigateToRole(context, 'instructor'),
            ),
            const SizedBox(height: 16),
            _buildRoleButton(
              context,
              'Client',
              Icons.person,
              Colors.blue,
              () => _navigateToRole(context, 'client'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String role,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(role),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  void _navigateToRole(BuildContext context, String role) {
    Widget screen;
    
    switch (role) {
      case 'admin':
        screen = const AdminDashboard();
        break;
      case 'instructor':
        screen = const InstructorDashboard();
        break;
      case 'client':
        screen = const ClientDashboard();
        break;
      default:
        screen = const ClientDashboard();
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
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
    switch (_currentIndex) {
      case 0:
        return const AdminHomeView();
      case 1:
        return const SessionsView(userRole: 'admin');
      case 2:
        return const TutorialsView(userRole: 'admin');
      case 3:
        return const ProfileView(userRole: 'admin');
      default:
        return const AdminHomeView();
    }
  }
}

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({Key? key}) : super(key: key);

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Dashboard'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
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
    switch (_currentIndex) {
      case 0:
        return const InstructorHomeView();
      case 1:
        return const SessionsView(userRole: 'instructor');
      case 2:
        return const TutorialsView(userRole: 'instructor');
      case 3:
        return const ProfileView(userRole: 'instructor');
      default:
        return const InstructorHomeView();
    }
  }
}

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({Key? key}) : super(key: key);

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Dashboard'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Sessions',
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
    switch (_currentIndex) {
      case 0:
        return const SessionsView(userRole: 'client');
      case 1:
        return const TutorialsView(userRole: 'client');
      case 2:
        return const ProfileView(userRole: 'client');
      default:
        return const SessionsView(userRole: 'client');
    }
  }
}

// Home Views
class AdminHomeView extends StatelessWidget {
  const AdminHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats row
          Row(
            children: [
              _buildStatCard(
                title: 'Active Members',
                value: '124',
                icon: Icons.person,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                title: 'Sessions Today',
                value: '8',
                icon: Icons.calendar_today,
                color: Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatCard(
                title: 'New Registrations',
                value: '12',
                icon: Icons.person_add,
                color: Colors.orange,
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
              _buildQuickAction(
                context: context,
                icon: Icons.add_circle,
                label: 'New Session',
                color: Colors.green,
                onTap: () => _navigateToCreateSession(context),
              ),
              _buildQuickAction(
                context: context,
                icon: Icons.video_library,
                label: 'New Tutorial',
                color: Colors.blue,
                onTap: () => _navigateToCreateTutorial(context),
              ),
              _buildQuickAction(
                context: context,
                icon: Icons.person_add,
                label: 'Add User',
                color: Colors.purple,
                onTap: () {},
              ),
              _buildQuickAction(
                context: context,
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.grey,
                onTap: () {},
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
          
          _buildSessionItem(
            context: context,
            title: 'Morning Yoga Flow',
            time: '9:00 AM - 10:00 AM',
            date: 'Today',
            instructor: 'Sara Johnson',
            spotsLeft: 7,
          ),
          
          _buildSessionItem(
            context: context,
            title: 'HIIT Circuit Training',
            time: '6:00 PM - 6:45 PM',
            date: 'Today',
            instructor: 'Mike Torres',
            spotsLeft: 0,
          ),
          
          _buildSessionItem(
            context: context,
            title: 'Strength Foundations',
            time: '5:00 PM - 6:00 PM',
            date: 'Tomorrow',
            instructor: 'David Clark',
            spotsLeft: 5,
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
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
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructorHomeView extends StatelessWidget {
  const InstructorHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructor Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Today's sessions
          Row(
            children: [
              const Text(
                'Today\'s Sessions',
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
          
          _buildSessionTimelineItem(
            time: '9:00 AM',
            title: 'Morning Yoga Flow',
            location: 'Studio A',
            spots: 7,
            total: 15,
          ),
          
          _buildSessionTimelineItem(
            time: '12:00 PM',
            title: 'Spin Class',
            location: 'Spin Studio',
            spots: 1,
            total: 12,
          ),
          
          _buildSessionTimelineItem(
            time: '5:00 PM',
            title: 'Strength Foundations',
            location: 'Weight Room',
            spots: 5,
            total: 15,
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
              _buildQuickAction(
                context: context,
                icon: Icons.add_circle,
                label: 'New Session',
                color: Colors.green,
                onTap: () => _navigateToCreateSession(context),
              ),
              _buildQuickAction(
                context: context,
                icon: Icons.video_library,
                label: 'New Tutorial',
                color: Colors.blue,
                onTap: () => _navigateToCreateTutorial(context),
              ),
              _buildQuickAction(
                context: context,
                icon: Icons.people,
                label: 'My Students',
                color: Colors.purple,
                onTap: () {},
              ),
              _buildQuickAction(
                context: context,
                icon: Icons.insights,
                label: 'Analytics',
                color: Colors.orange,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionTimelineItem({
    required String time,
    required String title,
    required String location,
    required int spots,
    required int total,
  }) {
    final bool isFull = spots <= 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 60,
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
          
          // Session info
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                          color: isFull
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFull
                                ? Colors.red.withOpacity(0.5)
                                : Colors.green.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          isFull ? 'Full' : '$spots spots',
                          style: TextStyle(
                            color: isFull ? Colors.red : Colors.green,
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
                        Icons.room,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sessions View
class SessionsView extends StatelessWidget {
  final String userRole;
  
  const SessionsView({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final now = DateTime.now();
                  final weekDay = now.weekday;
                  final startOfWeek = now.subtract(Duration(days: weekDay - 1));
                  final day = startOfWeek.add(Duration(days: index));
                  
                  final isSelected = index == 1; // Highlight Tuesday for demo
                  final isToday = day.day == now.day && day.month == now.month;
                  
                  return Container(
                    width: 40,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue.withOpacity(0.2) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontWeight: isSelected || isToday 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 16),
              
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip(label: 'All Classes', isSelected: true),
                    _buildFilterChip(label: 'HIIT', isSelected: false),
                    _buildFilterChip(label: 'Yoga', isSelected: false),
                    _buildFilterChip(label: 'Strength', isSelected: false),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Session list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSessionCard(
                context: context,
                title: 'Morning Yoga Flow',
                time: '9:00 AM',
                instructor: 'Sara Johnson',
                spots: 7,
                total: 15,
              ),
              
              _buildSessionCard(
                context: context,
                title: 'HIIT Circuit Training',
                time: '6:00 PM',
                instructor: 'Mike Torres',
                spots: 0,
                total: 15,
              ),
              
              _buildSessionCard(
                context: context,
                title: 'Strength Foundations',
                time: '5:00 PM',
                instructor: 'David Clark',
                spots: 5,
                total: 15,
              ),
            ],
          ),
        ),
        
        // Add session button (Admin/Instructor only)
        if (userRole != 'client')
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateSession(context),
                icon: const Icon(Icons.add),
                label: const Text('Add New Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {},
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildSessionCard({
    required BuildContext context,
    required String title,
    required String time,
    required String instructor,
    required int spots,
    required int total,
  }) {
    final bool isFull = spots <= 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToSessionDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFull
                            ? Colors.red.withOpacity(0.5)
                            : Colors.green.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      isFull ? 'Full' : '$spots spots',
                      style: TextStyle(
                        color: isFull ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
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
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    instructor,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (total - spots) / total,
                  backgroundColor: Colors.grey[200],
                  color: isFull ? Colors.red : Colors.green,
                  minHeight: 6,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                '${total - spots}/$total enrolled',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tutorials View
class TutorialsView extends StatelessWidget {
  final String userRole;
  
  const TutorialsView({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search tutorials...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        
        // Category tabs
        DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Cardio'),
                  Tab(text: 'Strength'),
                  Tab(text: 'Flexibility'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
              
              const SizedBox(height: 16),
              
              // Tutorial grid
              SizedBox(
                height: 420,
                child: TabBarView(
                  children: [
                    _buildTutorialGrid(),
                    _buildTutorialGrid(category: 'Cardio'),
                    _buildTutorialGrid(category: 'Strength'),
                    _buildTutorialGrid(category: 'Flexibility'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Add tutorial button (Admin/Instructor only)
        if (userRole != 'client')
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCreateTutorial(context),
                icon: const Icon(Icons.add),
                label: const Text('Create New Tutorial'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTutorialGrid({String? category}) {
    final List<Map<String, dynamic>> tutorials = [
      {
        'title': 'Proper Squat Form for Beginners',
        'instructor': 'David Clark',
        'category': 'Strength',
        'duration': '7:30',
      },
      {
        'title': 'HIIT Workout: 20 Minute Fat Burner',
        'instructor': 'Lisa Wong',
        'category': 'Cardio',
        'duration': '20:00',
      },
      {
        'title': 'Full Body Stretch Routine',
        'instructor': 'Sara Johnson',
        'category': 'Flexibility',
        'duration': '15:00',
      },
      {
        'title': 'Beginners Guide to Deadlifts',
        'instructor': 'Mike Torres',
        'category': 'Strength',
        'duration': '12:00',
      },
      {
        'title': 'Morning Yoga Flow for Energy',
        'instructor': 'Sara Johnson',
        'category': 'Flexibility',
        'duration': '25:00',
      },
      {
        'title': '30 Minute Treadmill Interval Workout',
        'instructor': 'Mike Torres',
        'category': 'Cardio',
        'duration': '30:00',
      },
    ];
    
    final filteredTutorials = category == null
        ? tutorials
        : tutorials.where((t) => t['category'] == category).toList();
    
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredTutorials.length,
      itemBuilder: (context, index) {
        final tutorial = filteredTutorials[index];
        return _buildTutorialCard(
          context: context,
          title: tutorial['title'],
          instructor: tutorial['instructor'],
          category: tutorial['category'],
          duration: tutorial['duration'],
        );
      },
    );
  }
  
  Widget _buildTutorialCard({
    required BuildContext context,
    required String title,
    required String instructor,
    required String category,
    required String duration,
  }) {
    // Determine category color
    Color categoryColor;
    switch (category.toLowerCase()) {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToTutorialDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      category.toLowerCase() == 'cardio'
                          ? Icons.directions_run
                          : (category.toLowerCase() == 'strength'
                              ? Icons.fitness_center
                              : Icons.self_improvement),
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Duration badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                // Play button
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Tutorial info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    instructor,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile View
class ProfileView extends StatelessWidget {
  final String userRole;
  
  const ProfileView({
    Key? key,
    required this.userRole,
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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _getRoleColor().withOpacity(0.2),
                  child: Text(
                    userRole[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _getUserName(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getRoleColor().withOpacity(0.5),
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
                      const SizedBox(width: 8),
                      Text(
                        userRole[0].toUpperCase() + userRole.substring(1),
                        style: TextStyle(
                          color: _getRoleColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Credits section (client only)
          if (userRole == 'client')
            _buildCreditsSection(),
          
          // Account information
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoCard(
            title: 'Email',
            value: '${userRole}@example.com',
            icon: Icons.email,
          ),
          
          _buildInfoCard(
            title: 'Phone',
            value: '+1 (555) 123-4567',
            icon: Icons.phone,
          ),
          
          _buildInfoCard(
            title: 'Member Since',
            value: 'January 2025',
            icon: Icons.calendar_today,
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credit Balance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildCreditCard(
              title: 'Gym Credits',
              value: '15',
              icon: Icons.fitness_center,
              color: Colors.blue,
            ),
            
            const SizedBox(width: 16),
            
            _buildCreditCard(
              title: 'Interval Credits',
              value: '5',
              icon: Icons.timer,
              color: Colors.orange,
            ),
          ],
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }
  
  Widget _buildCreditCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
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
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
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
  
  Color _getRoleColor() {
    switch (userRole) {
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
    switch (userRole) {
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
  
  String _getUserName() {
    switch (userRole) {
      case 'admin':
        return 'Admin User';
      case 'instructor':
        return 'Instructor User';
      case 'client':
        return 'Client User';
      default:
        return 'User';
    }
  }
}

// Session Detail Screen
class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({Key? key}) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  bool _isBooked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.blue.withOpacity(0.2),
              child: const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Session details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Strength Foundations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Instructor',
                    value: 'David Clark',
                  ),
                  
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: 'Tomorrow',
                  ),
                  
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: '5:00 PM - 6:00 PM',
                  ),
                  
                  _buildDetailRow(
                    icon: Icons.room,
                    label: 'Location',
                    value: 'Weight Room',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Capacity progress
                  const Text(
                    'Capacity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 10 / 15,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                      minHeight: 8,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  const Text(
                    '10/15 enrolled',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'About This Session',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'This Strength Foundations session is designed for all fitness levels. You will build strength and muscle tone through progressive resistance training. Please bring appropriate workout attire.',
                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Credit requirement
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Credits Required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'This session requires 1 credit OR 1 interval credit',
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your credits: 15 (+ 5 interval)',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Book button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _toggleBooking(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isBooked ? Colors.red : Colors.blue,
                      ),
                      child: Text(_isBooked ? 'Cancel Booking' : 'Book Session'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  void _toggleBooking() {
    setState(() {
      if (_isBooked) {
        _isBooked = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        _showBookingConfirmation();
      }
    });
  }
  
  void _showBookingConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Strength Foundations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildDialogRow(
              icon: Icons.calendar_today,
              text: 'Tomorrow',
            ),
            _buildDialogRow(
              icon: Icons.access_time,
              text: '5:00 PM - 6:00 PM',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Credit Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current credits:'),
                Text('15', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Required credits:'),
                Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remaining credits:'),
                Text(
                  '14',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isBooked = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session booked successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDialogRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

// Create Session Screen
class CreateSessionScreen extends StatelessWidget {
  const CreateSessionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form fields
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Session Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        // Category dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: 'Strength',
                                isExpanded: true,
                                items: [
                                  'Strength',
                                  'Cardio',
                                  'Yoga',
                                  'HIIT',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {},
                                hint: const Text('Category'),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Instructor dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: 'David Clark',
                                isExpanded: true,
                                items: [
                                  'David Clark',
                                  'Sara Johnson',
                                  'Mike Torres',
                                  'Lisa Wong',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {},
                                hint: const Text('Instructor'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () {},
                              ),
                            ),
                            readOnly: true,
                            controller: TextEditingController(text: 'Tomorrow'),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Time picker
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Time',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: () {},
                              ),
                            ),
                            readOnly: true,
                            controller: TextEditingController(text: '5:00 PM'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        // Duration
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Duration (min)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(text: '60'),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Capacity
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Capacity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(text: '15'),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Credits
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Credits',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(text: '1'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            
            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Create Session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Create Tutorial Screen with Firebase Video Integration
class CreateTutorialScreen extends StatelessWidget {
  const CreateTutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Tutorial'),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Column(
              children: [
                const Text(
                  'Create a New Tutorial',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select videos from our library to include in your custom tutorial',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Basic info form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Tutorial Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Category dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'Strength',
                            isExpanded: true,
                            items: [
                              'Strength',
                              'Cardio',
                              'Flexibility',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {},
                            hint: const Text('Category'),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Difficulty dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: 'Beginner',
                            isExpanded: true,
                            items: [
                              'Beginner',
                              'Intermediate',
                              'Advanced',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {},
                            hint: const Text('Difficulty'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Video selection section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select Videos From Library',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip(label: 'All', isSelected: true),
                      _buildFilterChip(label: 'Strength', isSelected: false),
                      _buildFilterChip(label: 'Cardio', isSelected: false),
                      _buildFilterChip(label: 'día 1', isSelected: false),
                      _buildFilterChip(label: 'día 2', isSelected: false),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Video list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildVideoItem(
                        title: 'Press de banca - Barra',
                        bodyPart: 'Pecho, Tríceps, Hombros parte delantera',
                        type: 'strength',
                        dayName: 'día 1',
                        isSelected: true,
                      ),
                      
                      _buildVideoItem(
                        title: 'Cinta de correr 8 km/h ~ 5 mph',
                        bodyPart: 'Sistema cardiovascular, Piernas',
                        type: 'cardio',
                        dayName: 'día 1',
                        isSelected: false,
                      ),
                      
                      _buildVideoItem(
                        title: 'Jumping jacks',
                        bodyPart: 'Sistema cardiovascular, Cuerpo completo',
                        type: 'cardio',
                        dayName: 'día 1',
                        isSelected: true,
                      ),
                      
                      _buildVideoItem(
                        title: 'Extension de codo - Polea',
                        bodyPart: 'Tríceps',
                        type: 'strength',
                        dayName: 'día 1',
                        isSelected: false,
                      ),
                      
                      _buildVideoItem(
                        title: 'Curl de bíceps - Polea',
                        bodyPart: 'Bíceps',
                        type: 'strength',
                        dayName: 'día 1',
                        isSelected: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Create button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '3 videos selected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tutorial created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Create Tutorial'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {},
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildVideoItem({
    required String title,
    required String bodyPart,
    required String type,
    required String dayName,
    required bool isSelected,
  }) {
    // Determine type color
    Color typeColor = type == 'cardio' ? Colors.red : Colors.blue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Video thumbnail placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: type == 'cardio'
                    ? Colors.red.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                type == 'cardio'
                    ? Icons.directions_run
                    : Icons.fitness_center,
                color: typeColor,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Video details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    bodyPart,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: typeColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          dayName,
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Selection checkbox
            Checkbox(
              value: isSelected,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}

// Tutorial Detail Screen
class TutorialDetailScreen extends StatelessWidget {
  const TutorialDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Detail'),
      ),
      body: Column(
        children: [
          // Video player placeholder
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Play button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                
                // Video controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '0:00 / 7:30',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tutorial info
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Proper Squat Form for Beginners',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Text(
                        'By David Clark',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'Strength',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'Beginner',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tutorial description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'This tutorial covers the proper form for performing a squat, one of the most fundamental strength exercises. Learn how to position your feet, maintain a neutral spine, and achieve proper depth while avoiding common mistakes.',
                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Target muscles
                  const Text(
                    'Target Muscle Groups',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMuscleTag('Quadriceps'),
                      _buildMuscleTag('Glutes'),
                      _buildMuscleTag('Hamstrings'),
                      _buildMuscleTag('Lower Back'),
                      _buildMuscleTag('Core'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInstructionStep(
                    number: 1,
                    text: 'Stand with feet shoulder-width apart.',
                  ),
                  
                  _buildInstructionStep(
                    number: 2,
                    text: 'Keep your back straight and core engaged.',
                  ),
                  
                  _buildInstructionStep(
                    number: 3,
                    text: 'Bend at the knees and hips, lowering as if sitting in a chair.',
                  ),
                  
                  _buildInstructionStep(
                    number: 4,
                    text: 'Ensure knees don\'t extend past your toes.',
                  ),
                  
                  _buildInstructionStep(
                    number: 5,
                    text: 'Lower until thighs are parallel to the ground (or as low as comfortable).',
                  ),
                  
                  _buildInstructionStep(
                    number: 6,
                    text: 'Push through heels to return to standing position.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMuscleTag(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(muscle),
    );
  }
  
  Widget _buildInstructionStep({
    required int number,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Shared functions
Widget _buildQuickAction({
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
      onTap: () => _navigateToSessionDetail(context),
    ),
  );
}

// Navigation functions
void _navigateToSessionDetail(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SessionDetailScreen()),
  );
}

void _navigateToTutorialDetail(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TutorialDetailScreen()),
  );
}

void _navigateToCreateSession(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CreateSessionScreen()),
  );
}

void _navigateToCreateTutorial(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const CreateTutorialScreen()),
  );
}