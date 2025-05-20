import 'package:cloud_firestore/cloud_firestore.dart';

enum TutorialDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum TutorialCategory {
  cardio,
  strength,
  flexibility,
  balance,
  nutrition,
  recovery,
  technique,
  program,
}

class TutorialModel {
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
  final bool isPremium;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int viewCount;
  final double averageRating;
  final int ratingCount;
  
  // Video specific parameters
  final Map<String, dynamic>? videoMetadata;
  final List<VideoBookmark>? bookmarks;
  
  TutorialModel({
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
    required this.isPremium,
    required this.isPublished,
    required this.createdAt,
    this.updatedAt,
    required this.viewCount,
    required this.averageRating,
    required this.ratingCount,
    this.videoMetadata,
    this.bookmarks,
  });
  
  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      categories: (json['categories'] as List<dynamic>)
          .map((c) => TutorialCategory.values[c])
          .toList(),
      difficulty: TutorialDifficulty.values[json['difficulty']],
      durationMinutes: json['durationMinutes'],
      tags: List<String>.from(json['tags']),
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      isPremium: json['isPremium'],
      isPublished: json['isPublished'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : null,
      viewCount: json['viewCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      videoMetadata: json['videoMetadata'],
      bookmarks: json['bookmarks'] != null 
          ? (json['bookmarks'] as List<dynamic>)
              .map((b) => VideoBookmark.fromJson(b))
              .toList() 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'categories': categories.map((c) => c.index).toList(),
      'difficulty': difficulty.index,
      'durationMinutes': durationMinutes,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'isPremium': isPremium,
      'isPublished': isPublished,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'viewCount': viewCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'videoMetadata': videoMetadata,
      'bookmarks': bookmarks?.map((b) => b.toJson()).toList(),
    };
  }
  
  // Helper getters for display purposes
  String get difficultyString {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return 'Beginner';
      case TutorialDifficulty.intermediate:
        return 'Intermediate';
      case TutorialDifficulty.advanced:
        return 'Advanced';
      case TutorialDifficulty.expert:
        return 'Expert';
    }
  }
  
  String get categoryString {
    if (categories.isEmpty) return 'Uncategorized';
    
    final categoryNames = categories.map((c) {
      switch (c) {
        case TutorialCategory.cardio:
          return 'Cardio';
        case TutorialCategory.strength:
          return 'Strength';
        case TutorialCategory.flexibility:
          return 'Flexibility';
        case TutorialCategory.balance:
          return 'Balance';
        case TutorialCategory.nutrition:
          return 'Nutrition';
        case TutorialCategory.recovery:
          return 'Recovery';
        case TutorialCategory.technique:
          return 'Technique';
        case TutorialCategory.program:
          return 'Program';
      }
    }).toList();
    
    return categoryNames.join(', ');
  }
  
  // Create a copy with updated fields
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
    bool? isPremium,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    double? averageRating,
    int? ratingCount,
    Map<String, dynamic>? videoMetadata,
    List<VideoBookmark>? bookmarks,
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
      isPremium: isPremium ?? this.isPremium,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      videoMetadata: videoMetadata ?? this.videoMetadata,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class VideoBookmark {
  final String id;
  final String title;
  final String description;
  final int timestamp; // in seconds
  
  VideoBookmark({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });
  
  factory VideoBookmark.fromJson(Map<String, dynamic> json) {
    return VideoBookmark(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      timestamp: json['timestamp'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp,
    };
  }
  
  String get formattedTime {
    final minutes = timestamp ~/ 60;
    final seconds = timestamp % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class TutorialProgressModel {
  final String userId;
  final String tutorialId;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final int? userRating; // 1-5 stars
  final int lastWatchedPosition; // in seconds
  final DateTime lastAccessedAt;
  final List<String>? completedSections; // IDs of completed sections
  
  TutorialProgressModel({
    required this.userId,
    required this.tutorialId,
    required this.progress,
    required this.isCompleted,
    this.userRating,
    required this.lastWatchedPosition,
    required this.lastAccessedAt,
    this.completedSections,
  });
  
  factory TutorialProgressModel.fromJson(Map<String, dynamic> json) {
    return TutorialProgressModel(
      userId: json['userId'],
      tutorialId: json['tutorialId'],
      progress: json['progress'].toDouble(),
      isCompleted: json['isCompleted'],
      userRating: json['userRating'],
      lastWatchedPosition: json['lastWatchedPosition'] ?? 0,
      lastAccessedAt: (json['lastAccessedAt'] as Timestamp).toDate(),
      completedSections: json['completedSections'] != null 
          ? List<String>.from(json['completedSections']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tutorialId': tutorialId,
      'progress': progress,
      'isCompleted': isCompleted,
      'userRating': userRating,
      'lastWatchedPosition': lastWatchedPosition,
      'lastAccessedAt': lastAccessedAt,
      'completedSections': completedSections,
    };
  }
  
  // Create a copy with updated fields
  TutorialProgressModel copyWith({
    String? userId,
    String? tutorialId,
    double? progress,
    bool? isCompleted,
    int? userRating,
    int? lastWatchedPosition,
    DateTime? lastAccessedAt,
    List<String>? completedSections,
  }) {
    return TutorialProgressModel(
      userId: userId ?? this.userId,
      tutorialId: tutorialId ?? this.tutorialId,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      userRating: userRating ?? this.userRating,
      lastWatchedPosition: lastWatchedPosition ?? this.lastWatchedPosition,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      completedSections: completedSections ?? this.completedSections,
    );
  }
}