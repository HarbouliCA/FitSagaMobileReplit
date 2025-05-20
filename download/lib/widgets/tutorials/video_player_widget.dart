import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/utils/date_formatter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  
  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _showControls = true;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Once the video has been loaded, set state to display the first frame
      setState(() {});
    });
    
    // Add listener to update UI when video state changes
    _controller.addListener(_videoListener);
    
    // Hide controls after 3 seconds
    _startHideControlsTimer();
  }
  
  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }
  
  void _videoListener() {
    setState(() {
      _isPlaying = _controller.value.isPlaying;
      
      // Reset controls visibility when the video finishes
      if (_controller.value.position >= _controller.value.duration) {
        _showControls = true;
      }
    });
  }
  
  void _startHideControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && !_isDragging) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }
  
  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
      } else {
        _controller.play();
        _startHideControlsTimer();
      }
    });
  }
  
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls && _isPlaying) {
        _startHideControlsTimer();
      }
    });
  }
  
  String _formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0").substring(3);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                );
              } else if (snapshot.hasError) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Error loading video',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              } else {
                // Loading placeholder (thumbnail if available)
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: widget.thumbnailUrl != null
                        ? Image.network(
                            widget.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }
            },
          ),
          
          // Play button overlay (only when video is initialized)
          if (_controller.value.isInitialized && !_isPlaying)
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64.0,
              ),
              onPressed: _togglePlay,
            ),
          
          // Video controls overlay
          if (_showControls && _controller.value.isInitialized)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top controls (title, fullscreen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isFullScreen 
                                ? Icons.fullscreen_exit 
                                : Icons.fullscreen,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFullScreen,
                        ),
                      ],
                    ),
                    
                    // Center play/pause button
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        color: Colors.white,
                        size: 48.0,
                      ),
                      onPressed: _togglePlay,
                    ),
                    
                    // Bottom controls (progress bar)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Progress bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              // Current position
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                              
                              // Slider
                              Expanded(
                                child: GestureDetector(
                                  onHorizontalDragStart: (details) {
                                    _isDragging = true;
                                  },
                                  onHorizontalDragEnd: (details) {
                                    _isDragging = false;
                                    if (_isPlaying) {
                                      _startHideControlsTimer();
                                    }
                                  },
                                  child: Slider(
                                    value: _controller.value.position.inMilliseconds
                                        .toDouble().clamp(
                                          0, 
                                          _controller.value.duration.inMilliseconds
                                              .toDouble(),
                                        ),
                                    min: 0.0,
                                    max: _controller.value.duration.inMilliseconds
                                        .toDouble(),
                                    activeColor: AppTheme.primaryColor,
                                    inactiveColor: Colors.white.withOpacity(0.3),
                                    onChanged: (value) {
                                      setState(() {
                                        _controller.seekTo(
                                          Duration(milliseconds: value.toInt()),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              
                              // Total duration
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Playback speed controls
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Playback speed button
                              PopupMenuButton<double>(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.speed,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_controller.value.playbackSpeed}x',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                initialValue: _controller.value.playbackSpeed,
                                onSelected: (double speed) {
                                  setState(() {
                                    _controller.setPlaybackSpeed(speed);
                                  });
                                },
                                itemBuilder: (BuildContext context) {
                                  return <PopupMenuEntry<double>>[
                                    const PopupMenuItem<double>(
                                      value: 0.5,
                                      child: Text('0.5x'),
                                    ),
                                    const PopupMenuItem<double>(
                                      value: 1.0,
                                      child: Text('1.0x'),
                                    ),
                                    const PopupMenuItem<double>(
                                      value: 1.5,
                                      child: Text('1.5x'),
                                    ),
                                    const PopupMenuItem<double>(
                                      value: 2.0,
                                      child: Text('2.0x'),
                                    ),
                                  ];
                                },
                              ),
                            ],
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
    );
  }
}
