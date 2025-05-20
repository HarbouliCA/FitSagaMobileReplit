import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/services/booking_service.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load bookings when the screen initializes
    _loadBookings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBookings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      setState(() {
        _error = 'Please log in to view your bookings';
      });
      return;
    }
    
    final userId = authProvider.currentUser!.id;
    final bookingService = Provider.of<BookingService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Load upcoming bookings
      _upcomingBookings = await bookingService.getUserBookings(
        userId: userId,
        upcoming: true,
        limit: 50, // Higher limit to show more bookings
      );
      
      // Load past bookings
      _pastBookings = await bookingService.getUserBookings(
        userId: userId,
        upcoming: false,
        limit: 20, // Fewer past bookings
      );
      
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _cancelBooking(BookingModel booking) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) return;
    
    final userId = authProvider.currentUser!.id;
    final bookingService = Provider.of<BookingService>(context, listen: false);
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.sessionTitle ?? 'Session',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${booking.formattedDate} • ${booking.formattedTime}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            if (booking.canBeCancelled())
              const Text('Are you sure you want to cancel this booking? You will receive a credit refund.')
            else
              Text(
                'Warning: Cancelling within 24 hours of the session may not provide a credit refund.',
                style: TextStyle(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final result = await bookingService.cancelBooking(
        userId: userId,
        bookingId: booking.id,
      );
      
      if (result.success) {
        // Remove from upcoming bookings list
        setState(() {
          _upcomingBookings.removeWhere((b) => b.id == booking.id);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        setState(() {
          _error = result.errorMessage ?? 'Failed to cancel booking';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error cancelling booking: $e';
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
    
    // Show login message if not authenticated
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please sign in to view your bookings',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading your bookings...')
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadBookings,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_upcomingBookings, isUpcoming: true),
                    _buildBookingList(_pastBookings, isUpcoming: false),
                  ],
                ),
    );
  }
  
  Widget _buildBookingList(List<BookingModel> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'You have no upcoming bookings'
                  : 'No past bookings found',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            if (isUpcoming)
              ElevatedButton(
                onPressed: () {
                  // Navigate to sessions screen to book
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SizedBox(), // Replace with actual sessions screen
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Book a Session'),
              ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, isUpcoming);
        },
      ),
    );
  }
  
  Widget _buildBookingCard(BookingModel booking, bool isUpcoming) {
    final bool canCancel = isUpcoming && booking.canBeCancelled();
    
    // Determine status color
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = AppTheme.primaryColor;
        break;
      case BookingStatus.cancelled:
        statusColor = AppTheme.errorColor;
        break;
      case BookingStatus.attended:
        statusColor = AppTheme.successColor;
        break;
      case BookingStatus.noShow:
        statusColor = Colors.orange;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                _getStatusText(booking.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session title
                Text(
                  booking.sessionTitle ?? 'Session',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date and time
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      booking.formattedDate,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      booking.formattedTime,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Instructor info
                if (booking.instructorName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: AppTheme.textSecondaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Instructor: ${booking.instructorName}',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Credits used
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.creditsUsed} credit${booking.creditsUsed > 1 ? 's' : ''} used',
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (isUpcoming && booking.status == BookingStatus.confirmed) ...[
                  const SizedBox(height: 16),
                  
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canCancel ? () => _cancelBooking(booking) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(canCancel ? 'Cancel Booking' : 'Cannot Cancel'),
                    ),
                  ),
                  
                  if (!canCancel && booking.status == BookingStatus.confirmed)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Cancellation deadline passed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.attended:
        return 'Attended';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }
}