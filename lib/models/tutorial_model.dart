import 'package:cloud_firestore/cloud_firestore.dart';

/// A class representing a tutorial day in the fitness app.
class TutorialDay {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int dayNumber;
  final String difficulty;
  final int estimatedMinutes;
  final String imageUrl;
  final List<TutorialExercise> exercises;
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
    required this.exercises,
    required this.tags,
  });

  // Create from Firestore document
  factory TutorialDay.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse exercises list
    List<TutorialExercise> exercises = [];
    if (data['exercises'] != null) {
      exercises = (data['exercises'] as List)
          .map((e) => TutorialExercise.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    
    // Parse tags list
    List<String> tags = [];
    if (data['tags'] != null) {
      tags = List<String>.from(data['tags']);
    }

    return TutorialDay(
      id: doc.id,
      title: data['title'] ?? 'Unnamed Tutorial',
      subtitle: data['subtitle'] ?? '',
      description: data['description'] ?? '',
      dayNumber: data['dayNumber'] ?? 0,
      difficulty: data['difficulty'] ?? 'beginner',
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      imageUrl: data['imageUrl'] ?? '',
      exercises: exercises,
      tags: tags,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'dayNumber': dayNumber,
      'difficulty': difficulty,
      'estimatedMinutes': estimatedMinutes,
      'imageUrl': imageUrl,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'tags': tags,
    };
  }

  // Create a copy with updated fields
  TutorialDay copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    int? dayNumber,
    String? difficulty,
    int? estimatedMinutes,
    String? imageUrl,
    List<TutorialExercise>? exercises,
    List<String>? tags,
  }) {
    return TutorialDay(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      dayNumber: dayNumber ?? this.dayNumber,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      exercises: exercises ?? this.exercises,
      tags: tags ?? this.tags,
    );
  }
}

/// A class representing an exercise within a tutorial.
class TutorialExercise {
  final String id;
  final String title;
  final String description;
  final int orderIndex;
  final String videoUrl;
  final int durationSeconds;
  final int sets;
  final int? reps;
  final String? weight;
  final String difficulty;
  final String? thumbnailUrl;
  final List<String> muscleGroups;
  final bool isRequired;

  TutorialExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.videoUrl,
    required this.durationSeconds,
    required this.sets,
    this.reps,
    this.weight,
    required this.difficulty,
    this.thumbnailUrl,
    required this.muscleGroups,
    this.isRequired = true,
  });

  // Create from Map
  factory TutorialExercise.fromMap(Map<String, dynamic> map) {
    List<String> muscleGroups = [];
    if (map['muscleGroups'] != null) {
      muscleGroups = List<String>.from(map['muscleGroups']);
    }

    return TutorialExercise(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unnamed Exercise',
      description: map['description'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
      videoUrl: map['videoUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 60,
      sets: map['sets'] ?? 3,
      reps: map['reps'],
      weight: map['weight'],
      difficulty: map['difficulty'] ?? 'beginner',
      thumbnailUrl: map['thumbnailUrl'],
      muscleGroups: muscleGroups,
      isRequired: map['isRequired'] ?? true,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'videoUrl': videoUrl,
      'durationSeconds': durationSeconds,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'difficulty': difficulty,
      'thumbnailUrl': thumbnailUrl,
      'muscleGroups': muscleGroups,
      'isRequired': isRequired,
    };
  }

  // Create a copy with updated fields
  TutorialExercise copyWith({
    String? id,
    String? title,
    String? description,
    int? orderIndex,
    String? videoUrl,
    int? durationSeconds,
    int? sets,
    int? reps,
    String? weight,
    String? difficulty,
    String? thumbnailUrl,
    List<String>? muscleGroups,
    bool? isRequired,
  }) {
    return TutorialExercise(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      videoUrl: videoUrl ?? this.videoUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      difficulty: difficulty ?? this.difficulty,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}

/// A class representing user progress for a tutorial day.
class TutorialProgress {
  final String id;
  final String userId;
  final String tutorialDayId;
  final double progressPercentage;
  final List<String> completedExerciseIds;
  final DateTime lastUpdated;
  final bool isCompleted;

  TutorialProgress({
    required this.id,
    required this.userId,
    required this.tutorialDayId,
    required this.progressPercentage,
    required this.completedExerciseIds,
    required this.lastUpdated,
    required this.isCompleted,
  });

  // Create from Firestore document
  factory TutorialProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<String> completedExerciseIds = [];
    if (data['completedExerciseIds'] != null) {
      completedExerciseIds = List<String>.from(data['completedExerciseIds']);
    }

    return TutorialProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      tutorialDayId: data['tutorialDayId'] ?? '',
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      completedExerciseIds: completedExerciseIds,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tutorialDayId': tutorialDayId,
      'progressPercentage': progressPercentage,
      'completedExerciseIds': completedExerciseIds,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isCompleted': isCompleted,
    };
  }

  // Create a copy with updated fields
  TutorialProgress copyWith({
    String? id,
    String? userId,
    String? tutorialDayId,
    double? progressPercentage,
    List<String>? completedExerciseIds,
    DateTime? lastUpdated,
    bool? isCompleted,
  }) {
    return TutorialProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tutorialDayId: tutorialDayId ?? this.tutorialDayId,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Update progress based on completed exercises
  static TutorialProgress updateProgress({
    required TutorialProgress currentProgress,
    required List<TutorialExercise> allExercises,
    required List<String> completedExerciseIds,
  }) {
    // Calculate the number of required exercises
    final requiredExercises = allExercises.where((e) => e.isRequired).toList();
    final int totalRequired = requiredExercises.length;
    
    // If there are no required exercises, we can't calculate progress
    if (totalRequired == 0) {
      return currentProgress.copyWith(
        progressPercentage: completedExerciseIds.isNotEmpty ? 1.0 : 0.0,
        completedExerciseIds: completedExerciseIds,
        lastUpdated: DateTime.now(),
        isCompleted: completedExerciseIds.length == allExercises.length,
      );
    }
    
    // Count completed required exercises
    int completedRequired = 0;
    for (final exerciseId in completedExerciseIds) {
      final isRequired = requiredExercises.any((e) => e.id == exerciseId);
      if (isRequired) {
        completedRequired++;
      }
    }
    
    // Calculate progress percentage
    final double progressPercentage = completedRequired / totalRequired;
    
    // Determine if all required exercises are completed
    final bool isCompleted = completedRequired == totalRequired;
    
    return currentProgress.copyWith(
      progressPercentage: progressPercentage,
      completedExerciseIds: completedExerciseIds,
      lastUpdated: DateTime.now(),
      isCompleted: isCompleted,
    );
  }
}