import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class SessionProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // Filters
  DateTime? _selectedDate;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _instructorIdFilter;
  SessionStatus? _statusFilter;
  bool _onlyUserSessions = false;
  String? _searchQuery;

  SessionProvider(this._firebaseService);

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<SessionModel> get sessions => _sessions;
  
  // Getters for filters
  DateTime? get selectedDate => _selectedDate;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String? get instructorIdFilter => _instructorIdFilter;
  SessionStatus? get statusFilter => _statusFilter;
  bool get onlyUserSessions => _onlyUserSessions;
  String? get searchQuery => _searchQuery;
  
  // Set filters
  void setFilters({
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
    String? instructorId,
    SessionStatus? status,
    bool? onlyUserSessions,
    String? query,
  }) {
    _selectedDate = selectedDate;
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    _instructorIdFilter = instructorId;
    _statusFilter = status;
    _onlyUserSessions = onlyUserSessions ?? _onlyUserSessions;
    _searchQuery = query;
    notifyListeners();
  }
  
  // Clear filters
  void clearFilters() {
    _selectedDate = null;
    _startDateFilter = null;
    _endDateFilter = null;
    _instructorIdFilter = null;
    _statusFilter = null;
    _onlyUserSessions = false;
    _searchQuery = null;
    notifyListeners();
  }
  
  // Get filtered sessions
  List<SessionModel> get filteredSessions {
    List<SessionModel> result = List.from(_sessions);
    
    // Filter by date range or selected date
    if (_selectedDate != null) {
      final day = _selectedDate!;
      final nextDay = day.add(const Duration(days: 1));
      
      result = result.where((session) => 
          (session.startTime.isAfter(day) || session.startTime.isAtSameMomentAs(day)) && 
          session.startTime.isBefore(nextDay)
      ).toList();
    } else if (_startDateFilter != null && _endDateFilter != null) {
      result = result.where((session) => 
          (session.startTime.isAfter(_startDateFilter!) || session.startTime.isAtSameMomentAs(_startDateFilter!)) && 
          session.startTime.isBefore(_endDateFilter!)
      ).toList();
    } else if (_startDateFilter != null) {
      result = result.where((session) => 
          session.startTime.isAfter(_startDateFilter!) || session.startTime.isAtSameMomentAs(_startDateFilter!)
      ).toList();
    } else if (_endDateFilter != null) {
      result = result.where((session) => 
          session.startTime.isBefore(_endDateFilter!)
      ).toList();
    }
    
    // Filter by instructor
    if (_instructorIdFilter != null) {
      result = result.where((session) => session.instructorId == _instructorIdFilter).toList();
    }
    
    // Filter by status
    if (_statusFilter != null) {
      result = result.where((session) => session.status == _statusFilter).toList();
    }
    
    // Filter by search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result.where((session) => 
          session.title.toLowerCase().contains(query) ||
          session.description.toLowerCase().contains(query) ||
          session.instructorName.toLowerCase().contains(query)
      ).toList();
    }
    
    return result;
  }
  
  // Get sessions for a specific day
  List<SessionModel> getSessionsForDay(DateTime day) {
    final nextDay = day.add(const Duration(days: 1));
    
    return _sessions.where((session) => 
        (session.startTime.isAfter(day) || session.startTime.isAtSameMomentAs(day)) && 
        session.startTime.isBefore(nextDay)
    ).toList();
  }
  
  // Get sessions for a specific week
  List<SessionModel> getSessionsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    return _sessions.where((session) => 
        (session.startTime.isAfter(weekStart) || session.startTime.isAtSameMomentAs(weekStart)) && 
        session.startTime.isBefore(weekEnd)
    ).toList();
  }
  
  // Get sessions for a specific month
  List<SessionModel> getSessionsForMonth(DateTime monthStart) {
    // Create a date for the 1st of next month
    final year = monthStart.month == 12 ? monthStart.year + 1 : monthStart.year;
    final month = monthStart.month == 12 ? 1 : monthStart.month + 1;
    final nextMonthStart = DateTime(year, month, 1);
    
    return _sessions.where((session) => 
        (session.startTime.isAfter(monthStart) || session.startTime.isAtSameMomentAs(monthStart)) && 
        session.startTime.isBefore(nextMonthStart)
    ).toList();
  }
  
  // Get sessions for the current week
  List<SessionModel> get currentWeekSessions {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1)); // Monday of current week
    
    return getSessionsForWeek(weekStart);
  }
  
  // Get sessions by user
  List<SessionModel> getSessionsByUser(String userId) {
    return _sessions.where((session) => session.participantIds.contains(userId)).toList();
  }
  
  // Get sessions by instructor
  List<SessionModel> getSessionsByInstructor(String instructorId) {
    return _sessions.where((session) => session.instructorId == instructorId).toList();
  }
  
  // Get upcoming sessions
  List<SessionModel> get upcomingSessions {
    return _sessions.where((session) => session.status == SessionStatus.upcoming).toList();
  }
  
  // Get ongoing sessions
  List<SessionModel> get ongoingSessions {
    return _sessions.where((session) => session.status == SessionStatus.ongoing).toList();
  }
  
  // Get completed sessions
  List<SessionModel> get completedSessions {
    return _sessions.where((session) => session.status == SessionStatus.completed).toList();
  }
  
  // Get cancelled sessions
  List<SessionModel> get cancelledSessions {
    return _sessions.where((session) => session.status == SessionStatus.cancelled).toList();
  }
  
  // Get recurring sessions
  List<SessionModel> get recurringSessions {
    return _sessions.where((session) => session.isRecurring).toList();
  }
  
  // Get sessions linked to a parent recurring session
  List<SessionModel> getRecurringSessionInstances(String parentSessionId) {
    return _sessions.where((session) => 
        session.parentRecurringSessionId == parentSessionId
    ).toList();
  }
  
  // Get session by ID
  SessionModel? getSessionById(String id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Check for conflicts
  List<SessionModel> checkForConflicts(SessionModel newSession) {
    return _sessions.where((session) => newSession.hasConflict(session)).toList();
  }
  
  // Load all sessions
  Future<void> loadSessions({UserModel? user}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch sessions from Firestore
      final sessionsRef = _firebaseService.firestore.collection('sessions');
      QuerySnapshot sessionsSnapshot;
      
      // Default query - get sessions for current month and future
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);
      
      // Query for sessions within the relevant time frame
      sessionsSnapshot = await sessionsRef
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(currentMonthStart))
          .orderBy('startTime')
          .get();
      
      _sessions = sessionsSnapshot.docs
          .map((doc) => SessionModel.fromFirestore(doc))
          .toList();
      
      // Update session statuses based on current time
      _updateSessionStatuses();
      
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load sessions: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Update session statuses based on current time
  void _updateSessionStatuses() {
    final now = DateTime.now();
    List<SessionModel> updatedSessions = [];
    bool hasChanges = false;
    
    for (var session in _sessions) {
      if (session.status == SessionStatus.upcoming) {
        // Check if session should be marked as ongoing
        if (session.startTime.isBefore(now) && session.endTime.isAfter(now)) {
          updatedSessions.add(session.copyWith(status: SessionStatus.ongoing));
          hasChanges = true;
        }
        // Check if session should be marked as completed
        else if (session.endTime.isBefore(now)) {
          updatedSessions.add(session.copyWith(status: SessionStatus.completed));
          hasChanges = true;
        } else {
          updatedSessions.add(session);
        }
      } else if (session.status == SessionStatus.ongoing && session.endTime.isBefore(now)) {
        // Mark ongoing sessions as completed if they've ended
        updatedSessions.add(session.copyWith(status: SessionStatus.completed));
        hasChanges = true;
      } else {
        updatedSessions.add(session);
      }
    }
    
    if (hasChanges) {
      _sessions = updatedSessions;
      // Here we would also update the status in Firestore
      // This is omitted for simplicity but would be implemented in a real app
    }
  }
  
  // Create a new session
  Future<bool> createSession(SessionModel session) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Add to Firestore
      final docRef = await _firebaseService.firestore
          .collection('sessions')
          .add(session.toFirestore());
      
      // Add to local list with generated ID
      final newSession = session.copyWith(id: docRef.id);
      _sessions.add(newSession);
      
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
  
  // Create recurring sessions
  Future<bool> createRecurringSessions({
    required String title,
    required String description,
    required String instructorId,
    required String instructorName,
    required DateTime startDate,
    required int durationMinutes,
    required int maxParticipants,
    required int creditCost,
    required String recurringRule,
    String? location,
    required int numberOfOccurrences,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Generate parent session ID
      final String parentId = const Uuid().v4();
      
      // Create parent session
      final parentSession = SessionModel(
        id: parentId,
        title: title,
        description: description,
        instructorId: instructorId,
        instructorName: instructorName,
        startTime: startDate,
        durationMinutes: durationMinutes,
        maxParticipants: maxParticipants,
        participantIds: const [],
        creditCost: creditCost,
        isRecurring: true,
        recurringRule: recurringRule,
        location: location,
        status: SessionStatus.upcoming,
        createdAt: DateTime.now(),
      );
      
      // Add parent session to Firestore
      await _firebaseService.firestore
          .collection('sessions')
          .doc(parentId)
          .set(parentSession.toFirestore());
      
      // Add parent session to local list
      _sessions.add(parentSession);
      
      // Generate recurring instances
      List<SessionModel> recurringInstances = _generateRecurringInstances(
        parentSession: parentSession,
        numberOfOccurrences: numberOfOccurrences,
      );
      
      // Add recurring instances to Firestore
      for (var instance in recurringInstances) {
        final docRef = await _firebaseService.firestore
            .collection('sessions')
            .add(instance.toFirestore());
        
        // Add to local list with generated ID
        _sessions.add(instance.copyWith(id: docRef.id));
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create recurring sessions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Generate recurring instances based on parent session and rule
  List<SessionModel> _generateRecurringInstances({
    required SessionModel parentSession,
    required int numberOfOccurrences,
  }) {
    List<SessionModel> instances = [];
    final rule = parentSession.recurringRule;
    
    if (rule == null || rule.isEmpty) {
      return instances;
    }
    
    // Parse the RRULE format
    Map<String, String> ruleMap = {};
    for (var part in rule.split(';')) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        ruleMap[keyValue[0]] = keyValue[1];
      }
    }
    
    final freq = ruleMap['FREQ'];
    final byDay = ruleMap['BYDAY']?.split(',');
    
    if (freq == null) {
      return instances;
    }
    
    // Map of weekday abbreviations to day of week numbers
    const weekdayMap = {
      'MO': 1, // Monday
      'TU': 2,
      'WE': 3,
      'TH': 4,
      'FR': 5,
      'SA': 6,
      'SU': 7,
    };
    
    DateTime nextDate = parentSession.startTime.add(const Duration(days: 1));
    
    while (instances.length < numberOfOccurrences) {
      bool includeDate = false;
      
      switch (freq) {
        case 'DAILY':
          includeDate = true;
          break;
        case 'WEEKLY':
          if (byDay != null && byDay.isNotEmpty) {
            final weekday = nextDate.weekday;
            includeDate = byDay.any((day) => weekdayMap[day] == weekday);
          } else {
            // If no BYDAY specified, include same day of week as parent
            includeDate = nextDate.weekday == parentSession.startTime.weekday;
          }
          break;
        case 'MONTHLY':
          // Same day of month as parent
          includeDate = nextDate.day == parentSession.startTime.day;
          break;
        case 'YEARLY':
          // Same day and month as parent
          includeDate = nextDate.day == parentSession.startTime.day && 
                       nextDate.month == parentSession.startTime.month;
          break;
      }
      
      if (includeDate) {
        // Create new instance with same time of day
        final DateTime instanceDate = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
          parentSession.startTime.hour,
          parentSession.startTime.minute,
        );
        
        instances.add(SessionModel(
          id: const Uuid().v4(), // Temporary ID, will be replaced when saved to Firestore
          title: parentSession.title,
          description: parentSession.description,
          instructorId: parentSession.instructorId,
          instructorName: parentSession.instructorName,
          startTime: instanceDate,
          durationMinutes: parentSession.durationMinutes,
          maxParticipants: parentSession.maxParticipants,
          participantIds: const [],
          creditCost: parentSession.creditCost,
          isRecurring: false,
          parentRecurringSessionId: parentSession.id,
          location: parentSession.location,
          status: SessionStatus.upcoming,
          createdAt: DateTime.now(),
        ));
      }
      
      nextDate = nextDate.add(const Duration(days: 1));
    }
    
    return instances;
  }
  
  // Update an existing session
  Future<bool> updateSession(SessionModel updatedSession) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Update in Firestore
      await _firebaseService.firestore
          .collection('sessions')
          .doc(updatedSession.id)
          .update(updatedSession.toFirestore());
      
      // Update in local list
      final index = _sessions.indexWhere((s) => s.id == updatedSession.id);
      if (index != -1) {
        _sessions[index] = updatedSession;
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
  
  // Update all instances of a recurring session
  Future<bool> updateAllRecurringInstances(String parentSessionId, {
    String? title,
    String? description,
    int? durationMinutes,
    int? maxParticipants,
    int? creditCost,
    String? location,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get parent session
      final parentSession = getSessionById(parentSessionId);
      if (parentSession == null) {
        throw Exception('Parent session not found');
      }
      
      // Update parent session first
      SessionModel updatedParent = parentSession.copyWith(
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        maxParticipants: maxParticipants,
        creditCost: creditCost,
        location: location,
        updatedAt: DateTime.now(),
      );
      
      await updateSession(updatedParent);
      
      // Get all child instances
      final childInstances = getRecurringSessionInstances(parentSessionId);
      
      // Update each child instance
      for (var instance in childInstances) {
        // Only update upcoming instances
        if (instance.status == SessionStatus.upcoming) {
          SessionModel updatedInstance = instance.copyWith(
            title: title,
            description: description,
            durationMinutes: durationMinutes,
            maxParticipants: maxParticipants,
            creditCost: creditCost,
            location: location,
            updatedAt: DateTime.now(),
          );
          
          await updateSession(updatedInstance);
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update recurring sessions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Cancel a session
  Future<bool> cancelSession(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the session
      final session = getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      // Update status to cancelled
      final cancelledSession = session.copyWith(
        status: SessionStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      
      return await updateSession(cancelledSession);
    } catch (e) {
      _error = 'Failed to cancel session: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Cancel all instances of a recurring session
  Future<bool> cancelAllRecurringInstances(String parentSessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get parent session
      final parentSession = getSessionById(parentSessionId);
      if (parentSession == null) {
        throw Exception('Parent session not found');
      }
      
      // Cancel parent session first
      await cancelSession(parentSessionId);
      
      // Get all child instances
      final childInstances = getRecurringSessionInstances(parentSessionId);
      
      // Cancel each upcoming child instance
      for (var instance in childInstances) {
        if (instance.status == SessionStatus.upcoming) {
          await cancelSession(instance.id);
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to cancel recurring sessions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Book a session for a user
  Future<bool> bookSession({
    required String sessionId,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the session
      final session = getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      // Check if user can book
      if (!session.canUserBook(userId)) {
        throw Exception('Cannot book this session (full or already booked)');
      }
      
      // Add user to participants
      List<String> updatedParticipants = List.from(session.participantIds);
      updatedParticipants.add(userId);
      
      // Update session
      final updatedSession = session.copyWith(
        participantIds: updatedParticipants,
        updatedAt: DateTime.now(),
      );
      
      return await updateSession(updatedSession);
    } catch (e) {
      _error = 'Failed to book session: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Cancel a booking
  Future<bool> cancelBooking({
    required String sessionId,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the session
      final session = getSessionById(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }
      
      // Check if user can cancel
      if (!session.canUserCancel(userId)) {
        throw Exception('Cannot cancel this booking');
      }
      
      // Remove user from participants
      List<String> updatedParticipants = List.from(session.participantIds);
      updatedParticipants.remove(userId);
      
      // Update session
      final updatedSession = session.copyWith(
        participantIds: updatedParticipants,
        updatedAt: DateTime.now(),
      );
      
      return await updateSession(updatedSession);
    } catch (e) {
      _error = 'Failed to cancel booking: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Refresh sessions data
  Future<void> refreshSessions() async {
    return loadSessions();
  }
  
  // Clear all data (used during logout)
  void clear() {
    _sessions = [];
    _isInitialized = false;
    _error = null;
    clearFilters();
    notifyListeners();
  }
}