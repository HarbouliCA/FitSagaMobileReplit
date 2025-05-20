import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isLoading = false;
  String? _error;
  
  // Form controllers
  final _gymNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  
  // App settings
  bool _allowGuestBooking = false;
  bool _requireCreditCardDetails = true;
  int _maxSessionsPerClient = 3;
  int _cancellationPeriodHours = 24;
  bool _enableNotifications = true;
  bool _autoArchiveSessions = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _gymNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // In a real app, these would be loaded from Firebase
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock data for demonstration
      _gymNameController.text = 'FitSAGA Fitness Center';
      _contactEmailController.text = 'contact@fitsaga.com';
      _contactPhoneController.text = '(555) 123-4567';
      _addressController.text = '123 Fitness Street, Workout City, WO 12345';
      _websiteController.text = 'https://www.fitsaga.com';
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // In a real app, this would save to Firebase
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // Reset app cache
  Future<void> _resetAppCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App Cache'),
        content: const Text(
          'This will clear all cached data in the app. Users may experience slower load times until the cache is rebuilt. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reset Cache'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // In a real app, this would clear app cache
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App cache has been reset'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  // Export data
  Future<void> _exportData() async {
    final option = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Export Data'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('users'),
            child: const ListTile(
              leading: Icon(Icons.people),
              title: Text('Export User Data'),
              subtitle: Text('All user profiles and credit balances'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('sessions'),
            child: const ListTile(
              leading: Icon(Icons.event),
              title: Text('Export Session Data'),
              subtitle: Text('All sessions and bookings'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('financial'),
            child: const ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text('Export Financial Data'),
              subtitle: Text('All transactions and credit purchases'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('all'),
            child: const ListTile(
              leading: Icon(Icons.download),
              title: Text('Export All Data'),
              subtitle: Text('Complete database export'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(null),
            child: const ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
    
    if (option != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // In a real app, this would export data
        await Future.delayed(const Duration(seconds: 2));
        
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data export started. You will receive an email when it\'s ready.'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Ensure user is authenticated and is admin
    if (!authProvider.isAuthenticated || !authProvider.currentUser!.isAdmin) {
      return const Center(
        child: Text('You do not have permission to access settings'),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'Reload Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading settings...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppTheme.errorColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _error = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  
                  // Business Information
                  _buildBusinessInfoSection(),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Booking Settings
                  _buildBookingSettingsSection(),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // App Settings
                  _buildAppSettingsSection(),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Advanced Settings
                  _buildAdvancedSettingsSection(),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Save All Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.paddingMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildBusinessInfoSection() {
    return Card(
      elevation: AppTheme.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.business,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 16),
                Text(
                  'Business Information',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            const Text(
              'This information will be displayed to users throughout the app.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Gym Name
            TextField(
              controller: _gymNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                hintText: 'Enter your gym or business name',
                prefixIcon: Icon(Icons.storefront),
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact Email
            TextField(
              controller: _contactEmailController,
              decoration: const InputDecoration(
                labelText: 'Contact Email',
                hintText: 'Enter contact email address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Contact Phone
            TextField(
              controller: _contactPhoneController,
              decoration: const InputDecoration(
                labelText: 'Contact Phone',
                hintText: 'Enter contact phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Business Address',
                hintText: 'Enter your business address',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Website
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website',
                hintText: 'Enter your website URL',
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBookingSettingsSection() {
    return Card(
      elevation: AppTheme.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.event_available,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 16),
                Text(
                  'Booking Settings',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            const Text(
              'Configure how clients can book sessions.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Allow guest booking
            SwitchListTile(
              title: const Text('Allow Guest Booking'),
              subtitle: const Text('Allow users to book sessions without creating an account'),
              value: _allowGuestBooking,
              onChanged: (value) {
                setState(() {
                  _allowGuestBooking = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            
            // Require credit card details
            SwitchListTile(
              title: const Text('Require Credit Card Details'),
              subtitle: const Text('Require users to add payment method before booking'),
              value: _requireCreditCardDetails,
              onChanged: (value) {
                setState(() {
                  _requireCreditCardDetails = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            
            // Max sessions per client
            ListTile(
              title: const Text('Maximum Sessions Per Client'),
              subtitle: const Text('Maximum number of active bookings a client can have'),
              trailing: SizedBox(
                width: 80,
                child: DropdownButtonFormField<int>(
                  value: _maxSessionsPerClient,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [1, 2, 3, 5, 10, 15, 20].map((number) {
                    return DropdownMenuItem<int>(
                      value: number,
                      child: Text(number.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _maxSessionsPerClient = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const Divider(),
            
            // Cancellation period
            ListTile(
              title: const Text('Cancellation Period (hours)'),
              subtitle: const Text('Minimum hours before session start time for cancellation'),
              trailing: SizedBox(
                width: 80,
                child: DropdownButtonFormField<int>(
                  value: _cancellationPeriodHours,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [1, 2, 4, 8, 12, 24, 48, 72].map((hours) {
                    return DropdownMenuItem<int>(
                      value: hours,
                      child: Text(hours.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _cancellationPeriodHours = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppSettingsSection() {
    return Card(
      elevation: AppTheme.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.settings_applications,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 16),
                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            const Text(
              'Configure app behavior and notifications.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Enable push notifications
            SwitchListTile(
              title: const Text('Enable Push Notifications'),
              subtitle: const Text('Send notifications for bookings, reminders, and updates'),
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            
            // Auto archive sessions
            SwitchListTile(
              title: const Text('Auto-Archive Completed Sessions'),
              subtitle: const Text('Automatically archive sessions once they are completed'),
              value: _autoArchiveSessions,
              onChanged: (value) {
                setState(() {
                  _autoArchiveSessions = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(),
            
            // App version
            const ListTile(
              title: Text('App Version'),
              trailing: Text(
                '1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdvancedSettingsSection() {
    return Card(
      elevation: AppTheme.elevationMedium,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 16),
                Text(
                  'Advanced Settings',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            const Text(
              'Advanced settings for administrators. Use with caution.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Export data
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Export Data'),
              subtitle: const Text('Export user, session, or financial data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportData,
            ),
            const Divider(),
            
            // Reset cache
            ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: const Text('Reset App Cache'),
              subtitle: const Text('Clear all cached data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _resetAppCache,
            ),
            const Divider(),
            
            // Firebase settings
            const ListTile(
              leading: Icon(Icons.storage),
              title: Text('Firebase Settings'),
              subtitle: Text('Configure Firebase project and collections'),
              trailing: Icon(Icons.chevron_right),
              // This would open a more detailed Firebase settings screen
            ),
            const Divider(),
            
            // Danger zone
            const ListTile(
              leading: Icon(
                Icons.warning,
                color: AppTheme.errorColor,
              ),
              title: Text(
                'Danger Zone',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Show reset confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Reset All Data'),
                            content: const Text(
                              'This will permanently delete all users, sessions, tutorials, and other app data. This action cannot be undone. Are you absolutely sure?',
                              style: TextStyle(
                                color: AppTheme.errorColor,
                              ),
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
                                  Navigator.of(context).pop();
                                  
                                  // Show second confirmation
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Final Confirmation'),
                                      content: const Text(
                                        'Type "RESET ALL DATA" to confirm.',
                                      ),
                                      content: TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'RESET ALL DATA',
                                        ),
                                        onSubmitted: (value) {
                                          if (value == 'RESET ALL DATA') {
                                            Navigator.of(context).pop();
                                            // Would reset data here
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('All data has been reset'),
                                                backgroundColor: AppTheme.errorColor,
                                              ),
                                            );
                                          }
                                        },
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
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                ),
                                child: const Text('Reset All Data'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Reset All Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Show backup confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Create Full Backup'),
                            content: const Text(
                              'This will create a complete backup of all app data. The backup will be stored in Firebase Storage and can be downloaded.',
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
                                  Navigator.of(context).pop();
                                  // Would create backup here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Backup created successfully'),
                                      backgroundColor: AppTheme.successColor,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.infoColor,
                                ),
                                child: const Text('Create Backup'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.backup),
                      label: const Text('Create Full Backup'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.infoColor,
                        side: const BorderSide(color: AppTheme.infoColor),
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