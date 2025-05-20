import 'package:cloud_firestore/cloud_firestore.dart';

/// Class representing a complete tutorial program
class Tutorial {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> categories;
  final String difficulty;
  final bool isFeatured;
  final bool isPopular;
  final int totalDurationMinutes;
  final int daysCount;
  final double? userProgress; // null if not started, 0.0-1.0 if in progress

  Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.categories,
    required this.difficulty,
    required this.isFeatured,
    required this.isPopular,
    required this.totalDurationMinutes,
    required this.daysCount,
    this.userProgress,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      difficulty: json['difficulty'] ?? 'Beginner',
      isFeatured: json['isFeatured'] ?? false,
      isPopular: json['isPopular'] ?? false,
      totalDurationMinutes: json['totalDurationMinutes'] ?? 0,
      daysCount: json['daysCount'] ?? 1,
      userProgress: json['userProgress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories,
      'difficulty': difficulty,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'totalDurationMinutes': totalDurationMinutes,
      'daysCount': daysCount,
      'userProgress': userProgress,
    };
  }
}

/// Class representing a day within a tutorial program
class TutorialDay {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int dayNumber;
  final String difficulty;
  final int estimatedMinutes;
  final String imageUrl;
  final bool isCompleted;
  final bool isActive;
  final List<Exercise> exercises;
  final List<String> tags;

  TutorialDay({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.dayNumber,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.imageUrl,
    this.isCompleted = false,
    this.isActive = false,
    required this.exercises,
    required this.tags,
  });

  factory TutorialDay.fromJson(Map<String, dynamic> json) {
    return TutorialDay(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      dayNumber: json['dayNumber'] ?? 1,
      difficulty: json['difficulty'] ?? 'Beginner',
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      isActive: json['isActive'] ?? false,
      exercises: (json['exercises'] as List?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'dayNumber': dayNumber,
      'difficulty': difficulty,
      'estimatedMinutes': estimatedMinutes,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'isActive': isActive,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'tags': tags,
    };
  }
}

/// Class representing an exercise within a tutorial day
class Exercise {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final int sets;
  final int? reps; // Either reps or duration is used, not both
  final int? duration; // Duration in seconds
  final int restSeconds;
  final List<String> targetMuscles;
  final Map<String, dynamic>? modifiers; // For exercise variations

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.sets,
    this.reps,
    this.duration,
    required this.restSeconds,
    required this.targetMuscles,
    this.modifiers,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      sets: json['sets'] ?? 1,
      reps: json['reps'],
      duration: json['duration'],
      restSeconds: json['restSeconds'] ?? 30,
      targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
      modifiers: json['modifiers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'restSeconds': restSeconds,
      'targetMuscles': targetMuscles,
      'modifiers': modifiers,
    };
  }

  bool get isTimeBased => duration != null;
}

/// Class representing a user's progress for a specific tutorial
class TutorialProgress {
  final String userId;
  final String tutorialId;
  final Map<String, bool> completedDays;
  final int lastCompletedDay;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastUpdatedAt;

  TutorialProgress({
    required this.userId,
    required this.tutorialId,
    required this.completedDays,
    required this.lastCompletedDay,
    required this.startedAt,
    this.completedAt,
    required this.lastUpdatedAt,
  });

  factory TutorialProgress.fromJson(Map<String, dynamic> json) {
    return TutorialProgress(
      userId: json['userId'] ?? '',
      tutorialId: json['tutorialId'] ?? '',
      completedDays: Map<String, bool>.from(json['completedDays'] ?? {}),
      lastCompletedDay: json['lastCompletedDay'] ?? 0,
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      lastUpdatedAt: (json['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tutorialId': tutorialId,
      'completedDays': completedDays,
      'lastCompletedDay': lastCompletedDay,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  double getProgressPercentage(int totalDays) {
    if (totalDays <= 0) return 0.0;
    return lastCompletedDay / totalDays;
  }

  bool isCompleted(int totalDays) {
    return lastCompletedDay >= totalDays;
  }
}