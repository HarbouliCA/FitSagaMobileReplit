import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionType {
  personal,
  group,
  workshop,
  event,
}

class SessionModel {
  final String id;
  final String title;
  final String description;
  final SessionType type;
  final String instructorId;
  final String instructorName;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final int maxParticipants;
  final List<String> participantIds;
  final String? requirements;
  final String? level;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SessionModel({
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
    this.updatedAt,
  });

  // Create a copy of this session with optional field updates
  SessionModel copyWith({
    String? id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  bool get isFull => participantIds.length >= maxParticipants;
  int get availableSpots => maxParticipants - participantIds.length;
  bool get isPast => endTime.isBefore(DateTime.now());
  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  // Check if a user is registered for this session
  bool isUserRegistered(String userId) {
    return participantIds.contains(userId);
  }

  // Factory method to create a SessionModel from Firestore document
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return SessionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: _sessionTypeFromString(data['type'] ?? 'group'),
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 10,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      requirements: data['requirements'],
      level: data['level'],
      isActive: data['isActive'] ?? true,
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
      'type': _sessionTypeToString(type),
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
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Helper methods for type conversion
  static SessionType _sessionTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'personal':
        return SessionType.personal;
      case 'workshop':
        return SessionType.workshop;
      case 'event':
        return SessionType.event;
      case 'group':
      default:
        return SessionType.group;
    }
  }

  static String _sessionTypeToString(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return 'personal';
      case SessionType.workshop:
        return 'workshop';
      case SessionType.event:
        return 'event';
      case SessionType.group:
        return 'group';
    }
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, title: $title, instructor: $instructorName, '
        'startTime: $startTime, endTime: $endTime, '
        'participants: ${participantIds.length}/$maxParticipants)';
  }
}