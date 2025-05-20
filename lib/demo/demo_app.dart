import 'package:flutter/material.dart';
import 'package:fitsaga/demo/session_detail_demo.dart';
import 'package:fitsaga/demo/calendar_view_demo.dart'; 
import 'package:fitsaga/theme/app_theme.dart';

class DemoApp extends StatelessWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA Demo',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({Key? key}) : super(key: key);

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitSAGA Sessions'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
            Tab(icon: Icon(Icons.list), text: 'All Sessions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Calendar view tab
          CalendarViewDemo(sessions: demoSessions),
          
          // List view tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: demoSessions.length,
            itemBuilder: (context, index) {
              final session = demoSessions[index];
              return SessionCard(session: session);
            },
          ),
        ],
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final SessionModel session;

  const SessionCard({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SessionDetailDemo(
                session: session,
                user: demoUser,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (session.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  session.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Credits
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${session.creditsRequired} credits',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.formattedDate,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.formattedTimeRange,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Instructor and Type
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.instructorName ?? 'Unknown Instructor',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.sessionType,
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Availability
                  Row(
                    children: [
                      // Spots left indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: session.hasAvailableSlots
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          session.hasAvailableSlots
                              ? '${session.availableSlots} spots left'
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
                      
                      const Spacer(),
                      
                      // View Details Button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SessionDetailDemo(
                                session: session,
                                user: demoUser,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('View Details'),
                      ),
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
}

// Demo data
final UserModel demoUser = UserModel(
  id: 'user123',
  name: 'John Doe',
  gymCredits: 10,
  intervalCredits: 5,
);

final List<SessionModel> demoSessions = [
  SessionModel(
    id: 'session1',
    title: 'Morning Yoga Flow',
    description: 'Start your day with an energizing yoga flow that focuses on flexibility, balance, and mindfulness. This session is perfect for all levels and will help you build a strong foundation for your yoga practice. The instructor will guide you through a series of poses designed to awaken your body and calm your mind.',
    date: DateTime.now().add(const Duration(days: 1)),
    startTimeMinutes: 9 * 60, // 9:00 AM
    durationMinutes: 60,
    sessionType: 'Yoga',
    instructorName: 'Sara Johnson',
    roomName: 'Studio A',
    capacity: 15,
    bookedCount: 8,
    creditsRequired: 2,
    intensityLevel: 'Moderate',
    levelType: 'All Levels',
    imageUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
  ),
  SessionModel(
    id: 'session2',
    title: 'HIIT Circuit Training',
    description: 'A high-intensity interval training circuit that will challenge your strength, endurance, and power. This session combines bodyweight exercises with equipment-based movements to create a full-body workout that maximizes calorie burn and improves cardiovascular fitness.',
    date: DateTime.now().add(const Duration(days: 1)),
    startTimeMinutes: 18 * 60, // 6:00 PM
    durationMinutes: 45,
    sessionType: 'HIIT',
    instructorName: 'Mike Torres',
    roomName: 'Functional Training Area',
    capacity: 12,
    bookedCount: 12,
    creditsRequired: 3,
    intensityLevel: 'High',
    levelType: 'Intermediate/Advanced',
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b',
  ),
  SessionModel(
    id: 'session3',
    title: 'Strength Foundations',
    description: 'Build a solid foundation of strength with this session focused on proper form and technique for fundamental lifting movements. Learn how to safely and effectively perform squats, deadlifts, presses, and more while establishing good movement patterns.',
    date: DateTime.now().add(const Duration(days: 2)),
    startTimeMinutes: 17 * 60, // 5:00 PM
    durationMinutes: 60,
    sessionType: 'Strength',
    instructorName: 'David Clark',
    roomName: 'Weight Room',
    capacity: 8,
    bookedCount: 3,
    creditsRequired: 2,
    intensityLevel: 'Moderate',
    levelType: 'Beginner',
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
  ),
  SessionModel(
    id: 'session4',
    title: 'Spin Class',
    description: 'An energetic indoor cycling session that simulates various terrains and challenges through changes in pace, resistance, and position. This cardio-focused workout is set to motivating music and guided by an instructor who will lead you through hill climbs, sprints, and endurance intervals.',
    date: DateTime.now().add(const Duration(days: 3)),
    startTimeMinutes: 12 * 60, // 12:00 PM
    durationMinutes: 45,
    sessionType: 'Cardio',
    instructorName: 'Lisa Wong',
    roomName: 'Spin Studio',
    capacity: 20,
    bookedCount: 15,
    creditsRequired: 2,
    intensityLevel: 'Moderate to High',
    levelType: 'All Levels',
    imageUrl: 'https://images.unsplash.com/photo-1561214078-f3247647fc5e',
  ),
];