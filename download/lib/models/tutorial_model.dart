import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum representing difficulty levels for tutorials
enum TutorialLevel {
  /// Suitable for beginners with little to no experience
  beginner,
  
  /// For those with some experience but not advanced
  intermediate,
  
  /// For experienced users with substantial knowledge
  advanced,
  
  /// For all skill levels
  allLevels,
}

/// Extension to convert string to TutorialLevel enum
extension TutorialLevelExtension on String {
  TutorialLevel toTutorialLevel() {
    switch (this.toLowerCase()) {
      case 'beginner':
        return TutorialLevel.beginner;
      case 'intermediate':
        return TutorialLevel.intermediate;
      case 'advanced':
        return TutorialLevel.advanced;
      case 'alllevels':
        return TutorialLevel.allLevels;
      default:
        return TutorialLevel.allLevels;
    }
  }
}

/// Model class representing a tutorial in the FitSAGA app
class TutorialModel {
  /// Unique identifier for the tutorial
  final String id;
  
  /// Title of the tutorial
  String title;
  
  /// Detailed description of what the tutorial covers
  String description;
  
  /// ID of the instructor who created the tutorial
  String authorId;
  
  /// Name of the instructor who created the tutorial
  String authorName;
  
  /// URL to the tutorial video
  String videoUrl;
  
  /// List of image URLs for the tutorial
  List<String> imageUrls;
  
  /// Tutorial difficulty level
  TutorialLevel level;
  
  /// List of tags/keywords relevant to the tutorial
  List<String> tags;
  
  /// Duration of the tutorial in minutes
  int durationMinutes;
  
  /// Detailed steps/instructions for the tutorial
  List<String> steps;
  
  /// Equipment needed for the tutorial
  List<String> equipment;
  
  /// Whether the tutorial is featured on the home page
  bool isFeatured;
  
  /// Whether the tutorial is public and visible to all users
  bool isPublic;
  
  /// When the tutorial was created
  final DateTime createdAt;
  
  /// When the tutorial was last updated
  DateTime updatedAt;
  
  /// Constructor for creating a new TutorialModel
  TutorialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.authorName,
    required this.videoUrl,
    required this.imageUrls,
    required this.level,
    required this.tags,
    required this.durationMinutes,
    required this.steps,
    required this.equipment,
    required this.isFeatured,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Creates a TutorialModel from a Firebase document map
  factory TutorialModel.fromMap(Map<String, dynamic> map, String docId) {
    return TutorialModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      level: (map['level'] as String? ?? 'allLevels').toTutorialLevel(),
      tags: List<String>.from(map['tags'] ?? []),
      durationMinutes: map['durationMinutes'] ?? 0,
      steps: List<String>.from(map['steps'] ?? []),
      equipment: List<String>.from(map['equipment'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      isPublic: map['isPublic'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  /// Converts the TutorialModel to a map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'authorId': authorId,
      'authorName': authorName,
      'videoUrl': videoUrl,
      'imageUrls': imageUrls,
      'level': level.toString().split('.').last,
      'tags': tags,
      'durationMinutes': durationMinutes,
      'steps': steps,
      'equipment': equipment,
      'isFeatured': isFeatured,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
  
  /// Gets a formatted duration string (e.g., "15 mins")
  String get formattedDuration {
    return '$durationMinutes mins';
  }
  
  /// Checks if the tutorial has a video
  bool get hasVideo => videoUrl.isNotEmpty;
  
  /// Checks if the tutorial has images
  bool get hasImages => imageUrls.isNotEmpty;
  
  /// Gets the primary tutorial image (first in list or empty string)
  String get primaryImage => imageUrls.isNotEmpty ? imageUrls.first : '';
  
  /// Checks if tutorial has steps/instructions
  bool get hasSteps => steps.isNotEmpty;
  
  /// Checks if tutorial requires equipment
  bool get requiresEquipment => equipment.isNotEmpty;
  
  /// Creates a copy of this TutorialModel with optional new values
  TutorialModel copyWith({
    String? title,
    String? description,
    String? videoUrl,
    List<String>? imageUrls,
    TutorialLevel? level,
    List<String>? tags,
    int? durationMinutes,
    List<String>? steps,
    List<String>? equipment,
    bool? isFeatured,
    bool? isPublic,
  }) {
    return TutorialModel(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: this.authorId,
      authorName: this.authorName,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      level: level ?? this.level,
      tags: tags ?? this.tags,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      steps: steps ?? this.steps,
      equipment: equipment ?? this.equipment,
      isFeatured: isFeatured ?? this.isFeatured,
      isPublic: isPublic ?? this.isPublic,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(), // Always update when copied
    );
  }
  
  @override
  String toString() {
    return 'TutorialModel(id: $id, title: $title, author: $authorName, level: $level)';
  }
}