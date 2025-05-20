import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a booking for a session in the FitSAGA app
class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String sessionId;
  final String sessionTitle;
  final DateTime bookingDate;
  final DateTime sessionDate;
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;
  final int creditsUsed;
  final String status; // 'confirmed', 'pending', 'cancelled', 'completed'
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final bool userAttended;
  final String? userNotes;
  final String? instructorNotes;
  final String? instructorId;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.sessionTitle,
    required this.bookingDate,
    required this.sessionDate,
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.creditsUsed,
    required this.status,
    this.cancellationReason,
    this.cancellationDate,
    this.userAttended = false,
    this.userNotes,
    this.instructorNotes,
    this.instructorId,
  });

  /// Create a booking from Firestore document
  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      sessionId: data['sessionId'] ?? '',
      sessionTitle: data['sessionTitle'] ?? 'Unnamed Session',
      bookingDate: (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionDate: (data['sessionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionStartTime: (data['sessionStartTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionEndTime: (data['sessionEndTime'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 1)),
      creditsUsed: data['creditsUsed'] ?? 1,
      status: data['status'] ?? 'pending',
      cancellationReason: data['cancellationReason'],
      cancellationDate: (data['cancellationDate'] as Timestamp?)?.toDate(),
      userAttended: data['userAttended'] ?? false,
      userNotes: data['userNotes'],
      instructorNotes: data['instructorNotes'],
      instructorId: data['instructorId'],
    );
  }

  /// Convert booking to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'sessionDate': Timestamp.fromDate(sessionDate),
      'sessionStartTime': Timestamp.fromDate(sessionStartTime),
      'sessionEndTime': Timestamp.fromDate(sessionEndTime),
      'creditsUsed': creditsUsed,
      'status': status,
      'cancellationReason': cancellationReason,
      'cancellationDate': cancellationDate != null ? Timestamp.fromDate(cancellationDate!) : null,
      'userAttended': userAttended,
      'userNotes': userNotes,
      'instructorNotes': instructorNotes,
      'instructorId': instructorId,
    };
  }

  /// Create a copy of this booking with updated fields
  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? sessionId,
    String? sessionTitle,
    DateTime? bookingDate,
    DateTime? sessionDate,
    DateTime? sessionStartTime,
    DateTime? sessionEndTime,
    int? creditsUsed,
    String? status,
    String? cancellationReason,
    DateTime? cancellationDate,
    bool? userAttended,
    String? userNotes,
    String? instructorNotes,
    String? instructorId,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      sessionId: sessionId ?? this.sessionId,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      bookingDate: bookingDate ?? this.bookingDate,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionEndTime: sessionEndTime ?? this.sessionEndTime,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      userAttended: userAttended ?? this.userAttended,
      userNotes: userNotes ?? this.userNotes,
      instructorNotes: instructorNotes ?? this.instructorNotes,
      instructorId: instructorId ?? this.instructorId,
    );
  }

  /// Cancel this booking
  BookingModel cancel(String reason) {
    return copyWith(
      status: 'cancelled',
      cancellationReason: reason,
      cancellationDate: DateTime.now(),
    );
  }

  /// Mark this booking as completed with attendance
  BookingModel complete({required bool attended, String? instructorNote}) {
    return copyWith(
      status: 'completed',
      userAttended: attended,
      instructorNotes: instructorNote,
    );
  }

  /// Check if this booking is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return status == 'confirmed' && sessionDate.isAfter(now);
  }

  /// Check if this booking is active (happening now)
  bool get isActive {
    final now = DateTime.now();
    return status == 'confirmed' && 
           sessionDate.year == now.year && 
           sessionDate.month == now.month && 
           sessionDate.day == now.day &&
           sessionStartTime.isBefore(now) && 
           sessionEndTime.isAfter(now);
  }

  /// Check if this booking is past
  bool get isPast {
    final now = DateTime.now();
    return sessionDate.isBefore(now) && status != 'cancelled';
  }

  /// Check if user can cancel this booking
  bool get canCancel {
    final now = DateTime.now();
    final cancellationDeadline = sessionStartTime.subtract(const Duration(hours: 2));
    return status == 'confirmed' && now.isBefore(cancellationDeadline);
  }

  /// Generate sample bookings for testing/demo
  static List<BookingModel> getSampleBookings({required String userId, String userName = 'Demo User'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      // Upcoming booking
      BookingModel(
        id: 'booking1',
        userId: userId,
        userName: userName,
        sessionId: 'session1',
        sessionTitle: 'Morning Yoga',
        bookingDate: now.subtract(const Duration(days: 2)),
        sessionDate: today.add(const Duration(days: 1)),
        sessionStartTime: DateTime(today.year, today.month, today.day + 1, 7, 0),
        sessionEndTime: DateTime(today.year, today.month, today.day + 1, 8, 0),
        creditsUsed: 1,
        status: 'confirmed',
        instructorId: 'instructor1',
      ),
      // Active booking (today)
      BookingModel(
        id: 'booking2',
        userId: userId,
        userName: userName,
        sessionId: 'session2',
        sessionTitle: 'HIIT Training',
        bookingDate: now.subtract(const Duration(days: 3)),
        sessionDate: today,
        sessionStartTime: DateTime(today.year, today.month, today.day, 18, 0),
        sessionEndTime: DateTime(today.year, today.month, today.day, 19, 0),
        creditsUsed: 2,
        status: 'confirmed',
        instructorId: 'instructor2',
      ),
      // Past booking (completed with attendance)
      BookingModel(
        id: 'booking3',
        userId: userId,
        userName: userName,
        sessionId: 'session3',
        sessionTitle: 'Strength Training',
        bookingDate: now.subtract(const Duration(days: 10)),
        sessionDate: today.subtract(const Duration(days: 7)),
        sessionStartTime: DateTime(today.year, today.month, today.day - 7, 10, 0),
        sessionEndTime: DateTime(today.year, today.month, today.day - 7, 11, 0),
        creditsUsed: 1,
        status: 'completed',
        userAttended: true,
        instructorNotes: 'Great progress with form!',
        instructorId: 'instructor2',
      ),
      // Past booking (missed)
      BookingModel(
        id: 'booking4',
        userId: userId,
        userName: userName,
        sessionId: 'session4',
        sessionTitle: 'Pilates',
        bookingDate: now.subtract(const Duration(days: 5)),
        sessionDate: today.subtract(const Duration(days: 3)),
        sessionStartTime: DateTime(today.year, today.month, today.day - 3, 17, 0),
        sessionEndTime: DateTime(today.year, today.month, today.day - 3, 18, 0),
        creditsUsed: 1,
        status: 'completed',
        userAttended: false,
        instructorId: 'instructor1',
      ),
      // Cancelled booking
      BookingModel(
        id: 'booking5',
        userId: userId,
        userName: userName,
        sessionId: 'session5',
        sessionTitle: 'Spin Class',
        bookingDate: now.subtract(const Duration(days: 8)),
        sessionDate: today.subtract(const Duration(days: 5)),
        sessionStartTime: DateTime(today.year, today.month, today.day - 5, 12, 30),
        sessionEndTime: DateTime(today.year, today.month, today.day - 5, 13, 30),
        creditsUsed: 2,
        status: 'cancelled',
        cancellationReason: 'Schedule conflict',
        cancellationDate: now.subtract(const Duration(days: 6)),
        instructorId: 'instructor3',
      ),
    ];
  }
}