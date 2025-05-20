import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

class SessionDetailsScreen extends StatefulWidget {
  final SessionModel session;

  const SessionDetailsScreen({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);
    
    final user = authProvider.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user found. Please log in again.'),
        ),
      );
    }
    
    final isUserBooked = widget.session.isUserRegistered(user.id);
    final hasEnoughCredits = creditProvider.hasSufficientCredits(1);
    final now = DateTime.now();
    final canCancel = isUserBooked && widget.session.startTime.isAfter(now);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
        actions: [
          if (user.isInstructor && 
              (user.isAdmin || user.id == widget.session.instructorId))
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/sessions/edit',
                  arguments: widget.session,
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSessionHeader(),
                  _buildSessionInfo(),
                  if (_errorMessage != null)
                    _buildErrorMessage(),
                  _buildActions(
                    isUserBooked: isUserBooked,
                    hasEnoughCredits: hasEnoughCredits,
                    canCancel: canCancel,
                    sessionProvider: sessionProvider,
                    authProvider: authProvider,
                  ),
                  _buildSessionDescription(),
                  if (widget.session.requirements != null)
                    _buildRequirements(),
                  _buildInstructorInfo(),
                  _buildParticipantsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: _getTypeColor(widget.session.type),
        image: DecorationImage(
          image: AssetImage(_getTypeImage(widget.session.type)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            _getTypeColor(widget.session.type).withOpacity(0.8),
            BlendMode.srcATop,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: AppTheme.paddingMedium,
            left: AppTheme.paddingMedium,
            right: AppTheme.paddingMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.session.title,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'with ${widget.session.instructorName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        _getTypeText(widget.session.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTheme.fontSizeSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.session.level != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          widget.session.level!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final now = DateTime.now();
    final isPast = widget.session.isPast;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and time
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: _getTypeColor(widget.session.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                Icons.calendar_today,
                color: _getTypeColor(widget.session.type),
              ),
            ),
            title: Text(
              dateFormatter.format(widget.session.startTime),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${timeFormatter.format(widget.session.startTime)} - ${timeFormatter.format(widget.session.endTime)} (${widget.session.durationInMinutes} mins)',
            ),
          ),
          
          // Location
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: _getTypeColor(widget.session.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                Icons.location_on,
                color: _getTypeColor(widget.session.type),
              ),
            ),
            title: const Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(widget.session.location),
          ),
          
          // Session status
          if (isPast)
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: AppTheme.textLightColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This session has ended',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (widget.session.startTime.isAfter(now))
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: AppTheme.infoLightColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Starting in ${_getTimeUntil(widget.session.startTime)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Participant count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: AppTheme.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: widget.session.isFull
                      ? AppTheme.errorLightColor
                      : AppTheme.successLightColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.session.isFull
                          ? Icons.person_off
                          : Icons.people,
                      color: widget.session.isFull
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.session.isFull
                          ? 'Session Full'
                          : '${widget.session.availableSpots} spot${widget.session.availableSpots != 1 ? 's' : ''} left',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.session.isFull
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.credit_card,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Price:',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '1 Credit',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      padding: const EdgeInsets.all(AppTheme.paddingSmall),
      decoration: BoxDecoration(
        color: AppTheme.errorLightColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppTheme.errorColor,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions({
    required bool isUserBooked,
    required bool hasEnoughCredits,
    required bool canCancel,
    required SessionProvider sessionProvider,
    required AuthProvider authProvider,
  }) {
    if (widget.session.isPast) {
      // No actions for past sessions
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: isUserBooked
          ? ElevatedButton.icon(
              onPressed: canCancel
                  ? () => _cancelBooking(sessionProvider, authProvider)
                  : null,
              icon: const Icon(Icons.cancel),
              label: Text(canCancel ? 'Cancel Booking' : 'Cannot Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.paddingMedium,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: !widget.session.isFull && hasEnoughCredits
                  ? () => _bookSession(sessionProvider, authProvider)
                  : null,
              icon: const Icon(Icons.event_available),
              label: Text(
                widget.session.isFull
                    ? 'Session Full'
                    : !hasEnoughCredits
                        ? 'Need Credits'
                        : 'Book Session',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.paddingMedium,
                ),
              ),
            ),
    );
  }
  
  Widget _buildSessionDescription() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About This Session',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingRegular),
          Text(
            widget.session.description,
            style: const TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequirements() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What to Bring',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingRegular),
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.infoLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info,
                  color: AppTheme.infoColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.session.requirements!,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructorInfo() {
    // In a real app, we would fetch instructor details from Firebase
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructor',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingRegular),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getTypeColor(widget.session.type),
                    child: Text(
                      widget.session.instructorName.isNotEmpty
                          ? widget.session.instructorName[0].toUpperCase()
                          : 'I',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.instructorName,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Certified Fitness Trainer',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to instructor profile
                      Navigator.pushNamed(
                        context,
                        '/instructors/profile',
                        arguments: widget.session.instructorId,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getTypeColor(widget.session.type),
                      side: BorderSide(color: _getTypeColor(widget.session.type)),
                    ),
                    child: const Text('View Profile'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildParticipantsList() {
    if (widget.session.participantIds.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.session.participantIds.length}/${widget.session.maxParticipants}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingRegular),
          const Text(
            'See who's coming',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingRegular),
          // For now, just show avatars. In a real app, we would fetch user data
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.session.participantIds.length,
              itemBuilder: (context, index) {
                // For now, just show a placeholder
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryLightColor,
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _bookSession(
    SessionProvider sessionProvider,
    AuthProvider authProvider,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await sessionProvider.bookSession(
        widget.session.id,
        authProvider.currentUser!.id,
      );
      
      if (success) {
        if (mounted) {
          _showSuccessDialog(
            'Session Booked!',
            'You have successfully booked "${widget.session.title}".',
          );
        }
      } else {
        setState(() {
          _errorMessage = sessionProvider.error ?? 'Failed to book session.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _cancelBooking(
    SessionProvider sessionProvider,
    AuthProvider authProvider,
  ) async {
    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => _buildCancellationDialog(),
    );
    
    if (shouldCancel != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await sessionProvider.cancelBooking(
        widget.session.id,
        authProvider.currentUser!.id,
      );
      
      if (success) {
        if (mounted) {
          _showSuccessDialog(
            'Booking Cancelled',
            'Your booking for "${widget.session.title}" has been cancelled.',
          );
        }
      } else {
        setState(() {
          _errorMessage = sessionProvider.error ?? 'Failed to cancel booking.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Widget _buildCancellationDialog() {
    final now = DateTime.now();
    final hoursDifference = widget.session.startTime.difference(now).inHours;
    final willGetRefund = hoursDifference >= 24;
    
    return AlertDialog(
      title: const Text('Cancel Booking?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Are you sure you want to cancel your booking for "${widget.session.title}"?',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            decoration: BoxDecoration(
              color: willGetRefund 
                  ? AppTheme.successLightColor
                  : AppTheme.warningLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  willGetRefund ? Icons.check_circle : Icons.warning,
                  color: willGetRefund ? AppTheme.successColor : AppTheme.warningColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    willGetRefund
                        ? 'You will receive a full refund of 1 credit.'
                        : 'Cancellations less than 24 hours before the session do not qualify for a refund.',
                    style: TextStyle(
                      color: willGetRefund ? AppTheme.successColor : AppTheme.warningColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ),
              ],
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
    );
  }
  
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return AppTheme.primaryColor;
      case SessionType.group:
        return AppTheme.accentColor;
      case SessionType.workshop:
        return AppTheme.infoColor;
      case SessionType.event:
        return AppTheme.successColor;
    }
  }
  
  String _getTypeText(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return 'Personal Training';
      case SessionType.group:
        return 'Group Session';
      case SessionType.workshop:
        return 'Workshop';
      case SessionType.event:
        return 'Special Event';
    }
  }
  
  String _getTypeImage(SessionType type) {
    // In a real app, these would be actual image paths
    switch (type) {
      case SessionType.personal:
        return 'assets/images/personal_training.jpg';
      case SessionType.group:
        return 'assets/images/group_session.jpg';
      case SessionType.workshop:
        return 'assets/images/workshop.jpg';
      case SessionType.event:
        return 'assets/images/event.jpg';
    }
  }
  
  String _getTimeUntil(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''}';
    }
  }
}