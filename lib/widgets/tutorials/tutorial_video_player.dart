import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';

class TutorialVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String tutorialId;
  final List<VideoBookmark>? bookmarks;
  final bool allowBookmarking;
  
  const TutorialVideoPlayer({
    Key? key,
    required this.videoUrl,
    required this.tutorialId,
    this.bookmarks,
    this.allowBookmarking = false,
  }) : super(key: key);

  @override
  State<TutorialVideoPlayer> createState() => _TutorialVideoPlayerState();
}

class _TutorialVideoPlayerState extends State<TutorialVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String? _error;
  bool _showBookmarks = false;
  int _lastPosition = 0;
  double _playbackSpeed = 1.0;
  
  // Keep track of progress updates
  DateTime _lastProgressUpdate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  
  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Get last watched position if available
      final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      int startPosition = 0;
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        final progress = tutorialProvider.getProgressForTutorial(widget.tutorialId);
        if (progress != null && progress.lastWatchedPosition > 0) {
          startPosition = progress.lastWatchedPosition;
        }
      }
      
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      await _videoPlayerController.initialize();
      
      // Set up listener for position updates
      _videoPlayerController.addListener(_onVideoPositionChanged);
      
      // Seek to last position if needed
      if (startPosition > 0 && startPosition < _videoPlayerController.value.duration.inSeconds) {
        await _videoPlayerController.seekTo(Duration(seconds: startPosition));
      }
      
      final chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: false,
        looping: false,
        allowPlaybackSpeedChanging: true,
        allowedScreenSleep: false,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        customControls: const CupertinoControls(
          backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
          iconColor: Colors.white,
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryColor,
          handleColor: AppTheme.primaryColor,
          backgroundColor: Colors.grey.shade300,
          bufferedColor: AppTheme.primaryLightColor,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: AppTheme.errorColor, size: 42),
                const SizedBox(height: 16),
                Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeVideo,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      );
      
      setState(() {
        _chewieController = chewieController;
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error initializing video: ${e.toString()}';
        _isLoading = false;
      });
      print(_error);
    }
  }
  
  void _onVideoPositionChanged() {
    if (!_videoPlayerController.value.isInitialized) return;
    
    // Track current position
    final currentPosition = _videoPlayerController.value.position.inSeconds;
    
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
  }
  
  void _updateProgress() {
    // Don't update if not authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || authProvider.currentUser == null) return;
    
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    final duration = _videoPlayerController.value.duration.inSeconds;
    final position = _videoPlayerController.value.position.inSeconds;
    
    if (duration > 0) {
      // Calculate progress as percentage
      final progress = position / duration;
      
      // Determine if video is considered "completed"
      final isCompleted = progress >= 0.9; // 90% watched is considered complete
      
      // Update progress in provider
      tutorialProvider.updateTutorialProgress(
        userId: authProvider.currentUser!.id,
        tutorialId: widget.tutorialId,
        progress: progress,
        isCompleted: isCompleted,
        lastWatchedPosition: position,
      );
    }
  }
  
  void _toggleBookmarks() {
    setState(() {
      _showBookmarks = !_showBookmarks;
    });
  }
  
  void _jumpToBookmark(int timestamp) {
    _videoPlayerController.seekTo(Duration(seconds: timestamp));
  }
  
  void _changePlaybackSpeed() {
    // Cycle through speed options
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;
    
    setState(() {
      _playbackSpeed = speeds[nextIndex];
      _videoPlayerController.setPlaybackSpeed(_playbackSpeed);
    });
  }
  
  Future<void> _addBookmark() async {
    if (!widget.allowBookmarking) return;
    
    final currentPosition = _videoPlayerController.value.position.inSeconds;
    
    // Show dialog to add bookmark title and description
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddBookmarkDialog(
        currentPosition: currentPosition,
      ),
    );
    
    if (result != null) {
      final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Need to be admin or instructor
      if (!authProvider.isAuthenticated || 
          (!authProvider.currentUser!.isAdmin && !authProvider.currentUser!.isInstructor)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only instructors can add bookmarks'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        return;
      }
      
      // Create new bookmark
      final newBookmark = VideoBookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result['title'] ?? 'Bookmark',
        description: result['description'] ?? '',
        timestamp: currentPosition,
      );
      
      // Get existing bookmarks or create new list
      final existingBookmarks = widget.bookmarks ?? [];
      final updatedBookmarks = [...existingBookmarks, newBookmark];
      
      // Update bookmarks in tutorial
      final success = await tutorialProvider.updateBookmarks(
        tutorialId: widget.tutorialId,
        bookmarks: updatedBookmarks,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmark added successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tutorialProvider.error ?? 'Failed to add bookmark'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
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
    
    if (!_isInitialized || _chewieController == null) {
      return const Center(
        child: Text('Failed to initialize video player'),
      );
    }
    
    return Column(
      children: [
        // Video Player
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(controller: _chewieController!),
        ),
        
        // Enhanced controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  backgroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              
              // Bookmarks button
              TextButton.icon(
                onPressed: _toggleBookmarks,
                icon: Icon(
                  _showBookmarks ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white, 
                  size: 16,
                ),
                label: Text(
                  _showBookmarks ? 'Hide Bookmarks' : 'Show Bookmarks',
                  style: const TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: _showBookmarks 
                      ? AppTheme.primaryColor 
                      : Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              
              // Add bookmark button (only if allowed)
              if (widget.allowBookmarking)
                TextButton.icon(
                  onPressed: _addBookmark,
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text(
                    'Add Bookmark',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
        
        // Bookmarks section
        if (_showBookmarks && widget.bookmarks != null && widget.bookmarks!.isNotEmpty)
          Container(
            height: 200,
            color: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: widget.bookmarks!.length,
              itemBuilder: (context, index) {
                final bookmark = widget.bookmarks![index];
                return ListTile(
                  leading: const Icon(Icons.bookmark, color: AppTheme.primaryColor),
                  title: Text(bookmark.title),
                  subtitle: Text(bookmark.description),
                  trailing: Text(
                    bookmark.formattedTime,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _jumpToBookmark(bookmark.timestamp),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AddBookmarkDialog extends StatefulWidget {
  final int currentPosition;
  
  const _AddBookmarkDialog({
    Key? key,
    required this.currentPosition,
  }) : super(key: key);

  @override
  State<_AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<_AddBookmarkDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String get _formattedTime {
    final minutes = widget.currentPosition ~/ 60;
    final seconds = widget.currentPosition % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void initState() {
    super.initState();
    _titleController.text = 'Bookmark at $_formattedTime';
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Position: $_formattedTime',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Title cannot be empty'),
                  backgroundColor: AppTheme.warningColor,
                ),
              );
              return;
            }
            
            Navigator.of(context).pop({
              'title': _titleController.text,
              'description': _descriptionController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}