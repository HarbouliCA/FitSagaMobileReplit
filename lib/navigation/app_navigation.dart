import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/screens/home/home_screen.dart';
import 'package:fitsaga/screens/sessions/calendar_view_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_list_screen.dart';
import 'package:fitsaga/screens/profile/profile_screen.dart';
import 'package:fitsaga/screens/admin/admin_dashboard_screen.dart';
import 'package:fitsaga/screens/instructor/instructor_dashboard_screen.dart';
import 'package:fitsaga/widgets/common/app_drawer.dart';
import 'package:fitsaga/theme/app_theme.dart';

/// Main app navigation structure with bottom navigation and drawer
class AppNavigation extends StatefulWidget {
  const AppNavigation({Key? key}) : super(key: key);

  @override
  _AppNavigationState createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // List of screens for regular users
  final List<Widget> _regularScreens = [
    const HomeScreen(),
    const CalendarViewScreen(),
    const TutorialListScreen(),
    const ProfileScreen(),
  ];
  
  // List of screen titles for regular users
  final List<String> _regularTitles = [
    'Home',
    'Sessions',
    'Tutorials',
    'Profile',
  ];
  
  // List of bottom nav bar icons
  final List<IconData> _regularIcons = [
    Icons.home,
    Icons.calendar_today,
    Icons.video_library,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    // Get the authenticated user
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;
    final isInstructor = authProvider.isInstructor;
    
    // If admin or instructor, show their specialized dashboard
    if (isAdmin) {
      return const AdminDashboardScreen();
    }
    
    if (isInstructor) {
      return const InstructorDashboardScreen();
    }
    
    // Regular user navigation with bottom tabs
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_regularTitles[_currentIndex]),
        elevation: 0,
        actions: _buildAppBarActions(),
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _regularScreens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  // Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: List.generate(
        _regularIcons.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(_regularIcons[index]),
          label: _regularTitles[index],
        ),
      ),
    );
  }
  
  // Build app bar actions
  List<Widget> _buildAppBarActions() {
    final List<Widget> actions = [];
    
    // Add actions based on current screen
    switch (_currentIndex) {
      case 0: // Home screen
        actions.add(
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        );
        break;
        
      case 1: // Sessions screen
        actions.add(
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterDialog();
            },
          ),
        );
        break;
        
      case 2: // Tutorials screen
        actions.add(
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterDialog();
            },
          ),
        );
        actions.add(
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        );
        break;
        
      case 3: // Profile screen
        actions.add(
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        );
        break;
    }
    
    return actions;
  }
  
  // Show filter dialog
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Different filter options based on current screen
        if (_currentIndex == 1) {
          // Sessions filter
          return _buildSessionsFilterSheet();
        } else if (_currentIndex == 2) {
          // Tutorials filter
          return _buildTutorialsFilterSheet();
        }
        
        return const SizedBox.shrink();
      },
    );
  }
  
  // Build sessions filter sheet
  Widget _buildSessionsFilterSheet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Reset filters
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Session Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('Yoga'),
              _filterChip('HIIT'),
              _filterChip('Strength'),
              _filterChip('Pilates'),
              _filterChip('Cardio'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Duration',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('30 mins'),
              _filterChip('45 mins'),
              _filterChip('60 mins'),
              _filterChip('90+ mins'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Build tutorials filter sheet
  Widget _buildTutorialsFilterSheet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Tutorials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Reset filters
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Difficulty Level',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('Beginner'),
              _filterChip('Intermediate'),
              _filterChip('Advanced'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Muscle Group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip('Core'),
              _filterChip('Arms'),
              _filterChip('Legs'),
              _filterChip('Back'),
              _filterChip('Chest'),
              _filterChip('Full Body'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Create a filter chip
  Widget _filterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // Handle selection
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}