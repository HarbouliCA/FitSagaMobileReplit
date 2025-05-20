import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/demo/calendar_view_demo.dart';
import 'package:fitsaga/screens/auth/login_screen.dart';
import 'package:fitsaga/screens/profile/profile_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorials_screen.dart';
import 'package:fitsaga/screens/admin/admin_dashboard.dart';
import 'package:fitsaga/screens/instructor/instructor_dashboard.dart';

class MainAppScreen extends StatefulWidget {
  final User user;
  
  const MainAppScreen({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  Widget _buildBody() {
    // Different screens based on user role
    switch (widget.user.role) {
      case UserRole.admin:
        return _buildAdminScreens();
      case UserRole.instructor:
        return _buildInstructorScreens();
      case UserRole.client:
        return _buildClientScreens();
    }
  }
  
  Widget _buildAdminScreens() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboard(user: widget.user);
      case 1:
        return CalendarViewDemo(sessions: demoSessions);
      case 2:
        return TutorialsScreen(user: widget.user);
      case 3:
        return ProfileScreen(user: widget.user);
      default:
        return AdminDashboard(user: widget.user);
    }
  }
  
  Widget _buildInstructorScreens() {
    switch (_selectedIndex) {
      case 0:
        return InstructorDashboard(user: widget.user);
      case 1:
        return CalendarViewDemo(sessions: demoSessions);
      case 2:
        return TutorialsScreen(user: widget.user);
      case 3:
        return ProfileScreen(user: widget.user);
      default:
        return InstructorDashboard(user: widget.user);
    }
  }
  
  Widget _buildClientScreens() {
    switch (_selectedIndex) {
      case 0:
        return CalendarViewDemo(sessions: demoSessions);
      case 1:
        return TutorialsScreen(user: widget.user);
      case 2:
        return ProfileScreen(user: widget.user);
      default:
        return CalendarViewDemo(sessions: demoSessions);
    }
  }
  
  Widget _buildBottomNavigationBar() {
    // Different navigation items based on user role
    switch (widget.user.role) {
      case UserRole.admin:
        return _buildAdminNavBar();
      case UserRole.instructor:
        return _buildInstructorNavBar();
      case UserRole.client:
        return _buildClientNavBar();
    }
  }
  
  Widget _buildAdminNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
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
    );
  }
  
  Widget _buildInstructorNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
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
    );
  }
  
  Widget _buildClientNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: AppTheme.primaryColor,
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
    );
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}