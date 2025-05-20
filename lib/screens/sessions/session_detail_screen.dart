import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionModel {
  final String id;
  final String title;
  final String instructor;
  final DateTime dateTime;
  final int duration; // in minutes
  final String location;
  final String category;
  final int capacity;
  final int enrolled;
  final int creditsRequired;
  final String description;

  SessionModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.dateTime, 
    required this.duration,
    required this.location,
    required this.category,
    required this.capacity,
    required this.enrolled,
    required this.creditsRequired,
    required this.description,
  });
}

class SessionDetailScreen extends StatefulWidget {
  final SessionModel session;
  final String userRole;
  final int userGymCredits;
  final int userIntervalCredits;

  const SessionDetailScreen({
    Key? key,
    required this.session, 
    required this.userRole,
    required this.userGymCredits,
    required this.userIntervalCredits,
  }) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  bool _isBooked = false;
  bool _isConfirmingBooking = false;
  String _bookingError = '';
  
  // Calculate if user can afford to book
  bool get _canAffordBooking => 
      widget.userGymCredits >= widget.session.creditsRequired ||
      widget.userIntervalCredits >= 1;
  
  // Calculate if session is full
  bool get _isSessionFull => widget.session.enrolled >= widget.session.capacity;
  
  // Calculate if session is in the past
  bool get _isSessionInPast => widget.session.dateTime.isBefore(DateTime.now());
  
  // Can book logic combines all conditions
  bool get _canBook => !_isBooked && !_isSessionFull && !_isSessionInPast && _canAffordBooking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          if (widget.userRole == 'admin' || widget.userRole == 'instructor')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Edit session logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit session feature coming soon')),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image with category overlay
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(widget.session.category),
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.session.category).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.session.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_isSessionFull || _isSessionInPast)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          _isSessionInPast ? 'Session Ended' : 'Session Full',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Session details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and booking status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.session.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_isBooked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Booked',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Instructor
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Instructor: ${widget.session.instructor}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${DateFormat('EEEE, MMMM d, y').format(widget.session.dateTime)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Time
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Time: ${DateFormat('h:mm a').format(widget.session.dateTime)} (${widget.session.duration} min)',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.room, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Location: ${widget.session.location}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Capacity and enrollment
                  LinearProgressIndicator(
                    value: widget.session.capacity > 0 
                      ? widget.session.enrolled / widget.session.capacity 
                      : 0,
                    backgroundColor: Colors.grey[200],
                    color: _getEnrollmentColor(widget.session.enrolled, widget.session.capacity),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enrollment: ${widget.session.enrolled}/${widget.session.capacity}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getAvailabilityText(widget.session.enrolled, widget.session.capacity),
                        style: TextStyle(
                          color: _getEnrollmentColor(widget.session.enrolled, widget.session.capacity),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'About This Session',
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
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Credits required
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF0D47A1).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Color(0xFF0D47A1),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Credits Required',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This session requires ${widget.session.creditsRequired} credits OR 1 interval credit',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Your credits: ${widget.userGymCredits} (+ ${widget.userIntervalCredits} interval)',
                                      style: TextStyle(
                                        color: _canAffordBooking ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_bookingError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _bookingError,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Book button
                  if (widget.userRole == 'client')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canBook 
                          ? () => _showBookingConfirmation() 
                          : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0D47A1),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isBooked 
                          ? const Text('Cancel Booking') 
                          : const Text('Book Session'),
                      ),
                    ),
                  
                  // Cancel/Delete button (for admin/instructor)
                  if (widget.userRole == 'admin' || widget.userRole == 'instructor')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Delete session logic would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Delete session feature coming soon')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Session'),
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
  
  // Show booking confirmation dialog
  void _showBookingConfirmation() {
    setState(() {
      _isConfirmingBooking = true;
      _bookingError = '';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('EEEE, MMMM d, y').format(widget.session.dateTime)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('h:mm a').format(widget.session.dateTime)),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Credit Summary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current credits:'),
                Text('${widget.userGymCredits}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Required credits:'),
                Text('${widget.session.creditsRequired}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining credits:'),
                Text(
                  '${widget.userGymCredits - widget.session.creditsRequired}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (widget.userGymCredits - widget.session.creditsRequired) < 0 
                        ? Colors.red 
                        : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if ((widget.userGymCredits - widget.session.creditsRequired) < 0 && widget.userIntervalCredits > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Not enough regular credits!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'We\'ll use 1 interval credit instead.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isConfirmingBooking = false;
              });
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processBooking();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
  
  // Process booking after confirmation
  void _processBooking() {
    // In a real app, this would call a service to make the actual booking
    
    // Simulate booking success and update UI
    setState(() {
      _isBooked = true;
      _isConfirmingBooking = false;
      _bookingError = '';
    });
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session booked successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Helper methods for UI
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'yoga':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.flash_on;
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'pilates':
        return Icons.accessibility_new;
      default:
        return Icons.sports;
    }
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'yoga':
        return Colors.purple;
      case 'hiit':
        return Colors.orange;
      case 'strength':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'pilates':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
  }
  
  Color _getEnrollmentColor(int enrolled, int capacity) {
    final double ratio = capacity > 0 ? enrolled / capacity : 0;
    
    if (ratio >= 1.0) {
      return Colors.red;
    } else if (ratio >= 0.8) {
      return Colors.orange;
    } else if (ratio >= 0.5) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
  
  String _getAvailabilityText(int enrolled, int capacity) {
    final double ratio = capacity > 0 ? enrolled / capacity : 0;
    final int spotsLeft = capacity - enrolled;
    
    if (ratio >= 1.0) {
      return 'Full';
    } else if (ratio >= 0.8) {
      return '$spotsLeft spot${spotsLeft == 1 ? '' : 's'} left';
    } else if (ratio >= 0.5) {
      return 'Filling up';
    } else {
      return 'Available';
    }
  }
}