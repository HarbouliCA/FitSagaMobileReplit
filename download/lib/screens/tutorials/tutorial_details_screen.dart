import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/custom_app_bar.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/utils/date_formatter.dart';

class TutorialDetailsScreen extends StatelessWidget {
  const TutorialDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final tutorial = tutorialProvider.selectedTutorial;
    
    if (tutorial == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Tutorial Details',
        ),
        body: const Center(
          child: Text('No tutorial selected'),
        ),
      );
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tutorial Details',
        showCredits: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tutorial thumbnail
            _buildTutorialHeader(tutorial),
            
            // Tutorial details
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tutorial title
                  Text(
                    tutorial.title,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingRegular),
                  
                  // Author and difficulty
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tutorial.author,
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tutorial.difficultyLevel,
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingRegular),
                  
                  // Tutorial stats
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingRegular),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.timer,
                          DateFormatter.formatDuration(tutorial.duration),
                          'Duration',
                        ),
                        _buildStatItem(
                          Icons.calendar_today,
                          '${tutorial.days.length} ${tutorial.days.length == 1 ? 'day' : 'days'}',
                          'Program',
                        ),
                        _buildStatItem(
                          tutorial.category == 'exercise' 
                              ? Icons.fitness_center 
                              : Icons.restaurant,
                          tutorial.category == 'exercise' ? 'Exercise' : 'Nutrition',
                          'Category',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Tutorial description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingRegular),
                  
                  Text(
                    tutorial.description,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeRegular,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  // Tutorial goals
                  if (tutorial.goals != null && tutorial.goals!.isNotEmpty) ...[
                    const Text(
                      'Goals',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    ...tutorial.goals!.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(goal),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  
                  // Tutorial requirements
                  if (tutorial.requirements != null && tutorial.requirements!.isNotEmpty) ...[
                    const Text(
                      'Requirements',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    ...tutorial.requirements!.map((requirement) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.arrow_right,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(requirement),
                          ),
                        ],
                      ),
                    )),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  
                  // Tutorial days
                  const Text(
                    'Program Schedule',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingRegular),
                  
                  ...tutorial.days.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    return _buildDayCard(context, tutorialProvider, day, index);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialHeader(TutorialModel tutorial) {
    String imageUrl;
    
    // Get image URL based on category
    if (tutorial.category == 'exercise') {
      // Use exercise tutorial images
      imageUrl = tutorial.thumbnailUrl ?? 'https://pixabay.com/get/g0685dc24053184d714b4802dfeaf235646cd5c06cb8c326b1106f1647d32c8d0e0468e51ce2e6bfeeb3a7d74f3316bcfa4f5aef139818768496ba4b6593b881e_1280.jpg';
    } else {
      // Use nutrition tutorial images
      imageUrl = tutorial.thumbnailUrl ?? 'https://pixabay.com/get/g1336b6b70c7f64628d7e320e0a883f617d121431bc4c99e0658a78429471d3172572c3d4403ef7661af025e8a6abdfe07838430b2f9cdff5211177286733581d_1280.jpg';
    }

    return Stack(
      children: [
        // Thumbnail image
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  tutorial.category == 'exercise' 
                      ? Icons.fitness_center 
                      : Icons.restaurant,
                  color: Colors.grey.shade400,
                  size: 64,
                ),
              );
            },
          ),
        ),
        
        // Gradient overlay for text visibility
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(color: Colors.black, opacity: 0.1),
                Colors.black.withValues(color: Colors.black, opacity: 0.5),
              ],
            ),
          ),
        ),
        
        // Category badge
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: tutorial.category == 'exercise' 
                  ? AppTheme.exerciseColor 
                  : AppTheme.nutritionColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tutorial.category == 'exercise' 
                      ? Icons.fitness_center 
                      : Icons.restaurant,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  tutorial.category == 'exercise' ? 'Exercise' : 'Nutrition',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.fontSizeRegular,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLightColor,
            fontSize: AppTheme.fontSizeSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context, 
    TutorialProvider tutorialProvider, 
    TutorialDayModel day, 
    int index
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingRegular),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: ExpansionTile(
        title: Text(
          'Day ${day.dayNumber}: ${day.title}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${day.exercises.length} ${day.exercises.length == 1 ? 'exercise' : 'exercises'}',
          style: const TextStyle(
            fontSize: AppTheme.fontSizeSmall,
            color: AppTheme.textLightColor,
          ),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(color: AppTheme.primaryColor, opacity: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${day.dayNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingRegular,
              vertical: AppTheme.paddingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.description,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeRegular,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                const Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                ...day.exercises.map((exercise) => _buildExerciseItem(
                  context, 
                  tutorialProvider, 
                  exercise, 
                  day,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(
    BuildContext context, 
    TutorialProvider tutorialProvider, 
    ExerciseModel exercise, 
    TutorialDayModel day
  ) {
    final bool hasVideo = exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingRegular,
          vertical: AppTheme.paddingSmall,
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          hasVideo 
              ? 'Duration: ${DateFormatter.formatDuration(exercise.duration)}' 
              : exercise.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(color: AppTheme.primaryColor, opacity: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(
            hasVideo ? Icons.play_circle_outline : Icons.fitness_center,
            color: AppTheme.primaryColor,
          ),
        ),
        trailing: hasVideo
            ? const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textLightColor,
              )
            : null,
        onTap: hasVideo
            ? () {
                // Navigate to video player screen
                tutorialProvider.selectExercise(exercise);
                Navigator.pushNamed(context, '/tutorials/video');
              }
            : null,
      ),
    );
  }
}
