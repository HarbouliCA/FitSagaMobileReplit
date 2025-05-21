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
  final String thumbnailUrl;
  final String type;
  final String dayName;
  final String planId;
  
  VideoData({
    required this.id,
    required this.title,
    required this.bodyPart,
    required this.thumbnailUrl,
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
  List<String> _selectedIds = [];
  
  // Mock data from Firebase
  final List<VideoData> _allVideos = [
    VideoData(
      id: '10011090_18687781_2023_bc001.mp4',
      title: 'Press de banca - Barra',
      bodyPart: 'Pecho, Tríceps, Hombros parte delantera',
      thumbnailUrl: 'assets/images/strength1.jpg',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_cm005.mp4',
      title: 'Cinta de correr 8 km/h ~ 5 mph',
      bodyPart: 'Sistema cardiovascular, Piernas',
      thumbnailUrl: 'assets/images/cardio1.jpg',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_cw003.mp4',
      title: 'Jumping jacks',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      thumbnailUrl: 'assets/images/cardio2.jpg',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_gt001.mp4',
      title: 'Extension de codo - Polea',
      bodyPart: 'Tríceps',
      thumbnailUrl: 'assets/images/strength2.jpg',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_oa041.mp4',
      title: 'Curl de bíceps - Polea',
      bodyPart: 'Bíceps',
      thumbnailUrl: 'assets/images/strength3.jpg',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_ozp032.mp4',
      title: 'Saltos - Caja',
      bodyPart: 'Cuádriceps, Glúteos, Corvas, Zona lumbar',
      thumbnailUrl: 'assets/images/strength4.jpg',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687782_2023_ds001.mp4',
      title: 'Elevaciones laterales de pie - mancuernas',
      bodyPart: 'Hombros',
      thumbnailUrl: 'assets/images/strength5.jpg',
      type: 'strength',
      dayName: 'día 2',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687782_2023_gb002.mp4',
      title: 'Jalon al pecho',
      bodyPart: 'Dorsales, Bíceps, Espalda',
      thumbnailUrl: 'assets/images/strength6.jpg',
      type: 'strength',
      dayName: 'día 2',
      planId: '10011090',
    ),
    VideoData(
      id: '10031897_18739877_2023_cm001.mp4',
      title: 'Máquina de remos, Intensidad baja',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      thumbnailUrl: 'assets/images/cardio3.jpg',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10031897',
    ),
    VideoData(
      id: '10031897_18739877_2023_cm002.mp4',
      title: 'Entrenador elíptico',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      thumbnailUrl: 'assets/images/cardio4.jpg',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10031897',
    ),
  ];
  
  // Get available categories
  List<String> get _categories => ['All', 'Strength', 'Cardio'];
  
  // Get filtered videos
  List<VideoData> get _filteredVideos {
    if (_activeFilter == 'All') {
      return _allVideos;
    } else {
      return _allVideos.where((v) => 
        v.type.toLowerCase() == _activeFilter.toLowerCase()
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitSAGA Video Library'),
      ),
      body: Column(
        children: [
          // Filter pills
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((category) {
                final isSelected = _activeFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
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
                  '${_selectedIds.length} videos selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedIds.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIds.clear();
                      });
                    },
                    child: const Text('Clear Selection'),
                  ),
              ],
            ),
          ),
          
          // Videos grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredVideos.length,
              itemBuilder: (context, index) {
                final video = _filteredVideos[index];
                final isSelected = _selectedIds.contains(video.id);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(video.id);
                      } else {
                        _selectedIds.add(video.id);
                      }
                    });
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video thumbnail
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            children: [
                              // Placeholder image
                              Container(
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(
                                  video.type.toLowerCase() == 'cardio' 
                                    ? Icons.directions_run 
                                    : Icons.fitness_center,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Type badge
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: video.type.toLowerCase() == 'cardio'
                                      ? Colors.red 
                                      : Colors.blue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    video.type[0].toUpperCase() + video.type.substring(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Selection indicator
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Video info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                video.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Body part
                              Text(
                                video.bodyPart,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Plan and day info
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      video.dayName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 4),
                                  
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Plan ${video.planId}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
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
          
          // Create tutorial button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedIds.isEmpty ? null : () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Create Tutorial'),
                    content: Text(
                      'Tutorial would be created with ${_selectedIds.length} selected videos. These videos would be combined into a single tutorial program.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tutorial created successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Show success view
                          _showTutorialSuccess(context);
                        },
                        child: const Text('CREATE'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CREATE TUTORIAL'),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showTutorialSuccess(BuildContext context) {
    // Get selected videos
    final selectedVideos = _allVideos.where((v) => _selectedIds.contains(v.id)).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialSuccessScreen(videos: selectedVideos),
      ),
    );
  }
}

class TutorialSuccessScreen extends StatelessWidget {
  final List<VideoData> videos;
  
  const TutorialSuccessScreen({Key? key, required this.videos}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Created'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tutorial Created Successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your tutorial with ${videos.length} videos has been created and is ready to be published.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tutorial summary
            const Text(
              'Tutorial Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tutorial videos
            for (final video in videos)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      video.type.toLowerCase() == 'cardio' 
                          ? Icons.directions_run
                          : Icons.fitness_center,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    video.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    video.bodyPart,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: video.type.toLowerCase() == 'cardio'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: video.type.toLowerCase() == 'cardio'
                            ? Colors.red.withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      video.type[0].toUpperCase() + video.type.substring(1),
                      style: TextStyle(
                        color: video.type.toLowerCase() == 'cardio'
                            ? Colors.red
                            : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Create Another'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}