import 'package:flutter/material.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

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
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Success animation
            Container(
              width: double.infinity,
              color: AppTheme.primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green[600],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all set for ${session.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // Booking details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Session card
                  _buildSessionCard(),
                  const SizedBox(height: 20),
                  
                  // Booking information
                  _buildInfoCard(),
                  const SizedBox(height: 30),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil(
                              (route) => route.isFirst || route.settings.name == '/sessions',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View All Sessions'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil(
                              (route) => route.settings.name == '/home',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Go to Home'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Cancellation policy card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              const Text(
                                'Cancellation Policy',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCancellationPolicyItem(
                            '24+ hours before',
                            'Full credit refund',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          const Divider(height: 24),
                          _buildCancellationPolicyItem(
                            '12-24 hours before',
                            '50% credit refund',
                            Icons.remove_circle_outline,
                            Colors.orange,
                          ),
                          const Divider(height: 24),
                          _buildCancellationPolicyItem(
                            'Less than 12 hours',
                            'No refund available',
                            Icons.cancel_outlined,
                            Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'To cancel your booking, go to My Bookings section in the app.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSessionCard() {
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
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              session.formattedDate,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.access_time,
              'Time',
              session.formattedTimeRange,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.location_on,
              'Location',
              session.location ?? 'Main Gym',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.person,
              'Instructor',
              session.instructorName ?? 'TBA',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
            _buildDetailRow(
              Icons.confirmation_number,
              'Booking ID',
              'B-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.calendar_today,
              'Booked On',
              DateFormat('MMM dd, yyyy, hh:mm a').format(bookingDate),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.credit_card,
              'Credits Used',
              '$creditsUsed credits',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.verified,
              'Status',
              'Confirmed',
              valueColor: Colors.green[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCancellationPolicyItem(String timeframe, String policy, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeframe,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                policy,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}