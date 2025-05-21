import 'package:flutter/material.dart';

/// A simple app implementation to use when the main app is having compilation issues
class SimpleApp extends StatelessWidget {
  const SimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A58C0)),
        useMaterial3: true,
      ),
      home: const RoleSelectionScreen(),
    );
  }
}

/// The role selection screen
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A58C0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              const Text(
                'FitSAGA',
                style: TextStyle(
                  color: Color(0xFF4A58C0),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Subtitle
              const Text(
                'Gym Management App',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Role selection title
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Admin button
              _buildRoleButton(
                label: 'Admin',
                color: Colors.redAccent,
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // Instructor button
              _buildRoleButton(
                label: 'Instructor',
                color: Colors.green,
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // Client button
              _buildRoleButton(
                label: 'Client',
                color: Colors.blue,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}