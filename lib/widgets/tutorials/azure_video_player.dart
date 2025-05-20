import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/tutorial_provider_revised.dart';
import 'package:fitsaga/providers/auth_provider.dart';

class AzureVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String tutorialId;
  final String exerciseId;
  final int startPosition; // in seconds
  
  const AzureVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.tutorialId,
    required this.exerciseId,
    this.startPosition = 0,
  }) : super(key: key);

  @override
  State<AzureVideoPlayer> createState() => _AzureVideoPlayerState();
}

class _AzureVideoPlayerState extends State<AzureVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  int _lastPosition = 0;
  double _playbackSpeed = 1.0;
  
  // Keep track of progress updates
  DateTime _lastProgressUpdate = DateTime.now();
  bool _hasMarkedAsCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      await _controller.initialize();
      
      // Set up listener for position updates
      _controller.addListener(_onVideoPositionChanged);
      
      // Seek to specified start position if needed
      if (widget.startPosition > 0 && widget.startPosition < _controller.value.duration.inSeconds) {
        await _controller.seekTo(Duration(seconds: widget.startPosition));
      }
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
      
      // Auto-play if desired
      // _controller.play();
      
    } catch (e) {
      setState(() {
        _error = 'Error initializing video: ${e.toString()}';
        _isLoading = false;
      });
      print(_error);
    }
  }
  
  void _onVideoPositionChanged() {
    if (!_controller.value.isInitialized) return;
    
    // Track current position
    final currentPosition = _controller.value.position.inSeconds;
    
    // Only update if position has changed
    if (currentPosition != _lastPosition) {
      _lastPosition = currentPosition;
      
      final now = DateTime.now();
      // Only update progress every 10 seconds to avoid too many updates
      if (now.difference(_lastProgressUpdate).inSeconds > 10) {
        _updateProgress();
        _lastProgressUpdate = now;
      }
    }
    
    // Check if we've reached the 90% mark of the video (for marking as completed)
    if (!_hasMarkedAsCompleted && _controller.value.isInitialized) {
      final duration = _controller.value.duration.inSeconds;
      final position = _controller.value.position.inSeconds;
      
      if (duration > 0 && position > 0) {
        final progress = position / duration;
        if (progress >= 0.9) {
          _markExerciseAsCompleted();
          _hasMarkedAsCompleted = true;
        }
      }
    }
  }
  
  void _updateProgress() {
    // Don't update if not authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) return;
    
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    
    // Mark the current position as watched
    tutorialProvider.updateTutorialProgress(
      userId: authProvider.currentUser!.id,
      tutorialId: widget.tutorialId,
      progress: tutorialProvider.getProgressForTutorial(widget.tutorialId)?.progress ?? 0.1,
    );
  }
  
  void _markExerciseAsCompleted() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) return;
    
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    
    // Mark the exercise as completed
    tutorialProvider.markExerciseAsCompleted(
      userId: authProvider.currentUser!.id,
      tutorialId: widget.tutorialId,
      exerciseId: widget.exerciseId,
    );
  }
  
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        
        // Auto-hide controls when starting playback
        _showControls = false;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _controller.value.isPlaying) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    });
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    // Auto-hide controls after a few seconds if video is playing
    if (_showControls && _controller.value.isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }
  
  void _changePlaybackSpeed() {
    // Cycle through speed options
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;
    
    setState(() {
      _playbackSpeed = speeds[nextIndex];
      _controller.setPlaybackSpeed(_playbackSpeed);
    });
    
    // Show a snackbar to indicate the new speed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playback speed: ${_playbackSpeed}x'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _seekBack() {
    final newPosition = _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }
  
  void _seekForward() {
    final newPosition = _controller.value.position + const Duration(seconds: 10);
    final duration = _controller.value.duration;
    _controller.seekTo(newPosition > duration ? duration : newPosition);
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: AppTheme.errorColor, size: 42),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeVideo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (!_isInitialized) {
      return const Center(
        child: Text('Failed to initialize video player'),
      );
    }
    
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              
              // Play/Pause overlay
              if (_showControls)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Back 10s
                            IconButton(
                              onPressed: _seekBack,
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 24),
                            
                            // Play/Pause
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            
                            const SizedBox(width: 24),
                            
                            // Forward 10s
                            IconButton(
                              onPressed: _seekForward,
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Progress bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Current position
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              
                              const SizedBox(width: 10),
                              
                              // Seek bar
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: AppTheme.primaryColor,
                                    inactiveTrackColor: Colors.white30,
                                    thumbColor: AppTheme.primaryColor,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                                  ),
                                  child: Slider(
                                    value: _controller.value.position.inSeconds.toDouble(),
                                    min: 0.0,
                                    max: _controller.value.duration.inSeconds.toDouble(),
                                    onChanged: (value) {
                                      setState(() {
                                        _controller.seekTo(Duration(seconds: value.toInt()));
                                      });
                                    },
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 10),
                              
                              // Total duration
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Additional controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Playback speed button
                            TextButton.icon(
                              onPressed: _changePlaybackSpeed,
                              icon: const Icon(Icons.speed, color: Colors.white, size: 16),
                              label: Text(
                                '${_playbackSpeed}x',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black45,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
              // Loading indicator
              if (_controller.value.isBuffering)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
            ],
          ),
        ),
      ],
    );
  }
}