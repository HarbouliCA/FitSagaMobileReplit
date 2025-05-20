import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/screens/tutorials/tutorial_details_screen.dart';
import 'package:fitsaga/screens/tutorials/tutorial_create_edit_screen.dart';

class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({Key? key}) : super(key: key);

  @override
  State<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load tutorials when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTutorials();
    });
    
    // Add listener to text field
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  // Load tutorials and user progress
  Future<void> _loadTutorials() async {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!tutorialProvider.isInitialized) {
      await tutorialProvider.loadTutorials();
    }
    
    // Load user progress if authenticated
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      await tutorialProvider.loadUserProgress(authProvider.currentUser!.id);
    }
  }
  
  void _onSearchChanged() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.setFilters(query: _searchController.text);
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    tutorialProvider.clearFilters();
  }
  
  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }
  
  Widget _buildFilterSheet() {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    
    return StatefulBuilder(
      builder: (context, setState) {
        TutorialDifficulty? selectedDifficulty = tutorialProvider.difficultyFilter;
        TutorialCategory? selectedCategory = tutorialProvider.categoryFilter;
        bool premiumOnly = tutorialProvider.onlyPremium;
        
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Filter Tutorials',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Difficulty filter
                  const Text(
                    'Difficulty Level',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: selectedDifficulty == null,
                        onSelected: (_) {
                          setState(() {
                            selectedDifficulty = null;
                          });
                        },
                      ),
                      ...TutorialDifficulty.values.map((difficulty) {
                        String label;
                        switch (difficulty) {
                          case TutorialDifficulty.beginner:
                            label = 'Beginner';
                            break;
                          case TutorialDifficulty.intermediate:
                            label = 'Intermediate';
                            break;
                          case TutorialDifficulty.advanced:
                            label = 'Advanced';
                            break;
                          case TutorialDifficulty.expert:
                            label = 'Expert';
                            break;
                        }
                        
                        return FilterChip(
                          label: Text(label),
                          selected: selectedDifficulty == difficulty,
                          onSelected: (_) {
                            setState(() {
                              selectedDifficulty = difficulty;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category filter
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: selectedCategory == null,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = null;
                          });
                        },
                      ),
                      ...TutorialCategory.values.map((category) {
                        String label;
                        IconData icon;
                        
                        switch (category) {
                          case TutorialCategory.cardio:
                            label = 'Cardio';
                            icon = Icons.directions_run;
                            break;
                          case TutorialCategory.strength:
                            label = 'Strength';
                            icon = Icons.fitness_center;
                            break;
                          case TutorialCategory.flexibility:
                            label = 'Flexibility';
                            icon = Icons.accessibility;
                            break;
                          case TutorialCategory.balance:
                            label = 'Balance';
                            icon = Icons.balance;
                            break;
                          case TutorialCategory.nutrition:
                            label = 'Nutrition';
                            icon = Icons.restaurant;
                            break;
                          case TutorialCategory.recovery:
                            label = 'Recovery';
                            icon = Icons.hotel;
                            break;
                          case TutorialCategory.technique:
                            label = 'Technique';
                            icon = Icons.sports_gymnastics;
                            break;
                          case TutorialCategory.program:
                            label = 'Programs';
                            icon = Icons.calendar_today;
                            break;
                        }
                        
                        return FilterChip(
                          avatar: Icon(icon, size: 16),
                          label: Text(label),
                          selected: selectedCategory == category,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Premium toggle
                  SwitchListTile(
                    title: const Text('Premium Content Only'),
                    value: premiumOnly,
                    onChanged: (value) {
                      setState(() {
                        premiumOnly = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Spacer(),
                  
                  // Filter actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          tutorialProvider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset All'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          tutorialProvider.setFilters(
                            difficulty: selectedDifficulty,
                            category: selectedCategory,
                            premium: premiumOnly,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tutorials...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: _clearSearch,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text('Tutorials'),
        actions: [
          // Search icon
          IconButton(
            icon: Icon(_isSearching ? Icons.search_off : Icons.search),
            tooltip: _isSearching ? 'Cancel search' : 'Search',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
          ),
          
          // Filter icon
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: _openFilterDialog,
          ),
          
          // Refresh icon
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadTutorials,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Popular'),
            Tab(text: 'My Tutorials'),
          ],
        ),
      ),
      body: tutorialProvider.isLoading
          ? const LoadingIndicator(message: 'Loading tutorials...')
          : tutorialProvider.error != null
              ? CustomErrorWidget(
                  message: tutorialProvider.error!,
                  onRetry: _loadTutorials,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // For You tab - recommended tutorials
                    _isSearching || tutorialProvider.hasActiveFilters
                        ? _buildTutorialGrid(tutorialProvider.filteredTutorials)
                        : _buildRecommendedScreen(),
                    
                    // Popular tab - highest rated tutorials
                    _isSearching || tutorialProvider.hasActiveFilters
                        ? _buildTutorialGrid(tutorialProvider.filteredTutorials)
                        : _buildTutorialGrid(tutorialProvider.popularTutorials),
                    
                    // My Tutorials tab - user's in-progress and completed tutorials
                    _isSearching || tutorialProvider.hasActiveFilters
                        ? _buildTutorialGrid(tutorialProvider.filteredTutorials)
                        : _buildMyTutorialsScreen(),
                  ],
                ),
      floatingActionButton: authProvider.isAuthenticated && 
                            (authProvider.currentUser!.isAdmin || 
                             authProvider.currentUser!.isInstructor)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TutorialCreateEditScreen(),
                  ),
                ).then((value) {
                  if (value == true) {
                    _loadTutorials();
                  }
                });
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildRecommendedScreen() {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      return _buildTutorialGrid(tutorialProvider.popularTutorials);
    }
    
    final recommendedTutorials = tutorialProvider.getRecommendedTutorials();
    
    if (recommendedTutorials.isEmpty) {
      // Show popular tutorials instead
      return _buildTutorialGrid(tutorialProvider.popularTutorials);
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended section
          const Text(
            'Recommended For You',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildTutorialList(recommendedTutorials.take(3).toList()),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // In progress section
          const Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildProgressTutorialList(tutorialProvider.getInProgressTutorials()),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Categories section
          const Text(
            'Browse By Category',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildCategoriesGrid(),
        ],
      ),
    );
  }
  
  Widget _buildMyTutorialsScreen() {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      return const Center(
        child: Text('Please log in to view your tutorials'),
      );
    }
    
    final inProgressTutorials = tutorialProvider.getInProgressTutorials();
    final completedTutorials = tutorialProvider.getCompletedTutorials();
    
    if (inProgressTutorials.isEmpty && completedTutorials.isEmpty) {
      return const Center(
        child: Text('You haven\'t started any tutorials yet'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In progress section
          if (inProgressTutorials.isNotEmpty) ...[
            const Text(
              'In Progress',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildProgressTutorialList(inProgressTutorials),
            const SizedBox(height: AppTheme.spacingLarge),
          ],
          
          // Completed section
          if (completedTutorials.isNotEmpty) ...[
            const Text(
              'Completed',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildTutorialGrid(completedTutorials),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTutorialGrid(List<TutorialModel> tutorials) {
    if (tutorials.isEmpty) {
      return const Center(
        child: Text('No tutorials found'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tutorials.length,
      itemBuilder: (context, index) => _buildTutorialCard(tutorials[index]),
    );
  }
  
  Widget _buildTutorialList(List<TutorialModel> tutorials) {
    if (tutorials.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No tutorials found'),
        ),
      );
    }
    
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tutorials.length,
        itemBuilder: (context, index) => SizedBox(
          width: 160,
          child: _buildTutorialCard(tutorials[index]),
        ),
      ),
    );
  }
  
  Widget _buildProgressTutorialList(List<TutorialModel> tutorials) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    
    if (tutorials.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No tutorials in progress'),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        final tutorial = tutorials[index];
        final progress = tutorialProvider.getProgressForTutorial(tutorial.id);
        
        return InkWell(
          onTap: () => _openTutorialDetails(tutorial),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Thumbnail
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          image: tutorial.thumbnailUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(tutorial.thumbnailUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: tutorial.thumbnailUrl == null
                            ? const Icon(Icons.video_library, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Title and info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tutorial.categoryString,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Progress bar
                  if (progress != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress.progress * 100).toInt()}% complete',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTutorialCard(TutorialModel tutorial) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final progress = tutorialProvider.getProgressForTutorial(tutorial.id);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: AppTheme.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: InkWell(
        onTap: () => _openTutorialDetails(tutorial),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: tutorial.thumbnailUrl != null
                      ? Image.network(
                          tutorial.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.video_library,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
                
                // Premium badge
                if (tutorial.isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                
                // Progress overlay
                if (progress != null && progress.progress > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                      minHeight: 5,
                    ),
                  ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tutorial.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Difficulty
                  Row(
                    children: [
                      _buildDifficultyIndicator(tutorial.difficulty),
                      const SizedBox(width: 4),
                      Text(
                        tutorial.difficultyString,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating and duration
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tutorial.averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tutorial.durationMinutes} min',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
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
  
  Widget _buildDifficultyIndicator(TutorialDifficulty difficulty) {
    Color color;
    int dots;
    
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        color = Colors.green;
        dots = 1;
        break;
      case TutorialDifficulty.intermediate:
        color = Colors.blue;
        dots = 2;
        break;
      case TutorialDifficulty.advanced:
        color = Colors.orange;
        dots = 3;
        break;
      case TutorialDifficulty.expert:
        color = Colors.red;
        dots = 4;
        break;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < dots ? color : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
  
  Widget _buildCategoriesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: TutorialCategory.values.map((category) {
        String label;
        IconData icon;
        Color color;
        
        switch (category) {
          case TutorialCategory.cardio:
            label = 'Cardio';
            icon = Icons.directions_run;
            color = Colors.red;
            break;
          case TutorialCategory.strength:
            label = 'Strength';
            icon = Icons.fitness_center;
            color = Colors.blue;
            break;
          case TutorialCategory.flexibility:
            label = 'Flexibility';
            icon = Icons.accessibility;
            color = Colors.purple;
            break;
          case TutorialCategory.balance:
            label = 'Balance';
            icon = Icons.balance;
            color = Colors.green;
            break;
          case TutorialCategory.nutrition:
            label = 'Nutrition';
            icon = Icons.restaurant;
            color = Colors.orange;
            break;
          case TutorialCategory.recovery:
            label = 'Recovery';
            icon = Icons.hotel;
            color = Colors.teal;
            break;
          case TutorialCategory.technique:
            label = 'Technique';
            icon = Icons.sports_gymnastics;
            color = Colors.indigo;
            break;
          case TutorialCategory.program:
            label = 'Programs';
            icon = Icons.calendar_today;
            color = Colors.brown;
            break;
        }
        
        return InkWell(
          onTap: () {
            // Apply category filter
            final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
            tutorialProvider.setFilters(category: category);
            // Switch to the Popular tab which displays filtered results
            _tabController.animateTo(1);
          },
          child: Card(
            color: color.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              side: BorderSide(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  void _openTutorialDetails(TutorialModel tutorial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialDetailsScreen(
          tutorialId: tutorial.id,
        ),
      ),
    );
  }
}