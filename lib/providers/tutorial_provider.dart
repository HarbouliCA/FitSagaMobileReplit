import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

class TutorialProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  List<TutorialModel> _tutorials = [];
  List<TutorialProgress> _userProgress = [];
  List<TutorialRating> _userRatings = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // Filters
  TutorialCategory? _selectedCategory;
  TutorialLevel? _selectedLevel;
  bool _showOnlyFavorites = false;
  String? _searchQuery;

  TutorialProvider(this._firebaseService);

  // Getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<TutorialModel> get tutorials => _tutorials;
  List<TutorialProgress> get userProgress => _userProgress;
  
  // Getters for filters
  TutorialCategory? get selectedCategory => _selectedCategory;
  TutorialLevel? get selectedLevel => _selectedLevel;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String? get searchQuery => _searchQuery;
  
  // Set filters
  void setFilters({
    TutorialCategory? category,
    TutorialLevel? level,
    bool? onlyFavorites,
    String? query,
  }) {
    _selectedCategory = category;
    _selectedLevel = level;
    _showOnlyFavorites = onlyFavorites ?? _showOnlyFavorites;
    _searchQuery = query;
    notifyListeners();
  }
  
  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedLevel = null;
    _showOnlyFavorites = false;
    _searchQuery = null;
    notifyListeners();
  }
  
  // Get filtered tutorials
  List<TutorialModel> get filteredTutorials {
    List<TutorialModel> result = List.from(_tutorials);
    
    // Filter by category
    if (_selectedCategory != null) {
      result = result.where((tutorial) => tutorial.category == _selectedCategory).toList();
    }
    
    // Filter by level
    if (_selectedLevel != null) {
      result = result.where((tutorial) => 
          tutorial.level == _selectedLevel || tutorial.level == TutorialLevel.all).toList();
    }
    
    // Filter by search query
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      result = result.where((tutorial) => 
          tutorial.title.toLowerCase().contains(query) ||
          tutorial.description.toLowerCase().contains(query) ||
          tutorial.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          tutorial.instructorName.toLowerCase().contains(query)
      ).toList();
    }
    
    // Filter by favorites (would need to implement a favorites collection in Firestore)
    if (_showOnlyFavorites) {
      result = result.where((tutorial) => _isFavorite(tutorial.id)).toList();
    }
    
    return result;
  }
  
  // Get tutorials by category
  List<TutorialModel> getTutorialsByCategory(TutorialCategory category) {
    return _tutorials.where((tutorial) => tutorial.category == category).toList();
  }
  
  // Get tutorials by level
  List<TutorialModel> getTutorialsByLevel(TutorialLevel level) {
    return _tutorials.where((tutorial) => tutorial.level == level || tutorial.level == TutorialLevel.all).toList();
  }
  
  // Get trending tutorials (based on view count)
  List<TutorialModel> get trendingTutorials {
    final sortedList = List<TutorialModel>.from(_tutorials);
    sortedList.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sortedList.take(10).toList();
  }
  
  // Get highest rated tutorials
  List<TutorialModel> get highestRatedTutorials {
    final sortedList = List<TutorialModel>.from(_tutorials);
    sortedList.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedList.where((tutorial) => tutorial.rating > 0).take(10).toList();
  }
  
  // Get recently added tutorials
  List<TutorialModel> get recentTutorials {
    final sortedList = List<TutorialModel>.from(_tutorials);
    sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedList.take(10).toList();
  }
  
  // Get user's in-progress tutorials
  List<TutorialModel> get inProgressTutorials {
    final inProgressIds = _userProgress
        .where((progress) => progress.progress > 0 && !progress.isCompleted)
        .map((progress) => progress.tutorialId)
        .toList();
    
    return _tutorials
        .where((tutorial) => inProgressIds.contains(tutorial.id))
        .toList();
  }
  
  // Get user's completed tutorials
  List<TutorialModel> get completedTutorials {
    final completedIds = _userProgress
        .where((progress) => progress.isCompleted)
        .map((progress) => progress.tutorialId)
        .toList();
    
    return _tutorials
        .where((tutorial) => completedIds.contains(tutorial.id))
        .toList();
  }
  
  // Get tutorial by ID
  TutorialModel? getTutorialById(String id) {
    try {
      return _tutorials.firstWhere((tutorial) => tutorial.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get user progress for a specific tutorial
  TutorialProgress? getProgressForTutorial(String tutorialId) {
    try {
      return _userProgress.firstWhere(
        (progress) => progress.tutorialId == tutorialId,
      );
    } catch (e) {
      return null;
    }
  }
  
  // Check if a tutorial is marked as favorite
  bool _isFavorite(String tutorialId) {
    // This would need to check against a user's favorites in Firestore
    // For now, just return false as a placeholder
    return false;
  }
  
  // Load all tutorials
  Future<void> loadTutorials({UserModel? user}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Fetch tutorials from Firestore
      final tutorialsRef = _firebaseService.firestore.collection('tutorials');
      QuerySnapshot tutorialsSnapshot;
      
      // Admin sees all tutorials, others only see active ones
      if (user != null && user.isAdmin) {
        tutorialsSnapshot = await tutorialsRef.get();
      } else {
        tutorialsSnapshot = await tutorialsRef
            .where('isActive', isEqualTo: true)
            .get();
      }
      
      _tutorials = tutorialsSnapshot.docs
          .map((doc) => TutorialModel.fromFirestore(doc))
          .toList();
      
      // If user is authenticated, load their progress
      if (user != null) {
        await _loadUserProgress(user.id);
        await _loadUserRatings(user.id);
      }
      
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
  
  // Load user progress
  Future<void> _loadUserProgress(String userId) async {
    try {
      final progressRef = _firebaseService.firestore
          .collection('tutorial_progress')
          .where('userId', isEqualTo: userId);
      
      final progressSnapshot = await progressRef.get();
      
      _userProgress = progressSnapshot.docs
          .map((doc) => TutorialProgress.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to load tutorial progress: $e';
      rethrow;
    }
  }
  
  // Load user ratings
  Future<void> _loadUserRatings(String userId) async {
    try {
      final ratingsRef = _firebaseService.firestore
          .collection('tutorial_ratings')
          .where('userId', isEqualTo: userId);
      
      final ratingsSnapshot = await ratingsRef.get();
      
      _userRatings = ratingsSnapshot.docs
          .map((doc) => TutorialRating.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = 'Failed to load tutorial ratings: $e';
      rethrow;
    }
  }
  
  // Update user's tutorial progress
  Future<bool> updateTutorialProgress({
    required String userId,
    required String tutorialId,
    required double progress,
    required int positionInSeconds,
    bool? markAsCompleted,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if a progress record already exists
      final progressRef = _firebaseService.firestore
          .collection('tutorial_progress')
          .where('userId', isEqualTo: userId)
          .where('tutorialId', isEqualTo: tutorialId);
      
      final progressSnapshot = await progressRef.get();
      final now = DateTime.now();
      
      if (progressSnapshot.docs.isNotEmpty) {
        // Update existing progress
        final docId = progressSnapshot.docs.first.id;
        final existingProgress = TutorialProgress.fromFirestore(progressSnapshot.docs.first);
        
        // Only mark as completed if specified, otherwise keep existing value
        final isCompleted = markAsCompleted ?? existingProgress.isCompleted;
        
        await _firebaseService.firestore
            .collection('tutorial_progress')
            .doc(docId)
            .update({
              'progress': progress,
              'isCompleted': isCompleted,
              'lastWatched': Timestamp.fromDate(now),
              'lastPositionInSeconds': positionInSeconds,
              'updatedAt': Timestamp.fromDate(now),
            });
        
        // Update local progress list
        final index = _userProgress.indexWhere((p) => p.id == docId);
        if (index != -1) {
          _userProgress[index] = TutorialProgress(
            id: docId,
            userId: userId,
            tutorialId: tutorialId,
            progress: progress,
            isCompleted: isCompleted,
            lastWatched: now,
            lastPositionInSeconds: positionInSeconds,
            createdAt: existingProgress.createdAt,
            updatedAt: now,
          );
        }
      } else {
        // Create new progress record
        final newProgress = {
          'userId': userId,
          'tutorialId': tutorialId,
          'progress': progress,
          'isCompleted': markAsCompleted ?? false,
          'lastWatched': Timestamp.fromDate(now),
          'lastPositionInSeconds': positionInSeconds,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        };
        
        final docRef = await _firebaseService.firestore
            .collection('tutorial_progress')
            .add(newProgress);
        
        // Add to local progress list
        _userProgress.add(TutorialProgress(
          id: docRef.id,
          userId: userId,
          tutorialId: tutorialId,
          progress: progress,
          isCompleted: markAsCompleted ?? false,
          lastWatched: now,
          lastPositionInSeconds: positionInSeconds,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      // Increment view count for the tutorial
      await _incrementTutorialViewCount(tutorialId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update tutorial progress: $e';
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
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      _error = 'Rating must be between 1 and 5';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if user has already rated this tutorial
      final ratingRef = _firebaseService.firestore
          .collection('tutorial_ratings')
          .where('userId', isEqualTo: userId)
          .where('tutorialId', isEqualTo: tutorialId);
      
      final ratingSnapshot = await ratingRef.get();
      final now = DateTime.now();
      
      // Prepare for updating the tutorial's average rating
      final tutorialRef = _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId);
      
      final tutorialDoc = await tutorialRef.get();
      if (!tutorialDoc.exists) {
        _error = 'Tutorial not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final tutorial = TutorialModel.fromFirestore(tutorialDoc);
      
      await _firebaseService.firestore.runTransaction((transaction) async {
        if (ratingSnapshot.docs.isNotEmpty) {
          // Update existing rating
          final docId = ratingSnapshot.docs.first.id;
          final oldRating = (ratingSnapshot.docs.first.data() as Map<String, dynamic>)['rating'] ?? 0;
          
          // Update the rating document
          transaction.update(
            _firebaseService.firestore.collection('tutorial_ratings').doc(docId),
            {
              'rating': rating,
              'comment': comment,
              'updatedAt': Timestamp.fromDate(now),
            },
          );
          
          // Update tutorial's average rating
          // Formula: ((oldAvg * count) - oldRating + newRating) / count
          if (tutorial.ratingCount > 0) {
            double newAverage = ((tutorial.rating * tutorial.ratingCount) - oldRating + rating) / tutorial.ratingCount;
            
            transaction.update(
              tutorialRef,
              {
                'rating': newAverage,
                'updatedAt': Timestamp.fromDate(now),
              },
            );
            
            // Update local tutorial
            final index = _tutorials.indexWhere((t) => t.id == tutorialId);
            if (index != -1) {
              _tutorials[index] = _tutorials[index].copyWith(
                rating: newAverage,
                updatedAt: now,
              );
            }
          }
          
          // Update local ratings list
          final ratingIndex = _userRatings.indexWhere((r) => r.id == docId);
          if (ratingIndex != -1) {
            _userRatings[ratingIndex] = TutorialRating(
              id: docId,
              userId: userId,
              tutorialId: tutorialId,
              rating: rating,
              comment: comment,
              createdAt: _userRatings[ratingIndex].createdAt,
              updatedAt: now,
            );
          }
        } else {
          // Create new rating
          final newRatingRef = _firebaseService.firestore
              .collection('tutorial_ratings')
              .doc();
          
          transaction.set(
            newRatingRef,
            {
              'userId': userId,
              'tutorialId': tutorialId,
              'rating': rating,
              'comment': comment,
              'createdAt': Timestamp.fromDate(now),
              'updatedAt': Timestamp.fromDate(now),
            },
          );
          
          // Update tutorial's average rating and increment count
          // Formula: ((oldAvg * oldCount) + newRating) / (oldCount + 1)
          double newAverage = ((tutorial.rating * tutorial.ratingCount) + rating) / (tutorial.ratingCount + 1);
          
          transaction.update(
            tutorialRef,
            {
              'rating': newAverage,
              'ratingCount': FieldValue.increment(1),
              'updatedAt': Timestamp.fromDate(now),
            },
          );
          
          // Update local tutorial
          final index = _tutorials.indexWhere((t) => t.id == tutorialId);
          if (index != -1) {
            _tutorials[index] = _tutorials[index].copyWith(
              rating: newAverage,
              ratingCount: _tutorials[index].ratingCount + 1,
              updatedAt: now,
            );
          }
          
          // Add to local ratings list
          _userRatings.add(TutorialRating(
            id: newRatingRef.id,
            userId: userId,
            tutorialId: tutorialId,
            rating: rating,
            comment: comment,
            createdAt: now,
            updatedAt: now,
          ));
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
  
  // Toggle favorite status for a tutorial
  Future<bool> toggleFavorite(String userId, String tutorialId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if tutorial is already a favorite
      final favoriteRef = _firebaseService.firestore
          .collection('user_favorites')
          .where('userId', isEqualTo: userId)
          .where('tutorialId', isEqualTo: tutorialId);
      
      final favoriteSnapshot = await favoriteRef.get();
      
      if (favoriteSnapshot.docs.isNotEmpty) {
        // Remove from favorites
        await _firebaseService.firestore
            .collection('user_favorites')
            .doc(favoriteSnapshot.docs.first.id)
            .delete();
      } else {
        // Add to favorites
        await _firebaseService.firestore
            .collection('user_favorites')
            .add({
              'userId': userId,
              'tutorialId': tutorialId,
              'createdAt': FieldValue.serverTimestamp(),
            });
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update favorites: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Increment tutorial view count
  Future<void> _incrementTutorialViewCount(String tutorialId) async {
    try {
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId)
          .update({
            'viewCount': FieldValue.increment(1),
          });
      
      // Update local tutorial
      final index = _tutorials.indexWhere((t) => t.id == tutorialId);
      if (index != -1) {
        _tutorials[index] = _tutorials[index].copyWith(
          viewCount: _tutorials[index].viewCount + 1,
        );
      }
    } catch (e) {
      // Don't throw error for view count updates, just log it
      print('Failed to update view count: $e');
    }
  }
  
  // Create a new tutorial (Admin/Instructor function)
  Future<bool> createTutorial(TutorialModel tutorial) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Validate tutorial data
      if (tutorial.title.isEmpty || tutorial.description.isEmpty) {
        _error = 'Title and description are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Add to Firestore
      final docRef = await _firebaseService.firestore
          .collection('tutorials')
          .add(tutorial.toFirestore());
      
      // Add to local list with generated ID
      final newTutorial = tutorial.copyWith(id: docRef.id);
      _tutorials.add(newTutorial);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create tutorial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update an existing tutorial (Admin/Instructor function)
  Future<bool> updateTutorial(TutorialModel updatedTutorial) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Validate tutorial data
      if (updatedTutorial.title.isEmpty || updatedTutorial.description.isEmpty) {
        _error = 'Title and description are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Update in Firestore
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(updatedTutorial.id)
          .update(updatedTutorial.toFirestore());
      
      // Update in local list
      final index = _tutorials.indexWhere((t) => t.id == updatedTutorial.id);
      if (index != -1) {
        _tutorials[index] = updatedTutorial;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update tutorial: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Delete a tutorial (Admin function)
  Future<bool> deleteTutorial(String tutorialId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Delete from Firestore
      await _firebaseService.firestore
          .collection('tutorials')
          .doc(tutorialId)
          .delete();
      
      // Remove from local list
      _tutorials.removeWhere((t) => t.id == tutorialId);
      
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
  
  // Refresh tutorials data
  Future<void> refreshTutorials(String userId) async {
    return loadTutorials();
  }
  
  // Clear all data (used during logout)
  void clear() {
    _tutorials = [];
    _userProgress = [];
    _userRatings = [];
    _isInitialized = false;
    _error = null;
    clearFilters();
    notifyListeners();
  }
}