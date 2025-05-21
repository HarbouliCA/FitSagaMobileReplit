import 'package:flutter/material.dart';

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

class SimpleVideoBrowser extends StatefulWidget {
  const SimpleVideoBrowser({Key? key}) : super(key: key);

  @override
  State<SimpleVideoBrowser> createState() => _SimpleVideoBrowserState();
}

class _SimpleVideoBrowserState extends State<SimpleVideoBrowser> {
  String _activeFilter = 'All';
  List<String> _selectedIds = [];
  
  // Mock data from Firebase
  final List<VideoData> _allVideos = [
    VideoData(
      id: '10011090_18687781_2023_bc001.mp4',
      title: 'Press de banca - Barra',
      bodyPart: 'Pecho, Tríceps, Hombros parte delantera',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082263.png',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_cm005.mp4',
      title: 'Cinta de correr 8 km/h ~ 5 mph',
      bodyPart: 'Sistema cardiovascular, Piernas',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082247.png',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_cw003.mp4',
      title: 'Jumping jacks',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082253.png',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_gt001.mp4',
      title: 'Extension de codo - Polea',
      bodyPart: 'Tríceps',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082251.png',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_oa041.mp4',
      title: 'Curl de bíceps - Polea',
      bodyPart: 'Bíceps',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082252.png',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687781_2023_ozp032.mp4',
      title: 'Saltos - Caja',
      bodyPart: 'Cuádriceps, Glúteos, Corvas, Zona lumbar',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%201/images/3167082258.png',
      type: 'strength',
      dayName: 'día 1',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687782_2023_ds001.mp4',
      title: 'Elevaciones laterales de pie - mancuernas',
      bodyPart: 'Hombros',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%202/images/3167082271.png',
      type: 'strength',
      dayName: 'día 2',
      planId: '10011090',
    ),
    VideoData(
      id: '10011090_18687782_2023_gb002.mp4',
      title: 'Jalon al pecho',
      bodyPart: 'Dorsales, Bíceps, Espalda',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10011090/d%C3%ADa%202/images/3167082274.png',
      type: 'strength',
      dayName: 'día 2',
      planId: '10011090',
    ),
    VideoData(
      id: '10031897_18739877_2023_cm001.mp4',
      title: 'Máquina de remos, Intensidad baja',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10031897/d%C3%ADa%201/images/3177842282.png',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10031897',
    ),
    VideoData(
      id: '10031897_18739877_2023_cm002.mp4',
      title: 'Entrenador elíptico',
      bodyPart: 'Sistema cardiovascular, Cuerpo completo',
      thumbnailUrl: 'https://sagafit.blob.core.windows.net/sagathumbnails/10031897/d%C3%ADa%201/images/3177842285.png',
      type: 'cardio',
      dayName: 'día 1',
      planId: '10031897',
    ),
  ];
  
  // Get available categories
  Set<String> get _categories {
    final Set<String> categories = {'All'};
    for (final video in _allVideos) {
      categories.add(video.type.toLowerCase() == 'cardio' ? 'Cardio' : 'Strength');
    }
    return categories;
  }
  
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
        title: const Text('Tutorial Videos'),
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
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _activeFilter = category;
                      });
                    },
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
}