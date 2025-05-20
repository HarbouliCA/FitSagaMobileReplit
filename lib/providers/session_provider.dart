import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

class SessionProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  SessionProvider(this._firebaseService);

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<SessionModel> get sessions => _sessions;
  
  // Get only upcoming sessions (not in the past)
  List<SessionModel> get upcomingSessions {
    final now = DateTime.now();
    return _sessions
        .where((session) => session.startTime.isAfter(now) && session.isActive)
        .toList();
  }
  
  // Get sessions created by the current instructor
  List<SessionModel> getInstructorSessions(String instructorId) {
    return _sessions
        .where((session) => session.instructorId == instructorId)
        .toList();
  }
  
  // Get sessions booked by the current user
  List<SessionModel> get userSessions {
    return _sessions
        .where((session) => 
            session.participantIds.contains(_firebaseService.currentUser?.uid))
        .toList();
  }

  // Load all sessions
  Future<void> loadSessions(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Reference to the sessions collection
      final sessionsRef = _firebaseService.firestore.collection('sessions');
      QuerySnapshot snapshot;
      
      // Admin sees all sessions
      if (user.isAdmin) {
        snapshot = await sessionsRef.get();
      }
      // Instructors see their own sessions and all sessions they're registered for
      else if (user.isInstructor) {
        final instructorSessionsQuery = await sessionsRef
            .where('instructorId', isEqualTo: user.id)
            .get();
            
        final participantSessionsQuery = await sessionsRef
            .where('participantIds', arrayContains: user.id)
            .get();
            
        // Combine both result sets
        final allDocs = [
          ...instructorSessionsQuery.docs,
          ...participantSessionsQuery.docs,
        ];
        
        // Remove duplicates (sessions both created by and participated in by the instructor)
        final uniqueDocsMap = <String, QueryDocumentSnapshot>{};
        for (final doc in allDocs) {
          uniqueDocsMap[doc.id] = doc;
        }
        
        // Convert back to list
        snapshot = QuerySnapshot.withDocuments(uniqueDocsMap.values.toList());
      }
      // Clients see only sessions available to book and sessions they're registered for
      else {
        final availableSessionsQuery = await sessionsRef
            .where('isActive', isEqualTo: true)
            .get();
            
        final participantSessionsQuery = await sessionsRef
            .where('participantIds', arrayContains: user.id)
            .get();
            
        // Combine both result sets
        final allDocs = [
          ...availableSessionsQuery.docs,
          ...participantSessionsQuery.docs,
        ];
        
        // Remove duplicates
        final uniqueDocsMap = <String, QueryDocumentSnapshot>{};
        for (final doc in allDocs) {
          uniqueDocsMap[doc.id] = doc;
        }
        
        // Convert back to list
        snapshot = QuerySnapshot.withDocuments(uniqueDocsMap.values.toList());
      }
      
      // Parse sessions from snapshot
      _sessions = snapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
      
      // Sort sessions by start time (newest first)
      _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      _isInitialized = true;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load sessions: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create a new session
  Future<bool> createSession(SessionModel session) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate session data
      if (session.title.isEmpty || session.description.isEmpty) {
        _error = 'Session must have a title and description';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create session in Firestore
      final docRef = await _firebaseService.firestore.collection('sessions').add(
        session.toFirestore(),
      );
      
      // Create new session with assigned ID
      final newSession = SessionModel(
        id: docRef.id,
        title: session.title,
        description: session.description,
        type: session.type,
        instructorId: session.instructorId,
        instructorName: session.instructorName,
        startTime: session.startTime,
        endTime: session.endTime,
        location: session.location,
        maxParticipants: session.maxParticipants,
        participantIds: session.participantIds,
        requirements: session.requirements,
        level: session.level,
        isActive: session.isActive,
        createdAt: session.createdAt,
      );
      
      // Add to local list
      _sessions.add(newSession);
      
      // Sort sessions by start time
      _sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create session: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing session
  Future<bool> updateSession(SessionModel updatedSession) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update session in Firestore
      await _firebaseService.firestore
          .collection('sessions')
          .doc(updatedSession.id)
          .update(updatedSession.copyWith(
            updatedAt: DateTime.now(),
          ).toFirestore());
      
      // Update local list
      final index = _sessions.indexWhere((s) => s.id == updatedSession.id);
      if (index != -1) {
        _sessions[index] = updatedSession.copyWith(
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update session: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a session
  Future<bool> deleteSession(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete session from Firestore
      await _firebaseService.firestore
          .collection('sessions')
          .doc(sessionId)
          .delete();
      
      // Remove from local list
      _sessions.removeWhere((s) => s.id == sessionId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete session: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Book a session for a user
  Future<bool> bookSession(String sessionId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get session reference
      final sessionRef = _firebaseService.firestore
          .collection('sessions')
          .doc(sessionId);
      
      // Get current session data
      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) {
        _error = 'Session not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final session = SessionModel.fromFirestore(sessionDoc);
      
      // Check if session is active
      if (!session.isActive) {
        _error = 'This session is not available for booking';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Check if user is already registered
      if (session.participantIds.contains(userId)) {
        _error = 'You are already registered for this session';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Check if session is full
      if (session.isFull) {
        _error = 'This session is already full';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Update session participants in a transaction to prevent race conditions
      await _firebaseService.firestore.runTransaction((transaction) async {
        // Get the latest session data
        final latestSessionDoc = await transaction.get(sessionRef);
        final latestSession = SessionModel.fromFirestore(latestSessionDoc);
        
        // Double-check that session is not full
        if (latestSession.isFull) {
          throw Exception('This session is now full');
        }
        
        // Add user to participants
        final updatedParticipants = [...latestSession.participantIds, userId];
        
        // Update the session
        transaction.update(sessionRef, {
          'participantIds': updatedParticipants,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Now deduct credits in a separate transaction
        // This would be better handled in a Cloud Function to ensure atomicity
        final userCreditsRef = _firebaseService.firestore
            .collection('user_credits')
            .doc(userId);
        
        // Deduct 1 credit
        transaction.update(userCreditsRef, {
          'balance': FieldValue.increment(-1),
        });
        
        // Record the credit transaction
        final creditTransactionRef = _firebaseService.firestore
            .collection('credit_transactions')
            .doc();
        
        transaction.set(creditTransactionRef, {
          'userId': userId,
          'amount': 1, // 1 credit per session
          'isCredit': false, // deduction
          'type': 'booking',
          'description': 'Booking for ${latestSession.title}',
          'sessionId': sessionId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      
      // Update local session list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        final updatedParticipants = [..._sessions[index].participantIds, userId];
        _sessions[index] = _sessions[index].copyWith(
          participantIds: updatedParticipants,
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to book session: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel a session booking
  Future<bool> cancelBooking(String sessionId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get session reference
      final sessionRef = _firebaseService.firestore
          .collection('sessions')
          .doc(sessionId);
      
      // Get current session data
      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) {
        _error = 'Session not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final session = SessionModel.fromFirestore(sessionDoc);
      
      // Check if user is registered for this session
      if (!session.participantIds.contains(userId)) {
        _error = 'You are not registered for this session';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Check cancellation policy (e.g., 24h before session starts)
      final now = DateTime.now();
      final hoursDifference = session.startTime.difference(now).inHours;
      
      // Handle refund based on cancellation policy
      final shouldRefund = hoursDifference >= 24;
      
      // Update session participants in a transaction
      await _firebaseService.firestore.runTransaction((transaction) async {
        // Remove user from participants
        final updatedParticipants = [...session.participantIds]
          ..remove(userId);
        
        // Update the session
        transaction.update(sessionRef, {
          'participantIds': updatedParticipants,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Process refund if applicable
        if (shouldRefund) {
          // Refund credits to user
          final userCreditsRef = _firebaseService.firestore
              .collection('user_credits')
              .doc(userId);
          
          transaction.update(userCreditsRef, {
            'balance': FieldValue.increment(1), // Refund 1 credit
          });
          
          // Record the refund transaction
          final creditTransactionRef = _firebaseService.firestore
              .collection('credit_transactions')
              .doc();
          
          transaction.set(creditTransactionRef, {
            'userId': userId,
            'amount': 1,
            'isCredit': true, // addition (refund)
            'type': 'refund',
            'description': 'Refund for cancelled booking: ${session.title}',
            'sessionId': sessionId,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
      
      // Update local session list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        final updatedParticipants = [..._sessions[index].participantIds]
          ..remove(userId);
        _sessions[index] = _sessions[index].copyWith(
          participantIds: updatedParticipants,
          updatedAt: DateTime.now(),
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to cancel booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get a specific session by ID
  SessionModel? getSessionById(String sessionId) {
    try {
      return _sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  // Clear all data (used during logout)
  void clear() {
    _sessions = [];
    _isInitialized = false;
    _error = null;
    notifyListeners();
  }
}