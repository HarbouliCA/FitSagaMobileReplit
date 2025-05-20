import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/models/activity_model.dart';
import 'package:fitsaga/models/session_model.dart';

class SessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get all activities
  Future<List<ActivityModel>> getAllActivities() async {
    try {
      QuerySnapshot activitiesSnapshot = await _firestore
          .collection(AppConstants.activitiesCollection)
          .get();
      
      return activitiesSnapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get activity by ID
  Future<ActivityModel?> getActivityById(String activityId) async {
    try {
      DocumentSnapshot activityDoc = await _firestore
          .collection(AppConstants.activitiesCollection)
          .doc(activityId)
          .get();
      
      if (activityDoc.exists) {
        return ActivityModel.fromFirestore(activityDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get all upcoming sessions
  Future<List<SessionModel>> getUpcomingSessions() async {
    try {
      final now = DateTime.now();
      
      QuerySnapshot sessionsSnapshot = await _firestore
          .collection(AppConstants.sessionsCollection)
          .where('startTime', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: AppConstants.sessionStatusScheduled)
          .orderBy('startTime')
          .limit(50)
          .get();
      
      return sessionsSnapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get session by ID
  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      DocumentSnapshot sessionDoc = await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .get();
      
      if (sessionDoc.exists) {
        return SessionModel.fromFirestore(sessionDoc);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get sessions by instructor
  Future<List<SessionModel>> getSessionsByInstructor(String instructorId) async {
    try {
      final now = DateTime.now();
      
      QuerySnapshot sessionsSnapshot = await _firestore
          .collection(AppConstants.sessionsCollection)
          .where('instructorId', isEqualTo: instructorId)
          .where('startTime', isGreaterThanOrEqualTo: now)
          .orderBy('startTime')
          .get();
      
      return sessionsSnapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get sessions by activity type
  Future<List<SessionModel>> getSessionsByActivityType(String activityType) async {
    try {
      final now = DateTime.now();
      
      QuerySnapshot sessionsSnapshot = await _firestore
          .collection(AppConstants.sessionsCollection)
          .where('activityType', isEqualTo: activityType)
          .where('startTime', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: AppConstants.sessionStatusScheduled)
          .orderBy('startTime')
          .get();
      
      return sessionsSnapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }
  
  // Create a new session (for admin/instructor)
  Future<String?> createSession(Map<String, dynamic> sessionData) async {
    try {
      DocumentReference sessionRef = await _firestore
          .collection(AppConstants.sessionsCollection)
          .add({
        ...sessionData,
        'enrolledCount': 0,
        'status': AppConstants.sessionStatusScheduled,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return sessionRef.id;
    } catch (e) {
      return null;
    }
  }
  
  // Update a session (for admin/instructor)
  Future<bool> updateSession(String sessionId, Map<String, dynamic> sessionData) async {
    try {
      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({
        ...sessionData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Cancel a session (for admin/instructor)
  Future<bool> cancelSession(String sessionId) async {
    try {
      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({
        'status': AppConstants.sessionStatusCancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Search sessions
  Future<List<SessionModel>> searchSessions(String query) async {
    try {
      final now = DateTime.now();
      
      // Search by activity name
      QuerySnapshot activityNameSnapshot = await _firestore
          .collection(AppConstants.sessionsCollection)
          .where('activityName', isGreaterThanOrEqualTo: query)
          .where('activityName', isLessThanOrEqualTo: query + '\uf8ff')
          .where('startTime', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: AppConstants.sessionStatusScheduled)
          .orderBy('activityName')
          .orderBy('startTime')
          .limit(20)
          .get();
          
      // Search by instructor name
      QuerySnapshot instructorNameSnapshot = await _firestore
          .collection(AppConstants.sessionsCollection)
          .where('instructorName', isGreaterThanOrEqualTo: query)
          .where('instructorName', isLessThanOrEqualTo: query + '\uf8ff')
          .where('startTime', isGreaterThanOrEqualTo: now)
          .where('status', isEqualTo: AppConstants.sessionStatusScheduled)
          .orderBy('instructorName')
          .orderBy('startTime')
          .limit(20)
          .get();
          
      // Combine results and remove duplicates
      Map<String, SessionModel> uniqueSessions = {};
      
      for (var doc in activityNameSnapshot.docs) {
        uniqueSessions[doc.id] = SessionModel.fromFirestore(doc);
      }
      
      for (var doc in instructorNameSnapshot.docs) {
        uniqueSessions[doc.id] = SessionModel.fromFirestore(doc);
      }
      
      return uniqueSessions.values.toList();
    } catch (e) {
      return [];
    }
  }
}
