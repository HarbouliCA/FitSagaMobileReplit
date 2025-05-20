import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/tutorial_model.dart';
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
  bool _onlyPremium = false;
  
  TutorialProvider(this._firebaseService);
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  
  List<TutorialModel> get allTutorials => [..._tutorials];
  
  List<TutorialModel> get popularTutorials => _tutorials
      .where((tutorial) => tutorial.isPublished)
      .toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));
  
  // Filter getters
  String? get searchQuery => _searchQuery;
  TutorialDifficulty? get difficultyFilter => _difficultyFilter;
  TutorialCategory? get categoryFilter => _categoryFilter;
  bool get onlyPremium => _onlyPremium;
  
  bool get hasActiveFilters => 
      _searchQuery != null || 
      _difficultyFilter != null || 
      _categoryFilter != null || 
      _onlyPremium;
  
  // Filtered tutorials based on current filters
  List<TutorialModel> get filteredTutorials {
    List<TutorialModel> result = _tutorials
        .where((tutorial) => tutorial.isPublished)
        .toList();
    
    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result.where((tutorial) {
        return tutorial.title.toLowerCase().contains(query) ||
               tutorial.description.toLowerCase().contains(query) ||
               tutorial.tags.any((tag) => tag.toLowerCase().contains(query));
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
        return tutorial.categories.contains(_categoryFilter);
      }).toList();
    }
    
    // Apply premium filter
    if (_onlyPremium) {
      result = result.where((tutorial) => tutorial.isPremium).toList();
    }
    
    return result;
  }
  
  // Set filters
  void setFilters({
    String? query,
    TutorialDifficulty? difficulty,
    TutorialCategory? category,
    bool? premium,
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
    
    if (premium != null && premium != _onlyPremium) {
      _onlyPremium = premium;
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
    _onlyPremium = false;
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
          .where('isPublished', isEqualTo: true) // Only load published tutorials
          .get();
      
      _tutorials = tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
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
          .where('categories', arrayContains: category.index)
          .where('isPublished', isEqualTo: true)
          .get();
      
      return tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
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
    int? lastWatchedPosition,
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
        final updatedProgress = existingProgress.copyWith(
          progress: progress,
          isCompleted: isCompleted || existingProgress.isCompleted,
          lastWatchedPosition: lastWatchedPosition ?? existingProgress.lastWatchedPosition,
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
          lastWatchedPosition: lastWatchedPosition ?? 0,
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
  
  // Get recommended tutorials based on user history and preferences
  List<TutorialModel> getRecommendedTutorials() {
    // Use user's history to determine preferences
    if (_userProgress.isEmpty) {
      return popularTutorials.take(10).toList();
    }
    
    // Find categories the user has engaged with
    final preferredCategories = <TutorialCategory>[];
    final completedTutorialIds = getCompletedTutorials().map((t) => t.id).toList();
    
    for (final tutorial in _tutorials) {
      if (completedTutorialIds.contains(tutorial.id)) {
        preferredCategories.addAll(tutorial.categories);
      }
    }
    
    // Count frequency of each category
    final categoryCount = <TutorialCategory, int>{};
    for (final category in preferredCategories) {
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    
    // Sort categories by frequency
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get top categories
    final topCategories = sortedCategories
        .take(3)
        .map((e) => e.key)
        .toList();
    
    // Find tutorials in those categories that the user hasn't completed
    final recommendedTutorials = _tutorials
        .where((tutorial) => 
          tutorial.isPublished && 
          !completedTutorialIds.contains(tutorial.id) &&
          tutorial.categories.any((c) => topCategories.contains(c)))
        .toList();
    
    // Sort by rating
    recommendedTutorials.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    
    // Return top 10 or all if less
    return recommendedTutorials.take(10).toList();
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
      // Get the tutorial
      final tutorialRef = _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId);
      
      // Get the tutorial document
      final tutorialDoc = await tutorialRef.get();
      
      if (!tutorialDoc.exists) {
        _error = 'Tutorial not found';
        return false;
      }
      
      // Get current values
      final currentRatingCount = tutorialDoc.data()?['ratingCount'] ?? 0;
      final currentAverageRating = tutorialDoc.data()?['averageRating'] ?? 0.0;
      
      // Check if user has already rated this tutorial
      final userProgressDoc = await _firebaseService.firestore
          .collection('userProgress')
          .doc('${userId}_${tutorialId}')
          .get();
      
      int? previousRating;
      
      if (userProgressDoc.exists) {
        previousRating = userProgressDoc.data()?['userRating'];
      }
      
      // Update the tutorial's rating
      double newAverageRating;
      int newRatingCount;
      
      if (previousRating != null) {
        // User is updating their rating
        final totalRatingValue = currentAverageRating * currentRatingCount;
        final newTotalRatingValue = totalRatingValue - previousRating + rating;
        newAverageRating = newTotalRatingValue / currentRatingCount;
        newRatingCount = currentRatingCount;
      } else {
        // User is rating for the first time
        final totalRatingValue = currentAverageRating * currentRatingCount;
        final newTotalRatingValue = totalRatingValue + rating;
        newRatingCount = currentRatingCount + 1;
        newAverageRating = newTotalRatingValue / newRatingCount;
      }
      
      // Update the tutorial document
      await tutorialRef.update({
        'averageRating': newAverageRating,
        'ratingCount': newRatingCount,
      });
      
      // Update the user progress
      final progressRef = _firebaseService.firestore
          .collection('userProgress')
          .doc('${userId}_${tutorialId}');
      
      if (userProgressDoc.exists) {
        await progressRef.update({
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
          lastWatchedPosition: 0,
          lastAccessedAt: DateTime.now(),
        );
        
        await progressRef.set(newProgress.toJson());
        _userProgress.add(newProgress);
      }
      
      // Update the local tutorial
      final index = _tutorials.indexWhere((t) => t.id == tutorialId);
      if (index >= 0) {
        _tutorials[index] = _tutorials[index].copyWith(
          averageRating: newAverageRating,
          ratingCount: newRatingCount,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to rate tutorial: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Create a new tutorial
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
    required bool isPremium,
    required bool isPublished,
    Map<String, dynamic>? videoMetadata,
    List<VideoBookmark>? bookmarks,
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();
      
      final tutorial = TutorialModel(
        id: id,
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
        isPremium: isPremium,
        isPublished: isPublished,
        createdAt: now,
        updatedAt: now,
        viewCount: 0,
        averageRating: 0.0,
        ratingCount: 0,
        videoMetadata: videoMetadata,
        bookmarks: bookmarks,
      );
      
      // Create in Firebase
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(id)
          .set(tutorial.toJson());
      
      // Add to local list if published
      if (isPublished) {
        _tutorials.add(tutorial);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to create tutorial: ${e.toString()}';
      print(_error);
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
    Map<String, dynamic>? videoMetadata,
    List<VideoBookmark>? bookmarks,
  }) async {
    try {
      // Find the tutorial
      final index = _tutorials.indexWhere((t) => t.id == id);
      if (index < 0) {
        _error = 'Tutorial not found';
        return false;
      }
      
      final tutorial = _tutorials[index];
      final updatedAt = DateTime.now();
      
      // Create update data
      final updateData = <String, dynamic>{
        'updatedAt': updatedAt,
      };
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (content != null) updateData['content'] = content;
      if (categories != null) updateData['categories'] = categories.map((c) => c.index).toList();
      if (difficulty != null) updateData['difficulty'] = difficulty.index;
      if (durationMinutes != null) updateData['durationMinutes'] = durationMinutes;
      if (tags != null) updateData['tags'] = tags;
      if (thumbnailUrl != null) updateData['thumbnailUrl'] = thumbnailUrl;
      if (videoUrl != null) updateData['videoUrl'] = videoUrl;
      if (isPremium != null) updateData['isPremium'] = isPremium;
      if (isPublished != null) updateData['isPublished'] = isPublished;
      if (videoMetadata != null) updateData['videoMetadata'] = videoMetadata;
      if (bookmarks != null) updateData['bookmarks'] = bookmarks.map((b) => b.toJson()).toList();
      
      // Update in Firebase
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(id)
          .update(updateData);
      
      // Update in local list
      final updatedTutorial = tutorial.copyWith(
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
        updatedAt: updatedAt,
        videoMetadata: videoMetadata,
        bookmarks: bookmarks,
      );
      
      // Update or remove from local list depending on published status
      if (isPublished == false) {
        _tutorials.removeAt(index);
      } else {
        _tutorials[index] = updatedTutorial;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update tutorial: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Delete a tutorial
  Future<bool> deleteTutorial(String id) async {
    try {
      // Delete from Firebase
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(id)
          .delete();
      
      // Delete from local list
      _tutorials.removeWhere((t) => t.id == id);
      
      // Delete all related progress
      final progressRefs = await _firebaseService.firestore
          .collection('userProgress')
          .where('tutorialId', isEqualTo: id)
          .get();
      
      for (final doc in progressRefs.docs) {
        await doc.reference.delete();
      }
      
      // Delete from local progress
      _userProgress.removeWhere((p) => p.tutorialId == id);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete tutorial: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Add or update video bookmarks
  Future<bool> updateBookmarks({
    required String tutorialId,
    required List<VideoBookmark> bookmarks,
  }) async {
    try {
      // Find the tutorial
      final index = _tutorials.indexWhere((t) => t.id == tutorialId);
      if (index < 0) {
        _error = 'Tutorial not found';
        return false;
      }
      
      // Update in Firebase
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId)
          .update({
            'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      // Update in local list
      _tutorials[index] = _tutorials[index].copyWith(
        bookmarks: bookmarks,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update bookmarks: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Update video metadata
  Future<bool> updateVideoMetadata({
    required String tutorialId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      // Find the tutorial
      final index = _tutorials.indexWhere((t) => t.id == tutorialId);
      if (index < 0) {
        _error = 'Tutorial not found';
        return false;
      }
      
      // Update in Firebase
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId)
          .update({
            'videoMetadata': metadata,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      // Update in local list
      _tutorials[index] = _tutorials[index].copyWith(
        videoMetadata: metadata,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update video metadata: ${e.toString()}';
      print(_error);
      return false;
    }
  }
  
  // Increment tutorial view count
  Future<void> incrementViewCount(String tutorialId) async {
    try {
      // Update in Firebase
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId)
          .update({
            'viewCount': FieldValue.increment(1),
          });
      
      // Update local version
      final index = _tutorials.indexWhere((t) => t.id == tutorialId);
      if (index >= 0) {
        _tutorials[index] = _tutorials[index].copyWith(
          viewCount: _tutorials[index].viewCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Failed to increment view count: ${e.toString()}');
      // Don't set error as this is not critical
    }
  }
}