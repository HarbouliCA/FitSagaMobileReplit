import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/screens/tutorials/tutorials_screen.dart';

class TutorialDetailScreen extends StatefulWidget {
  final Tutorial tutorial;
  final User user;
  
  const TutorialDetailScreen({
    Key? key,
    required this.tutorial,
    required this.user,
  }) : super(key: key);

  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _isFullScreen = false;
  bool _isMuted = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen 
          ? null 
          : AppBar(
              title: Text(widget.tutorial.title),
              actions: [
                if (widget.user.role != UserRole.client)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit tutorial feature coming soon'),
                        ),
                      );
                    },
                  ),
              ],
            ),
      body: _isFullScreen
          ? _buildFullScreenVideoPlayer()
          : _buildTutorialDetail(),
    );
  }
  
  Widget _buildTutorialDetail() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail
                Image.network(
                  widget.tutorial.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                
                // Play button and controls overlay
                _buildVideoControls(),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and metadata
                Text(
                  widget.tutorial.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Metadata row
                Row(
                  children: [
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getCategoryColor().withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        widget.tutorial.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Duration
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(widget.tutorial.durationSeconds),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Release date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.tutorial.publishedDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
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
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Instructor info
                const Text(
                  'Instructor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        widget.tutorial.instructorName.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        ],
                      ),
                    ),
                    
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View instructor profile feature coming soon'),
                          ),
                        );
                      },
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Related tutorials
                const Text(
                  'Related Tutorials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getRelatedTutorials().length,
                    itemBuilder: (context, index) {
                      final tutorial = _getRelatedTutorials()[index];
                      return _buildRelatedTutorialCard(tutorial);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVideoControls() {
    return Stack(
      children: [
        // Background gradient for controls visibility
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        
        // Play/pause button
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
                if (_isPlaying) {
                  // Start progress animation (in a real app, this would be tied to video playback)
                  _startFakeProgressTimer();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
        
        // Bottom controls
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Current time
                Text(
                  _formatDuration((widget.tutorial.durationSeconds * _progress).toInt()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                
                // Progress bar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        trackShape: const RoundedRectSliderTrackShape(),
                        activeTrackColor: AppTheme.primaryColor,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: AppTheme.primaryColor,
                        overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _progress,
                        onChanged: (value) {
                          setState(() {
                            _progress = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                
                // Total time
                Text(
                  _formatDuration(widget.tutorial.durationSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                
                // Mute button
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                ),
                
                // Fullscreen button
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    setState(() {
                      _isFullScreen = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFullScreenVideoPlayer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFullScreen = false;
        });
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.tutorial.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildVideoControls(),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isFullScreen = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRelatedTutorialCard(Tutorial tutorial) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TutorialDetailScreen(
              tutorial: tutorial,
              user: widget.user,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      tutorial.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Duration badge
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _formatDuration(tutorial.durationSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
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
            
            // Instructor
            Text(
              tutorial.instructorName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  void _startFakeProgressTimer() {
    // For demo purposes only - simulates video progress
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _isPlaying) {
        setState(() {
          _progress += 0.005;
          if (_progress >= 1.0) {
            _progress = 0.0;
            _isPlaying = false;
          } else {
            _startFakeProgressTimer();
          }
        });
      }
    });
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  Color _getCategoryColor() {
    switch (widget.tutorial.category.toLowerCase()) {
      case 'cardio':
        return Colors.red;
      case 'strength':
        return Colors.blue;
      case 'flexibility':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  List<Tutorial> _getRelatedTutorials() {
    // In a real app, this would fetch related tutorials from the backend
    // For demo purposes, we'll just filter tutorials with the same category
    return demoTutorials
        .where((tutorial) => 
            tutorial.category == widget.tutorial.category && 
            tutorial.id != widget.tutorial.id)
        .toList();
  }
}