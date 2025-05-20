import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class TutorialSectionModel {
  final String id;
  final String tutorialId;
  final String title;
  final String description;
  final int orderIndex; // To control the order of sections
  final bool isLocked; // For premium or sequential unlocking
  final List<TutorialChapterModel> chapters;
  
  TutorialSectionModel({
    required this.id,
    required this.tutorialId,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.isLocked = false,
    required this.chapters,
  });
  
  factory TutorialSectionModel.fromJson(Map<String, dynamic> json) {
    return TutorialSectionModel(
      id: json['id'],
      tutorialId: json['tutorialId'],
      title: json['title'],
      description: json['description'],
      orderIndex: json['orderIndex'],
      isLocked: json['isLocked'] ?? false,
      chapters: (json['chapters'] as List<dynamic>?)
          ?.map((chapter) => TutorialChapterModel.fromJson(chapter))
          .toList() ?? [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutorialId': tutorialId,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'isLocked': isLocked,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }
  
  factory TutorialSectionModel.create({
    required String tutorialId,
    required String title,
    required String description,
    required int orderIndex,
    bool isLocked = false,
    List<TutorialChapterModel>? chapters,
  }) {
    return TutorialSectionModel(
      id: const Uuid().v4(),
      tutorialId: tutorialId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      isLocked: isLocked,
      chapters: chapters ?? [],
    );
  }
  
  TutorialSectionModel copyWith({
    String? id,
    String? tutorialId,
    String? title,
    String? description,
    int? orderIndex,
    bool? isLocked,
    List<TutorialChapterModel>? chapters,
  }) {
    return TutorialSectionModel(
      id: id ?? this.id,
      tutorialId: tutorialId ?? this.tutorialId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      isLocked: isLocked ?? this.isLocked,
      chapters: chapters ?? this.chapters,
    );
  }
  
  // Total duration of all chapters in this section (in seconds)
  int get totalDuration {
    return chapters.fold(0, (total, chapter) => total + chapter.durationSeconds);
  }
  
  // Format the total duration as a string (mm:ss or hh:mm:ss)
  String get formattedDuration {
    final duration = Duration(seconds: totalDuration);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

class TutorialChapterModel {
  final String id;
  final String title;
  final String? description;
  final int orderIndex; // To control the order of chapters within a section
  final String? videoUrl; // If chapter has its own video
  final int videoStartTime; // Start time in seconds (for main tutorial video)
  final int durationSeconds; // Duration of this chapter
  final bool isPreview; // Can be viewed without purchase/subscription
  final Map<String, dynamic>? resources; // Additional materials (PDFs, links, etc.)
  
  TutorialChapterModel({
    required this.id,
    required this.title,
    this.description,
    required this.orderIndex,
    this.videoUrl,
    required this.videoStartTime,
    required this.durationSeconds,
    this.isPreview = false,
    this.resources,
  });
  
  factory TutorialChapterModel.fromJson(Map<String, dynamic> json) {
    return TutorialChapterModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      orderIndex: json['orderIndex'],
      videoUrl: json['videoUrl'],
      videoStartTime: json['videoStartTime'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      isPreview: json['isPreview'] ?? false,
      resources: json['resources'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'videoUrl': videoUrl,
      'videoStartTime': videoStartTime,
      'durationSeconds': durationSeconds,
      'isPreview': isPreview,
      'resources': resources,
    };
  }
  
  factory TutorialChapterModel.create({
    required String title,
    String? description,
    required int orderIndex,
    String? videoUrl,
    required int videoStartTime,
    required int durationSeconds,
    bool isPreview = false,
    Map<String, dynamic>? resources,
  }) {
    return TutorialChapterModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      orderIndex: orderIndex,
      videoUrl: videoUrl,
      videoStartTime: videoStartTime,
      durationSeconds: durationSeconds,
      isPreview: isPreview,
      resources: resources,
    );
  }
  
  TutorialChapterModel copyWith({
    String? id,
    String? title,
    String? description,
    int? orderIndex,
    String? videoUrl,
    int? videoStartTime,
    int? durationSeconds,
    bool? isPreview,
    Map<String, dynamic>? resources,
  }) {
    return TutorialChapterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      videoUrl: videoUrl ?? this.videoUrl,
      videoStartTime: videoStartTime ?? this.videoStartTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isPreview: isPreview ?? this.isPreview,
      resources: resources ?? this.resources,
    );
  }
  
  // Format the start time as a string (mm:ss or hh:mm:ss)
  String get formattedStartTime {
    final duration = Duration(seconds: videoStartTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  // Format the duration as a string (mm:ss or hh:mm:ss)
  String get formattedDuration {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}