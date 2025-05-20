import 'package:flutter/material.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Widget to display information about a recurring session pattern
class RecurringSessionInfoWidget extends StatelessWidget {
  final SessionModel session;
  final bool isDetailed;
  final VoidCallback? onManageTap;

  const RecurringSessionInfoWidget({
    Key? key,
    required this.session,
    this.isDetailed = false,
    this.onManageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!session.isRecurring && session.parentRecurringSessionId == null) {
      return const SizedBox.shrink(); // Not a recurring session
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppTheme.paddingSmall,
        horizontal: 0,
      ),
      color: AppTheme.infoColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        side: BorderSide(
          color: AppTheme.infoColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.repeat,
                  color: AppTheme.infoColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  session.isRecurring 
                      ? 'Recurring Session' 
                      : 'Part of a Recurring Series',
                  style: const TextStyle(
                    color: AppTheme.infoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
                const Spacer(),
                if (onManageTap != null)
                  TextButton.icon(
                    onPressed: onManageTap,
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Manage Series'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.infoColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
              ],
            ),
            if (isDetailed) ...[
              const SizedBox(height: 12),
              _buildRecurringPattern(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringPattern() {
    if (session.recurringRule == null || session.recurringRule!.isEmpty) {
      return const Text(
        'No recurring pattern specified',
        style: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Parse the RRULE format
    Map<String, String> ruleMap = {};
    for (var part in session.recurringRule!.split(';')) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        ruleMap[keyValue[0]] = keyValue[1];
      }
    }

    final freq = ruleMap['FREQ'];
    if (freq == null) {
      return const Text(
        'Invalid recurring pattern',
        style: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    String patternText;
    
    switch (freq) {
      case 'DAILY':
        patternText = 'Repeats every day';
        break;
      case 'WEEKLY':
        final byDay = ruleMap['BYDAY']?.split(',');
        if (byDay != null && byDay.isNotEmpty) {
          final days = _formatWeekdays(byDay);
          patternText = 'Repeats weekly on $days';
        } else {
          final weekday = DateFormat('EEEE').format(session.startTime);
          patternText = 'Repeats weekly on $weekday';
        }
        break;
      case 'MONTHLY':
        final day = session.startTime.day;
        final ordinal = _getOrdinalSuffix(day);
        patternText = 'Repeats monthly on the $day$ordinal day';
        break;
      case 'YEARLY':
        final date = DateFormat('MMMM d').format(session.startTime);
        patternText = 'Repeats annually on $date';
        break;
      default:
        patternText = 'Repeats $freq';
    }

    // Time information
    final timeText = DateFormat('h:mm a').format(session.startTime);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          patternText,
          style: const TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: AppTheme.fontSizeRegular,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Always at $timeText for ${session.durationMinutes} minutes',
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: AppTheme.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  String _formatWeekdays(List<String> days) {
    const dayMap = {
      'MO': 'Monday',
      'TU': 'Tuesday',
      'WE': 'Wednesday',
      'TH': 'Thursday',
      'FR': 'Friday',
      'SA': 'Saturday',
      'SU': 'Sunday',
    };

    final formattedDays = days.map((day) => dayMap[day] ?? day).toList();
    
    if (formattedDays.length == 1) {
      return formattedDays.first;
    } else if (formattedDays.length == 2) {
      return '${formattedDays.first} and ${formattedDays.last}';
    } else {
      final lastDay = formattedDays.removeLast();
      return '${formattedDays.join(', ')}, and $lastDay';
    }
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}