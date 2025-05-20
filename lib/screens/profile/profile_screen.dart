import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initializeFields();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _initializeFields() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.displayName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Update user profile
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initializeFields(); // Reset fields
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: 12),
                  
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  
                  if (_isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const LoadingIndicator(color: Colors.white)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildSectionTitle('Account Type'),
                  const SizedBox(height: 12),
                  
                  _buildInfoCard(
                    title: user.role.toUpperCase(),
                    subtitle: _getRoleDescription(user.role),
                    icon: _getRoleIcon(user.role),
                    color: _getRoleColor(user.role),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Credits'),
                  const SizedBox(height: 12),
                  
                  _buildCreditsSection(user),
                  const SizedBox(height: 24),
                  
                  if (user.hasMembership) ...[
                    _buildSectionTitle('Membership'),
                    const SizedBox(height: 12),
                    
                    _buildMembershipCard(user),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildSectionTitle('Settings'),
                  const SizedBox(height: 12),
                  
                  _buildSettingsOptions(),
                  const SizedBox(height: 36),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        authProvider.signOut();
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildProfileHeader(UserModel user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
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
  
  Widget _buildProfileForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          enabled: _isEditing,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _emailController,
          enabled: false, // Email can't be changed
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _phoneController,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildCreditsSection(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: _buildCreditCard(
            title: 'Gym Credits',
            count: user.credits.gymCredits,
            icon: Icons.fitness_center,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCreditCard(
            title: 'Interval Credits',
            count: user.credits.intervalCredits,
            icon: Icons.timer,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreditCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to buy credits screen
              },
              child: const Text('Buy More'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembershipCard(UserModel user) {
    final membership = user.membership;
    if (membership == null) return const SizedBox.shrink();
    
    Color statusColor = membership.isExpiringSoon ? Colors.orange : Colors.green;
    String statusText = membership.isExpiringSoon 
        ? 'Expires Soon' 
        : 'Active';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  membership.plan.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMembershipDetail(
                  'Days Left',
                  '${membership.daysRemaining}',
                  Icons.calendar_today,
                ),
                _buildMembershipDetail(
                  'Monthly Credits',
                  '${membership.monthlyGymCredits}',
                  Icons.fitness_center,
                ),
                _buildMembershipDetail(
                  'Auto Renew',
                  membership.autoRenew ? 'Yes' : 'No',
                  Icons.autorenew,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to membership details screen
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Manage Membership'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembershipDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Show account type details or navigate to related screen
        },
      ),
    );
  }
  
  Widget _buildSettingsOptions() {
    final options = [
      {
        'title': 'Notifications',
        'icon': Icons.notifications,
        'color': Colors.blue,
      },
      {
        'title': 'Privacy Settings',
        'icon': Icons.privacy_tip,
        'color': Colors.purple,
      },
      {
        'title': 'App Preferences',
        'icon': Icons.settings,
        'color': Colors.green,
      },
      {
        'title': 'Help & Support',
        'icon': Icons.help,
        'color': Colors.orange,
      },
    ];
    
    return Column(
      children: options.map((option) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (option['color'] as Color).withOpacity(0.2),
              child: Icon(option['icon'] as IconData, color: option['color'] as Color),
            ),
            title: Text(option['title'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to respective settings screen
            },
          ),
        );
      }).toList(),
    );
  }
  
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'instructor':
        return Icons.fitness_center;
      case 'client':
      default:
        return Icons.person;
    }
  }
  
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'instructor':
        return Colors.blue;
      case 'client':
      default:
        return Colors.green;
    }
  }
  
  String _getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Full system access and management';
      case 'instructor':
        return 'Session management and client tracking';
      case 'client':
      default:
        return 'Access to sessions and tutorials';
    }
  }
}