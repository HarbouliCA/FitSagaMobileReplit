import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/models/credit_model.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/services/booking_service.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SessionBookingCard extends StatefulWidget {
  final SessionModel session;
  final UserCredit? userCredit;
  final Function()? onBookingComplete;

  const SessionBookingCard({
    Key? key,
    required this.session,
    this.userCredit,
    this.onBookingComplete,
  }) : super(key: key);

  @override
  State<SessionBookingCard> createState() => _SessionBookingCardState();
}

class _SessionBookingCardState extends State<SessionBookingCard> {
  bool _isLoading = false;
  String? _error;

  Future<void> _bookSession(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is logged in
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      setState(() {
        _error = 'Please log in to book a session';
      });
      return;
    }
    
    // Check if user has sufficient credits
    final userCredit = widget.userCredit;
    if (userCredit == null) {
      setState(() {
        _error = 'Unable to verify credit balance';
      });
      return;
    }
    
    if (!userCredit.hasSufficientCredits(widget.session.creditCost)) {
      setState(() {
        _error = 'Insufficient credits to book this session';
      });
      return;
    }
    
    // Show confirmation dialog
    final confirmed = await _showBookingConfirmationDialog(
      context: context,
      session: widget.session,
      userCredit: userCredit,
    );
    
    if (!confirmed) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final bookingService = Provider.of<BookingService>(context, listen: false);
      
      final result = await bookingService.bookSession(
        userId: authProvider.currentUser!.id,
        sessionId: widget.session.id,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (result.success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session booked successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Call onBookingComplete callback if provided
        if (widget.onBookingComplete != null) {
          widget.onBookingComplete!();
        }
      } else {
        setState(() {
          _error = result.errorMessage ?? 'Failed to book session';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'An error occurred: $e';
      });
    }
  }
  
  Future<bool> _showBookingConfirmationDialog({
    required BuildContext context,
    required SessionModel session,
    required UserCredit userCredit,
  }) async {
    final int requiredCredits = session.creditCost;
    final newCredits = userCredit.isUnlimited 
        ? 'Unlimited' 
        : (userCredit.totalCredits - requiredCredits).toString();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(session.startTime)} - ${_formatTime(session.startTime, session.endTime)}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (session.instructorName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Instructor: ${session.instructorName}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your credits:'),
                Text(
                  userCredit.getDisplayText(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Required:'),
                Text(
                  '$requiredCredits',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining:'),
                Text(
                  newCredits,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  String _formatTime(DateTime start, DateTime end) {
    return '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
  }
  
  Widget _buildCreditsIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.session.creditCost}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCapacityIndicator() {
    final int available = widget.session.maxCapacity - widget.session.currentBookings;
    final bool isNearlyFull = available <= 2;
    final bool isFull = available <= 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFull 
          ? AppTheme.errorColor.withOpacity(0.8)
          : isNearlyFull
              ? AppTheme.warningColor.withOpacity(0.8)
              : AppTheme.successColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull
                ? Icons.person_off
                : isNearlyFull
                    ? Icons.person_outlined
                    : Icons.people,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isFull
                ? 'Full'
                : '$available spot${available == 1 ? '' : 's'}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session title and indicators
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.session.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildCreditsIndicator(),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Session info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.session.startTime),
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(widget.session.startTime, widget.session.endTime),
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Capacity indicator
                _buildCapacityIndicator(),
              ],
            ),
            
            // Instructor
            if (widget.session.instructorName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Instructor: ${widget.session.instructorName}',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
            
            // Description if available
            if (widget.session.description != null && widget.session.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.session.description!,
                style: const TextStyle(
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Error message if any
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Book button
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: (widget.session.maxCapacity - widget.session.currentBookings) <= 0 
                          ? null // Disable button if session is full
                          : () => _bookSession(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        (widget.session.maxCapacity - widget.session.currentBookings) <= 0
                            ? 'Session Full'
                            : 'Book Now • ${widget.session.creditCost} Credit${widget.session.creditCost > 1 ? 's' : ''}',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}