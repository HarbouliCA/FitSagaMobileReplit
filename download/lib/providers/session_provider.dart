import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

/// Provider class for managing gym sessions in the FitSAGA app
class SessionProvider with ChangeNotifier {
  /// Instance of the Firebase service
  final FirebaseService _firebaseService = FirebaseService();
  
  /// List of all available sessions
  List<SessionModel> _sessions = [];
  
  /// List of sessions booked by the current user
  List<SessionModel> _userSessions = [];
  
  /// List of sessions created by the current instructor (if applicable)
  List<SessionModel> _instructorSessions = [];
  
  /// Currently selected session for viewing details
  SessionModel? _selectedSession;
  
  /// Loading state for session operations
  bool _isLoading = false;
  
  /// Error message if session operations fail
  String? _error;
  
  /// Flag to track if sessions have been loaded
  bool _isInitialized = false;
  
  /// Returns the list of all available sessions
  List<SessionModel> get sessions => _sessions;
  
  /// Returns the list of sessions booked by the current user
  List<SessionModel> get userSessions => _userSessions;
  
  /// Returns the list of sessions created by the current instructor
  List<SessionModel> get instructorSessions => _instructorSessions;
  
  /// Returns whether a session operation is in progress
  bool get isLoading => _isLoading;
  
  /// Returns any error message from the last session operation
  String? get error => _error;
  
  /// Returns whether sessions have been loaded
  bool get isInitialized => _isInitialized;
  
  /// Returns the currently selected session
  SessionModel? get selectedSession => _selectedSession;
  
  /// Loads all relevant sessions based on the current user
  Future<void> loadSessions(UserModel currentUser) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Load all available sessions
      _sessions = await _firebaseService.getAllSessions();
      
      // Load user's booked sessions
      _userSessions = await _firebaseService.getUserBookedSessions(currentUser.id);
      
      // If user is an instructor or admin, load their created sessions
      if (currentUser.isInstructor) {
        _instructorSessions = await _firebaseService.getSessionsByInstructor(currentUser.id);
      } else {
        _instructorSessions = [];
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load sessions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets sessions filtered by type
  List<SessionModel> getSessionsByType(SessionType type) {
    return _sessions.where((session) => session.type == type).toList();
  }
  
  /// Gets upcoming sessions (not yet started)
  List<SessionModel> get upcomingSessions {
    final now = DateTime.now();
    return _sessions
        .where((session) => session.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  /// Gets the user's upcoming booked sessions
  List<SessionModel> get upcomingUserSessions {
    final now = DateTime.now();
    return _userSessions
        .where((session) => session.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  /// Gets sessions scheduled for today
  List<SessionModel> get todaySessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _sessions
        .where((session) => 
            session.startTime.isAfter(today) && 
            session.startTime.isBefore(tomorrow))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  /// Creates a new session (instructor or admin only)
  Future<bool> createSession(SessionModel session) async {
    try {
      _setLoading(true);
      _clearError();
      
      final sessionId = await _firebaseService.createSession(session);
      
      if (sessionId != null) {
        // Update the session with the generated ID
        final newSession = session.copyWith();
        
        // Add to instructor sessions list
        _instructorSessions.add(newSession);
        
        // Also add to all sessions if it's active
        if (newSession.isActive) {
          _sessions.add(newSession);
        }
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create session.');
        return false;
      }
    } catch (e) {
      _setError('Failed to create session: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates an existing session (instructor or admin only)
  Future<bool> updateSession(SessionModel session) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.updateSession(session);
      
      if (success) {
        // Update session in lists
        _updateSessionInLists(session);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update session.');
        return false;
      }
    } catch (e) {
      _setError('Failed to update session: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Deletes a session (admin only)
  Future<bool> deleteSession(String sessionId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.deleteSession(sessionId);
      
      if (success) {
        // Remove session from lists
        _sessions.removeWhere((s) => s.id == sessionId);
        _instructorSessions.removeWhere((s) => s.id == sessionId);
        _userSessions.removeWhere((s) => s.id == sessionId);
        
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete session.');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete session: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Books a session for the current user
  Future<bool> bookSession(String sessionId, String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.bookSession(sessionId, userId);
      
      if (success) {
        // Find the session in the list
        final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
        
        if (sessionIndex != -1) {
          // Update the session with the new participant
          final updatedSession = _sessions[sessionIndex];
          updatedSession.participantIds.add(userId);
          
          // Add to user sessions
          if (!_userSessions.any((s) => s.id == sessionId)) {
            _userSessions.add(updatedSession);
          }
          
          notifyListeners();
        }
        
        return true;
      } else {
        _setError('Failed to book session. Check if you have enough credits.');
        return false;
      }
    } catch (e) {
      _setError('Failed to book session: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Cancels a session booking for the current user
  Future<bool> cancelBooking(String sessionId, String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.cancelSessionBooking(sessionId, userId);
      
      if (success) {
        // Find the session in the lists
        final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
        
        if (sessionIndex != -1) {
          // Update the session by removing the participant
          final updatedSession = _sessions[sessionIndex];
          updatedSession.participantIds.remove(userId);
          
          // Remove from user sessions
          _userSessions.removeWhere((s) => s.id == sessionId);
          
          notifyListeners();
        }
        
        return true;
      } else {
        _setError('Failed to cancel booking.');
        return false;
      }
    } catch (e) {
      _setError('Failed to cancel booking: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refreshes all session data
  Future<void> refreshSessions(UserModel currentUser) async {
    try {
      _setLoading(true);
      _clearError();
      
      await loadSessions(currentUser);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh sessions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates a session in all lists
  void _updateSessionInLists(SessionModel updatedSession) {
    // Update in all sessions list
    final allSessionsIndex = _sessions.indexWhere((s) => s.id == updatedSession.id);
    if (allSessionsIndex != -1) {
      _sessions[allSessionsIndex] = updatedSession;
    } else if (updatedSession.isActive) {
      _sessions.add(updatedSession);
    }
    
    // Update in instructor sessions list
    final instructorSessionsIndex = _instructorSessions.indexWhere((s) => s.id == updatedSession.id);
    if (instructorSessionsIndex != -1) {
      _instructorSessions[instructorSessionsIndex] = updatedSession;
    }
    
    // Update in user sessions list if user is registered
    final userSessionsIndex = _userSessions.indexWhere((s) => s.id == updatedSession.id);
    if (userSessionsIndex != -1) {
      _userSessions[userSessionsIndex] = updatedSession;
    }
  }
  
  /// Sets the loading state and notifies listeners if changed
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// Sets an error message and notifies listeners
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  /// Clears any existing error message
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
  
  /// Clears all session data (used for sign out)
  void clear() {
    _sessions = [];
    _userSessions = [];
    _instructorSessions = [];
    _selectedSession = null;
    _isInitialized = false;
    _clearError();
    notifyListeners();
  }
  
  /// Sets the currently selected session for viewing details
  void setSelectedSession(SessionModel session) {
    _selectedSession = session;
    notifyListeners();
  }
  
  /// Checks if a user has booked a specific session
  bool hasUserBookedSession(String sessionId, String userId) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      return _sessions[sessionIndex].participantIds.contains(userId);
    }
    return false;
  }
  
  /// Clears the currently selected session
  void clearSelectedSession() {
    _selectedSession = null;
    notifyListeners();
  }
}