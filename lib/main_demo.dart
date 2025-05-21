import 'package:flutter/material.dart';

void main() {
  runApp(const TutorialDemoApp());
}

class TutorialDemoApp extends StatelessWidget {
  const TutorialDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSAGA Tutorial Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const TutorialLibraryScreen(),
    );
  }
}

class VideoData {
  final String id;
  final String title;
  final String bodyPart;
  final String type;
  final String dayName;
  final String planId;
  
  VideoData({
    required this.id,
    required this.title,
    required this.bodyPart,
    required this.type,
    required this.dayName,
    required this.planId,
  });
}

class TutorialLibraryScreen extends StatefulWidget {
  const TutorialLibraryScreen({Key? key}) : super(key: key);

  @override
  State<TutorialLibraryScreen> createState() => _TutorialLibraryScreenState();
}

class _TutorialLibraryScreenState extends State<TutorialLibraryScreen> {
  String _activeFilter = 'All';
  final List<String> _selectedIds = [];
  String _searchQuery = '';
  
  // Mock data from Firebase
  final List<VideoData> _allVideos = [
    VideoData(
      id: '10011090_18687781_2023_bc001.mp4',
      title: 'Press de banca - Barra',
      bodyPart: 'Pecho, Tríceps, Hombros parte delantera',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_cm005.mp4',
      title: 'Cinta de correr 8 km/h ~ 5 mph',
      bodyPart: 'Sistema cardiovascular, Piernas',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_cw003.mp4',
      title: 'Jumping jacks',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_gt001.mp4',
      title: 'Extension de codo - Polea',
      bodyPart: 'Tríceps',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_oa041.mp4',
      title: 'Curl de bíceps - Polea',
      bodyPart: 'Bíceps',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_ozp032.mp4',
      title: 'Saltos - Caja',
      bodyPart: 'Cuádriceps, Glúteos, Corvas, Zona lumbar',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687782_2023_ds001.mp4',
      title: 'Elevaciones laterales de pie - mancuernas',
      bodyPart: 'Hombros',
      type: 'strength',
      dayName: 'día 2',
      planId: '10011090',
    ),
    VideoData(
      id: '10031897_18739877_2023_cm001.mp4',
      title: 'Máquina de remos, Intensidad baja',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10031897',
    ),
    VideoData(
      id: '10031897_18739877_2023_cm002.mp4',
      title: 'Entrenador elíptico',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10031897',
    ),
  ];
  
  // Get available categories
  List<String> get _categories => ['All', 'Strength', 'Cardio'];
  
  // Get unique body parts
  List<String> get _bodyParts {
    final Set<String> parts = {};
    for (final video in _allVideos) {
      for (final part in video.bodyPart.split(', ')) {
        parts.add(part);
      }
    }
    return parts.toList()..sort();
  }
  
  // Get unique plans
  List<String> get _plans {
    final Set<String> plans = {};
    for (final video in _allVideos) {
      plans.add(video.planId);
    }
    return plans.toList()..sort();
  }
  
  // Get unique days
  List<String> get _days {
    final Set<String> days = {};
    for (final video in _allVideos) {
      days.add(video.dayName);
    }
    return days.toList()..sort();
  }
  
  // Get filtered videos
  List<VideoData> get _filteredVideos {
    if (_searchQuery.isEmpty && _activeFilter == 'All') {
      return _allVideos;
    }
    
    return _allVideos.where((video) {
      // Filter by category
      if (_activeFilter != 'All' && video.type.toLowerCase() != _activeFilter.toLowerCase()) {
        return false;
      }
      
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        return video.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               video.bodyPart.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Tutorial Library'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats & Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Column(
              children: [
                const Text(
                  'Create a New Tutorial',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select videos from our library to include in your custom tutorial',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      icon: Icons.video_library,
                      value: _allVideos.length.toString(),
                      label: 'Videos',
                    ),
                    _buildStatCard(
                      icon: Icons.fitness_center,
                      value: _bodyParts.length.toString(),
                      label: 'Body Parts',
                    ),
                    _buildStatCard(
                      icon: Icons.category,
                      value: '2',
                      label: 'Categories',
                    ),
                  ],
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
                });
              },
            ),
          ),
          
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                final isSelected = _activeFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _activeFilter = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Selected videos count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredVideos.length} videos available',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedIds.isNotEmpty)
                  Chip(
                    label: Text('${_selectedIds.length} selected'),
                    backgroundColor: Colors.blue.withOpacity(0.2),
                  ),
              ],
            ),
          ),
          
          // Videos list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredVideos.length,
              itemBuilder: (context, index) {
                final video = _filteredVideos[index];
                final isSelected = _selectedIds.contains(video.id);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(video.id);
                        } else {
                          _selectedIds.add(video.id);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Exercise icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: video.type.toLowerCase() == 'cardio'
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              video.type.toLowerCase() == 'cardio'
                                  ? Icons.directions_run
                                  : Icons.fitness_center,
                              color: video.type.toLowerCase() == 'cardio'
                                  ? Colors.red
                                  : Colors.blue,
                              size: 30,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Exercise details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                Text(
                                  video.bodyPart,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                Row(
                                  children: [
                                    _buildInfoBadge(
                                      text: video.type,
                                      color: video.type.toLowerCase() == 'cardio'
                                          ? Colors.red
                                          : Colors.blue,
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    _buildInfoBadge(
                                      text: video.dayName,
                                      color: Colors.purple,
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    _buildInfoBadge(
                                      text: 'Plan ${video.planId}',
                                      color: Colors.teal,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Checkbox
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedIds.add(video.id);
                                } else {
                                  _selectedIds.remove(video.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Create tutorial button
          if (_selectedIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () {
                  // Show tutorial creation success
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Tutorial Created'),
                      content: Text(
                        'Your tutorial with ${_selectedIds.length} videos has been created successfully!',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Create Tutorial with ${_selectedIds.length} Videos'),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
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