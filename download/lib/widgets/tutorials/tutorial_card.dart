import 'package:flutter/material.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/utils/date_formatter.dart';

class TutorialCard extends StatelessWidget {
  final TutorialModel tutorial;
  final VoidCallback onTap;
  
  const TutorialCard({
    Key? key,
    required this.tutorial,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine color based on category
    Color categoryColor = tutorial.category == 'exercise' 
        ? AppTheme.exerciseColor 
        : AppTheme.nutritionColor;
    
    // Difficulty color
    Color difficultyColor;
    switch (tutorial.difficulty) {
      case 'beginner':
        difficultyColor = Colors.green;
        break;
      case 'intermediate':
        difficultyColor = Colors.orange;
        break;
      case 'advanced':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.blue;
    }
    
    return Card(
      elevation: AppTheme.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutorial thumbnail
            Stack(
              children: [
                // Thumbnail image
                Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: tutorial.thumbnailUrl != null
                      ? Image.network(
                          tutorial.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                tutorial.category == 'exercise' 
                                    ? Icons.fitness_center 
                                    : Icons.restaurant,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            tutorial.category == 'exercise' 
                                ? Icons.fitness_center 
                                : Icons.restaurant,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                ),
                
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
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
                
                // Difficulty badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: difficultyColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tutorial.difficultyLevel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Tutorial details
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingRegular),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tutorial.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  // Author
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
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  // Duration and days
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDuration(tutorial.duration),
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tutorial.days.length} ${tutorial.days.length == 1 ? 'day' : 'days'}',
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedTutorialCard extends StatelessWidget {
  final TutorialModel tutorial;
  final VoidCallback onTap;
  
  const FeaturedTutorialCard({
    Key? key,
    required this.tutorial,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppTheme.paddingRegular),
      child: Card(
        elevation: AppTheme.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutorial thumbnail
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: tutorial.thumbnailUrl != null
                    ? Image.network(
                        tutorial.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              tutorial.category == 'exercise' 
                                  ? Icons.fitness_center 
                                  : Icons.restaurant,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          tutorial.category == 'exercise' 
                              ? Icons.fitness_center 
                              : Icons.restaurant,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      ),
              ),
              
              // Tutorial details
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingRegular),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and difficulty
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tutorial.category == 'exercise' 
                                ? AppTheme.exerciseColor.withOpacity(0.1) 
                                : AppTheme.nutritionColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                          child: Text(
                            tutorial.category == 'exercise' ? 'Exercise' : 'Nutrition',
                            style: TextStyle(
                              color: tutorial.category == 'exercise' 
                                  ? AppTheme.exerciseColor 
                                  : AppTheme.nutritionColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                          child: Text(
                            tutorial.difficultyLevel,
                            style: const TextStyle(
                              color: AppTheme.textLightColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // Title
                    Text(
                      tutorial.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeRegular,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // Duration and days count
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDuration(tutorial.duration),
                          style: const TextStyle(
                            color: AppTheme.textLightColor,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tutorial.days.length} ${tutorial.days.length == 1 ? 'day' : 'days'}',
                          style: const TextStyle(
                            color: AppTheme.textLightColor,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
