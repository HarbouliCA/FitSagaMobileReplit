import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Difficulty levels for tutorials
enum TutorialDifficulty {
  beginner,
  intermediate,
  advanced,
  expert
}

/// Category types for tutorials
enum TutorialCategory {
  cardio,
  strength,
  flexibility,
  balance,
  nutrition,
  recovery,
  technique,
  program
}

/// Model for tutorials
class TutorialModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String authorId;
  final String authorName;
  final List<TutorialCategory> categories;
  final TutorialDifficulty difficulty;
  final int durationMinutes;
  final List<String> tags;
  final String? thumbnailUrl;
  final String? videoUrl;
  final double averageRating;
  final int ratingCount;
  final int viewCount;
  final bool isPublished;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const TutorialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.categories,
    required this.difficulty,
    required this.durationMinutes,
    required this.tags,
    this.thumbnailUrl,
    this.videoUrl,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.viewCount = 0,
    this.isPublished = false,
    this.isPremium = false,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  // Calculate reading time based on content length (estimate)
  int get estimatedReadingTimeMinutes {
    // Average reading speed: 200 words per minute
    const wordsPerMinute = 200;
    final wordCount = content.split(' ').length;
    return (wordCount / wordsPerMinute).ceil();
  }

  // Format categories as readable string
  String get categoryString {
    return categories.map((c) => _categoryToString(c).toCapitalized()).join(', ');
  }

  // Format difficulty as readable string
  String get difficultyString {
    return _difficultyToString(difficulty).toCapitalized();
  }

  // Factory method to create a TutorialModel from Firestore document
  factory TutorialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse categories from string list
    List<TutorialCategory> parsedCategories = [];
    if (data['categories'] != null) {
      for (final categoryStr in data['categories']) {
        final category = _parseCategory(categoryStr);
        if (category != null) {
          parsedCategories.add(category);
        }
      }
    }
    
    return TutorialModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      categories: parsedCategories,
      difficulty: _parseDifficulty(data['difficulty']),
      durationMinutes: data['durationMinutes'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      thumbnailUrl: data['thumbnailUrl'],
      videoUrl: data['videoUrl'],
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      isPublished: data['isPublished'] ?? false,
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'],
    );
  }

  // Create a copy with modified fields
  TutorialModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? authorId,
    String? authorName,
    List<TutorialCategory>? categories,
    TutorialDifficulty? difficulty,
    int? durationMinutes,
    List<String>? tags,
    String? thumbnailUrl,
    String? videoUrl,
    double? averageRating,
    int? ratingCount,
    int? viewCount,
    bool? isPublished,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TutorialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      categories: categories ?? this.categories,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      tags: tags ?? this.tags,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      viewCount: viewCount ?? this.viewCount,
      isPublished: isPublished ?? this.isPublished,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'categories': categories.map((c) => _categoryToString(c)).toList(),
      'difficulty': _difficultyToString(difficulty),
      'durationMinutes': durationMinutes,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'viewCount': viewCount,
      'isPublished': isPublished,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  // Helper methods for difficulty conversion
  static TutorialDifficulty _parseDifficulty(String? difficultyStr) {
    switch (difficultyStr?.toLowerCase()) {
      case 'beginner':
        return TutorialDifficulty.beginner;
      case 'intermediate':
        return TutorialDifficulty.intermediate;
      case 'advanced':
        return TutorialDifficulty.advanced;
      case 'expert':
        return TutorialDifficulty.expert;
      default:
        return TutorialDifficulty.beginner;
    }
  }

  static String _difficultyToString(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return 'beginner';
      case TutorialDifficulty.intermediate:
        return 'intermediate';
      case TutorialDifficulty.advanced:
        return 'advanced';
      case TutorialDifficulty.expert:
        return 'expert';
    }
  }

  // Helper methods for category conversion
  static TutorialCategory? _parseCategory(String? categoryStr) {
    switch (categoryStr?.toLowerCase()) {
      case 'cardio':
        return TutorialCategory.cardio;
      case 'strength':
        return TutorialCategory.strength;
      case 'flexibility':
        return TutorialCategory.flexibility;
      case 'balance':
        return TutorialCategory.balance;
      case 'nutrition':
        return TutorialCategory.nutrition;
      case 'recovery':
        return TutorialCategory.recovery;
      case 'technique':
        return TutorialCategory.technique;
      case 'program':
        return TutorialCategory.program;
      default:
        return null;
    }
  }

  static String _categoryToString(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.cardio:
        return 'cardio';
      case TutorialCategory.strength:
        return 'strength';
      case TutorialCategory.flexibility:
        return 'flexibility';
      case TutorialCategory.balance:
        return 'balance';
      case TutorialCategory.nutrition:
        return 'nutrition';
      case TutorialCategory.recovery:
        return 'recovery';
      case TutorialCategory.technique:
        return 'technique';
      case TutorialCategory.program:
        return 'program';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    content,
    authorId,
    authorName,
    categories,
    difficulty,
    durationMinutes,
    tags,
    thumbnailUrl,
    videoUrl,
    averageRating,
    ratingCount,
    viewCount,
    isPublished,
    isPremium,
    createdAt,
    updatedAt,
  ];
}

/// Model for tutorial progress tracking
class TutorialProgressModel extends Equatable {
  final String id;
  final String userId;
  final String tutorialId;
  final bool isCompleted;
  final double progress; // 0.0 to 1.0
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final int? userRating; // 1-5 stars
  final String? userFeedback;

  const TutorialProgressModel({
    required this.id,
    required this.userId,
    required this.tutorialId,
    this.isCompleted = false,
    this.progress = 0.0,
    this.startedAt,
    this.completedAt,
    required this.lastAccessedAt,
    this.userRating,
    this.userFeedback,
  });

  // Factory method to create from Firestore document
  factory TutorialProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TutorialProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      tutorialId: data['tutorialId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      progress: (data['progress'] ?? 0.0).toDouble(),
      startedAt: data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate() 
          : null,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp).toDate(),
      userRating: data['userRating'],
      userFeedback: data['userFeedback'],
    );
  }

  // Create a copy with modified fields
  TutorialProgressModel copyWith({
    String? id,
    String? userId,
    String? tutorialId,
    bool? isCompleted,
    double? progress,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    int? userRating,
    String? userFeedback,
  }) {
    return TutorialProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tutorialId: tutorialId ?? this.tutorialId,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      userRating: userRating ?? this.userRating,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tutorialId': tutorialId,
      'isCompleted': isCompleted,
      'progress': progress,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'userRating': userRating,
      'userFeedback': userFeedback,
    };
  }

  // Progress as percentage
  int get progressPercentage => (progress * 100).round();

  // Duration spent if completed
  Duration? get completionDuration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    tutorialId,
    isCompleted,
    progress,
    startedAt,
    completedAt,
    lastAccessedAt,
    userRating,
    userFeedback,
  ];
}

// Extension for string capitalization
extension StringExtension on String {
  String toCapitalized() => length > 0 
      ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
      : '';
}