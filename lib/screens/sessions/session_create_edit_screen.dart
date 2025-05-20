import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SessionCreateEditScreen extends StatefulWidget {
  final SessionModel? session; // Null for create, non-null for edit

  const SessionCreateEditScreen({
    Key? key,
    this.session,
  }) : super(key: key);

  @override
  State<SessionCreateEditScreen> createState() => _SessionCreateEditScreenState();
}

class _SessionCreateEditScreenState extends State<SessionCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _creditCostController;
  late TextEditingController _durationController;
  
  // Form values
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isRecurring = false;
  String _recurringFrequency = 'weekly';
  List<bool> _selectedDays = List.filled(7, false); // days of week
  int _recurringOccurrences = 4;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _maxParticipantsController = TextEditingController(text: '10');
    _creditCostController = TextEditingController(text: '1');
    _durationController = TextEditingController(text: '60');
    
    // Default values
    final now = DateTime.now();
    // Round up to the nearest hour
    final startTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      now.hour + 1, 
      0,
    );
    
    _selectedDate = startTime;
    _selectedTime = TimeOfDay(hour: startTime.hour, minute: startTime.minute);
    
    // If editing, populate form with session data
    if (widget.session != null) {
      _populateFormWithSession();
    }
  }
  
  void _populateFormWithSession() {
    final session = widget.session!;
    
    _titleController.text = session.title;
    _descriptionController.text = session.description;
    _locationController.text = session.location ?? '';
    _maxParticipantsController.text = session.maxParticipants.toString();
    _creditCostController.text = session.creditCost.toString();
    _durationController.text = session.durationMinutes.toString();
    
    _selectedDate = session.startTime;
    _selectedTime = TimeOfDay(
      hour: session.startTime.hour,
      minute: session.startTime.minute,
    );
    
    _isRecurring = session.isRecurring;
    
    // Parse recurring rule if exists
    if (session.recurringRule != null && session.recurringRule!.isNotEmpty) {
      Map<String, String> ruleMap = {};
      for (var part in session.recurringRule!.split(';')) {
        final keyValue = part.split('=');
        if (keyValue.length == 2) {
          ruleMap[keyValue[0]] = keyValue[1];
        }
      }
      
      final freq = ruleMap['FREQ'];
      if (freq != null) {
        _recurringFrequency = freq.toLowerCase();
      }
      
      final byDay = ruleMap['BYDAY']?.split(',');
      if (byDay != null && byDay.isNotEmpty) {
        // Map of weekday abbreviations to day of week numbers
        const weekdayMap = {
          'MO': 1, // Monday
          'TU': 2,
          'WE': 3,
          'TH': 4,
          'FR': 5,
          'SA': 6,
          'SU': 7,
        };
        
        // Reset first
        _selectedDays = List.filled(7, false);
        
        // Set selected days
        for (final day in byDay) {
          final dayIndex = weekdayMap[day];
          if (dayIndex != null) {
            _selectedDays[dayIndex - 1] = true;
          }
        }
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _creditCostController.dispose();
    _durationController.dispose();
    super.dispose();
  }
  
  DateTime get _sessionDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      
      // Ensure user is authenticated and is an instructor or admin
      if (!authProvider.isAuthenticated || 
          (!authProvider.currentUser!.isInstructor && !authProvider.currentUser!.isAdmin)) {
        throw Exception('You do not have permission to create or edit sessions');
      }
      
      final currentUser = authProvider.currentUser!;
      
      // Parse integer values
      final int maxParticipants = int.parse(_maxParticipantsController.text);
      final int creditCost = int.parse(_creditCostController.text);
      final int duration = int.parse(_durationController.text);
      
      // Check if this is a create or edit operation
      if (widget.session == null) {
        // Creating a new session
        
        // Build recurring rule if needed
        String? recurringRule;
        if (_isRecurring) {
          recurringRule = _buildRecurringRule();
        }
        
        // Create session
        if (_isRecurring) {
          // Create recurring sessions
          // First, check for conflicts
          final DateTime startDateTime = _sessionDateTime;
          
          // Create a temporary session for conflict checking
          final tempSession = SessionModel(
            id: const Uuid().v4(),
            title: _titleController.text,
            description: _descriptionController.text,
            instructorId: currentUser.id,
            instructorName: currentUser.name,
            startTime: startDateTime,
            durationMinutes: duration,
            maxParticipants: maxParticipants,
            participantIds: const [],
            creditCost: creditCost,
            isRecurring: true,
            recurringRule: recurringRule,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            status: SessionStatus.upcoming,
            createdAt: DateTime.now(),
          );
          
          final conflicts = sessionProvider.checkForConflicts(tempSession);
          if (conflicts.isNotEmpty) {
            _showConflictsDialog(conflicts);
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          // Create recurring sessions
          final success = await sessionProvider.createRecurringSessions(
            title: _titleController.text,
            description: _descriptionController.text,
            instructorId: currentUser.id,
            instructorName: currentUser.name,
            startDate: startDateTime,
            durationMinutes: duration,
            maxParticipants: maxParticipants,
            creditCost: creditCost,
            recurringRule: recurringRule!,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            numberOfOccurrences: _recurringOccurrences,
          );
          
          if (!success) {
            throw Exception(sessionProvider.error ?? 'Failed to create recurring sessions');
          }
        } else {
          // Create a single session
          final newSession = SessionModel(
            id: const Uuid().v4(),
            title: _titleController.text,
            description: _descriptionController.text,
            instructorId: currentUser.id,
            instructorName: currentUser.name,
            startTime: _sessionDateTime,
            durationMinutes: duration,
            maxParticipants: maxParticipants,
            participantIds: const [],
            creditCost: creditCost,
            isRecurring: false,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            status: SessionStatus.upcoming,
            createdAt: DateTime.now(),
          );
          
          // Check for conflicts
          final conflicts = sessionProvider.checkForConflicts(newSession);
          if (conflicts.isNotEmpty) {
            _showConflictsDialog(conflicts);
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          final success = await sessionProvider.createSession(newSession);
          
          if (!success) {
            throw Exception(sessionProvider.error ?? 'Failed to create session');
          }
        }
      } else {
        // Editing an existing session
        final updatedSession = widget.session!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          startTime: _sessionDateTime,
          durationMinutes: duration,
          maxParticipants: maxParticipants,
          creditCost: creditCost,
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          updatedAt: DateTime.now(),
        );
        
        // Check for conflicts
        final conflicts = sessionProvider.checkForConflicts(updatedSession);
        if (conflicts.isNotEmpty) {
          _showConflictsDialog(conflicts);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        final success = await sessionProvider.updateSession(updatedSession);
        
        if (!success) {
          throw Exception(sessionProvider.error ?? 'Failed to update session');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.session == null ? 
                  'Session created successfully' : 
                  'Session updated successfully',
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
  
  String _buildRecurringRule() {
    // Building a simple RRULE string
    String rule = 'FREQ=${_recurringFrequency.toUpperCase()}';
    
    // Add BYDAY for weekly frequency
    if (_recurringFrequency == 'weekly') {
      const dayAbbreviations = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      List<String> selectedDayAbbreviations = [];
      
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) {
          selectedDayAbbreviations.add(dayAbbreviations[i]);
        }
      }
      
      // If no days are selected, use the day of the selected date
      if (selectedDayAbbreviations.isEmpty) {
        final dayIndex = _selectedDate.weekday - 1; // 0-based index for our list
        selectedDayAbbreviations.add(dayAbbreviations[dayIndex]);
        _selectedDays[dayIndex] = true; // Update UI state
      }
      
      rule += ';BYDAY=${selectedDayAbbreviations.join(',')}';
    }
    
    return rule;
  }
  
  void _showConflictsDialog(List<SessionModel> conflicts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Conflicts Detected'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The session you are trying to create conflicts with the following existing sessions:',
                style: TextStyle(
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: conflicts.length,
                  itemBuilder: (context, index) {
                    final conflict = conflicts[index];
                    return ListTile(
                      title: Text(conflict.title),
                      subtitle: Text(
                        '${DateFormat('MMM d, y').format(conflict.startTime)} at ${DateFormat('h:mm a').format(conflict.startTime)}',
                      ),
                      leading: const Icon(
                        Icons.warning,
                        color: AppTheme.warningColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select a different time or date.',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session == null ? 'Create Session' : 'Edit Session'),
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
            onPressed: _isLoading ? null : _saveSession,
            icon: const Icon(Icons.save, color: AppTheme.primaryColor),
            label: Text(
              widget.session == null ? 'Create' : 'Save',
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
          ? const LoadingIndicator(message: 'Saving session...')
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
            
            // Session title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Session Title',
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
            
            // Date and time
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('EEEE, MMM d, y').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
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
                hintText: 'Enter session duration in minutes',
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
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
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'Enter location or room',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            
            // Capacity and cost
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxParticipantsController,
                    decoration: const InputDecoration(
                      labelText: 'Max Participants',
                      hintText: 'Enter maximum capacity',
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _creditCostController,
                    decoration: const InputDecoration(
                      labelText: 'Credit Cost',
                      hintText: 'Credits required',
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
            
            // Recurring session
            if (widget.session == null) // Only show for new sessions
              Card(
                elevation: AppTheme.elevationSmall,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recurring toggle
                      SwitchListTile(
                        title: const Text(
                          'Recurring Session',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Create multiple instances of this session automatically',
                        ),
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      
                      if (_isRecurring) ...[
                        const Divider(),
                        
                        // Frequency
                        ListTile(
                          title: const Text('Repeats'),
                          trailing: DropdownButton<String>(
                            value: _recurringFrequency,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _recurringFrequency = value;
                                });
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: 'daily',
                                child: const Text('Daily'),
                              ),
                              DropdownMenuItem(
                                value: 'weekly',
                                child: const Text('Weekly'),
                              ),
                              DropdownMenuItem(
                                value: 'monthly',
                                child: const Text('Monthly'),
                              ),
                            ],
                          ),
                        ),
                        
                        // Days of week (for weekly frequency)
                        if (_recurringFrequency == 'weekly') ...[
                          const Padding(
                            padding: EdgeInsets.only(
                              left: AppTheme.paddingMedium,
                              right: AppTheme.paddingMedium,
                              top: AppTheme.paddingSmall,
                            ),
                            child: Text(
                              'Repeat on:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingMedium,
                              vertical: AppTheme.paddingSmall,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDaySelector(0, 'M'),
                                _buildDaySelector(1, 'T'),
                                _buildDaySelector(2, 'W'),
                                _buildDaySelector(3, 'T'),
                                _buildDaySelector(4, 'F'),
                                _buildDaySelector(5, 'S'),
                                _buildDaySelector(6, 'S'),
                              ],
                            ),
                          ),
                        ],
                        
                        // Number of occurrences
                        ListTile(
                          title: const Text('Number of occurrences'),
                          trailing: SizedBox(
                            width: 60,
                            child: DropdownButton<int>(
                              value: _recurringOccurrences,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _recurringOccurrences = value;
                                  });
                                }
                              },
                              items: [
                                for (var i = 2; i <= 12; i++)
                                  DropdownMenuItem(
                                    value: i,
                                    child: Text(i.toString()),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSession,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.session == null ? 'Create Session' : 'Save Changes',
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
  
  Widget _buildDaySelector(int index, String label) {
    final isSelected = _selectedDays[index];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDays[index] = !_selectedDays[index];
        });
      },
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}