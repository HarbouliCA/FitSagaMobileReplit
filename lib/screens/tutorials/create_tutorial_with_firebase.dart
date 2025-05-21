import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tutorial_model.dart';

class CreateTutorialScreen extends StatefulWidget {
  const CreateTutorialScreen({Key? key}) : super(key: key);

  @override
  State<CreateTutorialScreen> createState() => _CreateTutorialScreenState();
}

class _CreateTutorialScreenState extends State<CreateTutorialScreen> with SingleTickerProviderStateMixin {
  // Controllers for form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Selected values for dropdowns
  String _selectedCategory = 'Strength';
  String _selectedDifficulty = 'Beginner';
  
  // Video filtering and selection
  List<VideoTutorial> _allVideos = [];
  List<VideoTutorial> _filteredVideos = [];
  List<VideoTutorial> _selectedVideos = [];
  String _searchQuery = '';
  
  // Tab controller for video categories
  late TabController _tabController;
  String _activeTab = 'All';
  
  // Loading state
  bool _isLoading = true;
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Get all exercise types for tab controller
    final types = ['All'] + VideoTutorial.getAllExerciseTypes().map((e) => 
      e[0].toUpperCase() + e.substring(1)).toList();
    
    // Initialize tab controller
    _tabController = TabController(
      length: types.length,
      vsync: this,
    );
    
    // Listen for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeTab = types[_tabController.index];
          _updateFilteredVideos();
        });
      }
    });
    
    // Load videos from Firebase or mock data
    _loadVideos();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  // Load videos from Firebase or mock data for testing
  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // In a real app, this would fetch from Firebase
      // If we have Firebase initialized:
      // final videoCollection = FirebaseFirestore.instance.collection('videos');
      // final snapshot = await videoCollection.get();
      // _allVideos = snapshot.docs.map((doc) => VideoTutorial.fromFirestore(doc)).toList();
      
      // For now, use mock data
      _allVideos = VideoTutorial.getMockTutorials();
      _filteredVideos = List.from(_allVideos);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load videos: ${e.toString()}';
      });
    }
  }
  
  // Filter videos based on search query and active tab
  void _updateFilteredVideos() {
    setState(() {
      _filteredVideos = _allVideos.where((video) {
        // Apply category filter
        if (_activeTab != 'All' && 
            video.type.toLowerCase() != _activeTab.toLowerCase()) {
          return false;
        }
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          return video.activity.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 video.bodyPart.toLowerCase().contains(_searchQuery.toLowerCase());
        }
        
        return true;
      }).toList();
    });
  }
  
  // Create a new tutorial with selected videos
  Future<void> _createTutorial() async {
    if (_selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one video')),
      );
      return;
    }
    
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the tutorial')),
      );
      return;
    }
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      // In a real app, this would create a tutorial in Firebase
      // final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      
      // final docRef = await firestore.collection('tutorials').add({
      //   'title': _titleController.text,
      //   'description': _descriptionController.text,
      //   'category': _selectedCategory,
      //   'difficulty': _selectedDifficulty,
      //   'videoIds': _selectedVideos.map((v) => v.id).toList(),
      //   'creatorId': userId,
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      
      // For demo, just simulate a delay
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isCreating = false;
      });
      
      // Show success dialog
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create tutorial: ${e.toString()}')),
      );
    }
  }
  
  // Show success dialog after tutorial creation
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Your tutorial "${_titleController.text}" has been created successfully with ${_selectedVideos.length} videos!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear form and go back to previous screen
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('DONE'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear the form to create another tutorial
              _titleController.clear();
              _descriptionController.clear();
              setState(() {
                _selectedVideos.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('CREATE ANOTHER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tutorial'),
        actions: [
          if (_selectedVideos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Badge(
                  label: Text(_selectedVideos.length.toString()),
                  child: const Icon(Icons.video_library),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    return Column(
      children: [
        // Form section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tutorial Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Category and Difficulty
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      value: _selectedCategory,
                      items: ['Strength', 'Cardio', 'Flexibility', 'HIIT']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      value: _selectedDifficulty,
                      items: ['Beginner', 'Intermediate', 'Advanced']
                          .map((difficulty) => DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDifficulty = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Divider(),
        
        // Video selection section
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Select Videos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedVideos.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedVideos.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Selection'),
                      ),
                  ],
                ),
              ),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or muscle group...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _updateFilteredVideos();
                    });
                  },
                ),
              ),
              
              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  const Tab(text: 'All'),
                  for (final type in VideoTutorial.getAllExerciseTypes())
                    Tab(text: type[0].toUpperCase() + type.substring(1)),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
              ),
              
              // Selected videos section
              if (_selectedVideos.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedVideos.length} Videos Selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedVideos.length,
                          itemBuilder: (context, index) {
                            final video = _selectedVideos[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Video type icon
                                  Container(
                                    width: 40,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: video.type == 'cardio'
                                          ? Colors.red.withOpacity(0.2)
                                          : Colors.blue.withOpacity(0.2),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: Icon(
                                      video.type == 'cardio'
                                          ? Icons.directions_run
                                          : Icons.fitness_center,
                                      color: video.type == 'cardio'
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                  ),
                                  
                                  // Video info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            video.activity,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            video.bodyPart,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Remove button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedVideos.remove(video);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Video list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredVideos.length,
                  itemBuilder: (context, index) {
                    final video = _filteredVideos[index];
                    final isSelected = _selectedVideos.contains(video);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
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
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildTag(
                                  video.type[0].toUpperCase() + video.type.substring(1),
                                  video.type == 'cardio' ? Colors.red : Colors.blue,
                                ),
                                _buildTag(
                                  video.dayName,
                                  Colors.purple,
                                ),
                                _buildTag(
                                  'Plan ${video.planId}',
                                  Colors.teal,
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedVideos.add(video);
                              } else {
                                _selectedVideos.remove(video);
                              }
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedVideos.remove(video);
                            } else {
                              _selectedVideos.add(video);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Create button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isCreating ? null : _createTutorial,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Create Tutorial with ${_selectedVideos.length} Videos'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
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
}