import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

class SessionDetailScreen extends StatefulWidget {
  final SessionModel session;

  const SessionDetailScreen({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  _SessionDetailScreenState createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  bool _isBooking = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.session.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black54,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            widget.session.imageUrl != null
                ? Image.network(
                    widget.session.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: [0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share session
            _shareSession();
          },
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session type and status
          Row(
            children: [
              _buildSessionTag(
                widget.session.sessionType,
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _buildSessionTag(
                widget.session.hasAvailableSlots
                    ? '${widget.session.availableSlots} spots left'
                    : 'Full',
                widget.session.hasAvailableSlots ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              _buildSessionTag(
                '${widget.session.creditsRequired} credits',
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Date and time
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            widget.session.formattedDate,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.access_time,
            'Time',
            widget.session.formattedTimeRange,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.person,
            'Instructor',
            widget.session.instructorName ?? 'Unknown Instructor',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.room,
            'Location',
            widget.session.roomName ?? 'Main Gym',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.group,
            'Capacity',
            '${widget.session.bookedCount}/${widget.session.capacity} booked',
          ),
          const SizedBox(height: 24),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.session.description,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Error message (if any)
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Book button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.session.hasAvailableSlots && !_isBooking
                  ? _showBookingConfirmation
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isBooking
                  ? const LoadingIndicator(color: Colors.white)
                  : Text(
                      widget.session.hasAvailableSlots
                          ? 'Book Session (${widget.session.creditsRequired} credits)'
                          : 'Session Full',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildSessionTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _showBookingConfirmation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      setState(() {
        _errorMessage = 'You need to be logged in to book a session';
      });
      return;
    }

    // Check if user has enough credits
    final hasEnoughCredits = user.credits.gymCredits >= widget.session.creditsRequired;
    if (!hasEnoughCredits) {
      setState(() {
        _errorMessage = 'You don\'t have enough credits to book this session';
      });
      return;
    }

    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session: ${widget.session.title}'),
            const SizedBox(height: 8),
            Text('Date: ${widget.session.formattedDate}'),
            const SizedBox(height: 8),
            Text('Time: ${widget.session.formattedTimeRange}'),
            const SizedBox(height: 8),
            Text('Credits Required: ${widget.session.creditsRequired}'),
            const SizedBox(height: 8),
            Text('Your Credits: ${user.credits.gymCredits}'),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to book this session? Credits will be deducted from your account.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    _bookSession();
  }

  void _shareSession() {
    // In a real app, this would use a sharing plugin like share_plus
    // For now, we'll just show a dialog with the session details
    final sessionInfo = 
      'Join me at ${widget.session.title}!\n\n'
      'Date: ${widget.session.formattedDate}\n'
      'Time: ${widget.session.formattedTimeRange}\n'
      'Instructor: ${widget.session.instructorName ?? "Unknown"}\n'
      'Type: ${widget.session.sessionType}\n\n'
      'Book now in the FitSAGA app!';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Session details to share:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(sessionInfo),
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
                  content: Text('Session details shared!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookSession() async {
    setState(() {
      _isBooking = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Deduct credits
      final success = await authProvider.deductCredits(
        gymCredits: widget.session.creditsRequired,
      );
      
      if (!success) {
        setState(() {
          _errorMessage = 'Failed to deduct credits';
          _isBooking = false;
        });
        return;
      }

      // In a real app, create booking in Firestore here
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Show success dialog or navigate to booking confirmation
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              session: widget.session,
              bookingDate: DateTime.now(),
              creditsUsed: widget.session.creditsRequired,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error booking session: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }
}

class BookingConfirmationScreen extends StatelessWidget {
  final SessionModel session;
  final DateTime bookingDate;
  final int creditsUsed;

  const BookingConfirmationScreen({
    Key? key,
    required this.session,
    required this.bookingDate,
    required this.creditsUsed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success icon
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            
            // Success message
            const Text(
              'Booking Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully booked ${session.title}',
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Booking details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Session', session.title),
                  const SizedBox(height: 8),
                  _buildDetailRow('Date', session.formattedDate),
                  const SizedBox(height: 8),
                  _buildDetailRow('Time', session.formattedTimeRange),
                  const SizedBox(height: 8),
                  _buildDetailRow('Instructor', session.instructorName ?? 'Unknown'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Location', session.roomName ?? 'Main Gym'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Credits Used', creditsUsed.toString()),
                  const SizedBox(height: 8),
                  _buildDetailRow('Booking ID', 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Booked On', DateFormat('MMM d, y - h:mm a').format(bookingDate)),
                ],
              ),
            ),
            const Spacer(),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Add to calendar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to calendar'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add to Calendar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share booking
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing booking details'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Go back to home or bookings
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}