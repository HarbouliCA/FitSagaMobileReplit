import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Firebase configuration class
class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );
  }
}

// Service to handle Firebase Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get videos => _firestore.collection('videos');
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get sessions => _firestore.collection('sessions');
  CollectionReference get tutorials => _firestore.collection('tutorials');

  // Get all videos
  Future<List<VideoTutorial>> getAllVideos() async {
    final QuerySnapshot snapshot = await videos.get();
    return snapshot.docs.map((doc) {
      return VideoTutorial.fromFirestore(doc);
    }).toList();
  }

  // Get videos by type (strength or cardio)
  Future<List<VideoTutorial>> getVideosByType(String type) async {
    final QuerySnapshot snapshot = await videos
        .where('type', isEqualTo: type.toLowerCase())
        .get();
    
    return snapshot.docs.map((doc) {
      return VideoTutorial.fromFirestore(doc);
    }).toList();
  }
  
  // Get videos by body part
  Future<List<VideoTutorial>> getVideosByBodyPart(String bodyPart) async {
    final QuerySnapshot snapshot = await videos
        .where('bodyPart', arrayContains: bodyPart)
        .get();
    
    return snapshot.docs.map((doc) {
      return VideoTutorial.fromFirestore(doc);
    }).toList();
  }
  
  // Get videos by plan ID
  Future<List<VideoTutorial>> getVideosByPlan(String planId) async {
    final QuerySnapshot snapshot = await videos
        .where('planId', isEqualTo: planId)
        .get();
    
    return snapshot.docs.map((doc) {
      return VideoTutorial.fromFirestore(doc);
    }).toList();
  }
  
  // Get videos by day
  Future<List<VideoTutorial>> getVideosByDay(String dayName) async {
    final QuerySnapshot snapshot = await videos
        .where('dayName', isEqualTo: dayName)
        .get();
    
    return snapshot.docs.map((doc) {
      return VideoTutorial.fromFirestore(doc);
    }).toList();
  }
  
  // Create a new tutorial by combining videos
  Future<String> createTutorial({
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required List<String> videoIds,
    required String creatorId,
  }) async {
    final docRef = await tutorials.add({
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'videoIds': videoIds,
      'creatorId': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
  
  // Get all tutorials
  Future<List<TutorialProgram>> getAllTutorials() async {
    final QuerySnapshot snapshot = await tutorials.get();
    
    return await Future.wait(snapshot.docs.map((doc) async {
      return await TutorialProgram.fromFirestore(doc, this);
    }).toList());
  }
  
  // Get tutorial by ID with videos
  Future<TutorialProgram?> getTutorialById(String tutorialId) async {
    final DocumentSnapshot doc = await tutorials.doc(tutorialId).get();
    
    if (doc.exists) {
      return await TutorialProgram.fromFirestore(doc, this);
    }
    
    return null;
  }
}

// Video Tutorial Model
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
  
  // Create a VideoTutorial from a Firestore document
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
  
  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'activity': activity,
      'bodyPart': bodyPart,
      'dayId': dayId,
      'dayName': dayName,
      'planId': planId,
      'thumbnailUrl': thumbnailUrl,
      'type': type,
      'videoId': videoId,
      'videoUrl': videoUrl,
      'lastUpdated': lastUpdated != null 
          ? Timestamp.fromDate(lastUpdated!) 
          : null,
    };
  }
}

// Tutorial Program Model
class TutorialProgram {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final List<VideoTutorial> videos;
  final String creatorId;
  final DateTime? createdAt;
  
  TutorialProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.videos,
    required this.creatorId,
    this.createdAt,
  });
  
  // Create a TutorialProgram from a Firestore document
  static Future<TutorialProgram> fromFirestore(
    DocumentSnapshot doc, 
    FirestoreService firestoreService
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get all video IDs from the tutorial
    final List<String> videoIds = List<String>.from(data['videoIds'] ?? []);
    
    // Fetch all the videos
    final List<VideoTutorial> videos = [];
    for (final videoId in videoIds) {
      final videoDoc = await firestoreService.videos.doc(videoId).get();
      if (videoDoc.exists) {
        videos.add(VideoTutorial.fromFirestore(videoDoc));
      }
    }
    
    return TutorialProgram(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      videos: videos,
      creatorId: data['creatorId'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  // Convert to a map for Firestore
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