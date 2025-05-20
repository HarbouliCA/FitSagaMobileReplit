import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

class CreateSessionScreen extends StatefulWidget {
  final SessionModel? sessionToEdit;

  const CreateSessionScreen({
    Key? key,
    this.sessionToEdit,
  }) : super(key: key);

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  
  // Form fields
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _requirementsController;
  late TextEditingController _levelController;
  
  SessionType _selectedType = SessionType.group;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  void _initializeForm() {
    _isEditMode = widget.sessionToEdit != null;
    
    // Initialize controllers with existing data if in edit mode
    if (_isEditMode) {
      final session = widget.sessionToEdit!;
      
      _titleController = TextEditingController(text: session.title);
      _descriptionController = TextEditingController(text: session.description);
      _locationController = TextEditingController(text: session.location);
      _maxParticipantsController = TextEditingController(text: session.maxParticipants.toString());
      _requirementsController = TextEditingController(text: session.requirements ?? '');
      _levelController = TextEditingController(text: session.level ?? '');
      
      _selectedType = session.type;
      _selectedDate = session.startTime;
      _startTime = TimeOfDay(hour: session.startTime.hour, minute: session.startTime.minute);
      _endTime = TimeOfDay(hour: session.endTime.hour, minute: session.endTime.minute);
    } else {
      // Initialize with empty values for new session
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _maxParticipantsController = TextEditingController(text: '15');
      _requirementsController = TextEditingController();
      _levelController = TextEditingController();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _requirementsController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Session' : 'Create New Session'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      _buildErrorMessage(),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                      
                    _buildSessionTypeSelector(),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    _buildBasicDetailsSection(),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    _buildDateTimeSection(),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    _buildAdditionalInfoSection(),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    ElevatedButton(
                      onPressed: () => _handleSubmit(authProvider, sessionProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isEditMode ? 'Update Session' : 'Create Session'),
                    ),
                    
                    if (_isEditMode) ...[
                      const SizedBox(height: AppTheme.spacingMedium),
                      OutlinedButton(
                        onPressed: () => _handleDelete(sessionProvider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Delete Session'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingSmall),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        border: Border.all(
          color: AppTheme.errorColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.errorColor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppTheme.errorColor,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionTypeSelector() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Type',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            SegmentedButton<SessionType>(
              segments: const [
                ButtonSegment<SessionType>(
                  value: SessionType.personal,
                  label: Text('Personal'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment<SessionType>(
                  value: SessionType.group,
                  label: Text('Group'),
                  icon: Icon(Icons.group),
                ),
                ButtonSegment<SessionType>(
                  value: SessionType.workshop,
                  label: Text('Workshop'),
                  icon: Icon(Icons.school),
                ),
                ButtonSegment<SessionType>(
                  value: SessionType.event,
                  label: Text('Event'),
                  icon: Icon(Icons.event),
                ),
              ],
              selected: <SessionType>{_selectedType},
              onSelectionChanged: (Set<SessionType> selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              _getSessionTypeDescription(_selectedType),
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: AppTheme.fontSizeSmall,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBasicDetailsSection() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Details',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Session Title',
                hintText: 'Enter a descriptive name for your session',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what participants can expect',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Location Field
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter the session location',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Maximum Participants Field
            TextFormField(
              controller: _maxParticipantsController,
              decoration: const InputDecoration(
                labelText: 'Maximum Participants',
                hintText: 'Enter maximum number of participants',
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter maximum participants';
                }
                
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid number';
                }
                
                if (_selectedType == SessionType.personal && number > 1) {
                  return 'Personal sessions can have only 1 participant';
                }
                
                return null;
              },
            ),
            
            // Automatically set max participants to 1 for personal training
            if (_selectedType == SessionType.personal && _maxParticipantsController.text != '1')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _maxParticipantsController.text = '1';
                    });
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('Set to 1 for Personal Training'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateTimeSection() {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date & Time',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Date Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Session Date'),
              subtitle: Text(dateFormatter.format(_selectedDate)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _showDatePicker,
            ),
            
            const Divider(),
            
            // Start Time Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Start Time'),
              subtitle: Text(_formatTimeOfDay(_startTime)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showTimePicker(true),
            ),
            
            const Divider(),
            
            // End Time Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer_off),
              title: const Text('End Time'),
              subtitle: Text(_formatTimeOfDay(_endTime)),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showTimePicker(false),
            ),
            
            // Show warning if end time is before or equal to start time
            if (_isEndTimeBeforeStartTime())
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacingSmall),
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.warningLightColor,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.warningColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'End time must be after start time',
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: AppTheme.spacingMedium),
            
            // Session Duration
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: AppTheme.infoLightColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_bottom,
                    color: AppTheme.infoColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duration: ${_calculateDuration()} minutes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.infoColor,
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
  
  Widget _buildAdditionalInfoSection() {
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information (Optional)',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Level Field
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(
                labelText: 'Difficulty Level',
                hintText: 'E.g., Beginner, Intermediate, Advanced',
                prefixIcon: Icon(Icons.signal_cellular_alt),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // Requirements Field
            TextFormField(
              controller: _requirementsController,
              decoration: const InputDecoration(
                labelText: 'Requirements',
                hintText: 'What should participants bring or prepare?',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }
  
  void _showTimePicker(bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          
          // If end time is now before start time, adjust it
          if (_isEndTimeBeforeStartTime()) {
            _endTime = TimeOfDay(
              hour: pickedTime.hour + 1,
              minute: pickedTime.minute,
            );
          }
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }
  
  bool _isEndTimeBeforeStartTime() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    return endMinutes <= startMinutes;
  }
  
  int _calculateDuration() {
    if (_isEndTimeBeforeStartTime()) {
      return 0;
    }
    
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    return endMinutes - startMinutes;
  }
  
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    
    return DateFormat.jm().format(dateTime);
  }
  
  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
  
  void _handleSubmit(
    AuthProvider authProvider,
    SessionProvider sessionProvider,
  ) async {
    // Hide any existing error
    setState(() {
      _errorMessage = null;
    });
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if end time is after start time
    if (_isEndTimeBeforeStartTime()) {
      setState(() {
        _errorMessage = 'End time must be after start time.';
      });
      return;
    }
    
    // Get current user
    final user = authProvider.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'You must be logged in to create a session.';
      });
      return;
    }
    
    // Check if user is authorized
    if (!user.isInstructor) {
      setState(() {
        _errorMessage = 'Only instructors and admins can create sessions.';
      });
      return;
    }
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Prepare start and end times
      final startDateTime = _combineDateTime(_selectedDate, _startTime);
      final endDateTime = _combineDateTime(_selectedDate, _endTime);
      
      if (_isEditMode) {
        // Update existing session
        final updatedSession = widget.sessionToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          location: _locationController.text.trim(),
          maxParticipants: int.parse(_maxParticipantsController.text.trim()),
          requirements: _requirementsController.text.isEmpty ? null : _requirementsController.text.trim(),
          level: _levelController.text.isEmpty ? null : _levelController.text.trim(),
          startTime: startDateTime,
          endTime: endDateTime,
        );
        
        final success = await sessionProvider.updateSession(updatedSession);
        
        if (success) {
          if (mounted) {
            _showSuccessDialog(
              'Session Updated',
              'Your session has been successfully updated.',
            );
          }
        } else {
          setState(() {
            _errorMessage = sessionProvider.error ?? 'Failed to update session.';
            _isLoading = false;
          });
        }
      } else {
        // Create new session
        final newSession = SessionModel(
          id: '', // Will be set by Firestore
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          instructorId: user.id,
          instructorName: user.name,
          startTime: startDateTime,
          endTime: endDateTime,
          location: _locationController.text.trim(),
          maxParticipants: int.parse(_maxParticipantsController.text.trim()),
          participantIds: [],
          requirements: _requirementsController.text.isEmpty ? null : _requirementsController.text.trim(),
          level: _levelController.text.isEmpty ? null : _levelController.text.trim(),
          isActive: true,
          createdAt: DateTime.now(),
        );
        
        final success = await sessionProvider.createSession(newSession);
        
        if (success) {
          if (mounted) {
            _showSuccessDialog(
              'Session Created',
              'Your new session has been successfully created.',
            );
          }
        } else {
          setState(() {
            _errorMessage = sessionProvider.error ?? 'Failed to create session.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }
  
  void _handleDelete(SessionProvider sessionProvider) async {
    if (!_isEditMode) {
      return;
    }
    
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this session?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'This will permanently remove "${widget.sessionToEdit!.title}" and cancel all participant bookings.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: AppTheme.warningLightColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete Session'),
          ),
        ],
      ),
    );
    
    if (shouldDelete != true || !mounted) {
      return;
    }
    
    // Set loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await sessionProvider.deleteSession(widget.sessionToEdit!.id);
      
      if (success) {
        if (mounted) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = sessionProvider.error ?? 'Failed to delete session.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }
  
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  String _getSessionTypeDescription(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return 'One-on-one training with an instructor. Limited to 1 participant.';
      case SessionType.group:
        return 'Group fitness class with multiple participants.';
      case SessionType.workshop:
        return 'Specialized training focused on specific techniques or skills.';
      case SessionType.event:
        return 'Special one-time fitness event or competition.';
    }
  }
}