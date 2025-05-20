import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/tutorial_model_revised.dart';
import 'package:fitsaga/services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  List<TutorialModel> _tutorials = [];
  List<TutorialProgressModel> _userProgress = [];
  
  // Filtering state
  String? _searchQuery;
  TutorialDifficulty? _difficultyFilter;
  TutorialCategory? _categoryFilter;
  bool _onlyPublished = true;
  
  TutorialProvider(this._firebaseService);
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  
  List<TutorialModel> get allTutorials => [..._tutorials];
  
  List<TutorialModel> get popularTutorials => _tutorials
      .where((tutorial) => tutorial.isPublished)
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  // Filter getters
  String? get searchQuery => _searchQuery;
  TutorialDifficulty? get difficultyFilter => _difficultyFilter;
  TutorialCategory? get categoryFilter => _categoryFilter;
  bool get onlyPublished => _onlyPublished;
  
  bool get hasActiveFilters => 
      _searchQuery != null || 
      _difficultyFilter != null || 
      _categoryFilter != null;
  
  // Filtered tutorials based on current filters
  List<TutorialModel> get filteredTutorials {
    List<TutorialModel> result = _tutorials
        .where((tutorial) => !_onlyPublished || tutorial.isPublished)
        .toList();
    
    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result.where((tutorial) {
        return tutorial.title.toLowerCase().contains(query) ||
               tutorial.description.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply difficulty filter
    if (_difficultyFilter != null) {
      result = result.where((tutorial) {
        return tutorial.difficulty == _difficultyFilter;
      }).toList();
    }
    
    // Apply category filter
    if (_categoryFilter != null) {
      result = result.where((tutorial) {
        return tutorial.category == _categoryFilter;
      }).toList();
    }
    
    return result;
  }
  
  // Set filters
  void setFilters({
    String? query,
    TutorialDifficulty? difficulty,
    TutorialCategory? category,
    bool? onlyPublished,
  }) {
    bool shouldNotify = false;
    
    if (query != null && query != _searchQuery) {
      _searchQuery = query.isEmpty ? null : query;
      shouldNotify = true;
    }
    
    if (difficulty != _difficultyFilter) {
      _difficultyFilter = difficulty;
      shouldNotify = true;
    }
    
    if (category != _categoryFilter) {
      _categoryFilter = category;
      shouldNotify = true;
    }
    
    if (onlyPublished != null && onlyPublished != _onlyPublished) {
      _onlyPublished = onlyPublished;
      shouldNotify = true;
    }
    
    if (shouldNotify) {
      notifyListeners();
    }
  }
  
  // Clear all filters
  void clearFilters() {
    _searchQuery = null;
    _difficultyFilter = null;
    _categoryFilter = null;
    _onlyPublished = true;
    notifyListeners();
  }
  
  // Load tutorials from Firebase
  Future<void> loadTutorials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final tutorialsSnapshot = await _firebaseService.firestore
          .collection('tutorials')
          .get();
      
      _tutorials = tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
      
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to load tutorials: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load tutorials by category
  Future<List<TutorialModel>> loadTutorialsByCategory(TutorialCategory category) async {
    try {
      final tutorialsSnapshot = await _firebaseService.firestore
          .collection('tutorials')
          .where('category', isEqualTo: category == TutorialCategory.exercise ? 'exercise' : 'nutrition')
          .get();
      
      return tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to load tutorials by category: ${e.toString()}';
      print(_error);
      return [];
    }
  }
  
  // Load user progress
  Future<void> loadUserProgress(String userId) async {
    try {
      final progressSnapshot = await _firebaseService.firestore
          .collection('userProgress')
          .where('userId', isEqualTo: userId)
          .get();
      
      _userProgress = progressSnapshot.docs
          .map((doc) => TutorialProgressModel.fromJson(doc.data()))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user progress: ${e.toString()}';
      print(_error);
    }
  }
  
  // Update tutorial progress
  Future<bool> updateTutorialProgress({
    required String userId,
    required String tutorialId,
    required double progress,
    bool isCompleted = false,
    List<String>? completedExercises,
    List<int>? completedDays,
  }) async {
    try {
      // Check if progress exists
      final existingProgressIndex = _userProgress.indexWhere(
        (p) => p.userId == userId && p.tutorialId == tutorialId,
      );
      
      final now = DateTime.now();
      
      if (existingProgressIndex >= 0) {
        // Update existing progress
        final existingProgress = _userProgress[existingProgressIndex];
        
        final newCompletedExercises = completedExercises != null
            ? [...existingProgress.completedExercises, ...completedExercises]
            : existingProgress.completedExercises;
            
        final newCompletedDays = completedDays != null
            ? [...existingProgress.completedDays, ...completedDays]
            : existingProgress.completedDays;
        
        // Remove duplicates
        final uniqueExercises = newCompletedExercises.toSet().toList();
        final uniqueDays = newCompletedDays.toSet().toList();
        
        final updatedProgress = existingProgress.copyWith(
          progress: progress,
          isCompleted: isCompleted || existingProgress.isCompleted,
          completedExercises: uniqueExercises,
          completedDays: uniqueDays,
          lastAccessedAt: now,
        );
        
        _userProgress[existingProgressIndex] = updatedProgress;
        
        // Update in Firebase
        await _firebaseService.firestore
            .collection('userProgress')
            .doc('${userId}_${tutorialId}')
            .set(updatedProgress.toJson());
      } else {
        // Create new progress
        final newProgress = TutorialProgressModel(
          userId: userId,
          tutorialId: tutorialId,
          progress: progress,
          isCompleted: isCompleted,
          completedExercises: completedExercises ?? [],
          completedDays: completedDays ?? [],
          lastAccessedAt: now,
        );
        
        _userProgress.add(newProgress);
        
        // Create in Firebase
        await _firebaseService.firestore
            .collection('userProgress')
            .doc('${userId}_${tutorialId}')
            .set(newProgress.toJson());
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update progress: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Get tutorial by ID
  TutorialModel? getTutorialById(String id) {
    try {
      return _tutorials.firstWhere((tutorial) => tutorial.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get progress for a specific tutorial
  TutorialProgressModel? getProgressForTutorial(String tutorialId) {
    try {
      return _userProgress.firstWhere(
        (progress) => progress.tutorialId == tutorialId,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Get in-progress tutorials for a user
  List<TutorialModel> getInProgressTutorials() {
    final inProgressIds = _userProgress
        .where((progress) => progress.progress > 0 && !progress.isCompleted)
        .map((progress) => progress.tutorialId)
        .toList();
    
    return _tutorials
        .where((tutorial) => inProgressIds.contains(tutorial.id))
        .toList()
      ..sort((a, b) {
        // Sort by most recently accessed
        final progressA = getProgressForTutorial(a.id);
        final progressB = getProgressForTutorial(b.id);
        
        if (progressA == null || progressB == null) return 0;
        return progressB.lastAccessedAt.compareTo(progressA.lastAccessedAt);
      });
  }
  
  // Get completed tutorials for a user
  List<TutorialModel> getCompletedTutorials() {
    final completedIds = _userProgress
        .where((progress) => progress.isCompleted)
        .map((progress) => progress.tutorialId)
        .toList();
    
    return _tutorials
        .where((tutorial) => completedIds.contains(tutorial.id))
        .toList()
      ..sort((a, b) {
        // Sort by most recently completed
        final progressA = getProgressForTutorial(a.id);
        final progressB = getProgressForTutorial(b.id);
        
        if (progressA == null || progressB == null) return 0;
        return progressB.lastAccessedAt.compareTo(progressA.lastAccessedAt);
      });
  }
  
  // Get recommended tutorials based on user history
  List<TutorialModel> getRecommendedTutorials() {
    // If no progress, return popular tutorials
    if (_userProgress.isEmpty) {
      return popularTutorials.take(5).toList();
    }
    
    // Find categories the user has engaged with
    final completedTutorialIds = getCompletedTutorials().map((t) => t.id).toList();
    final userCategories = <TutorialCategory>{};
    
    for (final tutorial in _tutorials) {
      if (completedTutorialIds.contains(tutorial.id)) {
        userCategories.add(tutorial.category);
      }
    }
    
    // Get tutorials in those categories user hasn't completed
    final recommendedTutorials = _tutorials
        .where((tutorial) => 
            tutorial.isPublished && 
            !completedTutorialIds.contains(tutorial.id) &&
            userCategories.contains(tutorial.category))
        .toList();
    
    // Sort by creation date (newest first)
    recommendedTutorials.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Return top 5
    return recommendedTutorials.take(5).toList();
  }
  
  // Rate a tutorial
  Future<bool> rateTutorial({
    required String userId,
    required String tutorialId,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) {
      _error = 'Invalid rating value. Must be between 1 and 5.';
      return false;
    }
    
    try {
      // Get the progress
      final userProgressDoc = await _firebaseService.firestore
          .collection('userProgress')
          .doc('${userId}_${tutorialId}')
          .get();
      
      if (userProgressDoc.exists) {
        await _firebaseService.firestore
            .collection('userProgress')
            .doc('${userId}_${tutorialId}')
            .update({
              'userRating': rating,
              'lastAccessedAt': FieldValue.serverTimestamp(),
            });
        
        // Update local progress
        final index = _userProgress.indexWhere(
          (p) => p.userId == userId && p.tutorialId == tutorialId,
        );
        
        if (index >= 0) {
          _userProgress[index] = _userProgress[index].copyWith(
            userRating: rating,
            lastAccessedAt: DateTime.now(),
          );
        }
      } else {
        // Create new progress entry
        final newProgress = TutorialProgressModel(
          userId: userId,
          tutorialId: tutorialId,
          progress: 0.0,
          isCompleted: false,
          userRating: rating,
          completedExercises: [],
          completedDays: [],
          lastAccessedAt: DateTime.now(),
        );
        
        await _firebaseService.firestore
            .collection('userProgress')
            .doc('${userId}_${tutorialId}')
            .set(newProgress.toJson());
            
        _userProgress.add(newProgress);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to rate tutorial: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Mark a day as completed
  Future<bool> markDayAsCompleted({
    required String userId,
    required String tutorialId,
    required int dayNumber,
  }) async {
    try {
      // Get existing progress
      final progress = getProgressForTutorial(tutorialId);
      
      if (progress == null) {
        // Create new progress with this day completed
        return await updateTutorialProgress(
          userId: userId,
          tutorialId: tutorialId,
          progress: 0.1, // Start with minimal progress
          completedDays: [dayNumber],
        );
      } else {
        // Update existing progress
        if (!progress.completedDays.contains(dayNumber)) {
          final newCompletedDays = [...progress.completedDays, dayNumber];
          
          // Get total days for this tutorial
          final tutorial = getTutorialById(tutorialId);
          if (tutorial == null) return false;
          
          final totalDays = tutorial.days.length;
          
          // Calculate progress as percentage of completed days
          double newProgress = totalDays > 0 
              ? newCompletedDays.length / totalDays 
              : progress.progress;
          
          // If all days completed, mark as complete
          bool isComplete = totalDays > 0 && newCompletedDays.length >= totalDays;
          
          return await updateTutorialProgress(
            userId: userId,
            tutorialId: tutorialId,
            progress: newProgress,
            isCompleted: isComplete,
            completedDays: [dayNumber],
          );
        }
        
        return true; // Already marked as completed
      }
    } catch (e) {
      _error = 'Failed to mark day as completed: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Mark an exercise as completed
  Future<bool> markExerciseAsCompleted({
    required String userId,
    required String tutorialId,
    required String exerciseId,
  }) async {
    try {
      // Get existing progress
      final progress = getProgressForTutorial(tutorialId);
      
      if (progress == null) {
        // Create new progress with this exercise completed
        return await updateTutorialProgress(
          userId: userId,
          tutorialId: tutorialId,
          progress: 0.05, // Start with minimal progress
          completedExercises: [exerciseId],
        );
      } else {
        // Update existing progress
        if (!progress.completedExercises.contains(exerciseId)) {
          // Get total exercises for this tutorial
          final tutorial = getTutorialById(tutorialId);
          if (tutorial == null) return false;
          
          int totalExercises = 0;
          for (final day in tutorial.days) {
            totalExercises += day.exercises.length;
          }
          
          final newCompletedExercises = [...progress.completedExercises, exerciseId];
          
          // Calculate progress as percentage of completed exercises
          double newProgress = totalExercises > 0 
              ? newCompletedExercises.length / totalExercises 
              : progress.progress;
          
          return await updateTutorialProgress(
            userId: userId,
            tutorialId: tutorialId,
            progress: newProgress,
            completedExercises: [exerciseId],
          );
        }
        
        return true; // Already marked as completed
      }
    } catch (e) {
      _error = 'Failed to mark exercise as completed: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Check if a day is completed
  bool isDayCompleted({
    required String tutorialId,
    required int dayNumber,
  }) {
    final progress = getProgressForTutorial(tutorialId);
    if (progress == null) {
      return false;
    }
    
    return progress.completedDays.contains(dayNumber);
  }
  
  // Check if an exercise is completed
  bool isExerciseCompleted({
    required String tutorialId,
    required String exerciseId,
  }) {
    final progress = getProgressForTutorial(tutorialId);
    if (progress == null) {
      return false;
    }
    
    return progress.completedExercises.contains(exerciseId);
  }
  
  // Get day by index
  TutorialDay? getDayByNumber({
    required String tutorialId,
    required int dayNumber,
  }) {
    final tutorial = getTutorialById(tutorialId);
    if (tutorial == null) return null;
    
    try {
      return tutorial.days.firstWhere((day) => day.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }
  
  // Get exercise by ID
  TutorialExercise? getExerciseById({
    required String tutorialId,
    required String exerciseId,
  }) {
    final tutorial = getTutorialById(tutorialId);
    if (tutorial == null) return null;
    
    for (final day in tutorial.days) {
      try {
        return day.exercises.firstWhere((exercise) => exercise.id == exerciseId);
      } catch (e) {
        // Continue to next day
      }
    }
    
    return null;
  }
}