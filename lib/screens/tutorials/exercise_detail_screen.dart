import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model_revised.dart';
import 'package:fitsaga/providers/tutorial_provider_revised.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/tutorials/azure_video_player.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String tutorialId;
  final String exerciseId;
  final int dayNumber;

  const ExerciseDetailScreen({
    Key? key,
    required this.tutorialId,
    required this.exerciseId,
    required this.dayNumber,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _loading = false;
  String? _error;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    
    // Check if this exercise is already completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCompletionStatus();
    });
  }
  
  void _checkCompletionStatus() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    setState(() {
      _isCompleted = tutorialProvider.isExerciseCompleted(
        tutorialId: widget.tutorialId,
        exerciseId: widget.exerciseId,
      );
    });
  }
  
  Future<void> _markAsCompleted() async {
    if (_isCompleted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to track your progress'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final success = await tutorialProvider.markExerciseAsCompleted(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorialId,
        exerciseId: widget.exerciseId,
      );
      
      if (success) {
        setState(() {
          _isCompleted = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercise marked as completed!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        setState(() {
          _error = 'Failed to mark exercise as completed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final exercise = tutorialProvider.getExerciseById(
      tutorialId: widget.tutorialId,
      exerciseId: widget.exerciseId,
    );
    
    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exercise Details'),
        ),
        body: const Center(
          child: Text('Exercise not found'),
        ),
      );
    }
    
    final tutorialDay = tutorialProvider.getDayByNumber(
      tutorialId: widget.tutorialId,
      dayNumber: widget.dayNumber,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          // Completion status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isCompleted
                ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400),
          ),
        ],
      ),
      body: _loading
          ? const LoadingIndicator(message: 'Updating progress...')
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video player (if video URL exists)
                  if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty)
                    AzureVideoPlayer(
                      videoUrl: exercise.videoUrl!,
                      tutorialId: widget.tutorialId,
                      exerciseId: widget.exerciseId,
                    )
                  // Thumbnail image (if no video but has image)
                  else if (exercise.thumbnailUrl != null && exercise.thumbnailUrl!.isNotEmpty)
                    Image.network(
                      exercise.thumbnailUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  // Placeholder (if no video or image)
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    
                  // Exercise details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise metadata
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Difficulty
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getDifficultyColor(exercise.difficulty).withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                _getDifficultyText(exercise.difficulty),
                                style: TextStyle(
                                  color: _getDifficultyColor(exercise.difficulty),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // Duration
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${exercise.duration} min',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Exercise stats (sets, reps, rest)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Sets
                                _buildStatItem(
                                  icon: Icons.repeat,
                                  label: 'Sets',
                                  value: '${exercise.sets}',
                                ),
                                
                                // Vertical divider
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                
                                // Reps
                                _buildStatItem(
                                  icon: Icons.fitness_center,
                                  label: 'Reps',
                                  value: exercise.reps ?? '-',
                                ),
                                
                                // Vertical divider
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                
                                // Rest time
                                _buildStatItem(
                                  icon: Icons.timer_outlined,
                                  label: 'Rest',
                                  value: exercise.restBetweenSets != null
                                      ? '${exercise.restBetweenSets}s'
                                      : '-',
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Equipment section
                        if (exercise.equipment != null && exercise.equipment!.isNotEmpty) ...[
                          const Text(
                            'Equipment Required',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.equipment!.map((item) {
                              return Chip(
                                label: Text(item),
                                backgroundColor: Colors.grey.shade200,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Muscle groups
                        if (exercise.muscleGroups != null && exercise.muscleGroups!.isNotEmpty) ...[
                          const Text(
                            'Target Muscle Groups',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: exercise.muscleGroups!.map((muscle) {
                              return Chip(
                                label: Text(muscle),
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.description,
                          style: const TextStyle(
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Instructions
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...exercise.instructions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Step number
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Step description
                                Expanded(
                                  child: Text(
                                    step,
                                    style: const TextStyle(
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 32),
                        
                        // Complete button
                        if (!_isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _markAsCompleted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Mark as Completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        
                        if (_isCompleted)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.successColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'You have completed this exercise',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.errorColor,
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Navigation to next/previous exercise
                        if (tutorialDay != null)
                          _buildExerciseNavigation(context, tutorialDay, exercise.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildExerciseNavigation(
    BuildContext context,
    TutorialDay day,
    String currentExerciseId,
  ) {
    // Find index of current exercise
    final currentIndex = day.exercises.indexWhere((e) => e.id == currentExerciseId);
    if (currentIndex == -1) return const SizedBox.shrink();
    
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex < day.exercises.length - 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous exercise button
        if (hasPrevious)
          OutlinedButton.icon(
            onPressed: () {
              final previousExercise = day.exercises[currentIndex - 1];
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailScreen(
                    tutorialId: widget.tutorialId,
                    exerciseId: previousExercise.id,
                    dayNumber: widget.dayNumber,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryColor),
            ),
          )
        else
          const SizedBox(width: 100),
          
        // Exercise counter
        Text(
          '${currentIndex + 1} / ${day.exercises.length}',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        
        // Next exercise button
        if (hasNext)
          ElevatedButton.icon(
            onPressed: () {
              final nextExercise = day.exercises[currentIndex + 1];
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailScreen(
                    tutorialId: widget.tutorialId,
                    exerciseId: nextExercise.id,
                    dayNumber: widget.dayNumber,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          )
        else
          const SizedBox(width: 100),
      ],
    );
  }
  
  Color _getDifficultyColor(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return Colors.green;
      case TutorialDifficulty.intermediate:
        return Colors.blue;
      case TutorialDifficulty.advanced:
        return Colors.orange;
    }
  }
  
  String _getDifficultyText(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return 'Beginner';
      case TutorialDifficulty.intermediate:
        return 'Intermediate';
      case TutorialDifficulty.advanced:
        return 'Advanced';
    }
  }
}