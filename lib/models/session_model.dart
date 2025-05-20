import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Class representing a gym session that can be booked by users
class SessionModel {
  final String id;
  final String title;
  final String description;
  final String sessionType;
  final DateTime date;
  final int startTimeMinutes; // Minutes from midnight (e.g., 8:30 AM = 510)
  final int durationMinutes;
  final String? instructorId;
  final String? instructorName; 
  final int capacity;
  final int bookedCount;
  final int creditsRequired;
  final String? roomId;
  final String? roomName;
  final String? imageUrl;
  final bool isCancelled;
  final Map<String, dynamic>? requirements;
  final List<String>? bookedUserIds;

  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sessionType,
    required this.date,
    required this.startTimeMinutes,
    required this.durationMinutes,
    this.instructorId,
    this.instructorName,
    required this.capacity,
    required this.bookedCount,
    required this.creditsRequired,
    this.roomId,
    this.roomName,
    this.imageUrl,
    this.isCancelled = false,
    this.requirements,
    this.bookedUserIds,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      sessionType: json['sessionType'] ?? '',
      date: json['date'] != null
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      startTimeMinutes: json['startTimeMinutes'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 60,
      instructorId: json['instructorId'],
      instructorName: json['instructorName'],
      capacity: json['capacity'] ?? 0,
      bookedCount: json['bookedCount'] ?? 0,
      creditsRequired: json['creditsRequired'] ?? 1,
      roomId: json['roomId'],
      roomName: json['roomName'],
      imageUrl: json['imageUrl'],
      isCancelled: json['isCancelled'] ?? false,
      requirements: json['requirements'],
      bookedUserIds: json['bookedUserIds'] != null
          ? List<String>.from(json['bookedUserIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sessionType': sessionType,
      'date': Timestamp.fromDate(date),
      'startTimeMinutes': startTimeMinutes,
      'durationMinutes': durationMinutes,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'capacity': capacity,
      'bookedCount': bookedCount,
      'creditsRequired': creditsRequired,
      'roomId': roomId,
      'roomName': roomName,
      'imageUrl': imageUrl,
      'isCancelled': isCancelled,
      'requirements': requirements,
      'bookedUserIds': bookedUserIds,
    };
  }

  /// Get the end time in minutes from midnight
  int get endTimeMinutes => startTimeMinutes + durationMinutes;

  /// Get the start time as a DateTime
  DateTime get startTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      startTimeMinutes ~/ 60,
      startTimeMinutes % 60,
    );
  }

  /// Get the end time as a DateTime
  DateTime get endTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      endTimeMinutes ~/ 60,
      endTimeMinutes % 60,
    );
  }

  /// Check if the session has available slots
  bool get hasAvailableSlots => !isCancelled && bookedCount < capacity;

  /// Get number of available slots
  int get availableSlots => isCancelled ? 0 : capacity - bookedCount;

  /// Format the date as a string (e.g., "Mon, Jan 1, 2023")
  String get formattedDate => DateFormat('E, MMM d, y').format(date);

  /// Format the time range as a string (e.g., "8:30 AM - 9:30 AM")
  String get formattedTimeRange {
    final startFormatted = DateFormat('h:mm a').format(startTime);
    final endFormatted = DateFormat('h:mm a').format(endTime);
    return '$startFormatted - $endFormatted';
  }

  /// Check if a session is in the future
  bool get isUpcoming => !isCancelled && date.isAfter(DateTime.now());

  /// Method to determine if a user has booked this session
  bool isBookedByUser(String userId) {
    return bookedUserIds?.contains(userId) ?? false;
  }

  /// Get sample sessions for testing and UI development
  static List<SessionModel> getSampleSessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      // Today's sessions
      SessionModel(
        id: 'session1',
        title: 'Morning Yoga Flow',
        description: 'Start your day with energy and focus with this gentle but effective yoga session.',
        sessionType: 'Yoga',
        date: today,
        startTimeMinutes: 8 * 60, // 8:00 AM
        durationMinutes: 60,
        instructorId: 'instructor1',
        instructorName: 'Sarah Johnson',
        capacity: 15,
        bookedCount: 8,
        creditsRequired: 1,
        roomId: 'room1',
        roomName: 'Studio 1',
        imageUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
      ),
      SessionModel(
        id: 'session2',
        title: 'High-Intensity Interval Training',
        description: 'A fast-paced workout that alternates between intense bursts of activity and fixed periods of less-intense activity or rest.',
        sessionType: 'HIIT',
        date: today,
        startTimeMinutes: 12 * 60, // 12:00 PM
        durationMinutes: 45,
        instructorId: 'instructor2',
        instructorName: 'Mike Davis',
        capacity: 10,
        bookedCount: 10, // Full session
        creditsRequired: 2,
        roomId: 'room2',
        roomName: 'Training Room',
        imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798',
      ),
      
      // Tomorrow's sessions
      SessionModel(
        id: 'session3',
        title: 'Strength Training Basics',
        description: 'Learn the fundamentals of strength training with proper form and technique.',
        sessionType: 'Strength',
        date: today.add(const Duration(days: 1)),
        startTimeMinutes: 9 * 60, // 9:00 AM
        durationMinutes: 75,
        instructorId: 'instructor3',
        instructorName: 'James Wilson',
        capacity: 8,
        bookedCount: 3,
        creditsRequired: 2,
        roomId: 'room3',
        roomName: 'Weights Room',
        imageUrl: 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5',
      ),
      SessionModel(
        id: 'session4',
        title: 'Pilates Core Focus',
        description: 'Strengthen your core and improve posture with this targeted Pilates session.',
        sessionType: 'Pilates',
        date: today.add(const Duration(days: 1)),
        startTimeMinutes: 17 * 60 + 30, // 5:30 PM
        durationMinutes: 60,
        instructorId: 'instructor4',
        instructorName: 'Emily Chen',
        capacity: 12,
        bookedCount: 5,
        creditsRequired: 1,
        roomId: 'room1',
        roomName: 'Studio 1',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
      ),
      
      // Next week sessions
      SessionModel(
        id: 'session5',
        title: 'Advanced Spinning',
        description: 'An intense indoor cycling session designed to build endurance and burn calories.',
        sessionType: 'Cardio',
        date: today.add(const Duration(days: 7)),
        startTimeMinutes: 18 * 60, // 6:00 PM
        durationMinutes: 45,
        instructorId: 'instructor5',
        instructorName: 'David Lee',
        capacity: 20,
        bookedCount: 12,
        creditsRequired: 2,
        roomId: 'room4',
        roomName: 'Cycling Studio',
        imageUrl: 'https://images.unsplash.com/photo-1517963628607-235ccdd5476c',
      ),
      SessionModel(
        id: 'session6',
        title: 'Beginner Yoga',
        description: 'A gentle introduction to yoga, focusing on basic poses and breathing techniques.',
        sessionType: 'Yoga',
        date: today.add(const Duration(days: 8)),
        startTimeMinutes: 10 * 60, // 10:00 AM
        durationMinutes: 60,
        instructorId: 'instructor1',
        instructorName: 'Sarah Johnson',
        capacity: 15,
        bookedCount: 7,
        creditsRequired: 1,
        roomId: 'room1',
        roomName: 'Studio 1',
        imageUrl: 'https://images.unsplash.com/photo-1588286840104-8957b019727f',
      ),
    ];
  }
}

