import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel extends Equatable {
  final String id;
  final String activityName;
  final String activityType;
  final String? title;
  final String instructorId;
  final String instructorName;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final int enrolledCount;
  final int requiredCredits;
  final String? description;
  final String? notes;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SessionModel({
    required this.id,
    required this.activityName,
    required this.activityType,
    this.title,
    required this.instructorId,
    required this.instructorName,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.enrolledCount,
    required this.requiredCredits,
    this.description,
    this.notes,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  SessionModel copyWith({
    String? id,
    String? activityName,
    String? activityType,
    String? title,
    String? instructorId,
    String? instructorName,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    int? enrolledCount,
    int? requiredCredits,
    String? description,
    String? notes,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      requiredCredits: requiredCredits ?? this.requiredCredits,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'] as String,
      activityName: map['activityName'] as String,
      activityType: map['activityType'] as String,
      title: map['title'] as String?,
      instructorId: map['instructorId'] as String,
      instructorName: map['instructorName'] as String,
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      capacity: map['capacity'] as int,
      enrolledCount: map['enrolledCount'] as int,
      requiredCredits: map['requiredCredits'] as int,
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      imageUrl: map['imageUrl'] as String?,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityName': activityName,
      'activityType': activityType,
      'title': title,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'capacity': capacity,
      'enrolledCount': enrolledCount,
      'requiredCredits': requiredCredits,
      'description': description,
      'notes': notes,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Computed properties
  Duration get sessionDuration => endTime.difference(startTime);
  bool get isFull => enrolledCount >= capacity;
  bool get isActive => status == 'active' && startTime.isAfter(DateTime.now());
  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isInProgress => startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  
  @override
  List<Object?> get props => [
    id,
    activityName,
    activityType,
    title,
    instructorId,
    instructorName,
    startTime,
    endTime,
    capacity,
    enrolledCount,
    requiredCredits,
    description,
    notes,
    imageUrl,
    status,
    createdAt,
    updatedAt,
  ];
}

class BookingModel extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final String status;
  final int creditsUsed;
  final DateTime bookingTime;
  final DateTime? cancelledTime;
  final String? cancellationReason;

  const BookingModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.status,
    required this.creditsUsed,
    required this.bookingTime,
    this.cancelledTime,
    this.cancellationReason,
  });

  BookingModel copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? status,
    int? creditsUsed,
    DateTime? bookingTime,
    DateTime? cancelledTime,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      bookingTime: bookingTime ?? this.bookingTime,
      cancelledTime: cancelledTime ?? this.cancelledTime,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      userId: map['userId'] as String,
      status: map['status'] as String,
      creditsUsed: map['creditsUsed'] as int,
      bookingTime: (map['bookingTime'] as Timestamp).toDate(),
      cancelledTime: map['cancelledTime'] != null 
          ? (map['cancelledTime'] as Timestamp).toDate() 
          : null,
      cancellationReason: map['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'status': status,
      'creditsUsed': creditsUsed,
      'bookingTime': Timestamp.fromDate(bookingTime),
      'cancelledTime': cancelledTime != null 
          ? Timestamp.fromDate(cancelledTime!) 
          : null,
      'cancellationReason': cancellationReason,
    };
  }

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  
  @override
  List<Object?> get props => [
    id,
    sessionId,
    userId,
    status,
    creditsUsed,
    bookingTime,
    cancelledTime,
    cancellationReason,
  ];
}