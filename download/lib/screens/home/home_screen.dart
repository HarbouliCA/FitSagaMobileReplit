import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/config/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user found. Please log in again.'),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(user),
      drawer: _buildDrawer(context, user, authProvider),
      body: _buildBody(user),
      bottomNavigationBar: _buildBottomNavBar(user),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel user) {
    return AppBar(
      title: const Text(AppConstants.appName),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // TODO: Navigate to notifications screen
          },
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryLightColor,
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDrawer(
      BuildContext context, UserModel user, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Sessions'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to sessions screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Tutorials'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to tutorials screen
            },
          ),
          if (user.isAdmin || user.isInstructor) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Create Session'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create session screen
              },
            ),
          ],
          if (user.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to user management screen
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Credits'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to credits screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show about dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserModel user) {
    // Show different home screens based on user role
    if (user.isAdmin) {
      return _buildAdminHomeScreen(user);
    } else if (user.isInstructor) {
      return _buildInstructorHomeScreen(user);
    } else {
      return _buildClientHomeScreen(user);
    }
  }

  Widget _buildAdminHomeScreen(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(user),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildQuickStatsCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildUpcomingSessionsCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildAdminActions(),
        ],
      ),
    );
  }

  Widget _buildInstructorHomeScreen(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(user),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildMySessionsCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildInstructorTutorialsCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildInstructorActions(),
        ],
      ),
    );
  }

  Widget _buildClientHomeScreen(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(user),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildCreditBalanceCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildMyBookingsCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildFeaturedTutorialsCard(),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildUpcomingSessionsCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    final greeting = _getGreeting();
    
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${user.name}!',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              _getWelcomeMessage(user),
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getWelcomeMessage(UserModel user) {
    if (user.isAdmin) {
      return 'You have admin access to all FitSAGA features.';
    } else if (user.isInstructor) {
      return 'You have instructor access to create and manage sessions.';
    } else {
      return 'Welcome to FitSAGA. Book sessions and view tutorials to start your fitness journey.';
    }
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    count: '28',
                    label: 'Users',
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_today,
                    count: '12',
                    label: 'Sessions',
                    color: AppTheme.accentColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.video_library,
                    count: '8',
                    label: 'Tutorials',
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          decoration: BoxDecoration(
            color: color.withValues(color: color, opacity: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          count,
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

  Widget _buildUpcomingSessionsCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all sessions
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            // Mock data for sessions
            _buildSessionItem(
              title: 'HIIT Workout',
              instructor: 'John Smith',
              time: '10:00 AM - 11:00 AM',
              date: 'Today',
              participants: 12,
              maxParticipants: 20,
            ),
            const Divider(),
            _buildSessionItem(
              title: 'Yoga for Beginners',
              instructor: 'Emma Wilson',
              time: '2:00 PM - 3:00 PM',
              date: 'Tomorrow',
              participants: 8,
              maxParticipants: 15,
            ),
            const Divider(),
            _buildSessionItem(
              title: 'Advanced Weight Training',
              instructor: 'Mike Johnson',
              time: '4:00 PM - 5:30 PM',
              date: 'May 22, 2023',
              participants: 6,
              maxParticipants: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem({
    required String title,
    required String instructor,
    required String time,
    required String date,
    required int participants,
    required int maxParticipants,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppTheme.spacingRegular),
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
                Text(
                  'by $instructor',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
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
          Column(
            children: [
              Text(
                '$participants/$maxParticipants',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.fontSizeSmall,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusCircular),
                child: LinearProgressIndicator(
                  value: participants / maxParticipants,
                  minHeight: 5,
                  backgroundColor: AppTheme.primaryLightColor.withValues(color: AppTheme.primaryLightColor, opacity: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_circle,
                    label: 'Create Session',
                    onPressed: () {
                      // TODO: Navigate to create session screen
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingRegular),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.people,
                    label: 'Manage Users',
                    onPressed: () {
                      // TODO: Navigate to user management screen
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.video_library,
                    label: 'Add Tutorial',
                    onPressed: () {
                      // TODO: Navigate to create tutorial screen
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingRegular),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.report,
                    label: 'Generate Reports',
                    onPressed: () {
                      // TODO: Navigate to reports screen
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.paddingMedium,
        ),
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySessionsCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Sessions',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to instructor sessions
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            // Mock data for instructor sessions
            _buildInstructorSessionItem(
              title: 'HIIT Workout',
              time: '10:00 AM - 11:00 AM',
              date: 'Today',
              participants: 12,
              maxParticipants: 20,
            ),
            const Divider(),
            _buildInstructorSessionItem(
              title: 'Strength Training',
              time: '1:00 PM - 2:30 PM',
              date: 'Tomorrow',
              participants: 8,
              maxParticipants: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorSessionItem({
    required String title,
    required String time,
    required String date,
    required int participants,
    required int maxParticipants,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppTheme.spacingRegular),
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
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
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
          Row(
            children: [
              Column(
                children: [
                  Text(
                    '$participants/$maxParticipants',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                  const Text(
                    'Participants',
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: AppTheme.fontSizeXSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                onPressed: () {
                  // TODO: Navigate to edit session
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorTutorialsCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Tutorials',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to instructor tutorials
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            // Mock data for instructor tutorials
            _buildTutorialItem(
              title: 'Proper Squat Form',
              duration: '15 mins',
              level: 'Beginner',
            ),
            const Divider(),
            _buildTutorialItem(
              title: 'Advanced Deadlift Techniques',
              duration: '25 mins',
              level: 'Advanced',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialItem({
    required String title,
    required String duration,
    required String level,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.infoColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppTheme.spacingRegular),
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
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.signal_cellular_alt,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      level,
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
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            onPressed: () {
              // TODO: Navigate to edit tutorial
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorActions() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_circle,
                    label: 'Create Session',
                    onPressed: () {
                      // TODO: Navigate to create session screen
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingRegular),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.video_call,
                    label: 'Add Tutorial',
                    onPressed: () {
                      // TODO: Navigate to create tutorial screen
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditBalanceCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Credit Balance',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Buy Credits'),
                  onPressed: () {
                    // TODO: Navigate to purchase credits
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingRegular),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(color: AppTheme.primaryColor, opacity: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.redeem,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Credits',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          '12',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successLightColor,
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusSmall),
                          ),
                          child: const Text(
                            '2 free bonus',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: AppTheme.fontSizeXSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('View History'),
                  onPressed: () {
                    // TODO: Navigate to credit history
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookingsCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all bookings
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            // Mock data for bookings
            _buildBookingItem(
              title: 'HIIT Workout',
              instructor: 'John Smith',
              time: '10:00 AM - 11:00 AM',
              date: 'Today',
              status: 'Confirmed',
            ),
            const Divider(),
            _buildBookingItem(
              title: 'Yoga for Beginners',
              instructor: 'Emma Wilson',
              time: '2:00 PM - 3:00 PM',
              date: 'Tomorrow',
              status: 'Confirmed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem({
    required String title,
    required String instructor,
    required String time,
    required String date,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppTheme.spacingRegular),
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
                Text(
                  'by $instructor',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppTheme.successColor,
                fontSize: AppTheme.fontSizeXSmall,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTutorialsCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured Tutorials',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all tutorials
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFeaturedTutorialItem(
                    title: 'Proper Squat Form',
                    instructor: 'John Smith',
                    duration: '15 mins',
                    level: 'Beginner',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacingRegular),
                  _buildFeaturedTutorialItem(
                    title: 'Advanced Deadlift',
                    instructor: 'Mike Johnson',
                    duration: '25 mins',
                    level: 'Advanced',
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: AppTheme.spacingRegular),
                  _buildFeaturedTutorialItem(
                    title: 'Yoga Basics',
                    instructor: 'Emma Wilson',
                    duration: '20 mins',
                    level: 'Beginner',
                    color: AppTheme.infoColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTutorialItem({
    required String title,
    required String instructor,
    required String duration,
    required String level,
    required Color color,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        color: color.withValues(color: color, opacity: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusRegular),
                topRight: Radius.circular(AppTheme.borderRadiusRegular),
              ),
              color: color,
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  instructor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: AppTheme.fontSizeXSmall,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 12,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeXSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      level,
                      style: TextStyle(
                        color: color,
                        fontSize: AppTheme.fontSizeXSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(UserModel user) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.fitness_center),
        label: 'Sessions',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.video_library),
        label: 'Tutorials',
      ),
    ];

    // Add admin/instructor specific items
    if (user.isAdmin || user.isInstructor) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Manage',
        ),
      );
    }

    // Add profile item
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    );

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        // TODO: Handle navigation
      },
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textLightColor,
    );
  }
}