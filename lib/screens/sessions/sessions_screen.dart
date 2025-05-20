import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/custom_app_bar.dart';
import 'package:fitsaga/widgets/common/custom_drawer.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/widgets/sessions/session_card.dart';
import 'package:fitsaga/widgets/sessions/session_filter.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({Key? key}) : super(key: key);

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _selectedIndex = 1; // Default tab index for bottom nav

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    
    await Future.wait([
      sessionProvider.fetchUpcomingSessions(),
      sessionProvider.fetchUserBookings(),
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
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already on sessions
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/tutorials');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _onSearch(String query) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    sessionProvider.setSearchQuery(query);
  }

  void _clearSearch() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    setState(() {
      _isSearching = false;
      _searchController.clear();
      sessionProvider.setSearchQuery(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);

    return Scaffold(
      appBar: SearchAppBar(
        title: 'Sessions',
        showCredits: true,
        onSearch: _onSearch,
        onClear: _clearSearch,
        initialQuery: sessionProvider.searchQuery,
      ),
      drawer: const CustomDrawer(currentRoute: '/sessions'),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textLightColor,
                tabs: const [
                  Tab(text: 'UPCOMING SESSIONS'),
                  Tab(text: 'MY BOOKINGS'),
                ],
                onTap: (_) {
                  // Force a rebuild when tab changes
                  setState(() {});
                },
              ),
            ),

            // Session filters
            if (_tabController.index == 0)
              SessionFilter(
                selectedActivityType: sessionProvider.selectedActivityType,
                selectedDate: sessionProvider.selectedDate,
                onActivityTypeChanged: sessionProvider.setActivityTypeFilter,
                onDateChanged: sessionProvider.setDateFilter,
                onClearFilters: sessionProvider.clearFilters,
              ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Upcoming sessions tab
                  _buildUpcomingSessionsTab(sessionProvider, creditProvider),
                  
                  // My bookings tab
                  _buildMyBookingsTab(sessionProvider),
                ],
              ),
            ),
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

  Widget _buildUpcomingSessionsTab(SessionProvider sessionProvider, CreditProvider creditProvider) {
    final sessions = sessionProvider.filteredSessions;
    final isLoading = sessionProvider.loading;
    final hasError = sessionProvider.error != null;
    
    if (isLoading) {
      return const LoadingIndicator(message: 'Loading sessions...');
    }
    
    if (hasError) {
      return ErrorDisplayWidget(
        message: sessionProvider.error ?? 'Failed to load sessions',
        onRetry: _refreshData,
      );
    }
    
    if (sessions.isEmpty) {
      return const EmptyStateWidget(
        message: 'No sessions found',
        subMessage: 'Try adjusting your filters or check back later',
        icon: Icons.event_busy,
      );
    }
    
    // Check if any sessions are already booked
    return ListView.builder(
      padding: const EdgeInsets.only(top: AppTheme.paddingRegular, bottom: AppTheme.paddingExtraLarge),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isBooked = sessionProvider.activeBookings.any(
          (booking) => booking.sessionId == session.id,
        );
        
        return SessionCard(
          session: session,
          onTap: () {
            sessionProvider.selectSession(session);
            Navigator.pushNamed(context, '/sessions/details');
          },
          showBookingStatus: true,
          isBooked: isBooked,
        );
      },
    );
  }

  Widget _buildMyBookingsTab(SessionProvider sessionProvider) {
    final bookings = sessionProvider.userBookings;
    final isLoading = sessionProvider.loading;
    final hasError = sessionProvider.error != null;
    
    if (isLoading) {
      return const LoadingIndicator(message: 'Loading bookings...');
    }
    
    if (hasError) {
      return ErrorDisplayWidget(
        message: sessionProvider.error ?? 'Failed to load bookings',
        onRetry: _refreshData,
      );
    }
    
    if (bookings.isEmpty) {
      return const EmptyStateWidget(
        message: 'No bookings found',
        subMessage: 'Book a session to get started',
        icon: Icons.event_busy,
      );
    }
    
    // Group bookings by status
    final activeBookings = bookings.where((b) => b.status == BookingStatus.confirmed && b.isUpcoming).toList();
    final pastBookings = bookings.where((b) => b.isPast || b.status != BookingStatus.confirmed).toList();
    
    return ListView(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingExtraLarge),
      children: [
        // Active bookings section
        if (activeBookings.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(
              left: AppTheme.paddingLarge,
              right: AppTheme.paddingLarge,
              top: AppTheme.paddingLarge,
              bottom: AppTheme.paddingSmall,
            ),
            child: Text(
              'Upcoming Bookings',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: activeBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(sessionProvider, activeBookings[index], true);
            },
          ),
        ],
        
        // Past bookings section
        if (pastBookings.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(
              left: AppTheme.paddingLarge,
              right: AppTheme.paddingLarge,
              top: AppTheme.paddingLarge,
              bottom: AppTheme.paddingSmall,
            ),
            child: Text(
              'Past Bookings',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: pastBookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(sessionProvider, pastBookings[index], false);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBookingCard(SessionProvider sessionProvider, BookingModel booking, bool isActive) {
    Color statusColor;
    IconData statusIcon;
    
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = isActive ? AppTheme.primaryColor : AppTheme.textLightColor;
        statusIcon = isActive ? Icons.event_available : Icons.event;
        break;
      case BookingStatus.cancelled:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.event_busy;
        break;
      case BookingStatus.attended:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.noShow:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingLarge,
        vertical: AppTheme.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        side: isActive 
            ? BorderSide(color: AppTheme.primaryColor, width: 1.5) 
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingRegular),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.activityName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.status.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Session details
            Row(
              children: [
                // Date and time
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppTheme.textLightColor,
                ),
                const SizedBox(width: 8),
                Text(
                  booking.sessionStartTime.difference(DateTime.now()).inDays < 7
                      ? '${booking.sessionStartTime.day}/${booking.sessionStartTime.month} at ${booking.sessionStartTime.hour}:${booking.sessionStartTime.minute.toString().padLeft(2, '0')}'
                      : '${booking.sessionStartTime.day}/${booking.sessionStartTime.month}/${booking.sessionStartTime.year}',
                  style: const TextStyle(
                    color: AppTheme.textColor,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Credits used
                const Icon(
                  Icons.stars,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${booking.creditsUsed} credits',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            // Cancel button for active bookings
            if (isActive && booking.isCancellable) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCancelBookingDialog(booking),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Booking'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelBookingDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? Your credits will be refunded.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelBooking(booking);
            },
            child: const Text('YES, CANCEL'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    try {
      final success = await sessionProvider.cancelBooking(
        booking.id, 
        'Cancelled by user',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully. Credits have been refunded.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sessionProvider.error ?? 'Failed to cancel booking. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
