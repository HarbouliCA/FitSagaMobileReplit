import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  confirmed,
  cancelled,
  attended,
  noShow
}

extension BookingStatusExtension on BookingStatus {
  String toStringValue() {
    switch (this) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.attended:
        return 'attended';
      case BookingStatus.noShow:
        return 'noShow';
    }
  }

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'attended':
        return BookingStatus.attended;
      case 'noshow':
      case 'no_show':
      case 'no-show':
        return BookingStatus.noShow;
      default:
        return BookingStatus.confirmed;
    }
  }
}

class BookingModel {
  final String id;
  final String userId;
  final String sessionId;
  final BookingStatus status;
  final int creditsUsed;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final DateTime? attendedAt;
  
  // Additional fields that might be useful
  final String? sessionTitle;
  final DateTime? sessionStartTime;
  final DateTime? sessionEndTime;
  final String? instructorId;
  final String? instructorName;

  BookingModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.status,
    required this.creditsUsed,
    required this.bookedAt,
    this.cancelledAt,
    this.attendedAt,
    this.sessionTitle,
    this.sessionStartTime,
    this.sessionEndTime,
    this.instructorId,
    this.instructorName,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sessionId: data['sessionId'] ?? '',
      status: BookingStatusExtension.fromString(data['status'] ?? 'confirmed'),
      creditsUsed: data['creditsUsed'] ?? 1,
      bookedAt: data['bookedAt'] != null 
          ? (data['bookedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      attendedAt: data['attendedAt'] != null 
          ? (data['attendedAt'] as Timestamp).toDate() 
          : null,
      sessionTitle: data['sessionTitle'],
      sessionStartTime: data['sessionStartTime'] != null 
          ? (data['sessionStartTime'] as Timestamp).toDate() 
          : null,
      sessionEndTime: data['sessionEndTime'] != null 
          ? (data['sessionEndTime'] as Timestamp).toDate() 
          : null,
      instructorId: data['instructorId'],
      instructorName: data['instructorName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'status': status.toStringValue(),
      'creditsUsed': creditsUsed,
      'bookedAt': Timestamp.fromDate(bookedAt),
      if (cancelledAt != null) 'cancelledAt': Timestamp.fromDate(cancelledAt!),
      if (attendedAt != null) 'attendedAt': Timestamp.fromDate(attendedAt!),
      if (sessionTitle != null) 'sessionTitle': sessionTitle,
      if (sessionStartTime != null) 'sessionStartTime': Timestamp.fromDate(sessionStartTime!),
      if (sessionEndTime != null) 'sessionEndTime': Timestamp.fromDate(sessionEndTime!),
      if (instructorId != null) 'instructorId': instructorId,
      if (instructorName != null) 'instructorName': instructorName,
    };
  }

  // Helper to get formatted date for display
  String get formattedDate {
    if (sessionStartTime == null) return 'Date not available';
    
    final day = sessionStartTime!.day.toString().padLeft(2, '0');
    final month = sessionStartTime!.month.toString().padLeft(2, '0');
    final year = sessionStartTime!.year;
    
    return '$day/$month/$year';
  }

  // Helper to get formatted time for display
  String get formattedTime {
    if (sessionStartTime == null || sessionEndTime == null) {
      return 'Time not available';
    }
    
    final startHour = sessionStartTime!.hour.toString().padLeft(2, '0');
    final startMinute = sessionStartTime!.minute.toString().padLeft(2, '0');
    
    final endHour = sessionEndTime!.hour.toString().padLeft(2, '0');
    final endMinute = sessionEndTime!.minute.toString().padLeft(2, '0');
    
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  // Check if booking can be cancelled (e.g., if it's more than 24 hours before session)
  bool canBeCancelled() {
    if (status != BookingStatus.confirmed) return false;
    if (sessionStartTime == null) return false;
    
    final now = DateTime.now();
    final cancellationDeadline = sessionStartTime!.subtract(const Duration(hours: 24));
    
    return now.isBefore(cancellationDeadline);
  }

  // Create a copy with updated fields
  BookingModel copyWith({
    String? id,
    String? userId,
    String? sessionId,
    BookingStatus? status,
    int? creditsUsed,
    DateTime? bookedAt,
    DateTime? cancelledAt,
    DateTime? attendedAt,
    String? sessionTitle,
    DateTime? sessionStartTime,
    DateTime? sessionEndTime,
    String? instructorId,
    String? instructorName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      bookedAt: bookedAt ?? this.bookedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      attendedAt: attendedAt ?? this.attendedAt,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionEndTime: sessionEndTime ?? this.sessionEndTime,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
    );
  }
}

// Result class for booking operations
class BookingResult {
  final bool success;
  final String? bookingId;
  final String? errorMessage;

  BookingResult({
    required this.success,
    this.bookingId,
    this.errorMessage,
  });

  factory BookingResult.success(String bookingId) {
    return BookingResult(
      success: true,
      bookingId: bookingId,
    );
  }

  factory BookingResult.error(String errorMessage) {
    return BookingResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}