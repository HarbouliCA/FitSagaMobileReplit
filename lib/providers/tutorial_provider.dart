import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/utils/error_handler.dart';

/// Provider for managing tutorial data and user progress
class TutorialProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // State
  bool _isLoading = false;
  String? _error;
  List<TutorialDay> _tutorialDays = [];
  Map<String, TutorialProgress> _userProgress = {};
  Map<String, TutorialDay> _tutorialDaysMap = {};
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TutorialDay> get tutorialDays => _tutorialDays;
  Map<String, TutorialProgress> get userProgress => _userProgress;
  
  // Filter getters
  List<TutorialDay> get beginnerTutorials => 
      _tutorialDays.where((day) => day.difficulty.toLowerCase() == 'beginner').toList();
  
  List<TutorialDay> get intermediateTutorials => 
      _tutorialDays.where((day) => day.difficulty.toLowerCase() == 'intermediate').toList();
  
  List<TutorialDay> get advancedTutorials => 
      _tutorialDays.where((day) => day.difficulty.toLowerCase() == 'advanced').toList();
  
  // Get tutorials by difficulty
  List<TutorialDay> getTutorialsByDifficulty(String difficulty) {
    return _tutorialDays.where((day) => 
        day.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
  }
  
  // Get tutorials by tag
  List<TutorialDay> getTutorialsByTag(String tag) {
    return _tutorialDays.where((day) => 
        day.tags.contains(tag.toLowerCase())).toList();
  }
  
  // Get tutorials by day number range
  List<TutorialDay> getTutorialsByDayRange(int startDay, int endDay) {
    return _tutorialDays.where((day) => 
        day.dayNumber >= startDay && day.dayNumber <= endDay).toList();
  }
  
  // Get a specific tutorial day by ID
  TutorialDay? getTutorialDay(String id) {
    return _tutorialDaysMap[id];
  }
  
  // Get progress for a specific tutorial day
  TutorialProgress? getProgressForTutorial(String tutorialDayId) {
    return _userProgress[tutorialDayId];
  }
  
  // Calculate overall progress percentage
  double getOverallProgress() {
    if (_tutorialDays.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    int completedDays = 0;
    
    for (final day in _tutorialDays) {
      final progress = _userProgress[day.id];
      if (progress != null) {
        totalProgress += progress.progressPercentage;
        if (progress.isCompleted) {
          completedDays++;
        }
      }
    }
    
    return totalProgress / _tutorialDays.length;
  }
  
  // Load tutorial days from Firestore
  Future<void> loadTutorialDays() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // For demo purposes, we'll use sample data instead of Firestore
      await Future.delayed(const Duration(seconds: 1));
      
      _tutorialDays = _getSampleTutorialDays();
      _tutorialDaysMap = {for (var day in _tutorialDays) day.id: day};
      
      // In a real app, this would be the code:
      /*
      final querySnapshot = await _firestore
          .collection('tutorialDays')
          .orderBy('dayNumber')
          .get();
      
      _tutorialDays = querySnapshot.docs
          .map((doc) => TutorialDay.fromFirestore(doc))
          .toList();
      
      _tutorialDaysMap = {for (var day in _tutorialDays) day.id: day};
      */
      
      _error = null;
    } catch (e) {
      _error = ErrorHandler.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load user progress for all tutorial days
  Future<void> loadUserProgress(String userId) async {
    if (userId.isEmpty) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // For demo purposes, we'll use sample data instead of Firestore
      await Future.delayed(const Duration(milliseconds: 500));
      
      _userProgress = _getSampleProgress(userId);
      
      // In a real app, this would be the code:
      /*
      final querySnapshot = await _firestore
          .collection('tutorialProgress')
          .where('userId', isEqualTo: userId)
          .get();
      
      _userProgress = {};
      for (final doc in querySnapshot.docs) {
        final progress = TutorialProgress.fromFirestore(doc);
        _userProgress[progress.tutorialDayId] = progress;
      }
      */
      
      _error = null;
    } catch (e) {
      _error = ErrorHandler.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update exercise completion status
  Future<void> updateExerciseCompletion({
    required String userId,
    required String tutorialDayId,
    required String exerciseId,
    required bool isCompleted,
  }) async {
    if (userId.isEmpty || tutorialDayId.isEmpty || exerciseId.isEmpty) return;
    
    try {
      final tutorialDay = _tutorialDaysMap[tutorialDayId];
      if (tutorialDay == null) {
        throw Exception('Tutorial day not found');
      }
      
      // Get current progress or create new one
      final currentProgress = _userProgress[tutorialDayId] ?? TutorialProgress(
        id: 'progress-$tutorialDayId-$userId',
        userId: userId,
        tutorialDayId: tutorialDayId,
        progressPercentage: 0.0,
        completedExerciseIds: [],
        lastUpdated: DateTime.now(),
        isCompleted: false,
      );
      
      // Update completed exercise IDs
      List<String> updatedCompletedIds = List.from(currentProgress.completedExerciseIds);
      if (isCompleted && !updatedCompletedIds.contains(exerciseId)) {
        updatedCompletedIds.add(exerciseId);
      } else if (!isCompleted && updatedCompletedIds.contains(exerciseId)) {
        updatedCompletedIds.remove(exerciseId);
      }
      
      // Calculate new progress
      final updatedProgress = TutorialProgress.updateProgress(
        currentProgress: currentProgress,
        allExercises: tutorialDay.exercises,
        completedExerciseIds: updatedCompletedIds,
      );
      
      // Update local state
      _userProgress[tutorialDayId] = updatedProgress;
      notifyListeners();
      
      // In a real app, we would update Firestore:
      /*
      // Get document reference (create or update)
      final progressRef = _firestore.collection('tutorialProgress').doc(updatedProgress.id);
      
      // Update document
      await progressRef.set(updatedProgress.toFirestore(), SetOptions(merge: true));
      */
    } catch (e) {
      _error = ErrorHandler.handleError(e);
      notifyListeners();
    }
  }
  
  // Mark tutorial day as completed
  Future<void> markTutorialDayCompleted({
    required String userId,
    required String tutorialDayId,
  }) async {
    if (userId.isEmpty || tutorialDayId.isEmpty) return;
    
    try {
      final tutorialDay = _tutorialDaysMap[tutorialDayId];
      if (tutorialDay == null) {
        throw Exception('Tutorial day not found');
      }
      
      // Get all exercise IDs
      final allExerciseIds = tutorialDay.exercises.map((e) => e.id).toList();
      
      // Get current progress or create new one
      final currentProgress = _userProgress[tutorialDayId] ?? TutorialProgress(
        id: 'progress-$tutorialDayId-$userId',
        userId: userId,
        tutorialDayId: tutorialDayId,
        progressPercentage: 0.0,
        completedExerciseIds: [],
        lastUpdated: DateTime.now(),
        isCompleted: false,
      );
      
      // Create completed progress
      final completedProgress = currentProgress.copyWith(
        progressPercentage: 1.0,
        completedExerciseIds: allExerciseIds,
        lastUpdated: DateTime.now(),
        isCompleted: true,
      );
      
      // Update local state
      _userProgress[tutorialDayId] = completedProgress;
      notifyListeners();
      
      // In a real app, we would update Firestore:
      /*
      // Get document reference (create or update)
      final progressRef = _firestore.collection('tutorialProgress').doc(completedProgress.id);
      
      // Update document
      await progressRef.set(completedProgress.toFirestore(), SetOptions(merge: true));
      */
    } catch (e) {
      _error = ErrorHandler.handleError(e);
      notifyListeners();
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Sample data for demo purposes
  List<TutorialDay> _getSampleTutorialDays() {
    final exercises1 = [
      TutorialExercise(
        id: 'exercise1',
        title: 'Warm-up Stretches',
        description: 'Simple stretches to prepare your body for the workout.',
        orderIndex: 0,
        videoUrl: 'https://example.com/videos/warm-up.mp4',
        durationSeconds: 300,
        sets: 1,
        difficulty: 'beginner',
        muscleGroups: ['full body'],
      ),
      TutorialExercise(
        id: 'exercise2',
        title: 'Basic Squats',
        description: 'Learn proper form for bodyweight squats.',
        orderIndex: 1,
        videoUrl: 'https://example.com/videos/squats.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 10,
        difficulty: 'beginner',
        muscleGroups: ['legs', 'glutes'],
      ),
      TutorialExercise(
        id: 'exercise3',
        title: 'Push-ups',
        description: 'Proper push-up technique with modifications for beginners.',
        orderIndex: 2,
        videoUrl: 'https://example.com/videos/pushups.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 8,
        difficulty: 'beginner',
        muscleGroups: ['chest', 'arms', 'shoulders'],
      ),
      TutorialExercise(
        id: 'exercise4',
        title: 'Planks',
        description: 'Core stability exercise with proper form demonstration.',
        orderIndex: 3,
        videoUrl: 'https://example.com/videos/planks.mp4',
        durationSeconds: 180,
        sets: 3,
        weight: 'Bodyweight',
        difficulty: 'beginner',
        muscleGroups: ['core', 'shoulders'],
      ),
      TutorialExercise(
        id: 'exercise5',
        title: 'Cool Down',
        description: 'Gentle stretches to cool down after workout.',
        orderIndex: 4,
        videoUrl: 'https://example.com/videos/cooldown.mp4',
        durationSeconds: 300,
        sets: 1,
        difficulty: 'beginner',
        muscleGroups: ['full body'],
      ),
    ];
    
    final exercises2 = [
      TutorialExercise(
        id: 'exercise6',
        title: 'Dumbbell Rows',
        description: 'Upper back exercise using dumbbells.',
        orderIndex: 0,
        videoUrl: 'https://example.com/videos/dumbbell-rows.mp4',
        durationSeconds: 240,
        sets: 3,
        reps: 12,
        weight: '10-15 lbs',
        difficulty: 'beginner',
        muscleGroups: ['back', 'biceps'],
      ),
      TutorialExercise(
        id: 'exercise7',
        title: 'Dumbbell Chest Press',
        description: 'Chest exercise using dumbbells.',
        orderIndex: 1,
        videoUrl: 'https://example.com/videos/chest-press.mp4',
        durationSeconds: 240,
        sets: 3,
        reps: 10,
        weight: '15-20 lbs',
        difficulty: 'beginner',
        muscleGroups: ['chest', 'triceps', 'shoulders'],
      ),
      TutorialExercise(
        id: 'exercise8',
        title: 'Bicep Curls',
        description: 'Isolation exercise for biceps using dumbbells.',
        orderIndex: 2,
        videoUrl: 'https://example.com/videos/bicep-curls.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 12,
        weight: '10-15 lbs',
        difficulty: 'beginner',
        muscleGroups: ['biceps'],
      ),
      TutorialExercise(
        id: 'exercise9',
        title: 'Tricep Extensions',
        description: 'Isolation exercise for triceps using dumbbells.',
        orderIndex: 3,
        videoUrl: 'https://example.com/videos/tricep-extensions.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 12,
        weight: '10-15 lbs',
        difficulty: 'beginner',
        muscleGroups: ['triceps'],
      ),
    ];

    final exercises3 = [
      TutorialExercise(
        id: 'exercise10',
        title: 'Lunges',
        description: 'Lower body exercise focusing on legs and glutes.',
        orderIndex: 0,
        videoUrl: 'https://example.com/videos/lunges.mp4',
        durationSeconds: 240,
        sets: 3,
        reps: 10,
        weight: 'Bodyweight',
        difficulty: 'beginner',
        muscleGroups: ['legs', 'glutes'],
      ),
      TutorialExercise(
        id: 'exercise11',
        title: 'Romanian Deadlifts',
        description: 'Posterior chain exercise focusing on hamstrings and glutes.',
        orderIndex: 1,
        videoUrl: 'https://example.com/videos/rdl.mp4',
        durationSeconds: 240,
        sets: 3,
        reps: 10,
        weight: '15-20 lbs',
        difficulty: 'intermediate',
        muscleGroups: ['hamstrings', 'glutes', 'lower back'],
      ),
      TutorialExercise(
        id: 'exercise12',
        title: 'Calf Raises',
        description: 'Isolation exercise for calves.',
        orderIndex: 2,
        videoUrl: 'https://example.com/videos/calf-raises.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 15,
        weight: 'Bodyweight',
        difficulty: 'beginner',
        muscleGroups: ['calves'],
      ),
      TutorialExercise(
        id: 'exercise13',
        title: 'Glute Bridges',
        description: 'Exercise focusing on glute activation and strength.',
        orderIndex: 3,
        videoUrl: 'https://example.com/videos/glute-bridges.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 15,
        weight: 'Bodyweight',
        difficulty: 'beginner',
        muscleGroups: ['glutes', 'core'],
      ),
    ];

    final exercises4 = [
      TutorialExercise(
        id: 'exercise14',
        title: 'Kettlebell Swings',
        description: 'Dynamic full-body exercise using a kettlebell.',
        orderIndex: 0,
        videoUrl: 'https://example.com/videos/kb-swings.mp4',
        durationSeconds: 240,
        sets: 4,
        reps: 15,
        weight: '15-25 lbs',
        difficulty: 'intermediate',
        muscleGroups: ['glutes', 'hamstrings', 'back', 'shoulders'],
      ),
      TutorialExercise(
        id: 'exercise15',
        title: 'Burpees',
        description: 'High-intensity full-body exercise.',
        orderIndex: 1,
        videoUrl: 'https://example.com/videos/burpees.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 10,
        weight: 'Bodyweight',
        difficulty: 'intermediate',
        muscleGroups: ['full body', 'cardio'],
      ),
      TutorialExercise(
        id: 'exercise16',
        title: 'Mountain Climbers',
        description: 'Dynamic core and cardio exercise.',
        orderIndex: 2,
        videoUrl: 'https://example.com/videos/mountain-climbers.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 20,
        weight: 'Bodyweight',
        difficulty: 'intermediate',
        muscleGroups: ['core', 'shoulders', 'cardio'],
      ),
      TutorialExercise(
        id: 'exercise17',
        title: 'Box Jumps',
        description: 'Plyometric exercise for lower body power.',
        orderIndex: 3,
        videoUrl: 'https://example.com/videos/box-jumps.mp4',
        durationSeconds: 180,
        sets: 3,
        reps: 10,
        weight: 'Bodyweight',
        difficulty: 'intermediate',
        muscleGroups: ['legs', 'glutes', 'cardio'],
      ),
    ];

    final exercises5 = [
      TutorialExercise(
        id: 'exercise18',
        title: 'Barbell Squats',
        description: 'Compound lower body exercise using a barbell.',
        orderIndex: 0,
        videoUrl: 'https://example.com/videos/barbell-squats.mp4',
        durationSeconds: 300,
        sets: 4,
        reps: 8,
        weight: 'Varies',
        difficulty: 'advanced',
        muscleGroups: ['legs', 'glutes', 'core'],
      ),
      TutorialExercise(
        id: 'exercise19',
        title: 'Deadlifts',
        description: 'Compound exercise for posterior chain using a barbell.',
        orderIndex: 1,
        videoUrl: 'https://example.com/videos/deadlifts.mp4',
        durationSeconds: 300,
        sets: 4,
        reps: 6,
        weight: 'Varies',
        difficulty: 'advanced',
        muscleGroups: ['hamstrings', 'glutes', 'back', 'forearms'],
      ),
      TutorialExercise(
        id: 'exercise20',
        title: 'Bench Press',
        description: 'Compound upper body exercise using a barbell and bench.',
        orderIndex: 2,
        videoUrl: 'https://example.com/videos/bench-press.mp4',
        durationSeconds: 300,
        sets: 4,
        reps: 8,
        weight: 'Varies',
        difficulty: 'advanced',
        muscleGroups: ['chest', 'triceps', 'shoulders'],
      ),
      TutorialExercise(
        id: 'exercise21',
        title: 'Overhead Press',
        description: 'Compound shoulder exercise using a barbell.',
        orderIndex: 3,
        videoUrl: 'https://example.com/videos/overhead-press.mp4',
        durationSeconds: 240,
        sets: 4,
        reps: 6,
        weight: 'Varies',
        difficulty: 'advanced',
        muscleGroups: ['shoulders', 'triceps', 'upper back'],
      ),
    ];
    
    return [
      TutorialDay(
        id: 'day1',
        title: 'Day 1: Getting Started',
        subtitle: 'Introduction to FitSAGA',
        description: 'Learn the basics of the gym and get familiar with the equipment. Focus on proper form and technique for fundamental exercises.',
        dayNumber: 1,
        difficulty: 'beginner',
        estimatedMinutes: 30,
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
        exercises: exercises1,
        tags: ['beginner', 'introduction', 'full body'],
      ),
      TutorialDay(
        id: 'day2',
        title: 'Day 2: Upper Body Focus',
        subtitle: 'Chest, Arms, and Shoulders',
        description: 'Build strength in your upper body with these targeted exercises. Learn proper form for dumbbell exercises.',
        dayNumber: 2,
        difficulty: 'beginner',
        estimatedMinutes: 45,
        imageUrl: 'https://images.unsplash.com/photo-1532384748853-8f54a8f476e2',
        exercises: exercises2,
        tags: ['beginner', 'upper body', 'strength'],
      ),
      TutorialDay(
        id: 'day3',
        title: 'Day 3: Lower Body Power',
        subtitle: 'Legs, Glutes, and Core',
        description: 'Focus on your lower body to build a strong foundation. Learn key exercises for leg and glute development.',
        dayNumber: 3,
        difficulty: 'intermediate',
        estimatedMinutes: 40,
        imageUrl: 'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a',
        exercises: exercises3,
        tags: ['intermediate', 'lower body', 'strength'],
      ),
      TutorialDay(
        id: 'day4',
        title: 'Day 4: Cardio Blast',
        subtitle: 'Heart-Pumping Exercises',
        description: 'Improve your cardiovascular health with this high-energy session. Combine strength and cardio for maximum benefit.',
        dayNumber: 4,
        difficulty: 'intermediate',
        estimatedMinutes: 50,
        imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c',
        exercises: exercises4,
        tags: ['intermediate', 'cardio', 'full body'],
      ),
      TutorialDay(
        id: 'day5',
        title: 'Day 5: Full Body Circuit',
        subtitle: 'Total Body Workout',
        description: 'Challenge every muscle group with this comprehensive circuit. Focus on compound movements with barbell exercises.',
        dayNumber: 5,
        difficulty: 'advanced',
        estimatedMinutes: 60,
        imageUrl: 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712',
        exercises: exercises5,
        tags: ['advanced', 'strength', 'full body'],
      ),
    ];
  }
  
  // Sample progress data for demo purposes
  Map<String, TutorialProgress> _getSampleProgress(String userId) {
    return {
      'day1': TutorialProgress(
        id: 'progress-day1-$userId',
        userId: userId,
        tutorialDayId: 'day1',
        progressPercentage: 1.0, // Completed
        completedExerciseIds: ['exercise1', 'exercise2', 'exercise3', 'exercise4', 'exercise5'],
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        isCompleted: true,
      ),
      'day2': TutorialProgress(
        id: 'progress-day2-$userId',
        userId: userId,
        tutorialDayId: 'day2',
        progressPercentage: 0.75, // In progress
        completedExerciseIds: ['exercise6', 'exercise7', 'exercise8'],
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: false,
      ),
      'day3': TutorialProgress(
        id: 'progress-day3-$userId',
        userId: userId,
        tutorialDayId: 'day3',
        progressPercentage: 0.25, // Just started
        completedExerciseIds: ['exercise10'],
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: false,
      ),
    };
  }
}