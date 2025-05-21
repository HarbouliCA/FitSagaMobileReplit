import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for video tutorials from Firebase collection
class VideoTutorial {
  final String id;
  final String activity;
  final String bodyPart;
  final String dayId;
  final String dayName; 
  final String planId;
  final String thumbnailUrl;
  final String type;
  final String videoId;
  final String videoUrl;
  final DateTime? lastUpdated;
  
  VideoTutorial({
    required this.id,
    required this.activity,
    required this.bodyPart,
    required this.dayId,
    required this.dayName,
    required this.planId,
    required this.thumbnailUrl,
    required this.type,
    required this.videoId,
    required this.videoUrl,
    this.lastUpdated,
  });
  
  /// Create a VideoTutorial from a Firestore document
  factory VideoTutorial.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VideoTutorial(
      id: doc.id,
      activity: data['activity'] ?? '',
      bodyPart: data['bodyPart'] ?? '',
      dayId: data['dayId'] ?? '',
      dayName: data['dayName'] ?? '',
      planId: data['planId'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      type: data['type'] ?? '',
      videoId: data['videoId'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      lastUpdated: data['lastUpdated'] != null 
          ? (data['lastUpdated'] as Timestamp).toDate() 
          : null,
    );
  }
  
  /// Used for mock data when not connected to Firebase
  static List<VideoTutorial> getMockTutorials() {
    return [
      VideoTutorial(
        id: '10011090_18687781_2023_bc001',
        activity: 'Press de banca - Barra',
        bodyPart: 'Pecho, Tríceps, Hombros parte delantera',
        dayId: '1',
        dayName: 'día 1',
        planId: '10011090',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082263.png',
        type: 'strength',
        videoId: 'bc001',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10011090_18687781_2023_bc001.mp4',
      ),
      VideoTutorial(
        id: '10011090_18687781_2023_cm005',
        activity: 'Cinta de correr 8 km/h ~ 5 mph',
        bodyPart: 'Sistema cardiovascular, Piernas',
        dayId: '1',
        dayName: 'día 1',
        planId: '10011090',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082247.png',
        type: 'cardio',
        videoId: 'cm005',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10011090_18687781_2023_cm005.mp4',
      ),
      VideoTutorial(
        id: '10011090_18687781_2023_cw003',
        activity: 'Jumping jacks',
        bodyPart: 'Sistema cardiovascular, Cuerpo completo',
        dayId: '1',
        dayName: 'día 1',
        planId: '10011090',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082253.png',
        type: 'cardio',
        videoId: 'cw003',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10011090_18687781_2023_cw003.mp4',
      ),
      VideoTutorial(
        id: '10011090_18687781_2023_gt001',
        activity: 'Extension de codo - Polea',
        bodyPart: 'Tríceps',
        dayId: '1',
        dayName: 'día 1',
        planId: '10011090',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082251.png',
        type: 'strength',
        videoId: 'gt001',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10011090_18687781_2023_gt001.mp4',
      ),
      VideoTutorial(
        id: '10011090_18687782_2023_ds001',
        activity: 'Elevaciones laterales de pie - mancuernas',
        bodyPart: 'Hombros',
        dayId: '2',
        dayName: 'día 2',
        planId: '10011090',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%202/images/3167082271.png',
        type: 'strength',
        videoId: 'ds001',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10011090_18687782_2023_ds001.mp4',
      ),
      VideoTutorial(
        id: '10031897_18739877_2023_cm001',
        activity: 'Máquina de remos, Intensidad baja',
        bodyPart: 'Sistema cardiovascular, Cuerpo completo',
        dayId: '1',
        dayName: 'día 1',
        planId: '10031897',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10031897/d%C3%ADa%201/images/3177842282.png',
        type: 'cardio',
        videoId: 'cm001',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10031897_18739877_2023_cm001.mp4',
      ),
      VideoTutorial(
        id: '10031897_18739877_2023_cm002',
        activity: 'Entrenador elíptico',
        bodyPart: 'Sistema cardiovascular, Cuerpo completo',
        dayId: '1',
        dayName: 'día 1',
        planId: '10031897',
        thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10031897/d%C3%ADa%201/images/3177842285.png',
        type: 'cardio',
        videoId: 'cm002',
        videoUrl: 'https://sagafit.blob.core.windows.net/sagavideos/10031897_18739877_2023_cm002.mp4',
      ),
    ];
  }
  
  /// Get all exercise types from available videos
  static Set<String> getAllExerciseTypes() {
    return getMockTutorials().map((v) => v.type).toSet();
  }
  
  /// Get all body parts from available videos
  static Set<String> getAllBodyParts() {
    final Set<String> parts = {};
    for (final video in getMockTutorials()) {
      for (final part in video.bodyPart.split(', ')) {
        parts.add(part);
      }
    }
    return parts;
  }
  
  /// Get all plan IDs from available videos
  static Set<String> getAllPlanIds() {
    return getMockTutorials().map((v) => v.planId).toSet();
  }
  
  /// Get all day names from available videos
  static Set<String> getAllDayNames() {
    return getMockTutorials().map((v) => v.dayName).toSet();
  }
}

/// Model for a tutorial program containing multiple videos
class TutorialProgram {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final List<VideoTutorial> videos;
  final String creatorId;
  final String creatorName;
  final DateTime? createdAt;
  
  TutorialProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.videos,
    required this.creatorId,
    required this.creatorName,
    this.createdAt,
  });
  
  /// Create a TutorialProgram from a Firestore document
  static Future<TutorialProgram> fromFirestore(
    DocumentSnapshot doc, 
    FirebaseFirestore firestore
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get all video IDs from the tutorial
    final List<String> videoIds = List<String>.from(data['videoIds'] ?? []);
    
    // Fetch all the videos
    final List<VideoTutorial> videos = [];
    for (final videoId in videoIds) {
      final videoDoc = await firestore.collection('videos').doc(videoId).get();
      if (videoDoc.exists) {
        videos.add(VideoTutorial.fromFirestore(videoDoc));
      }
    }
    
    // Get creator name
    String creatorName = 'Unknown';
    final creatorId = data['creatorId'] ?? '';
    if (creatorId.isNotEmpty) {
      final creatorDoc = await firestore.collection('users').doc(creatorId).get();
      if (creatorDoc.exists) {
        final creatorData = creatorDoc.data() as Map<String, dynamic>;
        creatorName = creatorData['name'] ?? 'Unknown';
      }
    }
    
    return TutorialProgram(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      videos: videos,
      creatorId: creatorId,
      creatorName: creatorName,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  /// Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'videoIds': videos.map((v) => v.id).toList(),
      'creatorId': creatorId,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
}