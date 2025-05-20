import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/screens/tutorials/tutorial_create_edit_screen.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class TutorialDetailsScreen extends StatefulWidget {
  final String tutorialId;

  const TutorialDetailsScreen({
    Key? key,
    required this.tutorialId,
  }) : super(key: key);

  @override
  State<TutorialDetailsScreen> createState() => _TutorialDetailsScreenState();
}

class _TutorialDetailsScreenState extends State<TutorialDetailsScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  double _userProgress = 0.0;
  bool _isCompleted = false;
  int? _userRating;
  bool _isSubmittingRating = false;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // Load tutorial details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTutorial();
    });
    
    // Add scroll listener to track progress
    _scrollController.addListener(_updateProgressFromScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_updateProgressFromScroll);
    _scrollController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  
  Future<void> _loadTutorial() async {
    final tutorial = _getTutorial();
    if (tutorial == null) return;
    
    // Initialize video if available
    if (tutorial.videoUrl != null && tutorial.videoUrl!.isNotEmpty) {
      await _initializeVideo(tutorial.videoUrl!);
    }
    
    // Load user progress if authenticated
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      // Get existing progress
      final progress = tutorialProvider.getProgressForTutorial(widget.tutorialId);
      
      if (progress != null) {
        setState(() {
          _userProgress = progress.progress;
          _isCompleted = progress.isCompleted;
          _userRating = progress.userRating;
        });
      }
      
      // Update tutorial progress for view
      if (progress == null || progress.progress < 0.1) {
        await tutorialProvider.updateTutorialProgress(
          userId: authProvider.currentUser!.id,
          tutorialId: widget.tutorialId,
          progress: 0.1,
        );
        
        setState(() {
          _userProgress = 0.1;
        });
      }
    }
  }
  
  TutorialModel? _getTutorial() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    return tutorialProvider.getTutorialById(widget.tutorialId);
  }
  
  Future<void> _initializeVideo(String videoUrl) async {
    try {
      _videoController = VideoPlayerController.network(videoUrl);
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: AppTheme.primaryLightColor,
        ),
      );
      
      // Add listener to track video progress
      _videoController!.addListener(_updateProgressFromVideo);
      
      if (mounted) setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
    }
  }
  
  void _updateProgressFromVideo() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;
    
    if (_videoController!.value.isPlaying) {
      final duration = _videoController!.value.duration.inSeconds;
      final position = _videoController!.value.position.inSeconds;
      
      if (duration > 0) {
        final progress = position / duration;
        _updateProgress(progress);
      }
    }
  }
  
  void _updateProgressFromScroll() {
    final scrollPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    
    if (maxScrollExtent > 0) {
      final progress = scrollPosition / maxScrollExtent;
      // Only update if user has scrolled beyond the current progress
      if (progress > _userProgress) {
        _updateProgress(progress);
      }
    }
  }
  
  void _updateProgress(double progress) {
    // Save user progress between 0 and 1
    final progressValue = progress.clamp(0.0, 1.0);
    
    // Don't update if we're already at max progress or complete
    if (_userProgress >= progressValue || _isCompleted) return;
    
    setState(() {
      _userProgress = progressValue;
      
      // Mark as completed if user reaches 90% through the content
      if (progressValue >= 0.9) {
        _isCompleted = true;
      }
    });
    
    // Save progress to backend if user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      tutorialProvider.updateTutorialProgress(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorialId,
        progress: progressValue,
        isCompleted: _isCompleted,
      );
    }
  }
  
  Future<void> _submitRating(int rating) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) {
      _showLoginPrompt();
      return;
    }
    
    setState(() {
      _isSubmittingRating = true;
    });
    
    try {
      final success = await tutorialProvider.rateTutorial(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorialId,
        rating: rating,
      );
      
      if (success) {
        setState(() {
          _userRating = rating;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your rating!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tutorialProvider.error ?? 'Failed to submit rating'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }
  
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to rate tutorials.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              // Implement this navigation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tutorialProvider = Provider.of<TutorialProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final tutorial = _getTutorial();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(tutorial?.title ?? 'Tutorial Details'),
        actions: [
          // Edit tutorial (for admin/instructor)
          if (authProvider.isAuthenticated && 
             tutorial != null &&
             (authProvider.currentUser!.isAdmin || 
              (authProvider.currentUser!.isInstructor && 
               authProvider.currentUser!.id == tutorial.authorId)))
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Tutorial',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TutorialCreateEditScreen(
                      tutorial: tutorial,
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    tutorialProvider.loadTutorials();
                  }
                });
              },
            ),
          
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing is not implemented yet'),
                ),
              );
            },
          ),
        ],
      ),
      body: tutorialProvider.isLoading
          ? const LoadingIndicator(message: 'Loading tutorial...')
          : tutorial == null
              ? CustomErrorWidget(
                  message: 'Tutorial not found',
                  onRetry: _loadTutorial,
                )
              : _buildTutorialContent(tutorial),
    );
  }
  
  Widget _buildTutorialContent(TutorialModel tutorial) {
    return Column(
      children: [
        // Progress indicator
        if (_userProgress > 0) ...[
          LinearProgressIndicator(
            value: _userProgress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
            minHeight: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_userProgress * 100).toInt()}% Complete',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
                if (_isCompleted)
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player if available
                if (_chewieController != null && _videoController != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  )
                else if (tutorial.thumbnailUrl != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      tutorial.thumbnailUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                
                // Tutorial info
                Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and metadata
                      Text(
                        tutorial.title,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Author
                          Text(
                            'By ${tutorial.authorName}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Spacer(),
                          // Difficulty badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(tutorial.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                              border: Border.all(
                                color: _getDifficultyColor(tutorial.difficulty).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              tutorial.difficultyString,
                              style: TextStyle(
                                color: _getDifficultyColor(tutorial.difficulty),
                                fontWeight: FontWeight.bold,
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Stats
                      Row(
                        children: [
                          _buildStatItem(
                            icon: Icons.star,
                            value: tutorial.averageRating.toStringAsFixed(1),
                            label: '${tutorial.ratingCount} ratings',
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            icon: Icons.timer,
                            value: '${tutorial.durationMinutes}',
                            label: 'minutes',
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            icon: Icons.visibility,
                            value: '${tutorial.viewCount}',
                            label: 'views',
                            color: Colors.green,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Categories
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tutorial.categories.map((category) {
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
                          
                          return Chip(
                            avatar: Icon(
                              icon,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            label: Text(label),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Rate tutorial card
                      if (_isCompleted) _buildRatingCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tutorial.description,
                        style: const TextStyle(
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Content
                      const Text(
                        'Tutorial Content',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MarkdownBody(
                        data: tutorial.content,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          h2: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          h3: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          p: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                          listBullet: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                          blockquote: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                          code: TextStyle(
                            fontFamily: 'monospace',
                            backgroundColor: Colors.grey.shade100,
                          ),
                          codeBlock: TextStyle(
                            fontFamily: 'monospace',
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Footer info
                      Text(
                        'Last updated: ${tutorial.updatedAt != null ? DateFormat.yMMMd().format(tutorial.updatedAt!) : DateFormat.yMMMd().format(tutorial.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: AppTheme.fontSizeSmall,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
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
  
  Widget _buildRatingCard() {
    return Card(
      elevation: AppTheme.elevationSmall,
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'How would you rate this tutorial?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_isSubmittingRating)
              const CircularProgressIndicator()
            else if (_userRating != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _userRating! ? Icons.star : Icons.star_border,
                        color: AppTheme.accentColor,
                      ),
                      onPressed: () => _submitRating(index + 1),
                    );
                  }),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star_border,
                        color: AppTheme.accentColor,
                      ),
                      onPressed: () => _submitRating(index + 1),
                    );
                  }),
                ],
              ),
            if (_userRating != null)
              Text(
                'Your rating: $_userRating/5',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
          ],
        ),
      ),
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
      case TutorialDifficulty.expert:
        return Colors.red;
    }
  }
}