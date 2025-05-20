import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String sessionId;
  final DateTime bookingDate;
  final int creditsUsed;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final bool hasAttended;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  
  BookingModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.bookingDate,
    required this.creditsUsed,
    required this.status,
    required this.hasAttended,
    this.cancellationReason,
    this.cancelledAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'bookingDate': bookingDate,
      'creditsUsed': creditsUsed,
      'status': status,
      'hasAttended': hasAttended,
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt,
    };
  }
  
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['userId'],
      sessionId: json['sessionId'],
      bookingDate: json['bookingDate'] is Timestamp 
          ? (json['bookingDate'] as Timestamp).toDate()
          : DateTime.parse(json['bookingDate'].toString()),
      creditsUsed: json['creditsUsed'],
      status: json['status'],
      hasAttended: json['hasAttended'] ?? false,
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] is Timestamp
          ? (json['cancelledAt'] as Timestamp).toDate()
          : json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'].toString())
              : null,
    );
  }
  
  BookingModel copyWith({
    String? id,
    String? userId,
    String? sessionId,
    DateTime? bookingDate,
    int? creditsUsed,
    String? status,
    bool? hasAttended,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      bookingDate: bookingDate ?? this.bookingDate,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      status: status ?? this.status,
      hasAttended: hasAttended ?? this.hasAttended,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
  
  // Get a list of sample bookings for testing
  static List<BookingModel> getSampleBookings() {
    return [
      BookingModel(
        id: '1',
        userId: 'user1',
        sessionId: 'session1',
        bookingDate: DateTime.now().subtract(const Duration(days: 1)),
        creditsUsed: 2,
        status: 'confirmed',
        hasAttended: false,
      ),
      BookingModel(
        id: '2',
        userId: 'user1',
        sessionId: 'session2',
        bookingDate: DateTime.now().subtract(const Duration(days: 3)),
        creditsUsed: 1,
        status: 'completed',
        hasAttended: true,
      ),
      BookingModel(
        id: '3',
        userId: 'user1',
        sessionId: 'session3',
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
        creditsUsed: 3,
        status: 'cancelled',
        hasAttended: false,
        cancellationReason: 'Schedule conflict',
        cancelledAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }
}