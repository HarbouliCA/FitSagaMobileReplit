import 'package:flutter/material.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';

class TutorialDetailScreen extends StatefulWidget {
  final Tutorial tutorial;

  const TutorialDetailScreen({Key? key, required this.tutorial}) : super(key: key);

  @override
  _TutorialDetailScreenState createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<TutorialDay> _tutorialDays = [];
  
  @override
  void initState() {
    super.initState();
    _loadTutorialDetails();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTutorialDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // In a real app, this would fetch from a provider or API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // For demo purposes, we'll create sample data
      final tutorialDays = _getSampleTutorialDays(widget.tutorial);
      
      setState(() {
        _tutorialDays = tutorialDays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.tutorial.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.network(
                    widget.tutorial.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Add to favorites
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to favorites'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share tutorial
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing tutorial...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildTutorialInfo(),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Days'),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: _buildTabContent(),
    );
  }
  
  Widget _buildTutorialInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(widget.tutorial.difficulty, _getDifficultyColor(widget.tutorial.difficulty)),
              _buildTag('${widget.tutorial.totalDurationMinutes} min', Colors.blue),
              _buildTag('${widget.tutorial.daysCount} days', Colors.purple),
              ...widget.tutorial.categories.map((category) => 
                _buildTag(category, AppTheme.primaryColor)).toList(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress if started
          if (widget.tutorial.userProgress != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your progress: ${(widget.tutorial.userProgress! * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: widget.tutorial.userProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    // Continue tutorial
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            widget.tutorial.description,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(
          size: 40,
          showText: true,
          text: 'Loading tutorial details...',
        ),
      );
    }
    
    if (_hasError) {
      return CustomErrorWidget(
        message: 'Error loading tutorial details: $_errorMessage',
        onRetry: _loadTutorialDetails,
        fullScreen: true,
      );
    }
    
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildDaysTab(),
      ],
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured video or preview
          _buildVideoPreview(widget.tutorial.imageUrl),
          const SizedBox(height: 24),
          
          // What you'll learn
          const Text(
            'What You\'ll Learn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildWhatYoullLearn(),
          const SizedBox(height: 24),
          
          // Equipment needed
          const Text(
            'Equipment Needed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildEquipmentNeeded(),
          const SizedBox(height: 24),
          
          // Trainer info
          const Text(
            'Your Trainer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTrainerInfo(),
          const SizedBox(height: 24),
          
          // Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // See all reviews
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReviews(),
          const SizedBox(height: 32),
          
          // Start button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.tutorial.userProgress != null
                  ? () {
                      // Continue tutorial
                    }
                  : () {
                      // Start tutorial
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Starting tutorial...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.tutorial.userProgress != null ? 'Continue Tutorial' : 'Start Tutorial',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDaysTab() {
    if (_tutorialDays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No daily workouts available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This tutorial does not have any daily workouts',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tutorialDays.length,
      itemBuilder: (context, index) {
        final day = _tutorialDays[index];
        final isCompleted = day.isCompleted;
        final isActive = day.isActive;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: isActive ? () => _navigateToDayDetail(day) : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Day indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isActive
                              ? AppTheme.primaryColor
                              : Colors.grey[300],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : Text(
                              '${day.dayNumber}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Day info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? null : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.estimatedMinutes} min • ${day.difficulty}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Play button
                  if (isActive)
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill),
                      color: AppTheme.primaryColor,
                      onPressed: () => _navigateToDayDetail(day),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.lock),
                      color: Colors.grey[400],
                      onPressed: null,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildVideoPreview(String imageUrl) {
    // In a real app, this would be a video player
    // For demo purposes, we'll use an image with a play button overlay
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {
                // Play video
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Playing tutorial preview...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWhatYoullLearn() {
    final items = [
      'Proper form for all exercises',
      'How to progressively increase intensity',
      'Nutrition tips to maximize results',
      'Recovery techniques for faster gains',
      'How to design your own workout routine',
    ];
    
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildEquipmentNeeded() {
    final equipment = [
      {'name': 'Dumbbells', 'required': true},
      {'name': 'Yoga Mat', 'required': true},
      {'name': 'Resistance Bands', 'required': false},
      {'name': 'Bench', 'required': false},
    ];
    
    return Column(
      children: equipment.map((item) {
        final bool isRequired = item['required'] as bool;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isRequired ? Icons.check_circle : Icons.info_outline,
                color: isRequired ? AppTheme.successColor : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: item['name'] as String,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: isRequired ? ' (Required)' : ' (Optional)',
                        style: TextStyle(
                          color: isRequired ? AppTheme.successColor : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildTrainerInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (exception, stackTrace) {},
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coach Michael Stevens',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Certified Personal Trainer',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 • 125 Reviews',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {
                // View trainer profile
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReviews() {
    final reviews = [
      {
        'name': 'Sarah J.',
        'rating': 5,
        'comment': 'This tutorial helped me gain 10lbs of muscle in just 6 weeks! The nutrition advice was especially helpful.',
        'date': '2 weeks ago',
      },
      {
        'name': 'David L.',
        'rating': 4,
        'comment': 'Great program overall. Some of the advanced exercises were challenging but the modifications helped.',
        'date': '1 month ago',
      },
    ];
    
    return Column(
      children: reviews.map((review) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review['date'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (review['rating'] as int)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'] as String,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        return Colors.blue;
    }
  }
  
  void _navigateToDayDetail(TutorialDay day) {
    // Navigate to day detail screen
    if (!day.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This day is locked. Complete previous days first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // In a real app, you would navigate to the day detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Day ${day.dayNumber}: ${day.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  List<TutorialDay> _getSampleTutorialDays(Tutorial tutorial) {
    // Create sample days based on the tutorial's daysCount
    final List<TutorialDay> days = [];
    for (int i = 1; i <= tutorial.daysCount; i++) {
      // Determine if day is completed or active based on progress
      bool isCompleted = false;
      bool isActive = false;
      
      if (tutorial.userProgress != null) {
        final completedDays = (tutorial.userProgress! * tutorial.daysCount).floor();
        isCompleted = i <= completedDays;
        isActive = i <= completedDays + 1; // Next day is active
      } else {
        isActive = i == 1; // Only first day is active for new tutorials
      }
      
      days.add(
        TutorialDay(
          id: 'day$i',
          title: _getDayTitle(tutorial, i),
          subtitle: _getDaySubtitle(tutorial, i),
          description: 'Detailed workout instructions for day $i of the program.',
          dayNumber: i,
          difficulty: tutorial.difficulty,
          estimatedMinutes: _getDayDuration(tutorial, i),
          imageUrl: tutorial.imageUrl,
          isCompleted: isCompleted,
          isActive: isActive,
          exercises: _getSampleExercises(),
          tags: tutorial.categories,
        ),
      );
    }
    
    return days;
  }
  
  String _getDayTitle(Tutorial tutorial, int dayNumber) {
    final List<String> titles = [
      'Introduction & Warm-up',
      'Building Foundation',
      'Increasing Intensity',
      'Focus on Form',
      'Pushing Your Limits',
      'Active Recovery',
      'Peak Performance',
      'Cool Down & Stretch',
      'Final Challenge',
      'Reflection & Progress',
    ];
    
    if (dayNumber <= titles.length) {
      return titles[dayNumber - 1];
    }
    
    return 'Day $dayNumber Workout';
  }
  
  String _getDaySubtitle(Tutorial tutorial, int dayNumber) {
    if (tutorial.categories.contains('strength')) {
      return 'Strength Training';
    } else if (tutorial.categories.contains('cardio')) {
      return 'Cardio Workout';
    } else if (tutorial.categories.contains('yoga')) {
      return 'Yoga Flow';
    } else if (tutorial.categories.contains('hiit')) {
      return 'HIIT Session';
    }
    
    return 'Fitness Training';
  }
  
  int _getDayDuration(Tutorial tutorial, int dayNumber) {
    // Distribute the total duration among days
    final avgDuration = tutorial.totalDurationMinutes ~/ tutorial.daysCount;
    
    // Add some variation
    if (dayNumber == 1) {
      return avgDuration - 5; // First day is usually shorter (intro)
    } else if (dayNumber == tutorial.daysCount) {
      return avgDuration - 5; // Last day might be shorter (cool down)
    } else if (dayNumber % 2 == 0) {
      return avgDuration + 5; // Add variation
    }
    
    return avgDuration;
  }
  
  List<Exercise> _getSampleExercises() {
    return [
      Exercise(
        id: 'ex1',
        name: 'Push-ups',
        description: 'Standard push-ups targeting chest, shoulders, and triceps.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Push-ups',
        videoUrl: 'https://example.com/videos/pushups.mp4',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      ),
      Exercise(
        id: 'ex2',
        name: 'Squats',
        description: 'Bodyweight squats targeting quadriceps, hamstrings, and glutes.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Squats',
        videoUrl: 'https://example.com/videos/squats.mp4',
        sets: 3,
        reps: 15,
        restSeconds: 60,
        targetMuscles: ['Quadriceps', 'Hamstrings', 'Glutes'],
      ),
      Exercise(
        id: 'ex3',
        name: 'Plank',
        description: 'Core stability exercise targeting the entire core and shoulders.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Plank',
        videoUrl: 'https://example.com/videos/plank.mp4',
        sets: 3,
        duration: 45,
        restSeconds: 30,
        targetMuscles: ['Core', 'Shoulders'],
      ),
      Exercise(
        id: 'ex4',
        name: 'Lunges',
        description: 'Forward lunges targeting quadriceps, hamstrings, and glutes.',
        imageUrl: 'https://via.placeholder.com/300x200?text=Lunges',
        videoUrl: 'https://example.com/videos/lunges.mp4',
        sets: 3,
        reps: 10,
        restSeconds: 45,
        targetMuscles: ['Quadriceps', 'Hamstrings', 'Glutes'],
      ),
    ];
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}