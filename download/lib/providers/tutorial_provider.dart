import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/models/user_model.dart';
import 'package:fitsaga/services/firebase_service.dart';

/// Provider class for managing tutorials in the FitSAGA app
class TutorialProvider with ChangeNotifier {
  /// Instance of the Firebase service
  final FirebaseService _firebaseService = FirebaseService();
  
  /// List of all available tutorials
  List<TutorialModel> _tutorials = [];
  
  /// Loading state for tutorial operations
  bool _isLoading = false;
  
  /// Error message if tutorial operations fail
  String? _error;
  
  /// Flag to track if tutorials have been loaded
  bool _isInitialized = false;
  
  /// Returns the list of all available tutorials
  List<TutorialModel> get tutorials => _tutorials;
  
  /// Returns whether a tutorial operation is in progress
  bool get isLoading => _isLoading;
  
  /// Returns any error message from the last tutorial operation
  String? get error => _error;
  
  /// Returns whether tutorials have been loaded
  bool get isInitialized => _isInitialized;
  
  /// Loads all available tutorials
  Future<void> loadTutorials() async {
    try {
      _setLoading(true);
      _clearError();
      
      _tutorials = await _firebaseService.getAllTutorials();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tutorials: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets a specific tutorial by ID
  Future<TutorialModel?> getTutorialById(String tutorialId) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Check if tutorial is already in the list
      final cachedTutorial = _tutorials.firstWhere(
        (tutorial) => tutorial.id == tutorialId,
        orElse: () => TutorialModel(
          id: '',
          title: '',
          description: '',
          authorId: '',
          authorName: '',
          videoUrl: '',
          imageUrls: [],
          level: TutorialLevel.allLevels,
          tags: [],
          durationMinutes: 0,
          steps: [],
          equipment: [],
          isFeatured: false,
          isPublic: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (cachedTutorial.id.isNotEmpty) {
        return cachedTutorial;
      }
      
      // Fetch from Firebase
      final tutorial = await _firebaseService.getTutorialById(tutorialId);
      
      if (tutorial != null && !_tutorials.any((t) => t.id == tutorial.id)) {
        _tutorials.add(tutorial);
        notifyListeners();
      }
      
      return tutorial;
    } catch (e) {
      _setError('Failed to get tutorial: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Creates a new tutorial (instructor or admin only)
  Future<bool> createTutorial(TutorialModel tutorial) async {
    try {
      _setLoading(true);
      _clearError();
      
      final tutorialId = await _firebaseService.createTutorial(tutorial);
      
      if (tutorialId != null) {
        // Update with the new ID
        final newTutorial = TutorialModel(
          id: tutorialId,
          title: tutorial.title,
          description: tutorial.description,
          authorId: tutorial.authorId,
          authorName: tutorial.authorName,
          videoUrl: tutorial.videoUrl,
          imageUrls: tutorial.imageUrls,
          level: tutorial.level,
          tags: tutorial.tags,
          durationMinutes: tutorial.durationMinutes,
          steps: tutorial.steps,
          equipment: tutorial.equipment,
          isFeatured: tutorial.isFeatured,
          isPublic: tutorial.isPublic,
          createdAt: tutorial.createdAt,
          updatedAt: tutorial.updatedAt,
        );
        
        _tutorials.add(newTutorial);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create tutorial.');
        return false;
      }
    } catch (e) {
      _setError('Failed to create tutorial: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Updates an existing tutorial (instructor or admin only)
  Future<bool> updateTutorial(TutorialModel tutorial) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.updateTutorial(tutorial);
      
      if (success) {
        // Update in list
        final index = _tutorials.indexWhere((t) => t.id == tutorial.id);
        if (index != -1) {
          _tutorials[index] = tutorial;
          notifyListeners();
        }
        return true;
      } else {
        _setError('Failed to update tutorial.');
        return false;
      }
    } catch (e) {
      _setError('Failed to update tutorial: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Deletes a tutorial (admin only)
  Future<bool> deleteTutorial(String tutorialId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _firebaseService.deleteTutorial(tutorialId);
      
      if (success) {
        _tutorials.removeWhere((t) => t.id == tutorialId);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete tutorial.');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete tutorial: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets tutorials filtered by difficulty level
  List<TutorialModel> getTutorialsByLevel(TutorialLevel level) {
    return _tutorials.where((tutorial) => tutorial.level == level).toList();
  }
  
  /// Gets tutorials filtered by tag
  List<TutorialModel> getTutorialsByTag(String tag) {
    return _tutorials.where((tutorial) => tutorial.tags.contains(tag)).toList();
  }
  
  /// Gets featured tutorials for the home page
  List<TutorialModel> get featuredTutorials {
    return _tutorials.where((tutorial) => tutorial.isFeatured).toList();
  }
  
  /// Gets tutorials created by a specific instructor
  List<TutorialModel> getTutorialsByInstructor(String instructorId) {
    return _tutorials.where((tutorial) => tutorial.authorId == instructorId).toList();
  }
  
  /// Gets tutorials sorted by most recent
  List<TutorialModel> get recentTutorials {
    final sorted = List<TutorialModel>.from(_tutorials);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
  
  /// Gets tutorials that contain equipment user has
  List<TutorialModel> getTutorialsWithEquipment(List<String> userEquipment) {
    return _tutorials.where((tutorial) {
      // If tutorial requires no equipment, include it
      if (!tutorial.requiresEquipment) return true;
      
      // Check if all required equipment is available to the user
      for (final equipment in tutorial.equipment) {
        if (!userEquipment.contains(equipment)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
  
  /// Checks if a user can manage a tutorial (is author or admin)
  bool canManageTutorial(TutorialModel tutorial, UserModel user) {
    return user.isAdmin || tutorial.authorId == user.id;
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
  
  /// Clears all tutorial data (used for sign out)
  void clear() {
    _tutorials = [];
    _isInitialized = false;
    _clearError();
    notifyListeners();
  }
}