import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

// A demo model for sessions
class SessionModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int startTimeMinutes;
  final int durationMinutes;
  final String sessionType;
  final String? instructorName;
  final String? roomName;
  final int capacity;
  final int bookedCount;
  final int creditsRequired;
  final String? intensityLevel;
  final String? levelType;
  final String? imageUrl;
  
  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTimeMinutes,
    required this.durationMinutes,
    required this.sessionType,
    this.instructorName,
    this.roomName,
    required this.capacity,
    required this.bookedCount,
    required this.creditsRequired,
    this.intensityLevel,
    this.levelType,
    this.imageUrl,
  });
  
  // Helper properties for formatted display
  String get formattedDate => DateFormat('EEEE, MMM d, yyyy').format(date);
  
  String get formattedStartTime {
    final hours = startTimeMinutes ~/ 60;
    final minutes = startTimeMinutes % 60;
    final isPM = hours >= 12;
    final hour12 = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
    return '$hour12:${minutes.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
  }
  
  String get formattedEndTime {
    final endTimeMinutes = startTimeMinutes + durationMinutes;
    final hours = endTimeMinutes ~/ 60;
    final minutes = endTimeMinutes % 60;
    final isPM = hours >= 12;
    final hour12 = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
    return '$hour12:${minutes.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
  }
  
  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';
  
  bool get hasAvailableSlots => bookedCount < capacity;
  
  int get availableSlots => capacity - bookedCount;
}

// A demo model for a user
class UserModel {
  final String id;
  final String name;
  final int gymCredits;
  final int intervalCredits;
  
  UserModel({
    required this.id,
    required this.name,
    required this.gymCredits,
    required this.intervalCredits,
  });
}

class SessionDetailDemo extends StatefulWidget {
  final SessionModel session;
  final UserModel user;
  
  const SessionDetailDemo({
    Key? key,
    required this.session,
    required this.user,
  }) : super(key: key);
  
  @override
  State<SessionDetailDemo> createState() => _SessionDetailDemoState();
}

class _SessionDetailDemoState extends State<SessionDetailDemo> {
  bool _isBooking = false;
  String? _errorMessage;
  bool _isBooked = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shareSession,
            icon: const Icon(Icons.share),
            tooltip: 'Share Session',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: widget.session.hasAvailableSlots && !_isBooked
          ? FloatingActionButton.extended(
              onPressed: _showBookingConfirmation,
              icon: const Icon(Icons.fitness_center),
              label: Text('Book (${widget.session.creditsRequired} credits)'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }
  
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          if (widget.session.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.session.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Session summary card
          _buildSessionSummaryCard(),
          const SizedBox(height: 24),

          // Description
          _buildSectionWithIcon(
            title: 'Description',
            icon: Icons.info_outline,
            iconColor: AppTheme.primaryColor,
            child: Text(
              widget.session.description,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Session details card
          _buildSessionDetailsCard(),
          const SizedBox(height: 24),

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
            const SizedBox(height: 16),
          ],
          
          // Booking button
          _isBooked 
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You\'re booked!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'See you on ${widget.session.formattedDate} at ${widget.session.formattedStartTime}',
                              style: TextStyle(
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: widget.session.hasAvailableSlots 
                      ? _showBookingConfirmation
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: _isBooking
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
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
        ],
      ),
    );
  }
  
  Widget _buildSessionSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session status indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.session.hasAvailableSlots
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.session.hasAvailableSlots
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.session.hasAvailableSlots
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 16,
                        color: widget.session.hasAvailableSlots
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.session.hasAvailableSlots
                            ? '${widget.session.availableSlots} spots left'
                            : 'Session Full',
                        style: TextStyle(
                          color: widget.session.hasAvailableSlots
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.credit_card,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.session.creditsRequired} credits',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Key information
            Row(
              children: [
                _buildInfoPill(
                  label: 'Date',
                  value: widget.session.formattedDate,
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoPill(
                  label: 'Time',
                  value: widget.session.formattedTimeRange,
                  icon: Icons.access_time,
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                _buildInfoPill(
                  label: 'Type',
                  value: widget.session.sessionType,
                  icon: Icons.fitness_center,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                _buildInfoPill(
                  label: 'Duration',
                  value: '${widget.session.durationMinutes} min',
                  icon: Icons.timer,
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Session Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            
            // Instructor
            _buildDetailRow(
              Icons.person,
              'Instructor',
              widget.session.instructorName ?? 'Unknown Instructor',
            ),
            const Divider(),
            
            // Location
            _buildDetailRow(
              Icons.room,
              'Location',
              widget.session.roomName ?? 'Main Gym',
            ),
            const Divider(),
            
            // Capacity
            _buildDetailRow(
              Icons.group,
              'Capacity',
              '${widget.session.bookedCount}/${widget.session.capacity} booked',
            ),
            const Divider(),
            
            // Intensity
            _buildDetailRow(
              Icons.speed,
              'Intensity',
              widget.session.intensityLevel ?? 'Moderate',
            ),
            const Divider(),
            
            // Level
            _buildDetailRow(
              Icons.trending_up,
              'Level',
              widget.session.levelType ?? 'All levels',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionWithIcon({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
  
  Future<void> _showBookingConfirmation() async {
    // Check if user has enough credits
    final hasEnoughCredits = widget.user.gymCredits >= widget.session.creditsRequired;
    if (!hasEnoughCredits) {
      setState(() {
        _errorMessage = 'You don\'t have enough credits to book this session';
      });
      
      // Show dialog with option to view credits
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not Enough Credits'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.credit_card_off,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'You don\'t have enough credits to book this session.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Required: ${widget.session.creditsRequired} credits\nYour balance: ${widget.user.gymCredits} credits',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
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
                    content: Text('This would navigate to credits screen'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Manage Credits'),
            ),
          ],
        ),
      );
      return;
    }

    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session details card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildConfirmationDetail(
                    Icons.calendar_today,
                    'Date',
                    widget.session.formattedDate,
                  ),
                  const SizedBox(height: 8),
                  _buildConfirmationDetail(
                    Icons.access_time,
                    'Time',
                    widget.session.formattedTimeRange,
                  ),
                  const SizedBox(height: 8),
                  _buildConfirmationDetail(
                    Icons.person,
                    'Instructor',
                    widget.session.instructorName ?? 'Unknown',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Credits summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Credits Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Balance:',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        '${widget.user.gymCredits} credits',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Session Cost:',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        '-${widget.session.creditsRequired} credits',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining Balance:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        '${widget.user.gymCredits - widget.session.creditsRequired} credits',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Confirmation text
            const Text(
              'By booking this session, you agree to the cancellation policy:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '• Full refund if cancelled 24+ hours before session\n'
              '• 50% refund if cancelled 12-24 hours before session\n'
              '• No refund if cancelled less than 12 hours before session',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() {
      _isBooking = true;
    });

    // Simulate booking process
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isBooking = false;
      _isBooked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session booked successfully!'),
        backgroundColor: Colors.green,
      ),
    );
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

  Widget _buildConfirmationDetail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}