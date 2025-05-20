import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({Key? key}) : super(key: key);

  @override
  _TutorialListScreenState createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _tutorialDays = [];
  
  @override
  void initState() {
    super.initState();
    _loadTutorialData();
  }
  
  Future<void> _loadTutorialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Simulate loading data from Firebase
      await Future.delayed(const Duration(seconds: 1));
      
      // Sample tutorial data (in a real app, this would come from Firebase)
      _tutorialDays = [
        {
          'id': 'day1',
          'title': 'Day 1: Getting Started',
          'subtitle': 'Introduction to FitSAGA',
          'description': 'Learn the basics of the gym and get familiar with the equipment.',
          'exercises': 5,
          'difficulty': 'Beginner',
          'duration': '30 mins',
          'imageUrl': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
          'progress': 1.0, // Completed
        },
        {
          'id': 'day2',
          'title': 'Day 2: Upper Body Focus',
          'subtitle': 'Chest, Arms, and Shoulders',
          'description': 'Build strength in your upper body with these targeted exercises.',
          'exercises': 7,
          'difficulty': 'Beginner',
          'duration': '45 mins',
          'imageUrl': 'https://images.unsplash.com/photo-1532384748853-8f54a8f476e2',
          'progress': 0.7, // In progress
        },
        {
          'id': 'day3',
          'title': 'Day 3: Lower Body Power',
          'subtitle': 'Legs, Glutes, and Core',
          'description': 'Focus on your lower body to build a strong foundation.',
          'exercises': 6,
          'difficulty': 'Intermediate',
          'duration': '40 mins',
          'imageUrl': 'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a',
          'progress': 0.3, // Just started
        },
        {
          'id': 'day4',
          'title': 'Day 4: Cardio Blast',
          'subtitle': 'Heart-Pumping Exercises',
          'description': 'Improve your cardiovascular health with this high-energy session.',
          'exercises': 8,
          'difficulty': 'Intermediate',
          'duration': '50 mins',
          'imageUrl': 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c',
          'progress': 0.0, // Not started
        },
        {
          'id': 'day5',
          'title': 'Day 5: Full Body Circuit',
          'subtitle': 'Total Body Workout',
          'description': 'Challenge every muscle group with this comprehensive circuit.',
          'exercises': 10,
          'difficulty': 'Advanced',
          'duration': '60 mins',
          'imageUrl': 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712',
          'progress': 0.0, // Not started
        },
      ];
    } catch (e) {
      setState(() {
        _error = 'Failed to load tutorial data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterDialog();
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search bar
              _showSearchBar();
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading tutorials...')
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadTutorialData,
                )
              : _buildTutorialList(),
    );
  }
  
  Widget _buildTutorialList() {
    if (_tutorialDays.isEmpty) {
      return const NoDataWidget(
        message: 'No tutorials available',
        icon: Icons.video_library,
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header with description
        const Text(
          'Fitness Tutorials',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Follow our structured tutorial program to learn proper form and technique for all exercises.',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 24),
        
        // Tutorial day cards
        for (final day in _tutorialDays) ...[
          _buildTutorialDayCard(day),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
  
  Widget _buildTutorialDayCard(Map<String, dynamic> day) {
    final progress = day['progress'] as double;
    final isCompleted = progress >= 1.0;
    final isStarted = progress > 0.0;
    
    return InkWell(
      onTap: () {
        // Navigate to tutorial detail screen
        _navigateToTutorialDay(day);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
              Stack(
                children: [
                  // Tutorial image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      day['imageUrl'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Difficulty badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(day['difficulty'] as String),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        day['difficulty'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  // Status indicator
                  if (isCompleted || isStarted)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isCompleted ? 'Completed' : 'In Progress',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      day['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Subtitle
                    Text(
                      day['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      day['description'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Info row
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.fitness_center,
                          label: '${day['exercises']} exercises',
                        ),
                        const SizedBox(width: 16),
                        _buildInfoChip(
                          icon: Icons.timer,
                          label: day['duration'] as String,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getProgressColor(progress),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // View tutorial details
                        _navigateToTutorialDay(day);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Continue or start tutorial
                        _navigateToTutorialDay(day, startExercise: true);
                      },
                      icon: Icon(isStarted ? Icons.play_arrow : Icons.start),
                      label: Text(isStarted ? 'Continue' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.grey : AppTheme.primaryColor,
                      ),
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
  
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
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
  
  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return AppTheme.successColor;
    } else if (progress >= 0.5) {
      return Colors.orange;
    } else if (progress > 0.0) {
      return AppTheme.primaryColor;
    } else {
      return Colors.grey;
    }
  }
  
  void _navigateToTutorialDay(Map<String, dynamic> day, {bool startExercise = false}) {
    // In a real app, this would navigate to the tutorial detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(startExercise 
            ? 'Starting ${day['title']}' 
            : 'Viewing details for ${day['title']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Tutorials',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Difficulty filter
              const Text(
                'Difficulty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterChip('Beginner', Colors.green),
                  const SizedBox(width: 8),
                  _buildFilterChip('Intermediate', Colors.orange),
                  const SizedBox(width: 8),
                  _buildFilterChip('Advanced', Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress filter
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterChip('Not Started', Colors.grey),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', AppTheme.successColor),
                ],
              ),
              const SizedBox(height: 24),
              
              // Apply/Clear buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Clear All'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Apply filters
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterChip(String label, Color color) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        // Apply filter
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: Colors.grey.shade800,
      ),
      side: BorderSide(
        color: Colors.grey.shade300,
      ),
    );
  }
  
  void _showSearchBar() {
    showSearch(
      context: context,
      delegate: TutorialSearchDelegate(_tutorialDays),
    );
  }
}

class TutorialSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> tutorials;
  
  TutorialSearchDelegate(this.tutorials);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Search for tutorials',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    final results = tutorials.where((tutorial) {
      final title = tutorial['title'] as String;
      final subtitle = tutorial['subtitle'] as String;
      final description = tutorial['description'] as String;
      
      return title.toLowerCase().contains(query.toLowerCase()) ||
             subtitle.toLowerCase().contains(query.toLowerCase()) ||
             description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tutorial = results[index];
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              tutorial['imageUrl'] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          title: Text(
            tutorial['title'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            tutorial['subtitle'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to tutorial detail
            close(context, tutorial['id'] as String);
          },
        );
      },
    );
  }
}