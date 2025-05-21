import 'package:flutter/material.dart';
import '../../models/tutorial_model.dart';

class TutorialDetailScreen extends StatefulWidget {
  final String tutorialId;
  
  const TutorialDetailScreen({
    Key? key,
    required this.tutorialId,
  }) : super(key: key);
  
  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TutorialProgram? _tutorial;
  int _selectedVideoIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadTutorial();
  }
  
  // Load tutorial data from Firebase
  Future<void> _loadTutorial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // In a real app, this would fetch from Firebase
      // final firestore = FirebaseFirestore.instance;
      // final doc = await firestore.collection('tutorials').doc(widget.tutorialId).get();
      // if (doc.exists) {
      //   _tutorial = await TutorialProgram.fromFirestore(doc, firestore);
      // } else {
      //   _errorMessage = 'Tutorial not found';
      // }
      
      // For demo, create a mock tutorial
      await Future.delayed(const Duration(seconds: 1));
      _tutorial = TutorialProgram(
        id: 'mock-tutorial-1',
        title: 'Full Body Strength Training',
        description: 'A comprehensive strength training program targeting all major muscle groups.',
        category: 'Strength',
        difficulty: 'Intermediate',
        videos: VideoTutorial.getMockTutorials()
            .where((v) => v.type == 'strength')
            .toList(),
        creatorId: 'instructor-1',
        creatorName: 'David Clark',
        createdAt: DateTime.now(),
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tutorial: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tutorial?.title ?? 'Tutorial Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildTutorialDetails(),
    );
  }
  
  Widget _buildTutorialDetails() {
    if (_tutorial == null) {
      return const Center(child: Text('Tutorial not found'));
    }
    
    final tutorial = _tutorial!;
    final selectedVideo = tutorial.videos.isNotEmpty ? tutorial.videos[_selectedVideoIndex] : null;
    
    return Column(
      children: [
        // Video player area
        if (selectedVideo != null) ...[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video thumbnail or placeholder
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      selectedVideo.type == 'cardio'
                          ? Icons.directions_run
                          : Icons.fitness_center,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                
                // Play button overlay
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 64,
                  ),
                  onPressed: () {
                    // In a real app, this would play the video
                    _showVideoDialog(selectedVideo);
                  },
                ),
                
                // Video title overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withOpacity(0.5),
                    child: Text(
                      selectedVideo.activity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Video selection tabs
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: tutorial.videos.length,
              itemBuilder: (context, index) {
                final video = tutorial.videos[index];
                final isSelected = index == _selectedVideoIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVideoIndex = index;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Thumbnail background
                        Container(
                          color: video.type == 'cardio'
                              ? Colors.red.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          child: Center(
                            child: Icon(
                              video.type == 'cardio'
                                  ? Icons.directions_run
                                  : Icons.fitness_center,
                              color: video.type == 'cardio'
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                        ),
                        
                        // Number badge for ordering
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        
        // Tutorial details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and creator
                Text(
                  tutorial.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Created by ${tutorial.creatorName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Category and difficulty badges
                Row(
                  children: [
                    _buildBadge(
                      tutorial.category,
                      Colors.blue,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    _buildBadge(
                      tutorial.difficulty,
                      _getDifficultyColor(tutorial.difficulty),
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
                
                Text(tutorial.description),
                
                const SizedBox(height: 24),
                
                // Video list
                const Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                for (int i = 0; i < tutorial.videos.length; i++)
                  _buildVideoItem(tutorial.videos[i], i),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildVideoItem(VideoTutorial video, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            // Thumbnail background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: video.type == 'cardio'
                    ? Colors.red.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                video.type == 'cardio'
                    ? Icons.directions_run
                    : Icons.fitness_center,
                color: video.type == 'cardio'
                    ? Colors.red
                    : Colors.blue,
                size: 30,
              ),
            ),
            
            // Play icon
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 30,
            ),
            
            // Number badge
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          video.activity,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(video.bodyPart),
            const SizedBox(height: 4),
            Text(
              '${video.dayName} • Plan ${video.planId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_fill),
          onPressed: () {
            setState(() {
              _selectedVideoIndex = index;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedVideoIndex = index;
          });
        },
      ),
    );
  }
  
  void _showVideoDialog(VideoTutorial video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(video.activity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'In a real app, this would play the video from Firebase storage.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Video URL: ${video.videoUrl}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
        return Colors.grey;
    }
  }
}