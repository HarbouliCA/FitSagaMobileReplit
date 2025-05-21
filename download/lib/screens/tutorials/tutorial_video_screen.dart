import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/custom_app_bar.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/widgets/tutorials/video_player_widget.dart';
import 'package:fitsaga/utils/date_formatter.dart';

class TutorialVideoScreen extends StatefulWidget {
  const TutorialVideoScreen({Key? key}) : super(key: key);

  @override
  State<TutorialVideoScreen> createState() => _TutorialVideoScreenState();
}

class _TutorialVideoScreenState extends State<TutorialVideoScreen> {
  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final tutorial = tutorialProvider.selectedTutorial;
    final exercise = tutorialProvider.selectedExercise;
    
    if (tutorial == null || exercise == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Exercise Video',
        ),
        body: const Center(
          child: Text('No exercise selected'),
        ),
      );
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: exercise.name,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video player
            if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty)
              VideoPlayerWidget(
                videoUrl: exercise.videoUrl!,
                thumbnailUrl: exercise.thumbnailUrl,
              )
            else
              Container(
                height: 200,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'No video available',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            
            // Exercise details
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  // Exercise info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(exercise.difficulty).withValues(color: _getDifficultyColor(exercise.difficulty), opacity: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          _getDifficultyText(exercise.difficulty),
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                            color: _getDifficultyColor(exercise.difficulty),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDuration(exercise.duration),
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeSmall,
                          color: AppTheme.textLightColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Exercise description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingRegular),
                  
                  Text(
                    exercise.description,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeRegular,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Equipment needed
                  if (exercise.equipment != null && exercise.equipment!.isNotEmpty) ...[
                    const Text(
                      'Equipment Needed',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.equipment!.map((equipment) => Chip(
                        label: Text(equipment),
                        backgroundColor: Colors.grey.shade100,
                      )).toList(),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  
                  // Target muscle groups
                  if (exercise.muscleGroups != null && exercise.muscleGroups!.isNotEmpty) ...[
                    const Text(
                      'Target Muscle Groups',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.muscleGroups!.map((muscle) => Chip(
                        label: Text(muscle),
                        backgroundColor: AppTheme.primaryColor.withValues(color: AppTheme.primaryColor, opacity: 0.1),
                        labelStyle: TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      )).toList(),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  
                  // Instructions
                  if (exercise.instructions != null && exercise.instructions!.isNotEmpty) ...[
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    ...exercise.instructions!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final instruction = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
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
                                    fontSize: AppTheme.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                instruction,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSizeRegular,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'All Levels';
    }
  }
}
