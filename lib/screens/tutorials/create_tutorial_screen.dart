import 'package:flutter/material.dart';

class CreateTutorialScreen extends StatefulWidget {
  final String userRole;
  final Function(Map<String, dynamic>) onTutorialCreated;

  const CreateTutorialScreen({
    Key? key,
    required this.userRole,
    required this.onTutorialCreated,
  }) : super(key: key);

  @override
  State<CreateTutorialScreen> createState() => _CreateTutorialScreenState();
}

class _CreateTutorialScreenState extends State<CreateTutorialScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _videoUrlController = TextEditingController();
  
  // Form values
  String _selectedCategory = 'Strength';
  String _selectedDifficulty = 'Beginner';
  List<String> _selectedMuscleGroups = [];
  List<String> _selectedEquipment = [];
  
  // Options for dropdowns
  final List<String> _categories = [
    'Strength',
    'Cardio', 
    'Flexibility',
    'Balance',
    'Recovery',
    'Nutrition'
  ];
  
  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];
  
  final List<String> _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Abs',
    'Legs',
    'Glutes',
    'Full Body'
  ];
  
  final List<String> _equipment = [
    'No Equipment',
    'Dumbbells',
    'Barbell',
    'Kettlebell',
    'Resistance Bands',
    'Yoga Mat',
    'Bench',
    'Pull-up Bar',
    'Medicine Ball',
    'Foam Roller'
  ];
  
  @override
  void initState() {
    super.initState();
    _durationController.text = '15';
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Tutorial'),
      ),
      body: SingleChildScrollView(
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
              
              // Category and difficulty row
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
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
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
              
              // Duration and video URL row
              Row(
                children: [
                  // Duration
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Numbers only';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Video URL
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _videoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Video URL',
                        hintText: 'https://',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (value) {
                        // Make video URL optional for now
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Muscle groups
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
                children: _muscleGroups.map((muscle) {
                  final isSelected = _selectedMuscleGroups.contains(muscle);
                  
                  return FilterChip(
                    label: Text(muscle),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMuscleGroups.add(muscle);
                        } else {
                          _selectedMuscleGroups.remove(muscle);
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
              
              // Equipment
              const Text(
                'Equipment Required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _equipment.map((item) {
                  final isSelected = _selectedEquipment.contains(item);
                  
                  return FilterChip(
                    label: Text(item),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEquipment.add(item);
                        } else {
                          _selectedEquipment.remove(item);
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
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Tutorial video upload section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Tutorial Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Drag and drop a video file here or click to select a file.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Center(
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video upload feature coming soon'),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              style: BorderStyle.dashed,
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 40,
                                color: Color(0xFF0D47A1),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload Video',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Max file size: 500MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0D47A1),
                  ),
                  child: const Text('Create Tutorial'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create tutorial data
      final Map<String, dynamic> tutorialData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'duration': int.parse(_durationController.text),
        'description': _descriptionController.text,
        'videoUrl': _videoUrlController.text.isNotEmpty 
          ? _videoUrlController.text 
          : 'https://example.com/placeholder-video.mp4', // Placeholder for demo
        'muscleGroups': _selectedMuscleGroups,
        'equipment': _selectedEquipment,
        'author': widget.userRole == 'admin' ? 'Admin User' : 'Instructor User',
        'createdAt': DateTime.now(),
        'isPublished': true,
        'thumbnailUrl': 'https://example.com/placeholder-thumbnail.jpg', // Placeholder for demo
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