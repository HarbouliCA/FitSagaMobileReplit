import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load user data when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Refresh user data
      await authProvider.refreshUserData();
      
      // Load credit data if user is authenticated
      if (authProvider.currentUser != null && !creditProvider.isInitialized) {
        await creditProvider.loadUserCredits(authProvider.currentUser!.id);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading || _isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading profile...'),
      );
    }
    
    final user = authProvider.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off,
                size: 64,
                color: AppTheme.textLightColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Not Logged In',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please sign in to view your profile',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                    vertical: AppTheme.paddingMedium,
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _showLogoutConfirmation,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Credits'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Profile Info Tab
            _buildProfileInfoTab(user),
            
            // Credits Tab
            _buildCreditsTab(user),
            
            // Settings Tab
            _buildSettingsTab(user),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileInfoTab(user) {
    final dateFormatter = DateFormat('MMMM d, yyyy');
    final joinDate = dateFormatter.format(user.createdAt);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_errorMessage != null)
            _buildErrorMessage(),
            
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Profile Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              InkWell(
                onTap: _changeProfilePhoto,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // User name and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => _editProfileField('name', user.name),
              ),
            ],
          ),
          
          // User role badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              border: Border.all(
                color: _getRoleColor(user.role),
                width: 1,
              ),
            ),
            child: Text(
              _getRoleText(user.role),
              style: TextStyle(
                color: _getRoleColor(user.role),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Profile information card
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // Email
                  _buildInfoRow(
                    label: 'Email',
                    value: user.email,
                    icon: Icons.email,
                    canEdit: false,
                  ),
                  
                  const Divider(),
                  
                  // Member since
                  _buildInfoRow(
                    label: 'Member Since',
                    value: joinDate,
                    icon: Icons.calendar_today,
                    canEdit: false,
                  ),
                  
                  const Divider(),
                  
                  // Phone number (placeholder - would normally be stored in user model)
                  _buildInfoRow(
                    label: 'Phone',
                    value: 'Add Phone Number',
                    icon: Icons.phone,
                    canEdit: true,
                    onEdit: () => _editProfileField('phone', ''),
                    valueColor: AppTheme.textLightColor,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Physical details card (placeholder)
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fitness Information',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // Height
                  _buildInfoRow(
                    label: 'Height',
                    value: 'Add Height',
                    icon: Icons.height,
                    canEdit: true,
                    onEdit: () => _editProfileField('height', ''),
                    valueColor: AppTheme.textLightColor,
                  ),
                  
                  const Divider(),
                  
                  // Weight
                  _buildInfoRow(
                    label: 'Weight',
                    value: 'Add Weight',
                    icon: Icons.monitor_weight,
                    canEdit: true,
                    onEdit: () => _editProfileField('weight', ''),
                    valueColor: AppTheme.textLightColor,
                  ),
                  
                  const Divider(),
                  
                  // Fitness Goals
                  _buildInfoRow(
                    label: 'Fitness Goals',
                    value: 'Add Fitness Goals',
                    icon: Icons.fitness_center,
                    canEdit: true,
                    onEdit: () => _editProfileField('fitnessGoals', ''),
                    valueColor: AppTheme.textLightColor,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Emergency contact card (placeholder)
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Contact',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  // Contact Name
                  _buildInfoRow(
                    label: 'Name',
                    value: 'Add Contact',
                    icon: Icons.person,
                    canEdit: true,
                    onEdit: () => _editProfileField('emergencyContactName', ''),
                    valueColor: AppTheme.textLightColor,
                  ),
                  
                  const Divider(),
                  
                  // Contact Phone
                  _buildInfoRow(
                    label: 'Phone',
                    value: 'Add Phone',
                    icon: Icons.phone,
                    canEdit: true,
                    onEdit: () => _editProfileField('emergencyContactPhone', ''),
                    valueColor: AppTheme.textLightColor,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    );
  }
  
  Widget _buildCreditsTab(user) {
    final creditProvider = Provider.of<CreditProvider>(context);
    
    if (creditProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (!creditProvider.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.credit_card_off,
              size: 64,
              color: AppTheme.textLightColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Credits Not Loaded',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load your credit information',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingMedium,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current balance card
          Card(
            elevation: AppTheme.elevationSmall,
            color: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                children: [
                  const Text(
                    'Available Credits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    creditProvider.creditBalance.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/credits/purchase');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingLarge,
                        vertical: AppTheme.paddingSmall,
                      ),
                    ),
                    child: const Text('Buy More Credits'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Credit Stats Card
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Credit Statistics',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          label: 'Total Purchased',
                          value: creditProvider.totalCreditsPurchased.toString(),
                          icon: Icons.shopping_basket,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          label: 'Total Used',
                          value: creditProvider.totalCreditsUsed.toString(),
                          icon: Icons.fitness_center,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Recent Transactions Section
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.paddingSmall,
              vertical: AppTheme.paddingMedium,
            ),
            child: Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Transaction list
          if (creditProvider.creditHistory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingLarge),
                child: Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: AppTheme.textLightColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: creditProvider.creditHistory.length > 5
                  ? 5 // Limit to 5 most recent transactions
                  : creditProvider.creditHistory.length,
              itemBuilder: (context, index) {
                final transaction = creditProvider.creditHistory[index];
                return _buildTransactionItem(transaction);
              },
            ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // View All Transactions Button
          if (creditProvider.creditHistory.length > 5)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/credits/history');
              },
              child: const Text('View All Transactions'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.paddingSmall,
              vertical: AppTheme.paddingMedium,
            ),
            child: Text(
              'Account Settings',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Account settings card
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Column(
              children: [
                // Change Password
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                
                const Divider(height: 1),
                
                // Email Notifications
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Notifications'),
                  trailing: Switch(
                    value: true, // Placeholder - would be from user settings
                    onChanged: (value) {
                      // Update user notification settings
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    // Toggle switch when tapping anywhere on the ListTile
                  },
                ),
                
                const Divider(height: 1),
                
                // Push Notifications
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Push Notifications'),
                  trailing: Switch(
                    value: true, // Placeholder - would be from user settings
                    onChanged: (value) {
                      // Update user notification settings
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    // Toggle switch when tapping anywhere on the ListTile
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.paddingSmall,
              vertical: AppTheme.paddingMedium,
            ),
            child: Text(
              'App Settings',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // App settings card
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Column(
              children: [
                // Theme
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Dark Theme'),
                  trailing: Switch(
                    value: false, // Placeholder - would be from app settings
                    onChanged: (value) {
                      // Update app theme
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    // Toggle switch when tapping anywhere on the ListTile
                  },
                ),
                
                const Divider(height: 1),
                
                // Language
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('English', style: TextStyle(color: AppTheme.textLightColor)),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: _showLanguageSelectionDialog,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.paddingSmall,
              vertical: AppTheme.paddingMedium,
            ),
            child: Text(
              'Help & Support',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Help and support card
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Column(
              children: [
                // Help Center
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to help center
                  },
                ),
                
                const Divider(height: 1),
                
                // Contact Support
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('Contact Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to contact support
                  },
                ),
                
                const Divider(height: 1),
                
                // Terms of Service
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to terms of service
                  },
                ),
                
                const Divider(height: 1),
                
                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                
                const Divider(height: 1),
                
                // About
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAboutDialog,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Danger Zone Card
          Card(
            elevation: AppTheme.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppTheme.paddingMedium),
                  child: Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: AppTheme.errorColor,
                  ),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                    ),
                  ),
                  onTap: _showDeleteAccountConfirmation,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXLarge),
        ],
      ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingSmall),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        border: Border.all(
          color: AppTheme.errorColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppTheme.errorColor,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required bool canEdit,
    VoidCallback? onEdit,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.textLightColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textLightColor,
                  fontSize: AppTheme.fontSizeSmall,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: AppTheme.fontSizeRegular,
                ),
              ),
            ],
          ),
        ),
        if (canEdit)
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
              color: AppTheme.primaryColor,
            ),
            onPressed: onEdit,
          ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
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
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.fontSizeLarge,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: AppTheme.fontSizeSmall,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionItem(creditTransaction) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    
    // Get appropriate icon and colors based on transaction type
    IconData icon;
    Color iconColor;
    Color backgroundColor;
    String typeText;
    String amountText;
    
    if (creditTransaction.isCredit) {
      switch (creditTransaction.type) {
        case CreditTransactionType.initial:
          icon = Icons.card_giftcard;
          iconColor = AppTheme.successColor;
          backgroundColor = AppTheme.successLightColor;
          typeText = 'Welcome Credits';
          amountText = '+${creditTransaction.amount}';
          break;
        case CreditTransactionType.purchase:
          icon = Icons.shopping_basket;
          iconColor = AppTheme.successColor;
          backgroundColor = AppTheme.successLightColor;
          typeText = 'Purchased';
          amountText = '+${creditTransaction.amount}';
          break;
        case CreditTransactionType.refund:
          icon = Icons.replay;
          iconColor = AppTheme.successColor;
          backgroundColor = AppTheme.successLightColor;
          typeText = 'Refund';
          amountText = '+${creditTransaction.amount}';
          break;
        default:
          icon = Icons.credit_card;
          iconColor = AppTheme.successColor;
          backgroundColor = AppTheme.successLightColor;
          typeText = 'Added';
          amountText = '+${creditTransaction.amount}';
      }
    } else {
      icon = Icons.fitness_center;
      iconColor = AppTheme.errorColor;
      backgroundColor = AppTheme.errorLightColor;
      typeText = 'Booking';
      amountText = '-${creditTransaction.amount}';
    }
    
    return Card(
      elevation: AppTheme.elevationXSmall,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creditTransaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${dateFormatter.format(creditTransaction.createdAt)} at ${timeFormatter.format(creditTransaction.createdAt)}',
                    style: const TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: creditTransaction.isCredit
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
                Text(
                  typeText,
                  style: const TextStyle(
                    color: AppTheme.textLightColor,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _changeProfilePhoto() {
    // In a real app, this would open image picker and upload to storage
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Photo'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take Photo'),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Library'),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Remove Current Photo'),
              textColor: AppTheme.errorColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _editProfileField(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    
    // Generate appropriate title and hint based on field
    String title;
    String hint;
    
    switch (field) {
      case 'name':
        title = 'Edit Name';
        hint = 'Enter your full name';
        break;
      case 'phone':
        title = 'Edit Phone Number';
        hint = 'Enter your phone number';
        break;
      case 'height':
        title = 'Edit Height';
        hint = 'Enter your height (cm)';
        break;
      case 'weight':
        title = 'Edit Weight';
        hint = 'Enter your weight (kg)';
        break;
      case 'fitnessGoals':
        title = 'Edit Fitness Goals';
        hint = 'Describe your fitness goals';
        break;
      case 'emergencyContactName':
        title = 'Edit Emergency Contact Name';
        hint = 'Enter contact name';
        break;
      case 'emergencyContactPhone':
        title = 'Edit Emergency Contact Phone';
        hint = 'Enter contact phone number';
        break;
      default:
        title = 'Edit Field';
        hint = 'Enter new value';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isEmpty) {
                return;
              }
              
              Navigator.of(context).pop();
              
              if (field == 'name') {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final success = await authProvider.updateProfile(name: newValue);
                  
                  if (!success && mounted) {
                    setState(() {
                      _errorMessage = authProvider.error ?? 'Failed to update name.';
                    });
                  }
                } catch (e) {
                  setState(() {
                    _errorMessage = 'An error occurred: $e';
                  });
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              } else {
                // For other fields, we would update them in the user model
                // This is a placeholder since we don't have those fields in our model yet
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated $field to $newValue'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) {
      controller.dispose();
    });
  }
  
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Password
              TextField(
                controller: currentPasswordController,
                obscureText: obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureCurrentPassword = !obscureCurrentPassword;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // New Password
              TextField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Confirm New Password
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate passwords
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;
                
                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }
                
                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }
                
                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                  return;
                }
                
                // In a real app, we would call an API to change the password
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    ).then((_) {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
  }
  
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language options
            ListTile(
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: AppTheme.primaryColor),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changed language to Spanish'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('French'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changed language to French'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('German'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changed language to German'),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Chinese'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changed language to Chinese'),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About FitSAGA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(
                  Icons.fitness_center,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'FitSAGA',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'FitSAGA is a gym management application that helps users book sessions, view tutorials, and track their fitness journey.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2023 FitSAGA. All rights reserved.',
              style: TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() {
                _isLoading = true;
              });
              
              try {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.signOut();
                
                if (success && mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else if (mounted) {
                  setState(() {
                    _errorMessage = authProvider.error ?? 'Failed to sign out.';
                    _isLoading = false;
                  });
                }
              } catch (e) {
                setState(() {
                  _errorMessage = 'An error occurred: $e';
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warning: This action cannot be undone.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Deleting your account will permanently remove all your data, including:',
            ),
            SizedBox(height: 8),
            Text('• Personal information'),
            Text('• Booking history'),
            Text('• Credit balance and history'),
            Text('• Any created content'),
            SizedBox(height: 16),
            Text(
              'Are you absolutely sure you want to delete your account?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, we would call an API to delete the account
              Navigator.of(context).pop();
              
              // Show confirmation
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                    'Please type "DELETE" to confirm account deletion:',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Final confirmation - in a real app, we would delete here
                        Navigator.of(context).pop();
                        
                        // Show success message and log out
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account deletion requested. You will be logged out.'),
                            duration: Duration(seconds: 5),
                          ),
                        );
                        
                        // Force a delay before redirecting to login
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pushReplacementNamed(context, '/login');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Delete Account'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
  
  Color _getRoleColor(role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.errorColor;
      case UserRole.instructor:
        return AppTheme.accentColor;
      case UserRole.client:
      default:
        return AppTheme.primaryColor;
    }
  }
  
  String _getRoleText(role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.client:
      default:
        return 'Client';
    }
  }
}