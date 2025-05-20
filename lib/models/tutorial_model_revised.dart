import 'package:cloud_firestore/cloud_firestore.dart';

enum TutorialDifficulty {
  beginner,
  intermediate,
  advanced,
}

enum TutorialCategory {
  exercise,
  nutrition,
}

class TutorialModel {
  final String id;
  final String title;
  final String description;
  final TutorialCategory category;
  final String? thumbnailUrl;
  final String author;
  final String authorId;
  final int duration; // Total duration in minutes
  final TutorialDifficulty difficulty;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TutorialDay> days;
  final List<String>? goals;
  final List<String>? equipmentRequired;
  final String? targetAudience;
  
  TutorialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.thumbnailUrl,
    required this.author,
    required this.authorId,
    required this.duration,
    required this.difficulty,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.days,
    this.goals,
    this.equipmentRequired,
    this.targetAudience,
  });
  
  factory TutorialModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TutorialModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: _getCategoryFromString(data['category'] ?? ''),
      thumbnailUrl: data['thumbnailUrl'],
      author: data['author'] ?? '',
      authorId: data['authorId'] ?? '',
      duration: data['duration'] ?? 0,
      difficulty: _getDifficultyFromString(data['difficulty'] ?? ''),
      isPublished: data['isPublished'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      days: (data['days'] as List<dynamic>?)
              ?.map((dayData) => TutorialDay.fromMap(dayData as Map<String, dynamic>))
              .toList() ??
          [],
      goals: (data['goals'] as List<dynamic>?)?.map((goal) => goal.toString()).toList(),
      equipmentRequired: (data['equipmentRequired'] as List<dynamic>?)?.map((eq) => eq.toString()).toList(),
      targetAudience: data['targetAudience'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': _getStringFromCategory(category),
      'thumbnailUrl': thumbnailUrl,
      'author': author,
      'authorId': authorId,
      'duration': duration,
      'difficulty': _getStringFromDifficulty(difficulty),
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'days': days.map((day) => day.toMap()).toList(),
      'goals': goals,
      'equipmentRequired': equipmentRequired,
      'targetAudience': targetAudience,
    };
  }
  
  static TutorialCategory _getCategoryFromString(String value) {
    switch (value.toLowerCase()) {
      case 'exercise':
        return TutorialCategory.exercise;
      case 'nutrition':
        return TutorialCategory.nutrition;
      default:
        return TutorialCategory.exercise;
    }
  }
  
  static String _getStringFromCategory(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.exercise:
        return 'exercise';
      case TutorialCategory.nutrition:
        return 'nutrition';
    }
  }
  
  static TutorialDifficulty _getDifficultyFromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return TutorialDifficulty.beginner;
      case 'intermediate':
        return TutorialDifficulty.intermediate;
      case 'advanced':
        return TutorialDifficulty.advanced;
      default:
        return TutorialDifficulty.beginner;
    }
  }
  
  static String _getStringFromDifficulty(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return 'beginner';
      case TutorialDifficulty.intermediate:
        return 'intermediate';
      case TutorialDifficulty.advanced:
        return 'advanced';
    }
  }
}

class TutorialDay {
  final String id;
  final int dayNumber;
  final String title;
  final String description;
  final int duration;
  final List<TutorialExercise> exercises;
  final bool restDay;
  
  TutorialDay({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.duration,
    required this.exercises,
    this.restDay = false,
  });
  
  factory TutorialDay.fromMap(Map<String, dynamic> map) {
    return TutorialDay(
      id: map['id'] ?? '',
      dayNumber: map['dayNumber'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((exercise) => TutorialExercise.fromMap(exercise as Map<String, dynamic>))
              .toList() ??
          [],
      restDay: map['restDay'] ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'duration': duration,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'restDay': restDay,
    };
  }
}

class TutorialExercise {
  final String id;
  final String name;
  final String description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int duration;
  final TutorialDifficulty difficulty;
  final List<String>? equipment;
  final List<String>? muscleGroups;
  final List<String> instructions;
  final int sets;
  final String? reps;
  final int? restBetweenSets;
  
  TutorialExercise({
    required this.id,
    required this.name,
    required this.description,
    this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.difficulty,
    this.equipment,
    this.muscleGroups,
    required this.instructions,
    required this.sets,
    this.reps,
    this.restBetweenSets,
  });
  
  factory TutorialExercise.fromMap(Map<String, dynamic> map) {
    return TutorialExercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'] ?? 0,
      difficulty: TutorialModel._getDifficultyFromString(map['difficulty'] ?? ''),
      equipment: (map['equipment'] as List<dynamic>?)?.map((eq) => eq.toString()).toList(),
      muscleGroups: (map['muscleGroups'] as List<dynamic>?)?.map((m) => m.toString()).toList(),
      instructions: (map['instructions'] as List<dynamic>?)
              ?.map((instruction) => instruction.toString())
              .toList() ??
          [],
      sets: map['sets'] ?? 0,
      reps: map['reps']?.toString(),
      restBetweenSets: map['restBetweenSets'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'difficulty': TutorialModel._getStringFromDifficulty(difficulty),
      'equipment': equipment,
      'muscleGroups': muscleGroups,
      'instructions': instructions,
      'sets': sets,
      'reps': reps,
      'restBetweenSets': restBetweenSets,
    };
  }
}

class TutorialProgressModel {
  final String userId;
  final String tutorialId;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final int? userRating; // 1-5 stars
  final List<String> completedExercises;
  final List<int> completedDays;
  final DateTime lastAccessedAt;
  
  TutorialProgressModel({
    required this.userId,
    required this.tutorialId,
    required this.progress,
    required this.isCompleted,
    this.userRating,
    required this.completedExercises,
    required this.completedDays,
    required this.lastAccessedAt,
  });
  
  factory TutorialProgressModel.fromJson(Map<String, dynamic> json) {
    return TutorialProgressModel(
      userId: json['userId'],
      tutorialId: json['tutorialId'],
      progress: json['progress'].toDouble(),
      isCompleted: json['isCompleted'],
      userRating: json['userRating'],
      completedExercises: (json['completedExercises'] as List<dynamic>?)
              ?.map((ex) => ex.toString())
              .toList() ??
          [],
      completedDays: (json['completedDays'] as List<dynamic>?)
              ?.map((day) => day as int)
              .toList() ??
          [],
      lastAccessedAt: (json['lastAccessedAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tutorialId': tutorialId,
      'progress': progress,
      'isCompleted': isCompleted,
      'userRating': userRating,
      'completedExercises': completedExercises,
      'completedDays': completedDays,
      'lastAccessedAt': lastAccessedAt,
    };
  }
  
  TutorialProgressModel copyWith({
    String? userId,
    String? tutorialId,
    double? progress,
    bool? isCompleted,
    int? userRating,
    List<String>? completedExercises,
    List<int>? completedDays,
    DateTime? lastAccessedAt,
  }) {
    return TutorialProgressModel(
      userId: userId ?? this.userId,
      tutorialId: tutorialId ?? this.tutorialId,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      userRating: userRating ?? this.userRating,
      completedExercises: completedExercises ?? this.completedExercises,
      completedDays: completedDays ?? this.completedDays,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}