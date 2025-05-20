import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/screens/main_app_screen.dart';

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
      home: const DemoLandingPage(),
    );
  }
}

class DemoLandingPage extends StatelessWidget {
  const DemoLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitSAGA Demo'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and app name
              Icon(
                Icons.fitness_center,
                size: 80,
                color: AppTheme.primaryColor,
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
                onTap: () => _navigateToRole(context, UserRole.admin),
              ),
              
              const SizedBox(height: 16),
              
              // Instructor role
              _buildRoleCard(
                context,
                title: 'Instructor Dashboard',
                description: 'Manage classes, tutorials, and students',
                icon: Icons.sports,
                color: Colors.green,
                onTap: () => _navigateToRole(context, UserRole.instructor),
              ),
              
              const SizedBox(height: 16),
              
              // Client role
              _buildRoleCard(
                context,
                title: 'Client View',
                description: 'Book sessions, view tutorials, and manage profile',
                icon: Icons.person,
                color: Colors.blue,
                onTap: () => _navigateToRole(context, UserRole.client),
              ),
              
              const SizedBox(height: 32),
              
              // App info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Demo Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This demo showcases the main features of the FitSAGA gym management app. '
                      'Select a role to explore the different features available to each user type.',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
  
  void _navigateToRole(BuildContext context, UserRole role) {
    // Create a demo user based on selected role
    final User user = _createDemoUser(role);
    
    // Navigate to main app with selected role
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainAppScreen(user: user),
      ),
    );
  }
  
  User _createDemoUser(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return User(
          id: 'admin1',
          email: 'admin@test.com',
          displayName: 'Admin User',
          role: UserRole.admin,
          credits: UserCredits(gymCredits: 0, intervalCredits: 0),
          photoUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857',
        );
      
      case UserRole.instructor:
        return User(
          id: 'instructor1',
          email: 'instructor@test.com',
          displayName: 'Instructor User',
          role: UserRole.instructor,
          credits: UserCredits(gymCredits: 0, intervalCredits: 0),
          photoUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
        );
      
      case UserRole.client:
        return User(
          id: 'client1',
          email: 'client@test.com',
          displayName: 'Client User',
          role: UserRole.client,
          credits: UserCredits(gymCredits: 15, intervalCredits: 5),
          photoUrl: 'https://images.unsplash.com/photo-1534308143481-c55f00be8bd7',
        );
    }
  }
}