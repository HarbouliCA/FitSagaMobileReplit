import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing the different types of gym sessions
enum SessionType {
  /// Individual one-on-one training with an instructor
  personal,
  
  /// Group class with multiple participants
  group,
  
  /// Specialized workshop focused on a specific technique or skill
  workshop,
  
  /// Special event (competition, challenge, etc.)
  event,
}

/// Extension to convert string to SessionType enum
extension SessionTypeExtension on String {
  SessionType toSessionType() {
    switch (this.toLowerCase()) {
      case 'personal':
        return SessionType.personal;
      case 'group':
        return SessionType.group;
      case 'workshop':
        return SessionType.workshop;
      case 'event':
        return SessionType.event;
      default:
        return SessionType.group; // Default to group session
    }
  }
}

/// Model class representing a gym session in the FitSAGA app
class SessionModel {
  /// Unique identifier for the session
  final String id;
  
  /// Title/name of the session
  String title;
  
  /// Detailed description of what the session entails
  String description;
  
  /// Type of session (personal, group, workshop, event)
  SessionType type;
  
  /// ID of the instructor leading the session
  String instructorId;
  
  /// Name of the instructor (for easier display without separate lookup)
  String instructorName;
  
  /// When the session starts
  DateTime startTime;
  
  /// When the session ends
  DateTime endTime;
  
  /// Location within the gym/facility where the session will take place
  String location;
  
  /// Maximum number of participants allowed
  int maxParticipants;
  
  /// List of user IDs who have booked this session
  List<String> participantIds;
  
  /// Any equipment or materials participants should bring
  String? requirements;
  
  /// Difficulty level (e.g., 'Beginner', 'Intermediate', 'Advanced')
  String? level;
  
  /// Whether the session is active and available for booking
  bool isActive;
  
  /// When the session was created
  final DateTime createdAt;
  
  /// Constructor for creating a new SessionModel
  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.instructorId,
    required this.instructorName,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.maxParticipants,
    required this.participantIds,
    this.requirements,
    this.level,
    required this.isActive,
    required this.createdAt,
  });
  
  /// Creates a SessionModel from a Firebase document map
  factory SessionModel.fromMap(Map<String, dynamic> map, String docId) {
    return SessionModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: (map['type'] as String? ?? 'group').toSessionType(),
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 10,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      requirements: map['requirements'],
      level: map['level'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  /// Converts the SessionModel to a map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'requirements': requirements,
      'level': level,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  /// Checks if the session is full (no more spots available)
  bool get isFull => participantIds.length >= maxParticipants;
  
  /// Calculates the number of available spots left
  int get availableSpots => maxParticipants - participantIds.length;
  
  /// Determines if the session has already passed
  bool get isPast => DateTime.now().isAfter(endTime);
  
  /// Calculates the duration of the session in minutes
  int get durationInMinutes => endTime.difference(startTime).inMinutes;
  
  /// The activity/exercise type for this session
  String get activityType => type == SessionType.personal ? 'Personal Training' : 
                             type == SessionType.group ? 'Group Class' : 
                             type == SessionType.workshop ? 'Workshop' : 'Event';
                             
  /// The activity name (alias for title to maintain API compatibility)
  String get activityName => title;
  
  /// Number of credits required to book this session
  int get requiredCredits => type == SessionType.personal ? 5 : 
                             type == SessionType.workshop ? 3 : 2;
                             
  /// The current status of the session (upcoming, in progress, completed)
  String get status {
    final now = DateTime.now();
    if (now.isBefore(startTime)) return 'Upcoming';
    if (now.isBefore(endTime)) return 'In Progress';
    return 'Completed';
  }
  
  /// Checks if a specific user is registered for this session
  bool isUserRegistered(String userId) => participantIds.contains(userId);
  
  /// Creates a copy of this SessionModel with optional new values
  SessionModel copyWith({
    String? title,
    String? description,
    SessionType? type,
    String? instructorId,
    String? instructorName,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    int? maxParticipants,
    List<String>? participantIds,
    String? requirements,
    String? level,
    bool? isActive,
  }) {
    return SessionModel(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      requirements: requirements ?? this.requirements,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      createdAt: this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'SessionModel(id: $id, title: $title, instructor: $instructorName, startTime: $startTime)';
  }
}