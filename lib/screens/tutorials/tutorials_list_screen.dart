import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TutorialsListScreen extends StatefulWidget {
  const TutorialsListScreen({Key? key}) : super(key: key);

  @override
  State<TutorialsListScreen> createState() => _TutorialsListScreenState();
}

class _TutorialsListScreenState extends State<TutorialsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load tutorials data when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTutorials();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Load tutorials data
  Future<void> _loadTutorials() async {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!tutorialProvider.isInitialized) {
      await tutorialProvider.loadTutorials(user: authProvider.currentUser);
    }
  }
  
  // Show filter dialog
  void _showFilterDialog() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    
    TutorialCategory? tempCategory = tutorialProvider.selectedCategory;
    TutorialLevel? tempLevel = tutorialProvider.selectedLevel;
    bool tempShowFavorites = tutorialProvider.showOnlyFavorites;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Tutorials'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category filter
                const Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: tempCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          tempCategory = null;
                        });
                      },
                    ),
                    ...TutorialCategory.values.map((category) {
                      return FilterChip(
                        label: Text(_getCategoryText(category)),
                        selected: tempCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            tempCategory = selected ? category : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Level filter
                const Text(
                  'Level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: tempLevel == null,
                      onSelected: (selected) {
                        setState(() {
                          tempLevel = null;
                        });
                      },
                    ),
                    ...TutorialLevel.values.map((level) {
                      return FilterChip(
                        label: Text(_getLevelText(level)),
                        selected: tempLevel == level,
                        onSelected: (selected) {
                          setState(() {
                            tempLevel = selected ? level : null;
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Favorites filter
                Row(
                  children: [
                    const Text(
                      'Show only favorites',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeMedium,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: tempShowFavorites,
                      onChanged: (value) {
                        setState(() {
                          tempShowFavorites = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tempCategory = null;
                  tempLevel = null;
                  tempShowFavorites = false;
                });
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply filters
                tutorialProvider.setFilters(
                  category: tempCategory,
                  level: tempLevel,
                  onlyFavorites: tempShowFavorites,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show search dialog
  void _showSearchDialog() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final searchController = TextEditingController(text: tutorialProvider.searchQuery);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tutorials'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search',
            hintText: 'Enter keywords',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply search query
              tutorialProvider.setFilters(
                query: searchController.text.isEmpty ? null : searchController.text,
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    ).then((_) {
      searchController.dispose();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildBody() {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (tutorialProvider.isLoading) {
      return const LoadingIndicator(message: 'Loading tutorials...');
    }
    
    if (tutorialProvider.error != null) {
      return CustomErrorWidget(
        message: tutorialProvider.error!,
        onRetry: _loadTutorials,
      );
    }
    
    return TabBarView(
      controller: _tabController,
      children: [
        // All Tutorials Tab
        _buildAllTutorialsTab(tutorialProvider),
        
        // In Progress Tab
        _buildInProgressTab(tutorialProvider, authProvider),
        
        // Completed Tab
        _buildCompletedTab(tutorialProvider, authProvider),
      ],
    );
  }
  
  Widget _buildAllTutorialsTab(TutorialProvider tutorialProvider) {
    final filteredTutorials = tutorialProvider.filteredTutorials;
    
    if (filteredTutorials.isEmpty) {
      return _buildEmptyState(
        'No Tutorials Found',
        'There are no tutorials matching your filters.',
        Icons.video_library_outlined,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTutorials,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active filters indicator
            if (_hasActiveFilters(tutorialProvider))
              _buildActiveFiltersChip(tutorialProvider),
              
            // Categories section
            if (tutorialProvider.selectedCategory == null)
              _buildCategoriesSection(tutorialProvider),
              
            // Tutorials grid
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorialProvider.selectedCategory != null 
                        ? _getCategoryText(tutorialProvider.selectedCategory!)
                        : tutorialProvider.selectedLevel != null
                            ? '${_getLevelText(tutorialProvider.selectedLevel!)} Tutorials'
                            : tutorialProvider.showOnlyFavorites
                                ? 'Favorite Tutorials'
                                : tutorialProvider.searchQuery != null
                                    ? 'Search Results'
                                    : 'All Tutorials',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    '${filteredTutorials.length} tutorial${filteredTutorials.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildTutorialsGrid(filteredTutorials),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInProgressTab(TutorialProvider tutorialProvider, AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return _buildSignInPrompt();
    }
    
    final inProgressTutorials = tutorialProvider.inProgressTutorials;
    
    if (inProgressTutorials.isEmpty) {
      return _buildEmptyState(
        'No Tutorials In Progress',
        'You haven\'t started watching any tutorials yet.',
        Icons.play_circle_outline,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTutorials,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Continue Watching',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                '${inProgressTutorials.length} tutorial${inProgressTutorials.length != 1 ? 's' : ''} in progress',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildProgressList(inProgressTutorials, tutorialProvider),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompletedTab(TutorialProvider tutorialProvider, AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return _buildSignInPrompt();
    }
    
    final completedTutorials = tutorialProvider.completedTutorials;
    
    if (completedTutorials.isEmpty) {
      return _buildEmptyState(
        'No Completed Tutorials',
        'You haven\'t completed any tutorials yet.',
        Icons.done_all_outlined,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadTutorials,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Completed Tutorials',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                '${completedTutorials.length} tutorial${completedTutorials.length != 1 ? 's' : ''} completed',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildTutorialsGrid(completedTutorials),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoriesSection(TutorialProvider tutorialProvider) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: TutorialCategory.values.length,
              itemBuilder: (context, index) {
                final category = TutorialCategory.values[index];
                return _buildCategoryCard(category, tutorialProvider);
              },
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // Trending tutorials section
          if (tutorialProvider.trendingTutorials.isNotEmpty) ...[
            const Text(
              'Trending Tutorials',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tutorialProvider.trendingTutorials.length,
                itemBuilder: (context, index) {
                  final tutorial = tutorialProvider.trendingTutorials[index];
                  return _buildTutorialCard(tutorial, tutorialProvider, horizontal: true);
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
          ],
          
          // Recently added tutorials section
          if (tutorialProvider.recentTutorials.isNotEmpty) ...[
            const Text(
              'Recently Added',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tutorialProvider.recentTutorials.length,
                itemBuilder: (context, index) {
                  final tutorial = tutorialProvider.recentTutorials[index];
                  return _buildTutorialCard(tutorial, tutorialProvider, horizontal: true);
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCategoryCard(TutorialCategory category, TutorialProvider tutorialProvider) {
    final categoryTutorials = tutorialProvider.getTutorialsByCategory(category);
    final categoryColor = _getCategoryColor(category);
    
    return GestureDetector(
      onTap: () {
        tutorialProvider.setFilters(category: category);
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: AppTheme.spacingSmall),
        decoration: BoxDecoration(
          color: categoryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
          border: Border.all(color: categoryColor.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              color: categoryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _getCategoryText(category),
              style: TextStyle(
                color: categoryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${categoryTutorials.length} tutorial${categoryTutorials.length != 1 ? 's' : ''}',
              style: TextStyle(
                color: categoryColor.withOpacity(0.8),
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTutorialCard(TutorialModel tutorial, TutorialProvider tutorialProvider, {bool horizontal = false}) {
    final progress = tutorialProvider.getProgressForTutorial(tutorial.id);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/tutorials/details',
          arguments: tutorial,
        );
      },
      child: Container(
        width: horizontal ? 280 : null,
        margin: EdgeInsets.only(
          right: horizontal ? AppTheme.spacingMedium : 0,
          bottom: horizontal ? 0 : AppTheme.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with level badge
            Stack(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.borderRadiusRegular),
                    topRight: Radius.circular(AppTheme.borderRadiusRegular),
                  ),
                  child: tutorial.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: tutorial.thumbnailUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 160,
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 160,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.error),
                          ),
                        )
                      : Container(
                          height: 160,
                          color: _getCategoryColor(tutorial.category).withOpacity(0.3),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(tutorial.category),
                              size: 48,
                              color: _getCategoryColor(tutorial.category),
                            ),
                          ),
                        ),
                ),
                
                // Level badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(tutorial.level),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      _getLevelText(tutorial.level),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeXSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Duration badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      tutorial.formattedDuration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeXSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Premium badge
                if (tutorial.isPremium)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.fontSizeXSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Progress indicator
            if (progress != null && progress.progress > 0)
              LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                ),
                minHeight: 3,
              ),
            
            // Tutorial details
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
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Instructor
                  Text(
                    'by ${tutorial.instructorName}',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Category & Views
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(tutorial.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          _getCategoryText(tutorial.category),
                          style: TextStyle(
                            color: _getCategoryColor(tutorial.category),
                            fontSize: AppTheme.fontSizeXSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.visibility,
                        size: 12,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatViewCount(tutorial.viewCount),
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeXSmall,
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
  
  Widget _buildTutorialsGrid(List<TutorialModel> tutorials) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        return _buildTutorialCard(tutorials[index], Provider.of<TutorialProvider>(context));
      },
    );
  }
  
  Widget _buildProgressList(List<TutorialModel> tutorials, TutorialProvider tutorialProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        final tutorial = tutorials[index];
        final progress = tutorialProvider.getProgressForTutorial(tutorial.id);
        
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/tutorials/details',
              arguments: tutorial,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.borderRadiusRegular),
                        bottomLeft: Radius.circular(AppTheme.borderRadiusRegular),
                      ),
                      child: tutorial.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: tutorial.thumbnailUrl,
                              height: 80,
                              width: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 80,
                                width: 120,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 80,
                                width: 120,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.error),
                              ),
                            )
                          : Container(
                              height: 80,
                              width: 120,
                              color: _getCategoryColor(tutorial.category).withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  _getCategoryIcon(tutorial.category),
                                  size: 32,
                                  color: _getCategoryColor(tutorial.category),
                                ),
                              ),
                            ),
                    ),
                    
                    // Tutorial details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                              'by ${tutorial.instructorName}',
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Continue watching',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: AppTheme.fontSizeSmall,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (progress != null)
                                  Text(
                                    '${(progress.progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: AppTheme.fontSizeSmall,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Progress bar
                if (progress != null)
                  LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 3,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textLightColor,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSignInPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 64,
            color: AppTheme.textLightColor,
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Text(
            'Sign In Required',
            style: TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
            child: Text(
              'Please sign in to track your progress and access completed tutorials.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
                vertical: AppTheme.paddingMedium,
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveFiltersChip(TutorialProvider tutorialProvider) {
    int filterCount = 0;
    if (tutorialProvider.selectedCategory != null) filterCount++;
    if (tutorialProvider.selectedLevel != null) filterCount++;
    if (tutorialProvider.showOnlyFavorites) filterCount++;
    if (tutorialProvider.searchQuery != null) filterCount++;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$filterCount active filter${filterCount != 1 ? 's' : ''}',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              tutorialProvider.clearFilters();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
  
  bool _hasActiveFilters(TutorialProvider tutorialProvider) {
    return tutorialProvider.selectedCategory != null ||
           tutorialProvider.selectedLevel != null ||
           tutorialProvider.showOnlyFavorites ||
           tutorialProvider.searchQuery != null;
  }
  
  Widget? _buildFloatingActionButton() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Only show FAB for admins and instructors
    if (authProvider.currentUser != null && authProvider.currentUser!.isInstructor) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tutorials/manage');
        },
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      );
    }
    
    return null;
  }
  
  // Helper methods for category display
  String _getCategoryText(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.strength:
        return 'Strength';
      case TutorialCategory.cardio:
        return 'Cardio';
      case TutorialCategory.flexibility:
        return 'Flexibility';
      case TutorialCategory.recovery:
        return 'Recovery';
      case TutorialCategory.nutrition:
        return 'Nutrition';
      case TutorialCategory.mindfulness:
        return 'Mindfulness';
      case TutorialCategory.equipment:
        return 'Equipment';
      case TutorialCategory.technique:
        return 'Technique';
      case TutorialCategory.other:
        return 'Other';
    }
  }
  
  IconData _getCategoryIcon(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.strength:
        return Icons.fitness_center;
      case TutorialCategory.cardio:
        return Icons.directions_run;
      case TutorialCategory.flexibility:
        return Icons.accessibility_new;
      case TutorialCategory.recovery:
        return Icons.hotel;
      case TutorialCategory.nutrition:
        return Icons.restaurant;
      case TutorialCategory.mindfulness:
        return Icons.self_improvement;
      case TutorialCategory.equipment:
        return Icons.sports_gymnastics;
      case TutorialCategory.technique:
        return Icons.sports;
      case TutorialCategory.other:
        return Icons.category;
    }
  }
  
  Color _getCategoryColor(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.strength:
        return Colors.red.shade700;
      case TutorialCategory.cardio:
        return Colors.orange.shade700;
      case TutorialCategory.flexibility:
        return Colors.purple.shade700;
      case TutorialCategory.recovery:
        return Colors.blue.shade700;
      case TutorialCategory.nutrition:
        return Colors.green.shade700;
      case TutorialCategory.mindfulness:
        return Colors.indigo.shade700;
      case TutorialCategory.equipment:
        return Colors.brown.shade700;
      case TutorialCategory.technique:
        return Colors.teal.shade700;
      case TutorialCategory.other:
        return Colors.blueGrey.shade700;
    }
  }
  
  // Helper methods for level display
  String _getLevelText(TutorialLevel level) {
    switch (level) {
      case TutorialLevel.beginner:
        return 'Beginner';
      case TutorialLevel.intermediate:
        return 'Intermediate';
      case TutorialLevel.advanced:
        return 'Advanced';
      case TutorialLevel.all:
        return 'All Levels';
    }
  }
  
  Color _getLevelColor(TutorialLevel level) {
    switch (level) {
      case TutorialLevel.beginner:
        return Colors.green;
      case TutorialLevel.intermediate:
        return Colors.orange;
      case TutorialLevel.advanced:
        return Colors.red;
      case TutorialLevel.all:
        return Colors.blue;
    }
  }
  
  // Format view count (e.g., 1.2K, 3.5M)
  String _formatViewCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}