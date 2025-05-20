import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/providers/tutorial_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _durationController;
  
  // Form values
  TutorialLevel _selectedLevel = TutorialLevel.beginner;
  TutorialCategory _selectedCategory = TutorialCategory.strength;
  bool _isPremium = false;
  bool _isActive = true;
  List<String> _tags = [];
  
  // Media handling
  File? _thumbnailFile;
  File? _videoFile;
  String? _thumbnailUrl;
  String? _videoUrl;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _durationController = TextEditingController();
    
    // If editing, populate form with tutorial data
    if (widget.tutorial != null) {
      _populateFormWithTutorial();
    } else {
      // Default values for new tutorial
      _durationController.text = '15';
    }
  }
  
  void _populateFormWithTutorial() {
    final tutorial = widget.tutorial!;
    
    _titleController.text = tutorial.title;
    _descriptionController.text = tutorial.description;
    _durationController.text = tutorial.durationInMinutes.toString();
    _selectedLevel = tutorial.level;
    _selectedCategory = tutorial.category;
    _isPremium = tutorial.isPremium;
    _isActive = tutorial.isActive;
    _tags = List.from(tutorial.tags);
    
    // Existing media URLs
    _thumbnailUrl = tutorial.thumbnailUrl;
    _videoUrl = tutorial.videoUrl;
    
    // Initialize video player if video exists
    if (tutorial.videoUrl.isNotEmpty) {
      _initializeVideoPlayer(tutorial.videoUrl);
    }
  }
  
  Future<void> _initializeVideoPlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    
    try {
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Error initializing video: $e';
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
  
  Future<void> _pickThumbnail() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 720,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _thumbnailFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking thumbnail: $e';
      });
    }
  }
  
  Future<void> _pickVideo() async {
    try {
      final pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );
      
      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
          _isVideoInitialized = false;
        });
        
        // Dispose of old controller if exists
        await _videoController?.dispose();
        
        // Initialize new video controller
        _videoController = VideoPlayerController.file(_videoFile!);
        
        try {
          await _videoController!.initialize();
          
          setState(() {
            _isVideoInitialized = true;
            
            // Auto-set the duration based on the video
            final minutes = _videoController!.value.duration.inMinutes;
            _durationController.text = minutes.toString();
          });
        } catch (e) {
          setState(() {
            _error = 'Error initializing video: $e';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking video: $e';
      });
    }
  }
  
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }
  
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }
  
  Future<void> _saveTutorial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if ((_thumbnailFile == null && _thumbnailUrl == null) || 
        (_videoFile == null && _videoUrl == null)) {
      setState(() {
        _error = 'A thumbnail and video are required';
      });
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
      
      // Upload media files first (this would be implemented with Firebase Storage)
      // For now, we'll just pretend we've done this
      final String thumbnailUrl = _thumbnailFile != null ? 
          'https://example.com/thumbnails/${const Uuid().v4()}' : _thumbnailUrl!;
          
      final String videoUrl = _videoFile != null ? 
          'https://example.com/videos/${const Uuid().v4()}' : _videoUrl!;
      
      final int durationInMinutes = int.parse(_durationController.text);
      
      if (widget.tutorial == null) {
        // Creating a new tutorial
        final newTutorial = TutorialModel(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          thumbnailUrl: thumbnailUrl,
          videoUrl: videoUrl,
          instructorId: currentUser.id,
          instructorName: currentUser.name,
          level: _selectedLevel,
          category: _selectedCategory,
          tags: _tags,
          durationInMinutes: durationInMinutes,
          isPremium: _isPremium,
          isActive: _isActive,
          createdAt: DateTime.now(),
        );
        
        final success = await tutorialProvider.createTutorial(newTutorial);
        
        if (!success) {
          throw Exception(tutorialProvider.error ?? 'Failed to create tutorial');
        }
      } else {
        // Updating an existing tutorial
        final updatedTutorial = widget.tutorial!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          thumbnailUrl: thumbnailUrl,
          videoUrl: videoUrl,
          level: _selectedLevel,
          category: _selectedCategory,
          tags: _tags,
          durationInMinutes: durationInMinutes,
          isPremium: _isPremium,
          isActive: _isActive,
          updatedAt: DateTime.now(),
        );
        
        final success = await tutorialProvider.updateTutorial(updatedTutorial);
        
        if (!success) {
          throw Exception(tutorialProvider.error ?? 'Failed to update tutorial');
        }
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Form(
        key: _formKey,
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
            
            // Media section - Thumbnail and Video
            Card(
              elevation: AppTheme.elevationMedium,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Media',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    
                    // Thumbnail
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thumbnail Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Upload a high-quality image that represents this tutorial. Recommended size: 1280x720 pixels.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: AppTheme.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickThumbnail,
                                icon: const Icon(Icons.image),
                                label: const Text('Select Thumbnail'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          width: 200,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                            border: Border.all(color: Colors.grey.shade300),
                            image: _thumbnailFile != null
                                ? DecorationImage(
                                    image: FileImage(_thumbnailFile!),
                                    fit: BoxFit.cover,
                                  )
                                : _thumbnailUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_thumbnailUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: _thumbnailFile == null && _thumbnailUrl == null
                              ? const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                    
                    const Divider(height: 48),
                    
                    // Video
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tutorial Video',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Upload the main tutorial video. Maximum duration: 30 minutes.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: AppTheme.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.video_library),
                                label: const Text('Select Video'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Container(
                          width: 200,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _videoController != null && _isVideoInitialized
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _videoController!.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _videoController!.value.isPlaying
                                              ? _videoController!.pause()
                                              : _videoController!.play();
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : _videoFile != null || _videoUrl != null
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.videocam,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Basic info section
            Card(
              elevation: AppTheme.elevationMedium,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        labelText: 'Tutorial Title',
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
                    const SizedBox(height: 24),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter a detailed description',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Level and Category
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TutorialLevel>(
                            decoration: const InputDecoration(
                              labelText: 'Difficulty Level',
                              prefixIcon: Icon(Icons.signal_cellular_alt),
                            ),
                            value: _selectedLevel,
                            items: TutorialLevel.values.map((level) {
                              return DropdownMenuItem<TutorialLevel>(
                                value: level,
                                child: Text(_getLevelText(level)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLevel = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: DropdownButtonFormField<TutorialCategory>(
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category),
                            ),
                            value: _selectedCategory,
                            items: TutorialCategory.values.map((category) {
                              return DropdownMenuItem<TutorialCategory>(
                                value: category,
                                child: Text(_getCategoryText(category)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Duration
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        hintText: 'Enter tutorial duration',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the duration';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter a valid duration';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Tags and Settings
            Card(
              elevation: AppTheme.elevationMedium,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags and Settings',
                      style: TextStyle(
                        fontSize: AppTheme.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    
                    // Tags
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tags',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add tags to help users find this tutorial more easily.',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTagsInput(),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: AppTheme.primaryLightColor.withOpacity(0.2),
                              labelStyle: const TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 48),
                    
                    // Premium switch
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium Content',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Premium tutorials are only available to users with a subscription.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: AppTheme.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isPremium,
                          onChanged: (value) {
                            setState(() {
                              _isPremium = value;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Active status
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Inactive tutorials are not visible to users.',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: AppTheme.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
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
            
            if (widget.tutorial != null) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Additional info for editing
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created on: ${DateFormat('MMMM d, yyyy').format(widget.tutorial!.createdAt)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    if (widget.tutorial!.updatedAt != null)
                      Text(
                        'Last updated: ${DateFormat('MMMM d, yyyy').format(widget.tutorial!.updatedAt!)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Views: ${widget.tutorial!.viewCount}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                    if (widget.tutorial!.ratingCount > 0)
                      Text(
                        'Rating: ${widget.tutorial!.rating.toStringAsFixed(1)} (${widget.tutorial!.ratingCount} ${widget.tutorial!.ratingCount == 1 ? 'rating' : 'ratings'})',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTagsInput() {
    final tagController = TextEditingController();
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: tagController,
            decoration: const InputDecoration(
              hintText: 'Add a tag',
              prefixIcon: Icon(Icons.tag),
            ),
            onSubmitted: (value) {
              _addTag(value);
              tagController.clear();
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            _addTag(tagController.text);
            tagController.clear();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
  
  String _getLevelText(TutorialLevel level) {
    switch (level) {
      case TutorialLevel.beginner:
        return 'Beginner';
      case TutorialLevel.intermediate:
        return 'Intermediate';
      case TutorialLevel.advanced:
        return 'Advanced';
      case TutorialLevel.all:
        return 'All Levels';
    }
  }
  
  String _getCategoryText(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.strength:
        return 'Strength';
      case TutorialCategory.cardio:
        return 'Cardio';
      case TutorialCategory.flexibility:
        return 'Flexibility';
      case TutorialCategory.recovery:
        return 'Recovery';
      case TutorialCategory.nutrition:
        return 'Nutrition';
      case TutorialCategory.mindfulness:
        return 'Mindfulness';
      case TutorialCategory.equipment:
        return 'Equipment';
      case TutorialCategory.technique:
        return 'Technique';
      case TutorialCategory.other:
        return 'Other';
    }
  }
}