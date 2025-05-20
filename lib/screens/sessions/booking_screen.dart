import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<BookingModel> _bookings = [];
  List<SessionModel> _sessions = [];

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
      _hasError = false;
    });

    try {
      // In a real app, this would fetch from a provider or API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Get sample data for demo purposes
      final sessions = SessionModel.getSampleSessions();
      
      // Create sample bookings
      final bookings = _createSampleBookings(sessions);

      setState(() {
        _sessions = sessions;
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BookingModel> _createSampleBookings(List<SessionModel> sessions) {
    final List<BookingModel> bookings = [];
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user == null) return [];
    
    // Create a few sample bookings
    for (int i = 0; i < 3; i++) {
      if (i < sessions.length) {
        final session = sessions[i];
        final status = i == 0 ? 'confirmed' : (i == 1 ? 'pending' : 'completed');
        
        bookings.add(
          BookingModel(
            id: 'booking$i',
            userId: user.uid,
            sessionId: session.id,
            bookingDate: DateTime.now().subtract(Duration(days: i)),
            creditsUsed: session.creditsRequired,
            status: status,
            hasAttended: status == 'completed',
          ),
        );
      }
    }
    
    // Add a cancelled booking
    if (sessions.length > 3) {
      bookings.add(
        BookingModel(
          id: 'bookingCancelled',
          userId: user.uid,
          sessionId: sessions[3].id,
          bookingDate: DateTime.now().subtract(const Duration(days: 5)),
          creditsUsed: sessions[3].creditsRequired,
          status: 'cancelled',
          cancellationReason: 'Schedule conflict',
          cancelledAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      );
    }
    
    return bookings;
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    // Show confirmation dialog
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel your booking for "${_getSessionForBooking(booking)?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    ) ?? false;
    
    if (!confirm) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, this would call an API to cancel the booking
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Update booking status
      final updatedBookings = _bookings.map((b) {
        if (b.id == booking.id) {
          return b.copyWith(
            status: 'cancelled',
            cancellationReason: 'User cancelled',
            cancelledAt: DateTime.now(),
          );
        }
        return b;
      }).toList();
      
      setState(() {
        _bookings = updatedBookings;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  SessionModel? _getSessionForBooking(BookingModel booking) {
    return _sessions.firstWhere(
      (session) => session.id == booking.sessionId,
      orElse: () => SessionModel(
        id: '',
        title: 'Unknown Session',
        description: '',
        sessionType: '',
        date: DateTime.now(),
        startTimeMinutes: 0,
        durationMinutes: 0,
        capacity: 0,
        bookedCount: 0,
        creditsRequired: 0,
      ),
    );
  }

  List<BookingModel> _getFilteredBookings(String status) {
    if (status == 'all') return _bookings;
    return _bookings.where((booking) => booking.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(
          size: 40,
          showText: true,
          text: 'Loading bookings...',
        ),
      );
    }

    if (_hasError) {
      return CustomErrorWidget(
        message: 'Error loading bookings: $_errorMessage',
        onRetry: _loadBookings,
        fullScreen: true,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBookingsList(_getActiveBookings()),
        _buildBookingsList(_getCompletedBookings()),
        _buildBookingsList(_getCancelledBookings()),
      ],
    );
  }

  List<BookingModel> _getActiveBookings() {
    return _bookings.where((booking) => 
      booking.status == 'confirmed' || booking.status == 'pending'
    ).toList();
  }

  List<BookingModel> _getCompletedBookings() {
    return _bookings.where((booking) => booking.status == 'completed').toList();
  }

  List<BookingModel> _getCancelledBookings() {
    return _bookings.where((booking) => booking.status == 'cancelled').toList();
  }

  Widget _buildBookingsList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
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
          final session = _getSessionForBooking(booking);
          
          if (session == null) return const SizedBox.shrink();
          
          return _buildBookingCard(booking, session);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, SessionModel session) {
    final bool isUpcoming = booking.status == 'confirmed' || booking.status == 'pending';
    final bool isPending = booking.status == 'pending';
    final bool isCancelled = booking.status == 'cancelled';
    final bool isCompleted = booking.status == 'completed';
    
    // Determine status color
    Color statusColor;
    if (isPending) {
      statusColor = Colors.orange;
    } else if (isCancelled) {
      statusColor = Colors.red;
    } else if (isCompleted) {
      statusColor = Colors.green;
    } else {
      statusColor = AppTheme.primaryColor;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Booked on ${DateFormat('MMM d, y').format(booking.bookingDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Session details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: session.imageUrl != null
                          ? Image.network(
                              session.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.fitness_center,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Session info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.sessionType,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.formattedDate,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.formattedTimeRange,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Credits used
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${booking.creditsUsed} credit${booking.creditsUsed > 1 ? 's' : ''} used',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                if (isCancelled && booking.cancellationReason != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Cancellation reason: ${booking.cancellationReason}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                // Actions
                if (isUpcoming) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _cancelBooking(booking),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Cancel Booking',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                      if (!isPending) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to session details
                          },
                          icon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                          label: Text(
                            'View Details',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ],
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