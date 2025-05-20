import 'package:flutter/material.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/services/booking_service.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({Key? key}) : super(key: key);

  @override
  _UserBookingsScreenState createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  String? _errorMessage;
  
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  List<BookingModel> _cancelledBookings = [];
  
  Map<String, SessionModel> _sessionsCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;
      
      if (userId == null) {
        setState(() {
          _errorMessage = 'You need to be logged in to view your bookings';
          _isLoading = false;
        });
        return;
      }
      
      // In a real app, this would fetch from the BookingService
      // For demo purposes, we'll use sample data
      final allBookings = BookingModel.getSampleBookings();
      
      final now = DateTime.now();
      
      // Sort bookings into categories
      _upcomingBookings = [];
      _pastBookings = [];
      _cancelledBookings = [];
      
      for (final booking in allBookings) {
        // Get session details for each booking
        if (!_sessionsCache.containsKey(booking.sessionId)) {
          try {
            // In a real app, this would fetch from the BookingService
            // For demo purposes, we'll use sample data
            final sessions = SessionModel.getSampleSessions();
            for (final session in sessions) {
              _sessionsCache[session.id] = session;
            }
          } catch (e) {
            // Ignore errors, session will be null
          }
        }
        
        final session = _sessionsCache[booking.sessionId];
        if (session == null) continue;

        if (booking.status == 'cancelled') {
          _cancelledBookings.add(booking);
        } else if (session.date.isAfter(now) && booking.status != 'completed') {
          _upcomingBookings.add(booking);
        } else {
          _pastBookings.add(booking);
        }
      }
      
      // Sort by date
      _upcomingBookings.sort((a, b) {
        final sessionA = _sessionsCache[a.sessionId];
        final sessionB = _sessionsCache[b.sessionId];
        if (sessionA == null || sessionB == null) return 0;
        return sessionA.date.compareTo(sessionB.date);
      });
      
      _pastBookings.sort((a, b) {
        final sessionA = _sessionsCache[a.sessionId];
        final sessionB = _sessionsCache[b.sessionId];
        if (sessionA == null || sessionB == null) return 0;
        return sessionB.date.compareTo(sessionA.date); // Descending
      });
      
      _cancelledBookings.sort((a, b) {
        return b.bookingDate.compareTo(a.bookingDate); // Descending
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading bookings: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final session = _sessionsCache[booking.sessionId];
    if (session == null) return;
    
    // Calculate time until session
    final now = DateTime.now();
    final sessionTime = session.date;
    final hoursUntilSession = sessionTime.difference(now).inHours;
    
    // Determine refund amount based on cancellation policy
    int refundAmount = 0;
    String refundMessage = '';
    Color refundColor = Colors.red;
    
    if (hoursUntilSession >= 24) {
      // Full refund
      refundAmount = booking.creditsUsed;
      refundMessage = 'You will receive a full refund of ${booking.creditsUsed} credits';
      refundColor = Colors.green;
    } else if (hoursUntilSession >= 12) {
      // Partial refund (50%)
      refundAmount = (booking.creditsUsed / 2).ceil();
      refundMessage = 'You will receive a partial refund of $refundAmount credits (50%)';
      refundColor = Colors.orange;
    } else {
      // No refund
      refundMessage = 'No refund will be applied as per the cancellation policy';
      refundColor = Colors.red;
    }
    
    // Show enhanced cancellation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel your booking for ${session.title}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Session details reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        session.formattedDate,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        session.formattedTimeRange,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Refund information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: refundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: refundColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        refundAmount > 0 ? Icons.credit_score : Icons.money_off, 
                        color: refundColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refund Summary',
                        style: TextStyle(
                          color: refundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    refundMessage,
                    style: TextStyle(
                      color: refundColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Full policy details
            ExpansionTile(
              title: const Text(
                'Cancellation Policy Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              children: [
                Text(
                  '• Full refund if cancelled 24+ hours before session\n'
                  '• 50% refund if cancelled 12-24 hours before session\n'
                  '• No refund if cancelled less than 12 hours before session',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Booking'),
          ),
        ],
      ),
    );
    
    if (shouldCancel != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // In a real app, this would call the BookingService
      // For demo purposes, we'll simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Process refund
      if (refundAmount > 0) {
        await authProvider.addCredits(gymCredits: refundAmount);
      }
      
      // Move booking to cancelled list with updated information
      final cancelledBooking = booking.copyWith(
        status: 'cancelled',
        cancellationReason: 'User cancelled',
        cancelledAt: DateTime.now(),
      );
      
      setState(() {
        _upcomingBookings.remove(booking);
        _cancelledBookings.add(cancelledBooking);
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refundAmount > 0
              ? 'Booking cancelled successfully. ${refundAmount} credits refunded.'
              : 'Booking cancelled successfully. No credits were refunded.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Bookings',
            onPressed: () {
              _tabController.animateTo(2); // Navigate to cancelled tab
            },
            textColor: Colors.white,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling booking: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBookings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(_upcomingBookings, canCancel: true),
                    _buildBookingsList(_pastBookings),
                    _buildBookingsList(_cancelledBookings, isCancelled: true),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/sessions');
        },
        label: const Text('Book New Session'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings,
      {bool canCancel = false, bool isCancelled = false}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCancelled
                  ? Icons.cancel_outlined
                  : canCancel
                      ? Icons.calendar_today_outlined
                      : Icons.history_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isCancelled
                  ? 'No cancelled bookings'
                  : canCancel
                      ? 'No upcoming bookings'
                      : 'No past bookings',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              canCancel
                  ? 'Book a session to get started'
                  : 'Check back later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            if (canCancel)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/sessions');
                },
                icon: const Icon(Icons.fitness_center),
                label: const Text('Browse Sessions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final session = _sessionsCache[booking.sessionId];
        if (session == null) return const SizedBox.shrink();
        
        return _buildBookingCard(booking, session, canCancel: canCancel);
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, SessionModel session,
      {bool canCancel = false}) {
    final bool isPast = session.date.isBefore(DateTime.now());
    final bool isCancelled = booking.status == 'cancelled';
    final bool hasAttended = booking.hasAttended;
    
    Color statusColor;
    String statusText;
    
    if (isCancelled) {
      statusColor = Colors.red;
      statusText = 'Cancelled';
    } else if (isPast) {
      statusColor = hasAttended ? Colors.green : Colors.orange;
      statusText = hasAttended ? 'Attended' : 'Missed';
    } else {
      statusColor = Colors.blue;
      statusText = 'Confirmed';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        children: [
          // Session header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Session details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date and time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.formattedDate,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.formattedTimeRange,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Instructor and type
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.instructorName ?? 'Unknown Instructor',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.sessionType,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Booking details
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Booking ID: ${booking.id}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Booked on: ${DateFormat('MMM d, yyyy').format(booking.bookingDate)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (isCancelled && booking.cancelledAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cancelled on: ${DateFormat('MMM d, yyyy').format(booking.cancelledAt!)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Credits used: ${booking.creditsUsed}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                if (canCancel) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/sessions/detail',
                              arguments: session,
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _cancelBooking(booking),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // View details button for past/cancelled bookings
                if (!canCancel) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/sessions/detail',
                          arguments: session,
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
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
}