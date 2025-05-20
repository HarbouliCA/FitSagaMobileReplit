import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

/// Provider for handling tutorials and user progress
class TutorialProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  List<TutorialModel> _tutorials = [];
  Map<String, TutorialProgressModel> _userProgress = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // Filters
  TutorialDifficulty? _difficultyFilter;
  TutorialCategory? _categoryFilter;
  bool _onlyFavorites = false;
  bool _onlyPremium = false;
  String? _searchQuery;
  
  TutorialProvider(this._firebaseService);
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<TutorialModel> get tutorials => _tutorials;
  Map<String, TutorialProgressModel> get userProgress => _userProgress;
  
  // Filter getters
  TutorialDifficulty? get difficultyFilter => _difficultyFilter;
  TutorialCategory? get categoryFilter => _categoryFilter;
  bool get onlyFavorites => _onlyFavorites;
  bool get onlyPremium => _onlyPremium;
  String? get searchQuery => _searchQuery;
  
  // Set filters
  void setFilters({
    TutorialDifficulty? difficulty,
    TutorialCategory? category,
    bool? favorites,
    bool? premium,
    String? query,
  }) {
    _difficultyFilter = difficulty;
    _categoryFilter = category;
    _onlyFavorites = favorites ?? _onlyFavorites;
    _onlyPremium = premium ?? _onlyPremium;
    _searchQuery = query;
    notifyListeners();
  }
  
  // Clear filters
  void clearFilters() {
    _difficultyFilter = null;
    _categoryFilter = null;
    _onlyFavorites = false;
    _onlyPremium = false;
    _searchQuery = null;
    notifyListeners();
  }
  
  // Get filtered tutorials
  List<TutorialModel> get filteredTutorials {
    List<TutorialModel> result = List.from(_tutorials);
    
    // Filter by difficulty
    if (_difficultyFilter != null) {
      result = result.where((tutorial) => tutorial.difficulty == _difficultyFilter).toList();
    }
    
    // Filter by category
    if (_categoryFilter != null) {
      result = result.where((tutorial) => tutorial.categories.contains(_categoryFilter)).toList();
    }
    
    // Filter by premium status
    if (_onlyPremium) {
      result = result.where((tutorial) => tutorial.isPremium).toList();
    }
    
    // Filter by search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result.where((tutorial) => 
        tutorial.title.toLowerCase().contains(query) ||
        tutorial.description.toLowerCase().contains(query) ||
        tutorial.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }
    
    // Sort by rating and then by creation date
    result.sort((a, b) {
      int ratingCompare = b.averageRating.compareTo(a.averageRating);
      if (ratingCompare != 0) return ratingCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return result;
  }
  
  // Get popular tutorials (highest rated)
  List<TutorialModel> get popularTutorials {
    final tutorials = List<TutorialModel>.from(_tutorials);
    tutorials.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return tutorials.take(10).toList();
  }
  
  // Get latest tutorials
  List<TutorialModel> get latestTutorials {
    final tutorials = List<TutorialModel>.from(_tutorials);
    tutorials.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tutorials.take(10).toList();
  }
  
  // Get tutorials by category
  List<TutorialModel> getTutorialsByCategory(TutorialCategory category) {
    return _tutorials.where((tutorial) => tutorial.categories.contains(category)).toList();
  }
  
  // Get tutorials by difficulty
  List<TutorialModel> getTutorialsByDifficulty(TutorialDifficulty difficulty) {
    return _tutorials.where((tutorial) => tutorial.difficulty == difficulty).toList();
  }
  
  // Get tutorial by ID
  TutorialModel? getTutorialById(String id) {
    try {
      return _tutorials.firstWhere((tutorial) => tutorial.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get user progress for tutorial
  TutorialProgressModel? getProgressForTutorial(String tutorialId) {
    return _userProgress[tutorialId];
  }
  
  // Get completed tutorials for a user
  List<TutorialModel> getCompletedTutorials() {
    final completedIds = _userProgress.values
        .where((progress) => progress.isCompleted)
        .map((progress) => progress.tutorialId)
        .toSet();
    
    return _tutorials.where((tutorial) => completedIds.contains(tutorial.id)).toList();
  }
  
  // Get in-progress tutorials for a user
  List<TutorialModel> getInProgressTutorials() {
    final inProgressIds = _userProgress.values
        .where((progress) => !progress.isCompleted && progress.progress > 0)
        .map((progress) => progress.tutorialId)
        .toSet();
    
    return _tutorials.where((tutorial) => inProgressIds.contains(tutorial.id)).toList();
  }
  
  // Recommended tutorials based on user progress and preferences
  List<TutorialModel> getRecommendedTutorials() {
    // If no user progress, return popular tutorials
    if (_userProgress.isEmpty) {
      return popularTutorials;
    }
    
    // Get completed tutorials
    final completedTutorials = getCompletedTutorials();
    if (completedTutorials.isEmpty) {
      // If no completed tutorials, recommend beginner tutorials
      return _tutorials
          .where((t) => t.difficulty == TutorialDifficulty.beginner)
          .take(5)
          .toList();
    }
    
    // Find common categories in completed tutorials
    final Map<TutorialCategory, int> categoryCount = {};
    for (final tutorial in completedTutorials) {
      for (final category in tutorial.categories) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }
    
    // Get most common categories
    final preferredCategories = categoryCount.entries
        .sortedBy<num>((entry) => -entry.value)
        .take(2)
        .map((e) => e.key)
        .toList();
    
    // Find user's highest completed difficulty
    TutorialDifficulty highestDifficulty = TutorialDifficulty.beginner;
    for (final tutorial in completedTutorials) {
      if (tutorial.difficulty.index > highestDifficulty.index) {
        highestDifficulty = tutorial.difficulty;
      }
    }
    
    // Get next difficulty level if available
    final nextDifficulty = highestDifficulty.index < TutorialDifficulty.values.length - 1
        ? TutorialDifficulty.values[highestDifficulty.index + 1]
        : highestDifficulty;
    
    // Find tutorials in preferred categories and appropriate difficulty
    // that the user hasn't completed yet
    final completedIds = completedTutorials.map((t) => t.id).toSet();
    final recommendedTutorials = _tutorials.where((tutorial) =>
      !completedIds.contains(tutorial.id) &&
      (tutorial.difficulty == highestDifficulty || tutorial.difficulty == nextDifficulty) &&
      tutorial.categories.any((c) => preferredCategories.contains(c))
    ).toList();
    
    // Sort by matches with preferred categories
    recommendedTutorials.sort((a, b) {
      final aMatches = a.categories.where((c) => preferredCategories.contains(c)).length;
      final bMatches = b.categories.where((c) => preferredCategories.contains(c)).length;
      return bMatches.compareTo(aMatches);
    });
    
    return recommendedTutorials.take(10).toList();
  }
  
  // Load all tutorials
  Future<void> loadTutorials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final QuerySnapshot tutorialsSnapshot = await _firebaseService.firestore
          .collection('tutorials')
          .where('isPublished', isEqualTo: true)
          .get();
      
      _tutorials = tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
      
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tutorials: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Load user progress for tutorials
  Future<void> loadUserProgress(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final QuerySnapshot progressSnapshot = await _firebaseService.firestore
          .collection('tutorialProgress')
          .where('userId', isEqualTo: userId)
          .get();
      
      _userProgress = {};
      for (final doc in progressSnapshot.docs) {
        final progress = TutorialProgressModel.fromFirestore(doc);
        _userProgress[progress.tutorialId] = progress;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user progress: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Update user progress for a tutorial
  Future<bool> updateTutorialProgress({
    required String userId,
    required String tutorialId,
    required double progress,
    bool? isCompleted,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get existing progress or create new
      final existingProgressDoc = await _firebaseService.firestore
          .collection('tutorialProgress')
          .where('userId', isEqualTo: userId)
          .where('tutorialId', isEqualTo: tutorialId)
          .limit(1)
          .get();
      
      final now = DateTime.now();
      
      if (existingProgressDoc.docs.isNotEmpty) {
        // Update existing progress
        final docId = existingProgressDoc.docs.first.id;
        final existingProgress = TutorialProgressModel.fromFirestore(existingProgressDoc.docs.first);
        
        // Determine completion status
        final bool completed = isCompleted ?? (progress >= 1.0);
        
        // Update progress document
        await _firebaseService.firestore
            .collection('tutorialProgress')
            .doc(docId)
            .update({
              'progress': progress,
              'isCompleted': completed,
              'lastAccessedAt': Timestamp.fromDate(now),
              if (completed && existingProgress.completedAt == null)
                'completedAt': Timestamp.fromDate(now),
            });
        
        // Update local state
        _userProgress[tutorialId] = existingProgress.copyWith(
          progress: progress,
          isCompleted: completed,
          lastAccessedAt: now,
          completedAt: completed && existingProgress.completedAt == null ? now : existingProgress.completedAt,
        );
      } else {
        // Create new progress document
        final bool completed = isCompleted ?? (progress >= 1.0);
        
        final newProgress = TutorialProgressModel(
          id: '', // Will be set after Firestore adds the document
          userId: userId,
          tutorialId: tutorialId,
          progress: progress,
          isCompleted: completed,
          startedAt: now,
          completedAt: completed ? now : null,
          lastAccessedAt: now,
        );
        
        // Add to Firestore
        final docRef = await _firebaseService.firestore
            .collection('tutorialProgress')
            .add(newProgress.toFirestore());
        
        // Update local state
        _userProgress[tutorialId] = newProgress.copyWith(id: docRef.id);
      }
      
      // Update tutorial view count
      final tutorial = getTutorialById(tutorialId);
      if (tutorial != null) {
        await _firebaseService.firestore
            .collection('tutorials')
            .doc(tutorialId)
            .update({
              'viewCount': FieldValue.increment(1),
            });
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update progress: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Rate a tutorial
  Future<bool> rateTutorial({
    required String userId,
    required String tutorialId,
    required int rating,
    String? feedback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Validate rating (1-5 stars)
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }
      
      // Get progress document to update
      final progressQuery = await _firebaseService.firestore
          .collection('tutorialProgress')
          .where('userId', isEqualTo: userId)
          .where('tutorialId', isEqualTo: tutorialId)
          .limit(1)
          .get();
      
      String progressDocId;
      if (progressQuery.docs.isNotEmpty) {
        // Update existing progress
        progressDocId = progressQuery.docs.first.id;
        
        await _firebaseService.firestore
            .collection('tutorialProgress')
            .doc(progressDocId)
            .update({
              'userRating': rating,
              if (feedback != null) 'userFeedback': feedback,
              'lastAccessedAt': FieldValue.serverTimestamp(),
            });
        
        // Update local state
        final existingProgress = TutorialProgressModel.fromFirestore(progressQuery.docs.first);
        _userProgress[tutorialId] = existingProgress.copyWith(
          userRating: rating,
          userFeedback: feedback ?? existingProgress.userFeedback,
          lastAccessedAt: DateTime.now(),
        );
      } else {
        // Create new progress entry with rating
        final newProgress = TutorialProgressModel(
          id: '', // Will be set after Firestore adds the document
          userId: userId,
          tutorialId: tutorialId,
          progress: 0,
          isCompleted: false,
          lastAccessedAt: DateTime.now(),
          userRating: rating,
          userFeedback: feedback,
        );
        
        // Add to Firestore
        final docRef = await _firebaseService.firestore
            .collection('tutorialProgress')
            .add(newProgress.toFirestore());
        
        progressDocId = docRef.id;
        
        // Update local state
        _userProgress[tutorialId] = newProgress.copyWith(id: progressDocId);
      }
      
      // Update tutorial rating in a transaction for consistency
      await _firebaseService.firestore.runTransaction((transaction) async {
        // Get the tutorial document
        final tutorialDoc = await transaction.get(_firebaseService.firestore.collection('tutorials').doc(tutorialId));
        
        if (!tutorialDoc.exists) {
          throw Exception('Tutorial not found');
        }
        
        // Calculate new rating
        final currentRating = tutorialDoc.data()?['averageRating'] ?? 0.0;
        final currentCount = tutorialDoc.data()?['ratingCount'] ?? 0;
        
        // Check if this user has already rated before
        bool isNewRating = true;
        if (progressQuery.docs.isNotEmpty) {
          final oldRating = progressQuery.docs.first.data()?['userRating'];
          isNewRating = oldRating == null;
        }
        
        double newAverage;
        int newCount;
        
        if (isNewRating) {
          // Brand new rating
          newCount = currentCount + 1;
          final totalPoints = (currentRating * currentCount) + rating;
          newAverage = totalPoints / newCount;
        } else {
          // Updating existing rating - need to remove old rating first
          final oldRating = progressQuery.docs.first.data()?['userRating'] ?? 0;
          final totalPointsMinusOld = (currentRating * currentCount) - oldRating;
          final totalPoints = totalPointsMinusOld + rating;
          newCount = currentCount; // Count stays the same
          newAverage = totalPoints / newCount;
        }
        
        // Update the tutorial document
        transaction.update(tutorialDoc.reference, {
          'averageRating': newAverage,
          'ratingCount': newCount,
        });
        
        // Update local tutorial object
        final index = _tutorials.indexWhere((t) => t.id == tutorialId);
        if (index != -1) {
          _tutorials[index] = _tutorials[index].copyWith(
            averageRating: newAverage,
            ratingCount: newCount,
          );
        }
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to rate tutorial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Create a new tutorial (for admin/instructor)
  Future<bool> createTutorial({
    required String title,
    required String description,
    required String content,
    required String authorId,
    required String authorName,
    required List<TutorialCategory> categories,
    required TutorialDifficulty difficulty,
    required int durationMinutes,
    required List<String> tags,
    String? thumbnailUrl,
    String? videoUrl,
    bool isPremium = false,
    bool isPublished = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final tutorial = TutorialModel(
        id: '', // Will be set after Firestore adds the document
        title: title,
        description: description,
        content: content,
        authorId: authorId,
        authorName: authorName,
        categories: categories,
        difficulty: difficulty,
        durationMinutes: durationMinutes,
        tags: tags,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        averageRating: 0.0,
        ratingCount: 0,
        viewCount: 0,
        isPublished: isPublished,
        isPremium: isPremium,
        createdAt: DateTime.now(),
      );
      
      // Add to Firestore
      final docRef = await _firebaseService.firestore
          .collection('tutorials')
          .add(tutorial.toFirestore());
      
      // Add to local state if published
      if (isPublished) {
        _tutorials.add(tutorial.copyWith(id: docRef.id));
        notifyListeners();
      }
      
      _isLoading = false;
      return true;
    } catch (e) {
      _error = 'Failed to create tutorial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update an existing tutorial
  Future<bool> updateTutorial({
    required String id,
    String? title,
    String? description,
    String? content,
    List<TutorialCategory>? categories,
    TutorialDifficulty? difficulty,
    int? durationMinutes,
    List<String>? tags,
    String? thumbnailUrl,
    String? videoUrl,
    bool? isPremium,
    bool? isPublished,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get current tutorial
      final tutorial = getTutorialById(id);
      if (tutorial == null) {
        throw Exception('Tutorial not found');
      }
      
      // Create updated data map
      final updateData = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (content != null) 'content': content,
        if (categories != null) 'categories': categories.map((c) => c.toString().split('.').last).toList(),
        if (difficulty != null) 'difficulty': difficulty.toString().split('.').last,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        if (tags != null) 'tags': tags,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (videoUrl != null) 'videoUrl': videoUrl,
        if (isPremium != null) 'isPremium': isPremium,
        if (isPublished != null) 'isPublished': isPublished,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      // Update in Firestore
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(id)
          .update(updateData);
      
      // Update local state
      final index = _tutorials.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tutorials[index] = _tutorials[index].copyWith(
          title: title,
          description: description,
          content: content,
          categories: categories,
          difficulty: difficulty,
          durationMinutes: durationMinutes,
          tags: tags,
          thumbnailUrl: thumbnailUrl,
          videoUrl: videoUrl,
          isPremium: isPremium,
          isPublished: isPublished,
          updatedAt: DateTime.now(),
        );
        
        // If tutorial is unpublished, remove from local list
        if (isPublished == false) {
          _tutorials.removeAt(index);
        }
        
        notifyListeners();
      }
      
      _isLoading = false;
      return true;
    } catch (e) {
      _error = 'Failed to update tutorial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete a tutorial
  Future<bool> deleteTutorial(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Delete from Firestore
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(id)
          .delete();
      
      // Delete from local state
      _tutorials.removeWhere((t) => t.id == id);
      
      // Also delete all progress entries for this tutorial
      final progressQuery = await _firebaseService.firestore
          .collection('tutorialProgress')
          .where('tutorialId', isEqualTo: id)
          .get();
      
      // Batch delete all progress entries
      final batch = _firebaseService.firestore.batch();
      for (final doc in progressQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Remove from local progress map
      _userProgress.remove(id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete tutorial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Clear all data (used during logout)
  void clear() {
    _tutorials = [];
    _userProgress = {};
    _isInitialized = false;
    _error = null;
    clearFilters();
    notifyListeners();
  }
}

// Extension for sorting
extension SortedBy<T> on Iterable<T> {
  List<T> sortedBy<R extends Comparable>(R Function(T) key) {
    final list = toList();
    list.sort((a, b) => key(a).compareTo(key(b)));
    return list;
  }
}