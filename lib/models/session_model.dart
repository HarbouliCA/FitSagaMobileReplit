import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Represents a fitness session that users can book
class SessionModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String instructorId;
  final String? instructorName;
  final int capacity;
  final int bookedCount;
  final int creditsRequired;
  final String sessionType;
  final String? imageUrl;
  final bool isRecurring;
  final String? recurringPattern;
  final List<String>? tags;

  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.instructorId,
    this.instructorName,
    required this.capacity,
    required this.bookedCount,
    required this.creditsRequired,
    required this.sessionType,
    this.imageUrl,
    this.isRecurring = false,
    this.recurringPattern,
    this.tags,
  });

  // Create a session from Firebase document snapshot
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse dates from Firestore Timestamps
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final startTime = (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endTime = (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 1));
    
    // Parse tags if they exist
    List<String>? tags;
    if (data['tags'] != null) {
      tags = List<String>.from(data['tags']);
    }

    return SessionModel(
      id: doc.id,
      title: data['title'] ?? 'Unnamed Session',
      description: data['description'] ?? '',
      date: date,
      startTime: startTime,
      endTime: endTime,
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'],
      capacity: data['capacity'] ?? 10,
      bookedCount: data['bookedCount'] ?? 0,
      creditsRequired: data['creditsRequired'] ?? 1,
      sessionType: data['sessionType'] ?? 'general',
      imageUrl: data['imageUrl'],
      isRecurring: data['isRecurring'] ?? false,
      recurringPattern: data['recurringPattern'],
      tags: tags,
    );
  }

  // Convert session to a map for Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'instructorId': instructorId,
      'instructorName': instructorName,
      'capacity': capacity,
      'bookedCount': bookedCount,
      'creditsRequired': creditsRequired,
      'sessionType': sessionType,
      'imageUrl': imageUrl,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'tags': tags,
    };
  }

  // Create copy of session with updated fields
  SessionModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? instructorId,
    String? instructorName,
    int? capacity,
    int? bookedCount,
    int? creditsRequired,
    String? sessionType,
    String? imageUrl,
    bool? isRecurring,
    String? recurringPattern,
    List<String>? tags,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      capacity: capacity ?? this.capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      creditsRequired: creditsRequired ?? this.creditsRequired,
      sessionType: sessionType ?? this.sessionType,
      imageUrl: imageUrl ?? this.imageUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      tags: tags ?? this.tags,
    );
  }

  // Check if session has available slots
  bool get hasAvailableSlots => bookedCount < capacity;

  // Get the number of available slots
  int get availableSlots => capacity - bookedCount;

  // Get formatted date string
  String get formattedDate => DateFormat('EEEE, MMMM d, yyyy').format(date);

  // Get formatted time range string
  String get formattedTimeRange {
    final startFormat = DateFormat('h:mm a');
    final endFormat = DateFormat('h:mm a');
    return '${startFormat.format(startTime)} - ${endFormat.format(endTime)}';
  }

  // Get duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // Check if session is in the past
  bool get isPast => date.isBefore(DateTime.now());

  // Check if session is upcoming (today or in the future)
  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);
    return sessionDay.isAtSameMomentAs(today) || sessionDay.isAfter(today);
  }

  // Generate sample sessions for demo/testing
  static List<SessionModel> getSampleSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      SessionModel(
        id: 'session1',
        title: 'Morning Yoga',
        description: 'Start your day with a refreshing yoga session to improve flexibility and mental clarity.',
        date: today,
        startTime: DateTime(today.year, today.month, today.day, 7, 0),
        endTime: DateTime(today.year, today.month, today.day, 8, 0),
        instructorId: 'instructor1',
        instructorName: 'Sarah Johnson',
        capacity: 15,
        bookedCount: 10,
        creditsRequired: 1,
        sessionType: 'yoga',
        imageUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
        tags: ['beginner', 'yoga', 'morning'],
      ),
      SessionModel(
        id: 'session2',
        title: 'HIIT Training',
        description: 'High-intensity interval training to maximize calorie burn and improve cardiovascular health.',
        date: today.add(const Duration(days: 1)),
        startTime: DateTime(today.year, today.month, today.day + 1, 18, 0),
        endTime: DateTime(today.year, today.month, today.day + 1, 19, 0),
        instructorId: 'instructor2',
        instructorName: 'Mike Torres',
        capacity: 12,
        bookedCount: 8,
        creditsRequired: 2,
        sessionType: 'hiit',
        imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798',
        tags: ['intermediate', 'hiit', 'evening'],
      ),
      SessionModel(
        id: 'session3',
        title: 'Strength Training',
        description: 'Build muscle and improve overall strength with this focused training session.',
        date: today.add(const Duration(days: 2)),
        startTime: DateTime(today.year, today.month, today.day + 2, 10, 0),
        endTime: DateTime(today.year, today.month, today.day + 2, 11, 0),
        instructorId: 'instructor2',
        instructorName: 'Mike Torres',
        capacity: 10,
        bookedCount: 10, // Full
        creditsRequired: 1,
        sessionType: 'strength',
        imageUrl: 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5',
        tags: ['intermediate', 'strength', 'morning'],
      ),
      SessionModel(
        id: 'session4',
        title: 'Pilates',
        description: 'Focus on core strength and posture improvement with controlled movements.',
        date: today.add(const Duration(days: 2)),
        startTime: DateTime(today.year, today.month, today.day + 2, 17, 0),
        endTime: DateTime(today.year, today.month, today.day + 2, 18, 0),
        instructorId: 'instructor1',
        instructorName: 'Sarah Johnson',
        capacity: 12,
        bookedCount: 6,
        creditsRequired: 1,
        sessionType: 'pilates',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
        tags: ['beginner', 'pilates', 'evening'],
      ),
      SessionModel(
        id: 'session5',
        title: 'Spin Class',
        description: 'High-energy cycling workout to build endurance and burn calories.',
        date: today.add(const Duration(days: 3)),
        startTime: DateTime(today.year, today.month, today.day + 3, 12, 30),
        endTime: DateTime(today.year, today.month, today.day + 3, 13, 30),
        instructorId: 'instructor3',
        instructorName: 'Emma Williams',
        capacity: 20,
        bookedCount: 15,
        creditsRequired: 2,
        sessionType: 'cardio',
        imageUrl: 'https://images.unsplash.com/photo-1534787238916-9ba6764efd4f',
        tags: ['intermediate', 'cardio', 'afternoon'],
      ),
    ];
  }
}