import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/screens/profile/credit_history_screen.dart';
import 'package:fitsaga/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  
  const ProfileScreen({
    Key? key, 
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _toggleEditing() {
    setState(() {
      if (_isEditing) {
        // Save changes (in a real app, this would update the backend)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _isEditing = !_isEditing;
    });
  }
  
  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditing,
            tooltip: _isEditing ? 'Save' : 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with avatar
            _buildProfileHeader(),
            
            const SizedBox(height: 24),
            
            // Credits section (only for client role)
            if (widget.user.role == UserRole.client) ...[
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
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: widget.user.photoUrl != null
                ? NetworkImage(widget.user.photoUrl!)
                : null,
            child: widget.user.photoUrl == null
                ? Text(
                    widget.user.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // User name
          _isEditing
              ? SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Text(
                  widget.user.displayName,
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
                  _getRoleName(),
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
              children: [
                const Icon(
                  Icons.credit_card,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Credits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreditHistoryScreen(user: widget.user),
                      ),
                    );
                  },
                  child: const Text('View History'),
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
                    widget.user.credits.gymCredits.toString(),
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Interval credits
                Expanded(
                  child: _buildCreditCard(
                    'Interval Credits',
                    widget.user.credits.intervalCredits.toString(),
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Purchase Credits'),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('This feature will be implemented in a future update.'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
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
              children: [
                const Icon(
                  Icons.account_circle,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
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
              widget.user.email,
              Icons.email,
              isEditable: false,
            ),
            
            const Divider(),
            
            // Phone
            _buildInfoRow(
              'Phone',
              widget.user.phoneNumber ?? 'Not set',
              Icons.phone,
              isEditable: _isEditing,
              controller: _phoneController,
            ),
            
            const Divider(),
            
            // Member since
            _buildInfoRow(
              'Member Since',
              'January 2023', // This would be from the real user data
              Icons.calendar_today,
              isEditable: false,
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
              children: [
                const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Birthday (example field)
            _buildInfoRow(
              'Birthday',
              'Not set',
              Icons.cake,
              isEditable: _isEditing,
            ),
            
            const Divider(),
            
            // Address (example field)
            _buildInfoRow(
              'Address',
              'Not set',
              Icons.home,
              isEditable: _isEditing,
            ),
            
            const Divider(),
            
            // Emergency contact (example field)
            _buildInfoRow(
              'Emergency Contact',
              'Not set',
              Icons.emergency,
              isEditable: _isEditing,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    String label, 
    String value, 
    IconData icon, {
    bool isEditable = false,
    TextEditingController? controller,
  }) {
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
            child: isEditable
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter $label',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Change Password'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.lock),
          label: const Text('Change Password'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Color _getRoleColor() {
    switch (widget.user.role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.instructor:
        return Colors.green;
      case UserRole.client:
        return Colors.blue;
    }
  }
  
  IconData _getRoleIcon() {
    switch (widget.user.role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.instructor:
        return Icons.sports;
      case UserRole.client:
        return Icons.person;
    }
  }
  
  String _getRoleName() {
    switch (widget.user.role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.client:
        return 'Client';
    }
  }
}