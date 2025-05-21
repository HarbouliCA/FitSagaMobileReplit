import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/custom_app_bar.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/utils/date_formatter.dart';
import 'package:fitsaga/config/constants.dart';

class SessionDetailsScreen extends StatefulWidget {
  const SessionDetailsScreen({Key? key}) : super(key: key);

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  bool _isLoading = false;
  String? _error;
  bool _hasBookedSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBookingStatus();
    });
  }

  Future<void> _checkBookingStatus() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final session = sessionProvider.selectedSession;
    
    if (session != null && authProvider.currentUser != null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final hasBooked = sessionProvider.hasUserBookedSession(
          session.id,
          authProvider.currentUser!.id,
        );
        
        setState(() {
          _hasBookedSession = hasBooked;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'Failed to check booking status: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToBooking() {
    Navigator.pushNamed(context, '/booking_confirmation');
  }

  void _cancelBooking() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final session = sessionProvider.selectedSession;
    
    if (session != null && authProvider.currentUser != null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        final success = await sessionProvider.cancelBooking(
          session.id,
          authProvider.currentUser!.id,
        );
        
        if (success) {
          setState(() {
            _hasBookedSession = false;
            _isLoading = false;
          });
          
          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          setState(() {
            _error = sessionProvider.error ?? 'Failed to cancel booking';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Failed to cancel booking: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final session = sessionProvider.selectedSession;
    
    if (session == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Session Details',
        ),
        body: const Center(
          child: Text('No session selected'),
        ),
      );
    }
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Session Details',
        showCredits: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading session details...')
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeMedium,
                            color: AppTheme.errorColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _checkBookingStatus,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Session image/header
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryDarkColor,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                session.title,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeHeading,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: AppTheme.spacingExtraLarge),
                              
                              // Session type pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(color: Colors.white, opacity: 0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  session.activityType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Session details section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Instructor info
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(color: Colors.grey, opacity: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Instructor',
                                      style: TextStyle(
                                        fontSize: AppTheme.fontSizeSmall,
                                        color: AppTheme.textLightColor,
                                      ),
                                    ),
                                    Text(
                                      session.instructorName,
                                      style: const TextStyle(
                                        fontSize: AppTheme.fontSizeMedium,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Date and time
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeSmall,
                                          color: AppTheme.textLightColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormatter.formatDate(session.startTime),
                                        style: const TextStyle(
                                          fontSize: AppTheme.fontSizeMedium,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Time',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeSmall,
                                          color: AppTheme.textLightColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormatter.formatSessionTimeRange(
                                          session.startTime,
                                          session.endTime,
                                        ),
                                        style: const TextStyle(
                                          fontSize: AppTheme.fontSizeMedium,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Location and spots
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Location',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeSmall,
                                          color: AppTheme.textLightColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        session.location,
                                        style: const TextStyle(
                                          fontSize: AppTheme.fontSizeMedium,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Available Spots',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeSmall,
                                          color: AppTheme.textLightColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        session.isFull
                                            ? 'Full'
                                            : '${session.availableSpots} / ${session.maxParticipants}',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeMedium,
                                          fontWeight: FontWeight.bold,
                                          color: session.isFull
                                              ? AppTheme.errorColor
                                              : AppTheme.successColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Description
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: AppTheme.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              session.description,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSizeRegular,
                                color: AppTheme.textPrimaryColor,
                                height: 1.5,
                              ),
                            ),
                            
                            if (session.requirements != null &&
                                session.requirements!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              
                              // Requirements
                              const Text(
                                'Requirements',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSizeMedium,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                session.requirements!,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeRegular,
                                  color: AppTheme.textPrimaryColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            // Credits required
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.infoLightColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Credits Required: ${session.requiredCredits}',
                                    style: const TextStyle(
                                      fontSize: AppTheme.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Session status
                            if (session.isPast) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorLightColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppTheme.errorColor,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'This session has already ended and cannot be booked.',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeRegular,
                                          color: AppTheme.errorColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (session.isFull && !_hasBookedSession) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningLightColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppTheme.warningColor,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'This session is currently full. Please check back later or book another session.',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontSizeRegular,
                                          color: AppTheme.warningColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (!_hasBookedSession &&
                                !creditProvider.hasUnlimitedCredits &&
                                creditProvider.totalCredits < session.requiredCredits) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorLightColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppTheme.errorColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'You don\'t have enough credits to book this session.',
                                            style: TextStyle(
                                              fontSize: AppTheme.fontSizeRegular,
                                              color: AppTheme.errorColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'You have: ${creditProvider.displayCredits} credits | Need: ${session.requiredCredits} credits',
                                            style: const TextStyle(
                                              fontSize: AppTheme.fontSizeSmall,
                                              color: AppTheme.errorColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            // Action buttons
                            if (!session.isPast) ...[
                              if (_hasBookedSession) ...[
                                // Cancel booking button
                                ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _cancelBooking,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('CANCEL BOOKING'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Add to calendar button
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Add to calendar functionality
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text('ADD TO CALENDAR'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ] else if (!session.isFull) ...[
                                // Book session button
                                ElevatedButton.icon(
                                  onPressed: (creditProvider.hasUnlimitedCredits ||
                                          creditProvider.totalCredits >= session.requiredCredits)
                                      ? (_isLoading ? null : _navigateToBooking)
                                      : null,
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('BOOK SESSION'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _hasBookedSession && !session.isPast
          ? Container(
              color: AppTheme.successLightColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.successColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You have booked this session',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}