/// Class representing a booking made by a user for a session
class BookingModel {
  final String id;
  final String userId;
  final String sessionId;
  final DateTime bookingDate;
  final int creditsUsed;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final bool hasAttended;
  final Map<String, dynamic>? metadata;

  BookingModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.bookingDate,
    required this.creditsUsed,
    required this.status,
    this.cancellationReason,
    this.cancelledAt,
    this.hasAttended = false,
    this.metadata,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      bookingDate: json['bookingDate'] != null
          ? (json['bookingDate'] as Timestamp).toDate()
          : DateTime.now(),
      creditsUsed: json['creditsUsed'] ?? 0,
      status: json['status'] ?? 'pending',
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null
          ? (json['cancelledAt'] as Timestamp).toDate()
          : null,
      hasAttended: json['hasAttended'] ?? false,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'creditsUsed': creditsUsed,
      'status': status,
      'cancellationReason': cancellationReason,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'hasAttended': hasAttended,
      'metadata': metadata,
    };
  }

  bool get isCancelled => status == 'cancelled';
  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  BookingModel copyWith({
    String? id,
    String? userId,
    String? sessionId,
    DateTime? bookingDate,
    int? creditsUsed,
    String? status,
    String? cancellationReason,
    DateTime? cancelledAt,
    bool? hasAttended,
    Map<String, dynamic>? metadata,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      bookingDate: bookingDate ?? this.bookingDate,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      status: status ?? this.status,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      hasAttended: hasAttended ?? this.hasAttended,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Class representing a specific gym room or studio
class RoomModel {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final String? imageUrl;
  final Map<String, dynamic>? equipment;
  final bool isActive;

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    this.imageUrl,
    this.equipment,
    this.isActive = true,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 0,
      imageUrl: json['imageUrl'],
      equipment: json['equipment'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'equipment': equipment,
      'isActive': isActive,
    };
  }
}