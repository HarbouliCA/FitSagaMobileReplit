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

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;
  bool _bookingSuccess = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);
    final session = sessionProvider.selectedSession;
    
    if (session == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Booking Confirmation',
        ),
        body: const Center(
          child: Text('No session selected'),
        ),
      );
    }
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Booking Confirmation',
        showCredits: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Processing your booking...')
          : _bookingSuccess
              ? _buildBookingSuccessView(session)
              : _buildConfirmationView(session, creditProvider),
    );
  }

  Widget _buildConfirmationView(SessionModel session, CreditProvider creditProvider) {
    final requiredCredits = session.requiredCredits;
    final availableCredits = creditProvider.hasUnlimitedCredits 
        ? "Unlimited" 
        : creditProvider.totalCredits.toString();
    final remainingCredits = creditProvider.hasUnlimitedCredits 
        ? "Unlimited" 
        : creditProvider.remainingAfterBooking(requiredCredits).toString();
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Confirmation icon
            const Icon(
              Icons.event_available,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Confirmation title
            Text(
              'Confirm Your Booking',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Session details
            Text(
              session.activityName,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spacingSmall),
            
            Text(
              'with ${session.instructorName}',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeRegular,
                color: AppTheme.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Date and time card
            Card(
              elevation: AppTheme.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingRegular),
                        Text(
                          DateFormatter.formatDate(session.startTime),
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: AppTheme.spacingRegular),
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Credits info card
            Card(
              elevation: AppTheme.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Credit Summary',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    _buildCreditRow(
                      'Available Credits:',
                      availableCredits,
                      false,
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildCreditRow(
                      'Required Credits:',
                      requiredCredits.toString(),
                      false,
                    ),
                    
                    const Divider(height: 24),
                    
                    _buildCreditRow(
                      'Remaining Credits:',
                      remainingCredits,
                      true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Warning text
            const Text(
              'By confirming this booking, the required credits will be deducted from your account.',
              style: TextStyle(
                color: AppTheme.textLightColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (_error != null) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingRegular),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(color: AppTheme.errorColor, opacity: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            SizedBox(height: AppTheme.spacingExtraLarge),
            
            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                
                const SizedBox(width: AppTheme.spacingLarge),
                
                // Confirm button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CONFIRM'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSuccessView(SessionModel session) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success icon
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: AppTheme.successColor,
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Success message
            Text(
              'Booking Successful!',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeHeading,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Session details
            Text(
              'You have successfully booked:',
              style: TextStyle(
                fontSize: AppTheme.fontSizeRegular,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Session info card
            Card(
              elevation: AppTheme.elevationSmall,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    Text(
                      session.activityName,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    Text(
                      'with ${session.instructorName}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeRegular,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                    
                    const Divider(height: 32),
                    
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: AppTheme.spacingRegular),
                        Text(
                          DateFormatter.formatDate(session.startTime),
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeRegular,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: AppTheme.spacingRegular),
                        Text(
                          DateFormatter.formatSessionTimeRange(
                            session.startTime, 
                            session.endTime,
                          ),
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeRegular,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: AppTheme.spacingRegular),
                        Text(
                          '${session.requiredCredits} credits used',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeRegular,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacingExtraLarge),
            
            // Action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      '/sessions', 
                      (route) => route.settings.name == '/home',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('VIEW MY BOOKINGS'),
                ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('BACK TO HOME'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditRow(String label, String value, bool isHighlighted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeRegular,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTheme.fontSizeRegular,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  void _confirmBooking() async {
    if (_isLoading) return;
    
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    final session = sessionProvider.selectedSession;
    
    if (session != null && authProvider.currentUser != null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Check if user has sufficient credits
      if (!creditProvider.hasUnlimitedCredits && 
          !creditProvider.hasSufficientCredits(session.requiredCredits)) {
        setState(() {
          _isLoading = false;
          _error = AppConstants.errorInsufficientCredits;
        });
        return;
      }
      
      // Process the booking
      final success = await sessionProvider.bookSession(
        session.id,
        authProvider.currentUser!.id,
      );
      
      if (success) {
        // Refresh credit data
        if (authProvider.currentUser != null) {
          await creditProvider.refreshCredits(authProvider.currentUser!.id);
        }
        
        setState(() {
          _isLoading = false;
          _bookingSuccess = true;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = sessionProvider.error ?? AppConstants.errorGeneralBooking;
        });
      }
    }
  }
}