import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class TutorialDetailsScreen extends StatefulWidget {
  final TutorialModel tutorial;

  const TutorialDetailsScreen({
    Key? key,
    required this.tutorial,
  }) : super(key: key);

  @override
  State<TutorialDetailsScreen> createState() => _TutorialDetailsScreenState();
}

class _TutorialDetailsScreenState extends State<TutorialDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _showControls = true;
  double _progress = 0.0;
  int _currentPosition = 0;
  String? _errorMessage;
  
  // Timer for hiding controls
  Future? _hideControlsTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initVideoPlayer();
    
    // Track initial view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackTutorialView();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _videoController.dispose();
    super.dispose();
  }
  
  // Initialize video player
  Future<void> _initVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.tutorial.videoUrl),
      );
      
      await _videoController.initialize();
      
      // Get saved position for the tutorial
      final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isAuthenticated) {
        final progress = tutorialProvider.getProgressForTutorial(widget.tutorial.id);
        if (progress != null && progress.lastPositionInSeconds > 0) {
          await _videoController.seekTo(Duration(seconds: progress.lastPositionInSeconds));
        }
      }
      
      // Set up listeners
      _videoController.addListener(_videoListener);
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: $e';
      });
    }
  }
  
  // Video player listener
  void _videoListener() {
    if (!mounted) return;
    
    final duration = _videoController.value.duration.inSeconds;
    final position = _videoController.value.position.inSeconds;
    
    if (duration > 0) {
      setState(() {
        _progress = position / duration;
        _currentPosition = position;
        _isPlaying = _videoController.value.isPlaying;
        _isBuffering = _videoController.value.isBuffering;
      });
    }
    
    // Check if video has ended
    if (position >= duration && duration > 0) {
      _updateProgress(1.0, true);
    }
  }
  
  // Track tutorial view
  Future<void> _trackTutorialView() async {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await tutorialProvider.updateTutorialProgress(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorial.id,
        progress: 0.0,  // Initial view, no progress yet
        positionInSeconds: 0,
      );
    }
  }
  
  // Update progress when user stops watching
  Future<void> _updateProgress(double progress, bool markCompleted) async {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await tutorialProvider.updateTutorialProgress(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorial.id,
        progress: progress,
        positionInSeconds: _currentPosition,
        markAsCompleted: markCompleted,
      );
    }
  }
  
  // Play or pause the video
  void _playPause() {
    setState(() {
      if (_isPlaying) {
        _videoController.pause();
        _updateProgress(_progress, false);
      } else {
        _videoController.play();
        _resetHideControlsTimer();
      }
      _isPlaying = !_isPlaying;
    });
  }
  
  // Rewind 10 seconds
  void _rewind() {
    final newPosition = _currentPosition - 10;
    _videoController.seekTo(Duration(seconds: newPosition < 0 ? 0 : newPosition));
    _resetHideControlsTimer();
  }
  
  // Fast forward 10 seconds
  void _fastForward() {
    final duration = _videoController.value.duration.inSeconds;
    final newPosition = _currentPosition + 10;
    _videoController.seekTo(Duration(seconds: newPosition > duration ? duration : newPosition));
    _resetHideControlsTimer();
  }
  
  // Toggle fullscreen
  void _toggleFullscreen() {
    // This would be implemented with a package like wakelock to prevent screen from turning off
    // and orientation changes to force landscape mode
    _resetHideControlsTimer();
  }
  
  // Reset the timer that hides the controls
  void _resetHideControlsTimer() {
    if (_hideControlsTimer != null) {
      _hideControlsTimer = null;
    }
    
    setState(() {
      _showControls = true;
    });
    
    _hideControlsTimer = Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }
  
  // Toggle controls visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _resetHideControlsTimer();
    }
  }
  
  // Format duration
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            tooltip: 'Rate Tutorial',
            onPressed: _showRatingDialog,
          ),
          if (_isUserAuthorized())
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Tutorial',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/tutorials/edit',
                  arguments: widget.tutorial,
                );
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player
          _buildVideoPlayer(),
          
          // Tabs for Details and Comments
          _buildTabs(),
        ],
      ),
    );
  }
  
  Widget _buildVideoPlayer() {
    if (_errorMessage != null) {
      return Container(
        height: 200,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isInitialized) {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    
    return AspectRatio(
      aspectRatio: _videoController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Video player
          GestureDetector(
            onTap: _toggleControls,
            child: VideoPlayer(_videoController),
          ),
          
          // Loading indicator
          if (_isBuffering && _isPlaying)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          
          // Controls overlay
          if (_showControls)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              trackShape: const RoundedRectSliderTrackShape(),
                              activeTrackColor: AppTheme.primaryColor,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: AppTheme.primaryColor,
                              overlayColor: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                            child: Slider(
                              value: _progress,
                              onChanged: (value) {
                                final duration = _videoController.value.duration.inSeconds;
                                final newPosition = (value * duration).toInt();
                                _videoController.seekTo(Duration(seconds: newPosition));
                                setState(() {
                                  _progress = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(_videoController.value.duration.inSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _rewind,
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: _playPause,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        IconButton(
                          onPressed: _fastForward,
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFullscreen,
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondaryColor,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                _buildDetailsTab(),
                
                // Reviews Tab
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Metadata
          Text(
            widget.tutorial.title,
            style: const TextStyle(
              fontSize: AppTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${widget.tutorial.instructorName}',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Tutorial metadata
          Row(
            children: [
              _buildMetadataItem(
                icon: Icons.category,
                label: _getCategoryText(widget.tutorial.category),
                color: _getCategoryColor(widget.tutorial.category),
              ),
              _buildMetadataItem(
                icon: Icons.signal_cellular_alt,
                label: _getLevelText(widget.tutorial.level),
                color: _getLevelColor(widget.tutorial.level),
              ),
              _buildMetadataItem(
                icon: Icons.timer,
                label: widget.tutorial.formattedDuration,
                color: AppTheme.textSecondaryColor,
              ),
              if (widget.tutorial.isPremium)
                _buildMetadataItem(
                  icon: Icons.star,
                  label: 'Premium',
                  color: Colors.amber,
                ),
            ],
          ),
          
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
            widget.tutorial.description,
            style: const TextStyle(
              color: AppTheme.textPrimaryColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Tags
          if (widget.tutorial.tags.isNotEmpty) ...[
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.tutorial.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppTheme.primaryLightColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          // Instructor info
          const Text(
            'Instructor',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              // Navigate to instructor profile
              Navigator.pushNamed(
                context,
                '/instructors/profile',
                arguments: widget.tutorial.instructorId,
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 24,
                  child: Text(
                    widget.tutorial.instructorName.isNotEmpty
                        ? widget.tutorial.instructorName[0].toUpperCase()
                        : 'I',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tutorial.instructorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'View instructor profile',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Related tutorials placeholder
          const Text(
            'Related Tutorials',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRelatedTutorials(),
        ],
      ),
    );
  }
  
  Widget _buildReviewsTab() {
    return FutureBuilder(
      future: _loadReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return _buildReviewsList();
      },
    );
  }
  
  Future<void> _loadReviews() async {
    // This would fetch reviews from Firestore
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  Widget _buildReviewsList() {
    final rating = widget.tutorial.rating;
    final ratingCount = widget.tutorial.ratingCount;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall rating
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
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
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.floor()
                          ? Icons.star
                          : index < rating
                              ? Icons.star_half
                              : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '$ratingCount ${ratingCount == 1 ? 'review' : 'reviews'}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showRatingDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingLarge,
                      vertical: AppTheme.paddingSmall,
                    ),
                  ),
                  child: const Text('Rate this Tutorial'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Reviews list (placeholder)
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Placeholder reviews
          if (ratingCount == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No reviews yet. Be the first to leave a review!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Placeholder number
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppTheme.primaryLightColor,
                            radius: 16,
                            child: Text(
                              'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Anonymous User',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < (5 - index) ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This is a placeholder review. In a real app, this would show actual user reviews from the database.',
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '2 days ago',
                        style: TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildMetadataItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: AppTheme.fontSizeSmall,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRelatedTutorials() {
    // This would be populated from the TutorialProvider in a real app
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: const Center(
        child: Text(
          'Related tutorials would appear here',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
  
  void _showRatingDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      _showSignInPrompt();
      return;
    }
    
    int selectedRating = 5;
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate this Tutorial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How would you rate this tutorial?',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  hintText: 'Share your thoughts about this tutorial',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
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
                _submitRating(selectedRating, commentController.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    ).then((_) {
      commentController.dispose();
    });
  }
  
  void _showSignInPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'You need to be signed in to rate tutorials.',
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
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitRating(int rating, String comment) async {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      return;
    }
    
    final success = await tutorialProvider.rateTutorial(
      userId: authProvider.currentUser!.id,
      tutorialId: widget.tutorial.id,
      rating: rating,
      comment: comment,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your rating!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tutorialProvider.error ?? 'Failed to submit rating'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  bool _isUserAuthorized() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return false;
    
    final user = authProvider.currentUser!;
    return user.isAdmin || (user.isInstructor && user.id == widget.tutorial.instructorId);
  }
  
  // Helper methods for category and level display
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
}