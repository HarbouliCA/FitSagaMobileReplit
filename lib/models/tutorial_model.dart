class VideoTutorial {
  final String id;
  final String activity;
  final String bodyPart;
  final String dayId;
  final String dayName;
  final String lastUpdated;
  final String planId;
  final String thumbnailId;
  final String thumbnailUrl;
  final String type;
  final String videoId;
  final String videoUrl;
  
  VideoTutorial({
    required this.id,
    required this.activity,
    required this.bodyPart,
    required this.dayId,
    required this.dayName,
    required this.lastUpdated,
    required this.planId,
    required this.thumbnailId,
    required this.thumbnailUrl,
    required this.type,
    required this.videoId,
    required this.videoUrl,
  });
  
  factory VideoTutorial.fromMap(Map<String, dynamic> map, String documentId) {
    return VideoTutorial(
      id: documentId,
      activity: map['activity'] ?? '',
      bodyPart: map['bodypart'] ?? '',
      dayId: map['dayId'] ?? '',
      dayName: map['dayName'] ?? '',
      lastUpdated: map['lastUpdated'] ?? '',
      planId: map['planId'] ?? '',
      thumbnailId: map['thumbnailId'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      type: map['type'] ?? '',
      videoId: map['videoId'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'activity': activity,
      'bodypart': bodyPart,
      'dayId': dayId,
      'dayName': dayName,
      'lastUpdated': lastUpdated,
      'planId': planId,
      'thumbnailId': thumbnailId,
      'thumbnailUrl': thumbnailUrl,
      'type': type,
      'videoId': videoId,
      'videoUrl': videoUrl,
    };
  }
}

class TutorialPlan {
  final String planId;
  final String name;
  final List<TutorialDay> days;
  
  TutorialPlan({
    required this.planId,
    required this.name,
    required this.days,
  });
}

class TutorialDay {
  final String dayId;
  final String dayName;
  final List<VideoTutorial> videos;
  
  TutorialDay({
    required this.dayId,
    required this.dayName,
    required this.videos,
  });
}

// Mock function to get all available tutorials from Firebase
List<VideoTutorial> getMockTutorials() {
  return [
    VideoTutorial(
      id: '10011090_18687781_2023_bc001.mp4',
      activity: 'Press de banca - Barra',
      bodyPart: 'Pecho, Tríceps, Hombros parte delantera',
      dayId: '18687781',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082263',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082263.png',
      type: 'strength',
      videoId: '2023_bc001.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 1/2023_bc001.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687781_2023_cm005.mp4',
      activity: 'Cinta de correr 8 km/h ~ 5 mph',
      bodyPart: 'Sistema cardiovascular, Piernas',
      dayId: '18687781',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082247',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082247.png',
      type: 'cardio',
      videoId: '2023_cm005.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 1/2023_cm005.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687781_2023_cw003.mp4',
      activity: 'Jumping jacks',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      dayId: '18687781',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082253',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082253.png',
      type: 'cardio',
      videoId: '2023_cw003.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 1/2023_cw003.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687781_2023_gt001.mp4',
      activity: 'Extension de codo - Polea',
      bodyPart: 'Tríceps',
      dayId: '18687781',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082251',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082251.png',
      type: 'strength',
      videoId: '2023_gt001.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 1/2023_gt001.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687781_2023_oa041.mp4',
      activity: 'Curl de bíceps - Polea',
      bodyPart: 'Bíceps',
      dayId: '18687781',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082252',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082252.png',
      type: 'strength',
      videoId: '2023_oa041.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 1/2023_oa041.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687781_2023_ozp032.mp4',
      activity: 'Saltos - Caja',
      bodyPart: 'Cuádriceps, Glúteos, Corvas, Zona lumbar',
      dayId: '18687781',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082258',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082258.png',
      type: 'strength',
      videoId: '2023_ozp032.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 1/2023_ozp032.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687782_2023_ds001.mp4',
      activity: 'Elevaciones laterales de pie - mancuernas',
      bodyPart: 'Hombros',
      dayId: '18687782',
      dayName: 'día 2',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082271',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%202/images/3167082271.png',
      type: 'strength',
      videoId: '2023_ds001.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 2/2023_ds001.mp4',
    ),
    VideoTutorial(
      id: '10011090_18687782_2023_gb002.mp4',
      activity: 'Jalon al pecho',
      bodyPart: 'Dorsales, Bíceps, Espalda',
      dayId: '18687782',
      dayName: 'día 2',
      lastUpdated: '27 mars 2025 à 13:47:45 UTC+1',
      planId: '10011090',
      thumbnailId: '3167082274',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%202/images/3167082274.png',
      type: 'strength',
      videoId: '2023_gb002.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10011090/día 2/2023_gb002.mp4',
    ),
    VideoTutorial(
      id: '10031897_18739877_2023_cm001.mp4',
      activity: 'Máquina de remos, Intensidad baja',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      dayId: '18739877',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:49 UTC+1',
      planId: '10031897',
      thumbnailId: '3177842282',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10031897/d%C3%ADa%201/images/3177842282.png',
      type: 'cardio',
      videoId: '2023_cm001.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10031897/día 1/2023_cm001.mp4',
    ),
    VideoTutorial(
      id: '10031897_18739877_2023_cm002.mp4',
      activity: 'Entrenador elíptico',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      dayId: '18739877',
      dayName: 'día 1',
      lastUpdated: '27 mars 2025 à 13:47:49 UTC+1',
      planId: '10031897',
      thumbnailId: '3177842285',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10031897/d%C3%ADa%201/images/3177842285.png',
      type: 'cardio',
      videoId: '2023_cm002.mp4',
      videoUrl: 'https://sagafit.blob.core.windows.net/sagafitvideos/10031897/día 1/2023_cm002.mp4',
    ),
  ];
}

// Get unique muscle groups from all videos
Set<String> getAllBodyParts() {
  final List<VideoTutorial> allVideos = getMockTutorials();
  final Set<String> bodyParts = {};
  
  for (final video in allVideos) {
    // Split by commas and add individual body parts
    final parts = video.bodyPart.split(', ');
    bodyParts.addAll(parts);
  }
  
  return bodyParts;
}

// Get all unique types (cardio, strength, etc.)
Set<String> getAllExerciseTypes() {
  final List<VideoTutorial> allVideos = getMockTutorials();
  return allVideos.map((video) => video.type).toSet();
}

// Organize videos into plan/day structure
List<TutorialPlan> organizeTutorialsByPlan() {
  final List<VideoTutorial> allVideos = getMockTutorials();
  
  // Group videos by planId
  final Map<String, Map<String, List<VideoTutorial>>> planMap = {};
  
  for (final video in allVideos) {
    // Initialize plan if doesn't exist
    if (!planMap.containsKey(video.planId)) {
      planMap[video.planId] = {};
    }
    
    // Initialize day if doesn't exist
    if (!planMap[video.planId]!.containsKey(video.dayId)) {
      planMap[video.planId]![video.dayId] = [];
    }
    
    // Add video to appropriate day
    planMap[video.planId]![video.dayId]!.add(video);
  }
  
  // Convert to TutorialPlan objects
  final List<TutorialPlan> plans = [];
  
  planMap.forEach((planId, daysMap) {
    final List<TutorialDay> days = [];
    
    daysMap.forEach((dayId, videos) {
      final String dayName = videos.first.dayName;
      
      days.add(TutorialDay(
        dayId: dayId,
        dayName: dayName,
        videos: videos,
      ));
    });
    
    plans.add(TutorialPlan(
      planId: planId,
      name: 'Plan $planId',
      days: days,
    ));
  });
  
  return plans;
}