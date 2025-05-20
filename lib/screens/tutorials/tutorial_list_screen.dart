import 'package:flutter/material.dart';
import 'package:fitsaga/models/tutorial_model.dart';
import 'package:fitsaga/navigation/app_router.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';

class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({Key? key}) : super(key: key);

  @override
  _TutorialListScreenState createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Tutorial> _tutorials = [];
  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTutorials();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTutorials() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // In a real app, this would fetch from a provider or API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Sample data for demo purposes
      final tutorials = _getSampleTutorials();
      
      setState(() {
        _tutorials = tutorials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  List<Tutorial> _getFilteredTutorials() {
    return _tutorials.where((tutorial) {
      // Apply category filter
      if (_selectedCategory != 'all' && 
          !tutorial.categories.contains(_selectedCategory)) {
        return false;
      }
      
      // Apply difficulty filter
      if (_selectedDifficulty != 'all' && 
          tutorial.difficulty.toLowerCase() != _selectedDifficulty.toLowerCase()) {
        return false;
      }
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return tutorial.title.toLowerCase().contains(searchTerm) ||
            tutorial.description.toLowerCase().contains(searchTerm) ||
            tutorial.categories.any((category) => 
                category.toLowerCase().contains(searchTerm));
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchBar,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTutorials,
        child: _buildContent(),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(
          size: 40,
          showText: true,
          text: 'Loading tutorials...',
        ),
      );
    }
    
    if (_hasError) {
      return CustomErrorWidget(
        message: 'Error loading tutorials: $_errorMessage',
        onRetry: _loadTutorials,
        fullScreen: true,
      );
    }
    
    final filteredTutorials = _getFilteredTutorials();
    
    if (filteredTutorials.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      children: [
        if (_searchController.text.isNotEmpty || 
            _selectedCategory != 'all' || 
            _selectedDifficulty != 'all')
          _buildActiveFilters(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCategorySection('Featured', 
                  filteredTutorials.where((t) => t.isFeatured).toList()),
              const SizedBox(height: 16),
              _buildCategorySection('Popular', 
                  filteredTutorials.where((t) => t.isPopular).toList()),
              const SizedBox(height: 16),
              _buildCategorySection('All Tutorials', filteredTutorials),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategorySection(String title, List<Tutorial> tutorials) {
    if (tutorials.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tutorials.length,
          itemBuilder: (context, index) {
            return _buildTutorialCard(tutorials[index]);
          },
        ),
      ],
    );
  }
  
  Widget _buildTutorialCard(Tutorial tutorial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToTutorialDetail(tutorial),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutorial image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                tutorial.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            
            // Tutorial content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and progress
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tutorial.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (tutorial.userProgress != null) ...[
                        Text(
                          '${(tutorial.userProgress! * 100).round()}%',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Duration and level
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tutorial.totalDurationMinutes} min',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.fitness_center,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tutorial.difficulty,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    tutorial.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Categories
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tutorial.categories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  // Progress bar if in progress
                  if (tutorial.userProgress != null && tutorial.userProgress! > 0) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: tutorial.userProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    if (_searchController.text.isNotEmpty) {
      message = 'No tutorials match your search criteria';
      icon = Icons.search_off;
    } else if (_selectedCategory != 'all' || _selectedDifficulty != 'all') {
      message = 'No tutorials match your filters';
      icon = Icons.filter_list_off;
    } else {
      message = 'No tutorials available';
      icon = Icons.video_library_outlined;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters or check back later',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedCategory = 'all';
                _selectedDifficulty = 'all';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Filters:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_searchController.text.isNotEmpty)
                _buildFilterChip(
                  'Search: ${_searchController.text}',
                  () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                ),
              if (_selectedCategory != 'all')
                _buildFilterChip(
                  'Category: ${_selectedCategory[0].toUpperCase()}${_selectedCategory.substring(1)}',
                  () {
                    setState(() {
                      _selectedCategory = 'all';
                    });
                  },
                ),
              if (_selectedDifficulty != 'all')
                _buildFilterChip(
                  'Difficulty: ${_selectedDifficulty[0].toUpperCase()}${_selectedDifficulty.substring(1)}',
                  () {
                    setState(() {
                      _selectedDifficulty = 'all';
                    });
                  },
                ),
              _buildFilterChip(
                'Clear All',
                () {
                  setState(() {
                    _searchController.clear();
                    _selectedCategory = 'all';
                    _selectedDifficulty = 'all';
                  });
                },
                isReset: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, VoidCallback onRemove, {bool isReset = false}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isReset ? Colors.white : Colors.black87,
          fontSize: 12,
        ),
      ),
      backgroundColor: isReset ? AppTheme.primaryColor : Colors.grey[200],
      deleteIcon: Icon(
        isReset ? Icons.refresh : Icons.close,
        size: 16,
        color: isReset ? Colors.white : Colors.black54,
      ),
      onDeleted: onRemove,
    );
  }
  
  void _navigateToTutorialDetail(Tutorial tutorial) {
    Navigator.of(context).pushNamed(
      AppRouter.tutorialDetail,
      arguments: tutorial,
    );
  }
  
  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tutorials...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Tutorials',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = 'all';
                            _selectedDifficulty = 'all';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChipOption('all', 'All', _selectedCategory, (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      }),
                      _filterChipOption('strength', 'Strength', _selectedCategory, (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      }),
                      _filterChipOption('cardio', 'Cardio', _selectedCategory, (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      }),
                      _filterChipOption('yoga', 'Yoga', _selectedCategory, (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      }),
                      _filterChipOption('hiit', 'HIIT', _selectedCategory, (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      }),
                      _filterChipOption('stretching', 'Stretching', _selectedCategory, (value) {
                        setModalState(() {
                          _selectedCategory = value;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Difficulty',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChipOption('all', 'All', _selectedDifficulty, (value) {
                        setModalState(() {
                          _selectedDifficulty = value;
                        });
                      }),
                      _filterChipOption('beginner', 'Beginner', _selectedDifficulty, (value) {
                        setModalState(() {
                          _selectedDifficulty = value;
                        });
                      }),
                      _filterChipOption('intermediate', 'Intermediate', _selectedDifficulty, (value) {
                        setModalState(() {
                          _selectedDifficulty = value;
                        });
                      }),
                      _filterChipOption('advanced', 'Advanced', _selectedDifficulty, (value) {
                        setModalState(() {
                          _selectedDifficulty = value;
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _filterChipOption(
    String value,
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final bool isSelected = selectedValue == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelected(selected ? value : 'all');
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
  
  List<Tutorial> _getSampleTutorials() {
    return [
      Tutorial(
        id: 'tutorial1',
        title: 'Complete Body Strength Workout',
        description: 'A comprehensive strength training program focused on building muscle and improving overall strength.',
        imageUrl: 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712',
        categories: ['strength', 'full body'],
        difficulty: 'Intermediate',
        isFeatured: true,
        isPopular: true,
        totalDurationMinutes: 120,
        daysCount: 5,
        userProgress: 0.3,
      ),
      Tutorial(
        id: 'tutorial2',
        title: 'Morning Yoga Flow',
        description: 'Start your day with energy and focus with this gentle but effective yoga routine.',
        imageUrl: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b',
        categories: ['yoga', 'flexibility'],
        difficulty: 'Beginner',
        isFeatured: true,
        isPopular: false,
        totalDurationMinutes: 30,
        daysCount: 7,
        userProgress: 0.7,
      ),
      Tutorial(
        id: 'tutorial3',
        title: 'HIIT Fat Burning Challenge',
        description: 'High-intensity interval training designed to maximize calorie burn and improve cardiovascular fitness.',
        imageUrl: 'https://images.unsplash.com/photo-1434682881908-b43d0467b798',
        categories: ['cardio', 'hiit'],
        difficulty: 'Advanced',
        isFeatured: false,
        isPopular: true,
        totalDurationMinutes: 45,
        daysCount: 14,
        userProgress: 0.0,
      ),
      Tutorial(
        id: 'tutorial4',
        title: 'Core Strength & Stability',
        description: 'Build a strong core foundation with exercises targeting all the abdominal and back muscles.',
        imageUrl: 'https://images.unsplash.com/photo-1516826957135-700dedea698c',
        categories: ['strength', 'core'],
        difficulty: 'Intermediate',
        isFeatured: false,
        isPopular: true,
        totalDurationMinutes: 60,
        daysCount: 10,
        userProgress: null,
      ),
      Tutorial(
        id: 'tutorial5',
        title: 'Flexibility & Mobility Routine',
        description: 'Improve your range of motion and prevent injuries with this comprehensive stretching program.',
        imageUrl: 'https://images.unsplash.com/photo-1551656941-dc4f9c646a6e',
        categories: ['stretching', 'recovery'],
        difficulty: 'Beginner',
        isFeatured: false,
        isPopular: false,
        totalDurationMinutes: 40,
        daysCount: 3,
        userProgress: null,
      ),
    ];
  }
}