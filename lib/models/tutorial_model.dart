import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TutorialLevel {
  beginner,
  intermediate,
  advanced,
  all,
}

enum TutorialCategory {
  strength,
  cardio,
  flexibility,
  recovery,
  nutrition,
  mindfulness,
  equipment,
  technique,
  other,
}

class TutorialModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String instructorId;
  final String instructorName;
  final TutorialLevel level;
  final TutorialCategory category;
  final List<String> tags;
  final int durationInMinutes;
  final bool isPremium;
  final int viewCount;
  final double rating;
  final int ratingCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TutorialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.instructorId,
    required this.instructorName,
    required this.level,
    required this.category,
    required this.tags,
    required this.durationInMinutes,
    required this.isPremium,
    this.viewCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  // Create a copy with modified fields
  TutorialModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    String? instructorId,
    String? instructorName,
    TutorialLevel? level,
    TutorialCategory? category,
    List<String>? tags,
    int? durationInMinutes,
    bool? isPremium,
    int? viewCount,
    double? rating,
    int? ratingCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TutorialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      level: level ?? this.level,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      isPremium: isPremium ?? this.isPremium,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format to minutes and seconds
  String get formattedDuration {
    final minutes = durationInMinutes;
    return '$minutes min';
  }

  // Factory method to create a TutorialModel from Firestore document
  factory TutorialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TutorialModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      level: _levelFromString(data['level'] ?? 'all'),
      category: _categoryFromString(data['category'] ?? 'other'),
      tags: List<String>.from(data['tags'] ?? []),
      durationInMinutes: data['durationInMinutes'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
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
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'level': _levelToString(level),
      'category': _categoryToString(category),
      'tags': tags,
      'durationInMinutes': durationInMinutes,
      'isPremium': isPremium,
      'viewCount': viewCount,
      'rating': rating,
      'ratingCount': ratingCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Helper methods for level conversion
  static TutorialLevel _levelFromString(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return TutorialLevel.beginner;
      case 'intermediate':
        return TutorialLevel.intermediate;
      case 'advanced':
        return TutorialLevel.advanced;
      case 'all':
      default:
        return TutorialLevel.all;
    }
  }

  static String _levelToString(TutorialLevel level) {
    switch (level) {
      case TutorialLevel.beginner:
        return 'beginner';
      case TutorialLevel.intermediate:
        return 'intermediate';
      case TutorialLevel.advanced:
        return 'advanced';
      case TutorialLevel.all:
        return 'all';
    }
  }

  // Helper methods for category conversion
  static TutorialCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return TutorialCategory.strength;
      case 'cardio':
        return TutorialCategory.cardio;
      case 'flexibility':
        return TutorialCategory.flexibility;
      case 'recovery':
        return TutorialCategory.recovery;
      case 'nutrition':
        return TutorialCategory.nutrition;
      case 'mindfulness':
        return TutorialCategory.mindfulness;
      case 'equipment':
        return TutorialCategory.equipment;
      case 'technique':
        return TutorialCategory.technique;
      case 'other':
      default:
        return TutorialCategory.other;
    }
  }

  static String _categoryToString(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.strength:
        return 'strength';
      case TutorialCategory.cardio:
        return 'cardio';
      case TutorialCategory.flexibility:
        return 'flexibility';
      case TutorialCategory.recovery:
        return 'recovery';
      case TutorialCategory.nutrition:
        return 'nutrition';
      case TutorialCategory.mindfulness:
        return 'mindfulness';
      case TutorialCategory.equipment:
        return 'equipment';
      case TutorialCategory.technique:
        return 'technique';
      case TutorialCategory.other:
        return 'other';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnailUrl,
    videoUrl,
    instructorId,
    instructorName,
    level,
    category,
    tags,
    durationInMinutes,
    isPremium,
    viewCount,
    rating,
    ratingCount,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'TutorialModel(id: $id, title: $title, instructor: $instructorName, level: $level, category: $category)';
  }
}

// Model to track user progress in tutorials
class TutorialProgress {
  final String id;
  final String userId;
  final String tutorialId;
  final double progress; // 0.0 to 1.0 representing completion percentage
  final bool isCompleted;
  final DateTime lastWatched;
  final int lastPositionInSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TutorialProgress({
    required this.id,
    required this.userId,
    required this.tutorialId,
    required this.progress,
    required this.isCompleted,
    required this.lastWatched,
    required this.lastPositionInSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a TutorialProgress from Firestore document
  factory TutorialProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TutorialProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      tutorialId: data['tutorialId'] ?? '',
      progress: (data['progress'] ?? 0.0).toDouble(),
      isCompleted: data['isCompleted'] ?? false,
      lastWatched: (data['lastWatched'] as Timestamp).toDate(),
      lastPositionInSeconds: data['lastPositionInSeconds'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tutorialId': tutorialId,
      'progress': progress,
      'isCompleted': isCompleted,
      'lastWatched': Timestamp.fromDate(lastWatched),
      'lastPositionInSeconds': lastPositionInSeconds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

// Model for user ratings on tutorials
class TutorialRating {
  final String id;
  final String userId;
  final String tutorialId;
  final int rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TutorialRating({
    required this.id,
    required this.userId,
    required this.tutorialId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a TutorialRating from Firestore document
  factory TutorialRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TutorialRating(
      id: doc.id,
      userId: data['userId'] ?? '',
      tutorialId: data['tutorialId'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'tutorialId': tutorialId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}