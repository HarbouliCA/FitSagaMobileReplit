import 'package:flutter/material.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/theme/app_theme.dart';

class TutorialFilter extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedDifficulty;
  final Function(String?) onCategoryChanged;
  final Function(String?) onDifficultyChanged;
  final Function() onClearFilters;
  
  const TutorialFilter({
    Key? key,
    this.selectedCategory,
    this.selectedDifficulty,
    required this.onCategoryChanged,
    required this.onDifficultyChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter by category
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingRegular,
              vertical: AppTheme.paddingSmall,
            ),
            child: Row(
              children: [
                const Text(
                  'Category:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeRegular,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLarge),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryFilterChip(
                          'All',
                          null,
                          Icons.all_inclusive,
                        ),
                        _buildCategoryFilterChip(
                          'Exercise',
                          AppConstants.tutorialCategoryExercise,
                          Icons.fitness_center,
                        ),
                        _buildCategoryFilterChip(
                          'Nutrition',
                          AppConstants.tutorialCategoryNutrition,
                          Icons.restaurant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter by difficulty
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingRegular,
              vertical: AppTheme.paddingSmall,
            ),
            child: Row(
              children: [
                const Text(
                  'Difficulty:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeRegular,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingLarge),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDifficultyFilterChip(
                          'All',
                          null,
                          Colors.grey,
                        ),
                        _buildDifficultyFilterChip(
                          'Beginner',
                          AppConstants.difficultyBeginner,
                          Colors.green,
                        ),
                        _buildDifficultyFilterChip(
                          'Intermediate',
                          AppConstants.difficultyIntermediate,
                          Colors.orange,
                        ),
                        _buildDifficultyFilterChip(
                          'Advanced',
                          AppConstants.difficultyAdvanced,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Clear filters button
          if (selectedCategory != null || selectedDifficulty != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingRegular,
                vertical: AppTheme.paddingSmall,
              ),
              child: ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryFilterChip(String label, String? category, IconData icon) {
    final isSelected = selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
      child: FilterChip(
        selected: isSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        backgroundColor: Colors.grey.withOpacity(0.1),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
        ),
        label: Text(label),
        onSelected: (selected) {
          onCategoryChanged(selected ? category : null);
        },
      ),
    );
  }
  
  Widget _buildDifficultyFilterChip(String label, String? difficulty, Color color) {
    final isSelected = selectedDifficulty == difficulty;
    
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
      child: FilterChip(
        selected: isSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        backgroundColor: Colors.grey.withOpacity(0.1),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        avatar: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        label: Text(label),
        onSelected: (selected) {
          onDifficultyChanged(selected ? difficulty : null);
        },
      ),
    );
  }
}
