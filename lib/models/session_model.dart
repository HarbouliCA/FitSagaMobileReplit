import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum SessionStatus {
  upcoming,
  ongoing,
  completed,
  cancelled
}

class SessionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final DateTime startTime;
  final int durationMinutes;
  final int maxParticipants;
  final List<String> participantIds;
  final int creditCost;
  final bool isRecurring;
  final String? recurringRule; // RRULE format (e.g., "FREQ=WEEKLY;BYDAY=MO,WE,FR")
  final String? parentRecurringSessionId;
  final String? location;
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.startTime,
    required this.durationMinutes,
    required this.maxParticipants,
    required this.participantIds,
    required this.creditCost,
    this.isRecurring = false,
    this.recurringRule,
    this.parentRecurringSessionId,
    this.location,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  // Get end time
  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));
  
  // Check if session is full
  bool get isFull => participantIds.length >= maxParticipants;
  
  // Get remaining spots
  int get remainingSpots => maxParticipants - participantIds.length;
  
  // Check if session has conflict with another session
  bool hasConflict(SessionModel other) {
    if (id == other.id) return false; // Same session
    
    // Check if instructor is the same
    if (instructorId == other.instructorId) {
      // Check time overlap
      if (startTime.isBefore(other.endTime) && 
          endTime.isAfter(other.startTime)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Check if user is enrolled
  bool isUserEnrolled(String userId) {
    return participantIds.contains(userId);
  }
  
  // Check if user can book (has spots and is not already booked)
  bool canUserBook(String userId) {
    return !isFull && !isUserEnrolled(userId) && status == SessionStatus.upcoming;
  }
  
  // Check if user can cancel
  bool canUserCancel(String userId) {
    return isUserEnrolled(userId) && status == SessionStatus.upcoming;
  }

  // Create a copy with modified fields
  SessionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? instructorId,
    String? instructorName,
    DateTime? startTime,
    int? durationMinutes,
    int? maxParticipants,
    List<String>? participantIds,
    int? creditCost,
    bool? isRecurring,
    String? recurringRule,
    String? parentRecurringSessionId,
    String? location,
    SessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      creditCost: creditCost ?? this.creditCost,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringRule: recurringRule ?? this.recurringRule,
      parentRecurringSessionId: parentRecurringSessionId ?? this.parentRecurringSessionId,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory method to create a SessionModel from Firestore document
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SessionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 60,
      maxParticipants: data['maxParticipants'] ?? 10,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      creditCost: data['creditCost'] ?? 1,
      isRecurring: data['isRecurring'] ?? false,
      recurringRule: data['recurringRule'],
      parentRecurringSessionId: data['parentRecurringSessionId'],
      location: data['location'],
      status: _statusFromString(data['status'] ?? 'upcoming'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'creditCost': creditCost,
      'isRecurring': isRecurring,
      'recurringRule': recurringRule,
      'parentRecurringSessionId': parentRecurringSessionId,
      'location': location,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Helper methods for status conversion
  static SessionStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return SessionStatus.ongoing;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'upcoming':
      default:
        return SessionStatus.upcoming;
    }
  }

  static String _statusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.ongoing:
        return 'ongoing';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
      case SessionStatus.upcoming:
        return 'upcoming';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructorId,
    instructorName,
    startTime,
    durationMinutes,
    maxParticipants,
    participantIds,
    creditCost,
    isRecurring,
    recurringRule,
    parentRecurringSessionId,
    location,
    status,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'SessionModel(id: $id, title: $title, instructor: $instructorName, startTime: $startTime)';
  }
}