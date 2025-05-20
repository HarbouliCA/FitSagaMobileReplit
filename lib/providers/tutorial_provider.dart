import 'package:flutter/foundation.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/services/firebase_service.dart';
import 'package:fitsaga/config/constants.dart';

class TutorialProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  
  TutorialProvider(this._firebaseService);
  
  bool _loading = false;
  String? _error;
  List<TutorialModel> _tutorials = [];
  TutorialModel? _selectedTutorial;
  ExerciseModel? _selectedExercise;
  
  // Filters
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _searchQuery;

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<TutorialModel> get tutorials => _tutorials;
  TutorialModel? get selectedTutorial => _selectedTutorial;
  ExerciseModel? get selectedExercise => _selectedExercise;
  
  // Filter getters
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;
  String? get searchQuery => _searchQuery;

  // Computed lists
  List<TutorialModel> get exerciseTutorials => 
      _tutorials.where((tutorial) => tutorial.isExerciseTutorial).toList();
  
  List<TutorialModel> get nutritionTutorials => 
      _tutorials.where((tutorial) => tutorial.isNutritionTutorial).toList();
  
  List<TutorialModel> get beginnerTutorials => 
      _tutorials.where((tutorial) => tutorial.isBeginner).toList();
  
  List<TutorialModel> get intermediateTutorials => 
      _tutorials.where((tutorial) => tutorial.isIntermediate).toList();
  
  List<TutorialModel> get advancedTutorials => 
      _tutorials.where((tutorial) => tutorial.isAdvanced).toList();
  
  List<TutorialModel> get featuredTutorials => 
      _tutorials.where((tutorial) => tutorial.isFeatured).toList();

  // Filtered tutorials
  List<TutorialModel> get filteredTutorials {
    return _tutorials.where((tutorial) {
      // Apply category filter
      if (_selectedCategory != null && tutorial.category != _selectedCategory) {
        return false;
      }
      
      // Apply difficulty filter
      if (_selectedDifficulty != null && tutorial.difficultyLevel != _selectedDifficulty) {
        return false;
      }
      
      // Apply search filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        return tutorial.title.toLowerCase().contains(query) || 
               tutorial.description.toLowerCase().contains(query) ||
               tutorial.author.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }
  
  // Methods
  Future<void> fetchAllTutorials() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      _tutorials = await _firebaseService.getAllTutorials();
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> fetchTutorialById(String tutorialId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      
      final tutorial = await _firebaseService.getTutorialById(tutorialId);
      _selectedTutorial = tutorial;
      
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<TutorialProgressModel> getUserTutorialProgress(String userId, String tutorialId) async {
    try {
      return await _firebaseService.getUserTutorialProgress(userId, tutorialId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
  
  Future<void> markExerciseAsCompleted(String userId, String exerciseId) async {
    try {
      if (_selectedTutorial == null) {
        throw Exception('No tutorial selected');
      }
      
      await _firebaseService.markExerciseAsCompleted(
        userId, 
        _selectedTutorial!.id, 
        exerciseId,
        _selectedTutorial!
      );
      
      // Refresh tutorial data
      await fetchTutorialById(_selectedTutorial!.id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Filter methods
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  void setDifficultyFilter(String? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }
  
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearFilters() {
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = null;
    notifyListeners();
  }
  
  // Tutorial and exercise selection
  void selectTutorial(TutorialModel tutorial) {
    _selectedTutorial = tutorial;
    _selectedExercise = null;
    notifyListeners();
  }
  
  void selectExercise(ExerciseModel exercise) {
    _selectedExercise = exercise;
    notifyListeners();
  }
  
  void clearSelectedTutorial() {
    _selectedTutorial = null;
    _selectedExercise = null;
    notifyListeners();
  }
  
  void clearSelectedExercise() {
    _selectedExercise = null;
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