import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TutorialCreateEditScreen extends StatefulWidget {
  final TutorialModel? tutorial; // Null for create, non-null for edit

  const TutorialCreateEditScreen({
    Key? key,
    this.tutorial,
  }) : super(key: key);

  @override
  State<TutorialCreateEditScreen> createState() => _TutorialCreateEditScreenState();
}

class _TutorialCreateEditScreenState extends State<TutorialCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _durationController;
  late TextEditingController _videoUrlController;
  
  // Form values
  TutorialDifficulty _difficulty = TutorialDifficulty.beginner;
  List<TutorialCategory> _selectedCategories = [];
  bool _isPremium = false;
  bool _isPublished = true;
  File? _thumbnailImage;
  String? _currentThumbnailUrl;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _contentController = TextEditingController();
    _tagsController = TextEditingController();
    _durationController = TextEditingController(text: '30');
    _videoUrlController = TextEditingController();
    
    // If editing, populate form with tutorial data
    if (widget.tutorial != null) {
      _populateFormWithTutorial();
    }
  }
  
  void _populateFormWithTutorial() {
    final tutorial = widget.tutorial!;
    
    _titleController.text = tutorial.title;
    _descriptionController.text = tutorial.description;
    _contentController.text = tutorial.content;
    _tagsController.text = tutorial.tags.join(', ');
    _durationController.text = tutorial.durationMinutes.toString();
    _videoUrlController.text = tutorial.videoUrl ?? '';
    
    _difficulty = tutorial.difficulty;
    _selectedCategories = List.from(tutorial.categories);
    _isPremium = tutorial.isPremium;
    _isPublished = tutorial.isPublished;
    _currentThumbnailUrl = tutorial.thumbnailUrl;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _thumbnailImage = File(image.path);
      });
    }
  }
  
  Future<void> _saveTutorial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
      
      // Ensure user is authenticated and is an instructor or admin
      if (!authProvider.isAuthenticated || 
          (!authProvider.currentUser!.isInstructor && !authProvider.currentUser!.isAdmin)) {
        throw Exception('You do not have permission to create or edit tutorials');
      }
      
      final currentUser = authProvider.currentUser!;
      
      // Parse integer values
      final int durationMinutes = int.parse(_durationController.text);
      
      // Parse tags
      final List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      
      // Handle thumbnail upload
      String? thumbnailUrl = _currentThumbnailUrl;
      if (_thumbnailImage != null) {
        // In a real app, this would upload the image to Firebase Storage
        // and get the download URL
        thumbnailUrl = 'https://example.com/placeholder-image.jpg';
        
        // For demonstration, we're just using the existing URL or a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload is simulated in this demo'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
      
      // Check if this is a create or edit operation
      bool success;
      if (widget.tutorial == null) {
        // Creating a new tutorial
        success = await tutorialProvider.createTutorial(
          title: _titleController.text,
          description: _descriptionController.text,
          content: _contentController.text,
          authorId: currentUser.id,
          authorName: currentUser.name,
          categories: _selectedCategories,
          difficulty: _difficulty,
          durationMinutes: durationMinutes,
          tags: tags,
          thumbnailUrl: thumbnailUrl,
          videoUrl: _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
          isPremium: _isPremium,
          isPublished: _isPublished,
        );
      } else {
        // Editing an existing tutorial
        success = await tutorialProvider.updateTutorial(
          id: widget.tutorial!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          content: _contentController.text,
          categories: _selectedCategories,
          difficulty: _difficulty,
          durationMinutes: durationMinutes,
          tags: tags,
          thumbnailUrl: thumbnailUrl,
          videoUrl: _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
          isPremium: _isPremium,
          isPublished: _isPublished,
        );
      }
      
      if (!success) {
        throw Exception(tutorialProvider.error ?? 'Failed to save tutorial');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tutorial == null ? 
                  'Tutorial created successfully' : 
                  'Tutorial updated successfully',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutorial == null ? 'Create Tutorial' : 'Edit Tutorial'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveTutorial,
            icon: const Icon(Icons.save, color: AppTheme.primaryColor),
            label: Text(
              widget.tutorial == null ? 'Create' : 'Save',
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Saving tutorial...')
          : _buildForm(),
    );
  }
  
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.errorColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Basic information
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter a descriptive title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a brief description',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Enter tags separated by commas',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            
            // Duration
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                hintText: 'Estimated time to complete',
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Categories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TutorialCategory.values.map((category) {
                String label;
                IconData icon;
                
                switch (category) {
                  case TutorialCategory.cardio:
                    label = 'Cardio';
                    icon = Icons.directions_run;
                    break;
                  case TutorialCategory.strength:
                    label = 'Strength';
                    icon = Icons.fitness_center;
                    break;
                  case TutorialCategory.flexibility:
                    label = 'Flexibility';
                    icon = Icons.accessibility;
                    break;
                  case TutorialCategory.balance:
                    label = 'Balance';
                    icon = Icons.balance;
                    break;
                  case TutorialCategory.nutrition:
                    label = 'Nutrition';
                    icon = Icons.restaurant;
                    break;
                  case TutorialCategory.recovery:
                    label = 'Recovery';
                    icon = Icons.hotel;
                    break;
                  case TutorialCategory.technique:
                    label = 'Technique';
                    icon = Icons.sports_gymnastics;
                    break;
                  case TutorialCategory.program:
                    label = 'Programs';
                    icon = Icons.calendar_today;
                    break;
                }
                
                final isSelected = _selectedCategories.contains(category);
                
                return FilterChip(
                  avatar: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 16,
                  ),
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryColor,
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Difficulty
            const Text(
              'Difficulty Level',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDifficultySelector(),
            const SizedBox(height: 24),
            
            // Media section
            const Text(
              'Media',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Thumbnail
            const Text(
              'Thumbnail Image',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildThumbnailPicker(),
            const SizedBox(height: 16),
            
            // Video URL
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Video URL (optional)',
                hintText: 'Enter URL to video content',
                prefixIcon: Icon(Icons.video_library),
              ),
            ),
            const SizedBox(height: 24),
            
            // Content
            const Text(
              'Tutorial Content',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Markdown Supported',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Write your tutorial content in Markdown format...',
                      border: InputBorder.none,
                    ),
                    maxLines: 15,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter tutorial content';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Publishing options
            const Text(
              'Publishing Options',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Premium toggle
            SwitchListTile(
              title: const Text('Premium Content'),
              subtitle: const Text('Requires subscription or credits to access'),
              value: _isPremium,
              onChanged: (value) {
                setState(() {
                  _isPremium = value;
                });
              },
              activeColor: AppTheme.accentColor,
            ),
            
            // Published toggle
            SwitchListTile(
              title: const Text('Published'),
              subtitle: const Text('Make this tutorial visible to users'),
              value: _isPublished,
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTutorial,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.tutorial == null ? 'Create Tutorial' : 'Save Changes',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  foregroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.paddingMedium,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDifficultySelector() {
    return Column(
      children: [
        for (final difficulty in TutorialDifficulty.values)
          RadioListTile<TutorialDifficulty>(
            title: Text(_getDifficultyLabel(difficulty)),
            subtitle: Text(_getDifficultyDescription(difficulty)),
            value: difficulty,
            groupValue: _difficulty,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _difficulty = value;
                });
              }
            },
            activeColor: _getDifficultyColor(difficulty),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
  
  Widget _buildThumbnailPicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
          border: Border.all(color: Colors.grey.shade300),
          image: _thumbnailImage != null
              ? DecorationImage(
                  image: FileImage(_thumbnailImage!),
                  fit: BoxFit.cover,
                )
              : _currentThumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_currentThumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
        ),
        child: _thumbnailImage == null && _currentThumbnailUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload Thumbnail Image',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
      ),
    );
  }
  
  String _getDifficultyLabel(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return 'Beginner';
      case TutorialDifficulty.intermediate:
        return 'Intermediate';
      case TutorialDifficulty.advanced:
        return 'Advanced';
      case TutorialDifficulty.expert:
        return 'Expert';
    }
  }
  
  String _getDifficultyDescription(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return 'For those new to fitness or this specific activity';
      case TutorialDifficulty.intermediate:
        return 'For those with some experience and basic fitness';
      case TutorialDifficulty.advanced:
        return 'For experienced users looking for a challenge';
      case TutorialDifficulty.expert:
        return 'For highly trained individuals only';
    }
  }
  
  Color _getDifficultyColor(TutorialDifficulty difficulty) {
    switch (difficulty) {
      case TutorialDifficulty.beginner:
        return Colors.green;
      case TutorialDifficulty.intermediate:
        return Colors.blue;
      case TutorialDifficulty.advanced:
        return Colors.orange;
      case TutorialDifficulty.expert:
        return Colors.red;
    }
  }
}