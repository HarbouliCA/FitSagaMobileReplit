import 'package:intl/intl.dart';
import 'package:fitsaga/config/constants.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final formatter = DateFormat(AppConstants.dateFormat);
    return formatter.format(date);
  }
  
  static String formatTime(DateTime time) {
    final formatter = DateFormat(AppConstants.timeFormat);
    return formatter.format(time);
  }
  
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat(AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }
  
  static String formatSessionTimeRange(DateTime start, DateTime end) {
    final timeFormatter = DateFormat(AppConstants.timeFormat);
    return '${timeFormatter.format(start)} - ${timeFormatter.format(end)}';
  }
  
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      
      if (remainingMinutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      } else {
        return '$hours:${remainingMinutes.toString().padLeft(2, '0')} hours';
      }
    }
  }
  
  static String formatDayOfWeek(DateTime date) {
    final formatter = DateFormat('EEEE');
    return formatter.format(date);
  }
  
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (targetDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (targetDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }
  
  static String formatCreditExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final daysRemaining = expiryDate.difference(now).inDays;
    
    if (daysRemaining < 0) {
      return 'Expired';
    } else if (daysRemaining == 0) {
      return 'Expires today';
    } else if (daysRemaining == 1) {
      return 'Expires tomorrow';
    } else if (daysRemaining < 30) {
      return 'Expires in $daysRemaining days';
    } else {
      return 'Expires on ${formatDate(expiryDate)}';
    }
  }
}