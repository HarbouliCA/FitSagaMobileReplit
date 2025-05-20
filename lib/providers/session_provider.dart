import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

class SessionProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  
  SessionProvider(this._firebaseService);
  
  bool _loading = false;
  String? _error;
  List<SessionModel> _sessions = [];
  List<SessionModel> _bookedSessions = [];
  SessionModel? _selectedSession;
  
  // Filters
  String? _activityTypeFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool _showOnlyAvailable = true;
  
  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<SessionModel> get sessions => _sessions;
  List<SessionModel> get bookedSessions => _bookedSessions;
  SessionModel? get selectedSession => _selectedSession;
  
  // Filter getters
  String? get activityTypeFilter => _activityTypeFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  bool get showOnlyAvailable => _showOnlyAvailable;

  // Computed lists
  List<SessionModel> get upcomingSessions => 
      _sessions.where((session) => session.isUpcoming).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  
  List<SessionModel> get pastSessions => 
      _sessions.where((session) => session.isPast).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Newest first
  
  List<SessionModel> get inProgressSessions => 
      _sessions.where((session) => session.isInProgress).toList();
  
  // Filtered sessions
  List<SessionModel> get filteredSessions {
    return _sessions.where((session) {
      // Apply activity type filter
      if (_activityTypeFilter != null && session.activityType != _activityTypeFilter) {
        return false;
      }
      
      // Apply date range filter
      if (_startDateFilter != null && session.startTime.isBefore(_startDateFilter!)) {
        return false;
      }
      
      if (_endDateFilter != null && session.startTime.isAfter(_endDateFilter!)) {
        return false;
      }
      
      // Apply availability filter
      if (_showOnlyAvailable && (!session.isActive || session.isFull)) {
        return false;
      }
      
      return true;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  // Methods
  Future<void> fetchSessions() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      _sessions = await _firebaseService.getSessions(
        startDate: _startDateFilter,
        endDate: _endDateFilter,
        activityType: _activityTypeFilter,
        onlyAvailable: _showOnlyAvailable,
      );
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> fetchBookedSessions(String userId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      _bookedSessions = await _firebaseService.getUserBookedSessions(userId);
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> fetchSessionById(String sessionId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final session = await _firebaseService.getSessionById(sessionId);
      _selectedSession = session;
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> hasUserBookedSession(String sessionId) async {
    try {
      if (_selectedSession == null) {
        return false;
      }
      
      final userId = await _getCurrentUserId();
      return await _firebaseService.hasUserBookedSession(userId, sessionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> bookSession(String sessionId, int creditsUsed) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final userId = await _getCurrentUserId();
      
      // Book the session
      await _firebaseService.bookSession(userId, sessionId, creditsUsed);
      
      // Refresh booked sessions
      await fetchBookedSessions(userId);
      
      // If the booked session is the selected session, refresh it
      if (_selectedSession != null && _selectedSession!.id == sessionId) {
        await fetchSessionById(sessionId);
      }
      
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      await _firebaseService.cancelBooking(bookingId, reason);
      
      // Refresh booked sessions
      final userId = await _getCurrentUserId();
      await fetchBookedSessions(userId);
      
      // If a session is selected, refresh it
      if (_selectedSession != null) {
        await fetchSessionById(_selectedSession!.id);
      }
      
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Filter methods
  void setActivityTypeFilter(String? activityType) {
    _activityTypeFilter = activityType;
    notifyListeners();
    fetchSessions();
  }
  
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    notifyListeners();
    fetchSessions();
  }
  
  void setShowOnlyAvailable(bool show) {
    _showOnlyAvailable = show;
    notifyListeners();
    fetchSessions();
  }
  
  void clearFilters() {
    _activityTypeFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _showOnlyAvailable = true;
    notifyListeners();
    fetchSessions();
  }
  
  // Session selection
  void selectSession(SessionModel session) {
    _selectedSession = session;
    notifyListeners();
  }
  
  void clearSelectedSession() {
    _selectedSession = null;
    notifyListeners();
  }
  
  Future<String> _getCurrentUserId() async {
    // This should be implemented to get the current user ID
    // For now, returning a placeholder
    return 'user123';
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}