import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/user_provider.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/custom_app_bar.dart';
import 'package:fitsaga/widgets/common/custom_drawer.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/widgets/sessions/session_card.dart';
import 'package:fitsaga/widgets/tutorials/tutorial_card.dart';
import 'package:fitsaga/utils/date_formatter.dart';
import 'package:fitsaga/utils/role_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    
    await Future.wait([
      sessionProvider.fetchUpcomingSessions(),
      sessionProvider.fetchUserBookings(),
      tutorialProvider.fetchFeaturedTutorials(),
      creditProvider.refreshCredits(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to corresponding screens
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/sessions');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/tutorials');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);
    
    // Redirect to role-specific dashboard if needed
    if (authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authProvider.isInstructor && !authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/instructor/dashboard');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'FitSAGA',
        showBackButton: false,
        showCredits: true,
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: '/home'),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppTheme.paddingExtraLarge),
          children: [
            // Welcome message
            _buildWelcomeSection(userProvider, creditProvider),
            
            // My bookings section
            _buildMyBookingsSection(context, sessionProvider),
            
            // Upcoming sessions
            _buildUpcomingSessionsSection(context, sessionProvider),
            
            // Featured tutorials
            _buildFeaturedTutorialsSection(context, tutorialProvider),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Tutorials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLightColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildWelcomeSection(UserProvider userProvider, CreditProvider creditProvider) {
    final user = userProvider.user;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null 
                    ? Text(
                        (user?.name.isNotEmpty == true) 
                            ? user!.name[0].toUpperCase() 
                            : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ) 
                    : null,
              ),
              const SizedBox(width: AppTheme.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.name ?? 'User'}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready for your workout today?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppTheme.fontSizeRegular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Credits info card
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingRegular),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLarge),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creditProvider.hasUnlimitedCredits 
                            ? 'Unlimited Access' 
                            : 'Your Credits: ${creditProvider.displayCredits}',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use credits to book sessions',
                        style: TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textLightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookingsSection(BuildContext context, SessionProvider sessionProvider) {
    final activeBookings = sessionProvider.activeBookings;
    final isLoading = sessionProvider.loading;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Bookings',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (activeBookings.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sessions');
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
        ),

        if (isLoading)
          const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (activeBookings.isEmpty)
          const EmptyStateWidget(
            message: 'No Upcoming Bookings',
            subMessage: 'Book a session to get started',
            icon: Icons.event_busy,
            iconSize: 48,
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: activeBookings.length > 2 ? 2 : activeBookings.length,
            itemBuilder: (context, index) {
              final booking = activeBookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                  vertical: AppTheme.paddingSmall,
                ),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    booking.activityName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    DateFormatter.formatDateTime(booking.sessionStartTime),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: const Text(
                      'BOOKED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () async {
                    final session = await sessionProvider.getSessionById(booking.sessionId);
                    if (session != null && context.mounted) {
                      sessionProvider.selectSession(session);
                      Navigator.pushNamed(context, '/sessions/details');
                    }
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildUpcomingSessionsSection(BuildContext context, SessionProvider sessionProvider) {
    final upcomingSessions = sessionProvider.upcomingSessions;
    final isLoading = sessionProvider.loading;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/sessions');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        if (isLoading)
          const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (upcomingSessions.isEmpty)
          const EmptyStateWidget(
            message: 'No Upcoming Sessions',
            subMessage: 'Check back later for new sessions',
            icon: Icons.event_busy,
            iconSize: 48,
          )
        else
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingRegular),
              itemCount: upcomingSessions.length > 5 ? 5 : upcomingSessions.length,
              itemBuilder: (context, index) {
                final session = upcomingSessions[index];
                return SizedBox(
                  width: 280,
                  child: CompactSessionCard(
                    session: session,
                    onTap: () {
                      sessionProvider.selectSession(session);
                      Navigator.pushNamed(context, '/sessions/details');
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedTutorialsSection(BuildContext context, TutorialProvider tutorialProvider) {
    final featuredTutorials = tutorialProvider.featuredTutorials;
    final isLoading = tutorialProvider.loading;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Tutorials',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/tutorials');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        if (isLoading)
          const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (featuredTutorials.isEmpty)
          const EmptyStateWidget(
            message: 'No Featured Tutorials',
            subMessage: 'Check back later for new tutorials',
            icon: Icons.videocam_off,
            iconSize: 48,
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingRegular),
              itemCount: featuredTutorials.length,
              itemBuilder: (context, index) {
                final tutorial = featuredTutorials[index];
                return FeaturedTutorialCard(
                  tutorial: tutorial,
                  onTap: () {
                    tutorialProvider.selectTutorial(tutorial);
                    Navigator.pushNamed(context, '/tutorials/details');
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
