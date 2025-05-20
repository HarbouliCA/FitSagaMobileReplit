import 'package:flutter/material.dart';
import 'package:fitsaga/models/auth_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/screens/tutorials/tutorial_detail_screen.dart';

class TutorialsScreen extends StatefulWidget {
  final User user;
  
  const TutorialsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Cardio'),
            Tab(text: 'Strength'),
            Tab(text: 'Flexibility'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All tutorials
          _buildTutorialList(demoTutorials),
          
          // Cardio tutorials
          _buildTutorialList(demoTutorials.where(
            (tutorial) => tutorial.category.toLowerCase() == 'cardio'
          ).toList()),
          
          // Strength tutorials
          _buildTutorialList(demoTutorials.where(
            (tutorial) => tutorial.category.toLowerCase() == 'strength'
          ).toList()),
          
          // Flexibility tutorials
          _buildTutorialList(demoTutorials.where(
            (tutorial) => tutorial.category.toLowerCase() == 'flexibility'
          ).toList()),
        ],
      ),
      // Admin/Instructor roles can add tutorials
      floatingActionButton: widget.user.role != UserRole.client
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add tutorial feature coming soon'),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search tutorials...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }
  
  Widget _buildTutorialList(List<Tutorial> tutorials) {
    // Filter tutorials based on search query
    final filteredTutorials = _searchQuery.isEmpty
        ? tutorials
        : tutorials.where((tutorial) =>
            tutorial.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            tutorial.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    return filteredTutorials.isEmpty
        ? _buildEmptyState()
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredTutorials.length,
            itemBuilder: (context, index) {
              return _buildTutorialCard(filteredTutorials[index]);
            },
          );
  }
  
  Widget _buildTutorialCard(Tutorial tutorial) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorialDetailScreen(
              tutorial: tutorial,
              user: widget.user,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail image
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
                  
                  // Play button overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  
                  // Duration badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(tutorial.durationSeconds),
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
            ),
            
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
                      fontSize: 16,
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
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(tutorial.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getCategoryColor(tutorial.category).withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      tutorial.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(tutorial.category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tutorials found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Tutorials will appear here',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
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
}

// Tutorial model
class Tutorial {
  final String id;
  final String title;
  final String description;
  final String category;
  final String instructorName;
  final String thumbnailUrl;
  final String videoUrl;
  final int durationSeconds;
  final DateTime publishedDate;
  
  Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.instructorName,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.durationSeconds,
    required this.publishedDate,
  });
}

// Demo tutorial data
final List<Tutorial> demoTutorials = [
  Tutorial(
    id: '1',
    title: 'Proper Squat Form for Beginners',
    description: 'Learn the correct form for squats to maximize results and minimize injury risk. This tutorial covers stance, depth, and common mistakes to avoid.',
    category: 'Strength',
    instructorName: 'David Clark',
    thumbnailUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
    videoUrl: 'https://example.com/videos/squats',
    durationSeconds: 450, // 7:30
    publishedDate: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Tutorial(
    id: '2',
    title: 'HIIT Workout: 20 Minute Fat Burner',
    description: 'This high-intensity interval training workout is designed to maximize calorie burn in just 20 minutes. No equipment required!',
    category: 'Cardio',
    instructorName: 'Lisa Wong',
    thumbnailUrl: 'https://images.unsplash.com/photo-1549576490-b0b4831ef60a',
    videoUrl: 'https://example.com/videos/hiit-workout',
    durationSeconds: 1200, // 20:00
    publishedDate: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Tutorial(
    id: '3',
    title: 'Full Body Stretch Routine',
    description: 'A comprehensive stretching routine targeting all major muscle groups. Perfect for improving flexibility and preventing injury.',
    category: 'Flexibility',
    instructorName: 'Sara Johnson',
    thumbnailUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
    videoUrl: 'https://example.com/videos/stretching',
    durationSeconds: 900, // 15:00
    publishedDate: DateTime.now().subtract(const Duration(days: 15)),
  ),
  Tutorial(
    id: '4',
    title: 'Beginners Guide to Deadlifts',
    description: 'Master the deadlift with this step-by-step guide. Learn proper form, breathing techniques, and progression strategies.',
    category: 'Strength',
    instructorName: 'Mike Torres',
    thumbnailUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
    videoUrl: 'https://example.com/videos/deadlifts',
    durationSeconds: 720, // 12:00
    publishedDate: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Tutorial(
    id: '5',
    title: 'Morning Yoga Flow for Energy',
    description: 'Start your day with this energizing yoga flow. Designed to wake up your body, improve circulation, and boost your mood.',
    category: 'Flexibility',
    instructorName: 'Sara Johnson',
    thumbnailUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
    videoUrl: 'https://example.com/videos/yoga-flow',
    durationSeconds: 1500, // 25:00
    publishedDate: DateTime.now().subtract(const Duration(days: 8)),
  ),
  Tutorial(
    id: '6',
    title: '30 Minute Treadmill Interval Workout',
    description: 'Maximize your treadmill time with this 30-minute interval workout. Alternating between high and low intensity periods for optimal fat burning.',
    category: 'Cardio',
    instructorName: 'Mike Torres',
    thumbnailUrl: 'https://images.unsplash.com/photo-1561214078-f3247647fc5e',
    videoUrl: 'https://example.com/videos/treadmill',
    durationSeconds: 1800, // 30:00
    publishedDate: DateTime.now().subtract(const Duration(days: 12)),
  ),
];