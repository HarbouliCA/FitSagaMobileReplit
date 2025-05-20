import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/custom_app_bar.dart';
import 'package:fitsaga/widgets/common/custom_drawer.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/widgets/tutorials/tutorial_card.dart';
import 'package:fitsaga/widgets/tutorials/tutorial_filter.dart';
import 'package:fitsaga/config/constants.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({Key? key}) : super(key: key);

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _selectedIndex = 2; // Default tab index for bottom nav

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    await tutorialProvider.fetchAllTutorials();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to corresponding screens
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/sessions');
        break;
      case 2:
        // Already on tutorials
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _onSearch(String query) {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.setSearchQuery(query);
  }

  void _clearSearch() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    setState(() {
      _isSearching = false;
      _searchController.clear();
      tutorialProvider.setSearchQuery(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);

    return Scaffold(
      appBar: SearchAppBar(
        title: 'Tutorials',
        showCredits: true,
        onSearch: _onSearch,
        onClear: _clearSearch,
        initialQuery: tutorialProvider.searchQuery,
      ),
      drawer: const CustomDrawer(currentRoute: '/tutorials'),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Tutorial filters
            TutorialFilter(
              selectedCategory: tutorialProvider.selectedCategory,
              selectedDifficulty: tutorialProvider.selectedDifficulty,
              onCategoryChanged: tutorialProvider.setCategoryFilter,
              onDifficultyChanged: tutorialProvider.setDifficultyFilter,
              onClearFilters: tutorialProvider.clearFilters,
            ),
            
            // Tutorials grid
            Expanded(
              child: _buildTutorialsGrid(tutorialProvider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Tutorials',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textLightColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildTutorialsGrid(TutorialProvider tutorialProvider) {
    final tutorials = tutorialProvider.filteredTutorials;
    final isLoading = tutorialProvider.loading;
    final hasError = tutorialProvider.error != null;
    
    if (isLoading) {
      return const LoadingIndicator(message: 'Loading tutorials...');
    }
    
    if (hasError) {
      return ErrorDisplayWidget(
        message: tutorialProvider.error ?? 'Failed to load tutorials',
        onRetry: _refreshData,
      );
    }
    
    if (tutorials.isEmpty) {
      return const EmptyStateWidget(
        message: 'No tutorials found',
        subMessage: 'Try adjusting your filters or check back later',
        icon: Icons.videocam_off,
      );
    }
    
    // Quick category chips
    return Column(
      children: [
        // Quick category filter chips
        if (tutorialProvider.selectedCategory == null && 
            tutorialProvider.selectedDifficulty == null &&
            tutorialProvider.searchQuery == null) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingLarge,
              vertical: AppTheme.paddingRegular,
            ),
            child: Row(
              children: [
                _buildQuickFilterChip(
                  'Exercise',
                  AppConstants.tutorialCategoryExercise,
                  Icons.fitness_center,
                  tutorialProvider,
                ),
                const SizedBox(width: 12),
                _buildQuickFilterChip(
                  'Nutrition',
                  AppConstants.tutorialCategoryNutrition,
                  Icons.restaurant,
                  tutorialProvider,
                ),
                const SizedBox(width: 12),
                _buildQuickFilterChip(
                  'Beginner',
                  AppConstants.difficultyBeginner,
                  Icons.star_border,
                  tutorialProvider,
                  isDifficulty: true,
                ),
                const SizedBox(width: 12),
                _buildQuickFilterChip(
                  'Advanced',
                  AppConstants.difficultyAdvanced,
                  Icons.star,
                  tutorialProvider,
                  isDifficulty: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        
        // Tutorials grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingRegular),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = tutorials[index];
              return TutorialCard(
                tutorial: tutorial,
                onTap: () {
                  tutorialProvider.selectTutorial(tutorial);
                  Navigator.pushNamed(context, '/tutorials/details');
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(
    String label, 
    String value, 
    IconData icon, 
    TutorialProvider provider, 
    {bool isDifficulty = false}
  ) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: AppTheme.primaryColor,
      ),
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      onPressed: () {
        if (isDifficulty) {
          provider.setDifficultyFilter(value);
        } else {
          provider.setCategoryFilter(value);
        }
      },
    );
  }
}
