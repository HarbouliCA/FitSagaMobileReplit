import 'package:flutter/material.dart';
import '../../models/tutorial_model.dart';

class EnhancedCreateTutorialScreen extends StatefulWidget {
  final String userRole;
  final Function(Map<String, dynamic>) onTutorialCreated;

  const EnhancedCreateTutorialScreen({
    Key? key,
    required this.userRole,
    required this.onTutorialCreated,
  }) : super(key: key);

  @override
  State<EnhancedCreateTutorialScreen> createState() => _EnhancedCreateTutorialScreenState();
}

class _EnhancedCreateTutorialScreenState extends State<EnhancedCreateTutorialScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  // Form values
  String _selectedCategory = 'Strength';
  String _selectedDifficulty = 'Beginner';
  List<String> _selectedBodyParts = [];
  List<VideoTutorial> _selectedVideos = [];
  
  // Filter values
  String _activeTab = 'All';
  String _searchQuery = '';
  List<VideoTutorial> _filteredVideos = [];
  
  // Tab controller
  late TabController _tabController;
  
  // Options for dropdowns
  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];
  
  @override
  void initState() {
    super.initState();
    _durationController.text = '0';
    
    // Initialize tab controller
    _tabController = TabController(
      length: getAllExerciseTypes().length + 1, // +1 for "All" tab
      vsync: this,
    );
    
    // Initialize filtered videos with all videos
    _filteredVideos = getMockTutorials();
    
    // Listen to tab changes
    _tabController.addListener(_handleTabChange);
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    
    setState(() {
      if (_tabController.index == 0) {
        _activeTab = 'All';
      } else {
        _activeTab = getAllExerciseTypes().elementAt(_tabController.index - 1);
      }
      _updateFilteredVideos();
    });
  }
  
  void _updateFilteredVideos() {
    List<VideoTutorial> allVideos = getMockTutorials();
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      allVideos = allVideos.where((video) {
        return video.activity.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               video.bodyPart.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Filter by selected tab
    if (_activeTab != 'All') {
      allVideos = allVideos.where((video) => video.type == _activeTab.toLowerCase()).toList();
    }
    
    setState(() {
      _filteredVideos = allVideos;
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Tutorial'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tutorial Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Difficulty and category row
                    Row(
                      children: [
                        // Category
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              for (final type in getAllExerciseTypes())
                                DropdownMenuItem<String>(
                                  value: type[0].toUpperCase() + type.substring(1), // Capitalize
                                  child: Text(type[0].toUpperCase() + type.substring(1)),
                                )
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a category';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Difficulty
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDifficulty,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder(),
                            ),
                            items: _difficulties.map((difficulty) {
                              return DropdownMenuItem<String>(
                                value: difficulty,
                                child: Text(difficulty),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a difficulty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Body part selection
                    const Text(
                      'Target Muscle Groups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: getAllBodyParts().map((bodyPart) {
                        final isSelected = _selectedBodyParts.contains(bodyPart);
                        
                        return FilterChip(
                          label: Text(bodyPart),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedBodyParts.add(bodyPart);
                              } else {
                                _selectedBodyParts.remove(bodyPart);
                              }
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: const Color(0xFF0D47A1).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF0D47A1),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Selected Videos
                    const Text(
                      'Selected Videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    if (_selectedVideos.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Text(
                            'No videos selected. Please select videos from the list below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (final video in _selectedVideos)
                            Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(video.thumbnailUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  video.activity,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  video.bodyPart,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedVideos.remove(video);
                                      
                                      // Recalculate total duration
                                      int totalDuration = 0;
                                      for (final video in _selectedVideos) {
                                        // Assuming each video is 5 minutes for demo purposes
                                        totalDuration += 5;
                                      }
                                      _durationController.text = totalDuration.toString();
                                    });
                                  },
                                ),
                              ),
                            ),
                          
                          // Total duration
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Text(
                                  'Total Duration:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_durationController.text} minutes',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Available videos section
                    const Text(
                      'Available Videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search videos by name or muscle group...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _updateFilteredVideos();
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tab bar with exercise types
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: [
                        const Tab(text: 'All'),
                        for (final type in getAllExerciseTypes())
                          Tab(text: type[0].toUpperCase() + type.substring(1)), // Capitalize
                      ],
                      labelColor: const Color(0xFF0D47A1),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF0D47A1),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Video grid
                    SizedBox(
                      height: 450, // Fixed height for grid
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredVideos.length,
                        itemBuilder: (context, index) {
                          final video = _filteredVideos[index];
                          final isSelected = _selectedVideos.contains(video);
                          
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF0D47A1) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedVideos.remove(video);
                                  } else {
                                    _selectedVideos.add(video);
                                  }
                                  
                                  // Update total duration
                                  int totalDuration = 0;
                                  for (final video in _selectedVideos) {
                                    // Assuming each video is 5 minutes for demo purposes
                                    totalDuration += 5;
                                  }
                                  _durationController.text = totalDuration.toString();
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thumbnail
                                  Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.network(
                                          video.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0D47A1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      // Exercise type badge
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: video.type == 'cardio'
                                                ? Colors.red.withOpacity(0.8)
                                                : Colors.blue.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            video.type[0].toUpperCase() + video.type.substring(1),
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
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Activity name
                                        Text(
                                          video.activity,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Body parts
                                        Text(
                                          video.bodyPart,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
                ),
              ),
            ),
          ),
          
          // Bottom button bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Create Tutorial'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVideos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one video for the tutorial'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Create tutorial data
      final Map<String, dynamic> tutorialData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'duration': int.parse(_durationController.text),
        'description': _descriptionController.text,
        'bodyParts': _selectedBodyParts,
        'videos': _selectedVideos.map((v) => v.id).toList(),
        'author': widget.userRole == 'admin' ? 'Admin User' : 'Instructor User',
        'createdAt': DateTime.now(),
        'isPublished': true,
      };
      
      // Pass data back to parent
      widget.onTutorialCreated(tutorialData);
      
      // Show success message and close
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutorial created successfully!')),
      );
      Navigator.of(context).pop();
    }
  }
}

class VideoTutorialPlayerScreen extends StatelessWidget {
  final VideoTutorial video;
  
  const VideoTutorialPlayerScreen({Key? key, required this.video}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.activity),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player placeholder
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Thumbnail as background
                Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[900],
                    );
                  },
                ),
                // Play button overlay
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                // Video controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.black.withOpacity(0.5),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          '0:00 / 5:00',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        const Icon(Icons.fullscreen, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video title
                  Text(
                    video.activity,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: video.type == 'cardio'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: video.type == 'cardio'
                            ? Colors.red.withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      video.type[0].toUpperCase() + video.type.substring(1),
                      style: TextStyle(
                        color: video.type == 'cardio' ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider
                  const Divider(),
                  
                  const SizedBox(height: 16),
                  
                  // Body parts
                  const Text(
                    'Target Muscle Groups',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    video.bodyPart,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Information cards
                  Row(
                    children: [
                      _buildInfoCard(
                        title: 'Plan ID',
                        value: video.planId,
                        icon: Icons.folder,
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        title: 'Day',
                        value: video.dayName,
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Instructions placeholder
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Start with proper form and positioning',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '2. Perform the movement with controlled motion',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '3. Maintain proper breathing throughout',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '4. Complete the recommended sets and repetitions',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF0D47A1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}