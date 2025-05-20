import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  confirmed,
  cancelled,
  attended,
  noShow
}

extension BookingStatusExtension on BookingStatus {
  String get value {
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
  
  static BookingStatus fromString(String status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'attended':
        return BookingStatus.attended;
      case 'noShow':
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
  final String activityName;
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;
  final BookingStatus status;
  final int creditsUsed;
  final DateTime bookedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  
  BookingModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.activityName,
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.status,
    required this.creditsUsed,
    required this.bookedAt,
    this.cancelledAt,
    this.cancellationReason,
  });
  
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sessionId: data['sessionId'] ?? '',
      activityName: data['activityName'] ?? '',
      sessionStartTime: data['sessionStartTime'] != null 
          ? (data['sessionStartTime'] as Timestamp).toDate() 
          : DateTime.now(),
      sessionEndTime: data['sessionEndTime'] != null 
          ? (data['sessionEndTime'] as Timestamp).toDate() 
          : DateTime.now().add(const Duration(hours: 1)),
      status: BookingStatusExtension.fromString(data['status'] ?? 'confirmed'),
      creditsUsed: data['creditsUsed'] ?? 1,
      bookedAt: data['bookedAt'] != null 
          ? (data['bookedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      cancelledAt: data['cancelledAt'] != null 
          ? (data['cancelledAt'] as Timestamp).toDate() 
          : null,
      cancellationReason: data['cancellationReason'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'activityName': activityName,
      'sessionStartTime': sessionStartTime,
      'sessionEndTime': sessionEndTime,
      'status': status.value,
      'creditsUsed': creditsUsed,
      'bookedAt': bookedAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
    };
  }
  
  bool get isCancellable {
    // Can cancel if:
    // 1. Status is confirmed
    // 2. Session hasn't started yet
    // 3. Within cancellation window (e.g., at least 2 hours before)
    final cancellationWindow = Duration(hours: 2);
    final now = DateTime.now();
    
    return status == BookingStatus.confirmed &&
           now.isBefore(sessionStartTime) &&
           now.isBefore(sessionStartTime.subtract(cancellationWindow));
  }
  
  bool get isUpcoming {
    final now = DateTime.now();
    return status == BookingStatus.confirmed && now.isBefore(sessionStartTime);
  }
  
  bool get isPast {
    final now = DateTime.now();
    return now.isAfter(sessionEndTime);
  }
}
