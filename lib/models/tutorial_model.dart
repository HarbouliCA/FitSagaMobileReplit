import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category; // 'exercise', 'nutrition'
  final String difficultyLevel; // 'beginner', 'intermediate', 'advanced'
  final String author;
  final Duration duration;
  final String? thumbnailUrl;
  final List<String>? goals;
  final List<String>? requirements;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TutorialDayModel> days;

  const TutorialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficultyLevel,
    required this.author,
    required this.duration,
    this.thumbnailUrl,
    this.goals,
    this.requirements,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
    required this.days,
  });

  TutorialModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? difficultyLevel,
    String? author,
    Duration? duration,
    String? thumbnailUrl,
    List<String>? goals,
    List<String>? requirements,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TutorialDayModel>? days,
  }) {
    return TutorialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      author: author ?? this.author,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      goals: goals ?? this.goals,
      requirements: requirements ?? this.requirements,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      days: days ?? this.days,
    );
  }

  factory TutorialModel.fromMap(Map<String, dynamic> map, List<TutorialDayModel> days) {
    return TutorialModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      difficultyLevel: map['difficultyLevel'] as String,
      author: map['author'] as String,
      duration: Duration(minutes: map['durationMinutes'] as int),
      thumbnailUrl: map['thumbnailUrl'] as String?,
      goals: map['goals'] != null 
          ? List<String>.from(map['goals'] as List) 
          : null,
      requirements: map['requirements'] != null 
          ? List<String>.from(map['requirements'] as List) 
          : null,
      isFeatured: map['isFeatured'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
      days: days,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficultyLevel': difficultyLevel,
      'author': author,
      'durationMinutes': duration.inMinutes,
      'thumbnailUrl': thumbnailUrl,
      'goals': goals,
      'requirements': requirements,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  int get totalExercises => days.fold(0, (sum, day) => sum + day.exercises.length);
  
  bool get isExerciseTutorial => category == 'exercise';
  bool get isNutritionTutorial => category == 'nutrition';
  
  bool get isBeginner => difficultyLevel == 'beginner';
  bool get isIntermediate => difficultyLevel == 'intermediate';
  bool get isAdvanced => difficultyLevel == 'advanced';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    difficultyLevel,
    author,
    duration,
    thumbnailUrl,
    goals,
    requirements,
    isFeatured,
    createdAt,
    updatedAt,
    days,
  ];
}

class TutorialDayModel extends Equatable {
  final String id;
  final String tutorialId;
  final int dayNumber;
  final String title;
  final String description;
  final List<ExerciseModel> exercises;

  const TutorialDayModel({
    required this.id,
    required this.tutorialId,
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.exercises,
  });

  TutorialDayModel copyWith({
    String? id,
    String? tutorialId,
    int? dayNumber,
    String? title,
    String? description,
    List<ExerciseModel>? exercises,
  }) {
    return TutorialDayModel(
      id: id ?? this.id,
      tutorialId: tutorialId ?? this.tutorialId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
    );
  }

  factory TutorialDayModel.fromMap(Map<String, dynamic> map, List<ExerciseModel> exercises) {
    return TutorialDayModel(
      id: map['id'] as String,
      tutorialId: map['tutorialId'] as String,
      dayNumber: map['dayNumber'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      exercises: exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorialId': tutorialId,
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
    id,
    tutorialId,
    dayNumber,
    title,
    description,
    exercises,
  ];
}

class ExerciseModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final Duration duration;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String>? muscleGroups;
  final List<String>? equipment;
  final List<String>? instructions;
  final int order;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    this.videoUrl,
    this.thumbnailUrl,
    this.muscleGroups,
    this.equipment,
    this.instructions,
    required this.order,
  });

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? difficulty,
    Duration? duration,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? muscleGroups,
    List<String>? equipment,
    List<String>? instructions,
    int? order,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      order: order ?? this.order,
    );
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      difficulty: map['difficulty'] as String,
      duration: Duration(seconds: map['durationSeconds'] as int),
      videoUrl: map['videoUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      muscleGroups: map['muscleGroups'] != null 
          ? List<String>.from(map['muscleGroups'] as List) 
          : null,
      equipment: map['equipment'] != null 
          ? List<String>.from(map['equipment'] as List) 
          : null,
      instructions: map['instructions'] != null 
          ? List<String>.from(map['instructions'] as List) 
          : null,
      order: map['order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'durationSeconds': duration.inSeconds,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'muscleGroups': muscleGroups,
      'equipment': equipment,
      'instructions': instructions,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    difficulty,
    duration,
    videoUrl,
    thumbnailUrl,
    muscleGroups,
    equipment,
    instructions,
    order,
  ];
}

class TutorialProgressModel extends Equatable {
  final String id;
  final String userId;
  final String tutorialId;
  final List<String> completedExercises;
  final List<int> completedDays;
  final bool isCompleted;
  final double progressPercentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastUpdatedAt;

  const TutorialProgressModel({
    required this.id,
    required this.userId,
    required this.tutorialId,
    required this.completedExercises,
    required this.completedDays,
    required this.isCompleted,
    required this.progressPercentage,
    required this.startedAt,
    this.completedAt,
    required this.lastUpdatedAt,
  });

  TutorialProgressModel copyWith({
    String? id,
    String? userId,
    String? tutorialId,
    List<String>? completedExercises,
    List<int>? completedDays,
    bool? isCompleted,
    double? progressPercentage,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastUpdatedAt,
  }) {
    return TutorialProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tutorialId: tutorialId ?? this.tutorialId,
      completedExercises: completedExercises ?? this.completedExercises,
      completedDays: completedDays ?? this.completedDays,
      isCompleted: isCompleted ?? this.isCompleted,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  factory TutorialProgressModel.fromMap(Map<String, dynamic> map) {
    return TutorialProgressModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      tutorialId: map['tutorialId'] as String,
      completedExercises: List<String>.from(map['completedExercises'] as List),
      completedDays: List<int>.from(map['completedDays'] as List),
      isCompleted: map['isCompleted'] as bool,
      progressPercentage: (map['progressPercentage'] as num).toDouble(),
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
      lastUpdatedAt: (map['lastUpdatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tutorialId': tutorialId,
      'completedExercises': completedExercises,
      'completedDays': completedDays,
      'isCompleted': isCompleted,
      'progressPercentage': progressPercentage,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
    };
  }

  factory TutorialProgressModel.initial({
    required String userId,
    required String tutorialId,
  }) {
    return TutorialProgressModel(
      id: '$userId-$tutorialId',
      userId: userId,
      tutorialId: tutorialId,
      completedExercises: [],
      completedDays: [],
      isCompleted: false,
      progressPercentage: 0.0,
      startedAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    tutorialId,
    completedExercises,
    completedDays,
    isCompleted,
    progressPercentage,
    startedAt,
    completedAt,
    lastUpdatedAt,
  ];
}