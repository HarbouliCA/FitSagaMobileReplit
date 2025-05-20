import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/sessions/conflict_display_widget.dart';
import 'package:fitsaga/screens/sessions/recurring_pattern_selector_screen.dart';
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
  String? _recurringRule;
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
        final DateTime startDateTime = _sessionDateTime;
        
        // Create session
        if (_isRecurring && _recurringRule != null) {
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
            recurringRule: _recurringRule,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            status: SessionStatus.upcoming,
            createdAt: DateTime.now(),
          );
          
          // Check for conflicts with potential recurring instances
          final conflicts = sessionProvider.checkForConflicts(tempSession);
          if (conflicts.isNotEmpty) {
            _showConflictsDialog(conflicts, tempSession);
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
            recurringRule: _recurringRule!,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            numberOfOccurrences: _recurringOccurrences,
          );
          
          if (!success) {
            throw Exception(sessionProvider.error ?? 'Failed to create recurring sessions');
          }
        } else {
          // Create a single (non-recurring) session
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
          final conflicts = sessionProvider.checkForConflicts(
            newSession, 
            checkRecurring: false,
          );
          
          if (conflicts.isNotEmpty) {
            _showConflictsDialog(conflicts, newSession);
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
        
        // Check for conflicts, but exclude recurring relationships when checking
        final conflicts = sessionProvider.checkForConflicts(
          updatedSession,
          checkRecurring: false,
        );
        
        if (conflicts.isNotEmpty) {
          _showConflictsDialog(conflicts, updatedSession);
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
                  _isRecurring ? 
                      'Recurring sessions created successfully' : 
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
  
  void _showConflictsDialog(List<SessionModel> conflicts, SessionModel proposedSession) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Conflicts Detected'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The session you are trying to create conflicts with existing sessions:',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Using our conflict display widget
                ConflictDisplayWidget(
                  conflicts: conflicts,
                  proposedSession: proposedSession,
                  onResolve: () {
                    Navigator.of(context).pop();
                    // Focus on the date and time fields
                    _selectDate();
                  },
                ),
                
                const SizedBox(height: 16),
                Text(
                  _isRecurring ? 
                    'Note: Recurring sessions require checking multiple dates for conflicts.' :
                    'Please select a different time or date to resolve this conflict.',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Focus on the date and time fields
              _selectDate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Change Date/Time'),
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
                            if (!value) {
                              _recurringRule = null;
                            }
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      
                      if (_isRecurring) ...[
                        const Divider(),
                        
                        if (_recurringRule != null) ...[
                          // Show selected pattern
                          _buildRecurringPatternSummary(),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Button to select pattern
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _selectRecurringPattern,
                            icon: Icon(
                              _recurringRule == null ? Icons.add : Icons.edit,
                              size: 18,
                            ),
                            label: Text(_recurringRule == null
                                ? 'Configure Recurring Pattern'
                                : 'Edit Recurring Pattern'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryLightColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Number of occurrences
                        if (_recurringRule != null) ...[
                          ListTile(
                            leading: const Icon(Icons.repeat, color: AppTheme.primaryColor),
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
                                  for (var i = 2; i <= 24; i++)
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
  
  // Launch the recurring pattern selector
  Future<void> _selectRecurringPattern() async {
    final rule = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => RecurringPatternSelectorScreen(
          initialPattern: _recurringRule,
          referenceDate: _sessionDateTime,
        ),
      ),
    );
    
    if (rule != null) {
      setState(() {
        _recurringRule = rule;
      });
    }
  }
  
  // Build a summary of the selected recurring pattern
  Widget _buildRecurringPatternSummary() {
    if (_recurringRule == null) {
      return const SizedBox.shrink();
    }
    
    // Parse the RRULE format
    Map<String, String> ruleMap = {};
    for (var part in _recurringRule!.split(';')) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        ruleMap[keyValue[0]] = keyValue[1];
      }
    }
    
    final freq = ruleMap['FREQ']?.toLowerCase();
    if (freq == null) {
      return const Text('Invalid recurring pattern');
    }
    
    String patternText;
    IconData patternIcon;
    
    switch (freq) {
      case 'daily':
        patternText = 'Every day';
        patternIcon = Icons.calendar_view_day;
        break;
      case 'weekly':
        final byDay = ruleMap['BYDAY']?.split(',');
        if (byDay != null && byDay.isNotEmpty) {
          patternText = 'Weekly on ${_formatWeekdays(byDay)}';
        } else {
          final weekday = DateFormat('EEEE').format(_selectedDate);
          patternText = 'Weekly on $weekday';
        }
        patternIcon = Icons.view_week;
        break;
      case 'monthly':
        patternIcon = Icons.calendar_view_month;
        if (ruleMap.containsKey('BYSETPOS') && ruleMap.containsKey('BYDAY')) {
          // By position (e.g., "first Monday")
          final pos = int.tryParse(ruleMap['BYSETPOS'] ?? '1') ?? 1;
          final day = ruleMap['BYDAY'];
          final ordinal = _getOrdinalText(pos);
          final dayName = _getDayName(day ?? 'MO');
          patternText = 'Monthly on the $ordinal $dayName';
        } else {
          // By day of month
          final day = _selectedDate.day;
          patternText = 'Monthly on day $day';
        }
        break;
      case 'yearly':
        patternText = 'Annually on ${DateFormat('MMMM d').format(_selectedDate)}';
        patternIcon = Icons.event;
        break;
      default:
        patternText = 'Custom pattern';
        patternIcon = Icons.repeat;
    }
    
    bool hasCount = ruleMap.containsKey('COUNT');
    bool hasUntil = ruleMap.containsKey('UNTIL');
    String limitText = '';
    
    if (hasCount) {
      final count = int.tryParse(ruleMap['COUNT'] ?? '0') ?? 0;
      limitText = ', $count occurrences';
    } else if (hasUntil) {
      try {
        final untilStr = ruleMap['UNTIL'] ?? '';
        // Parse YYYYMMDD format
        final year = int.parse(untilStr.substring(0, 4));
        final month = int.parse(untilStr.substring(4, 6));
        final day = int.parse(untilStr.substring(6, 8));
        final untilDate = DateTime(year, month, day);
        
        limitText = ', until ${DateFormat('MMM d, y').format(untilDate)}';
      } catch (e) {
        // Parsing error
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                patternIcon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  patternText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (limitText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                limitText,
                style: TextStyle(
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              'At ${DateFormat('h:mm a').format(_sessionDateTime)}',
              style: TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatWeekdays(List<String> days) {
    const dayMap = {
      'MO': 'Monday',
      'TU': 'Tuesday',
      'WE': 'Wednesday',
      'TH': 'Thursday',
      'FR': 'Friday',
      'SA': 'Saturday',
      'SU': 'Sunday',
    };

    final formattedDays = days.map((day) => dayMap[day] ?? day).toList();
    
    if (formattedDays.length == 1) {
      return formattedDays.first;
    } else if (formattedDays.length == 2) {
      return '${formattedDays.first} and ${formattedDays.last}';
    } else {
      final lastDay = formattedDays.removeLast();
      return '${formattedDays.join(', ')}, and $lastDay';
    }
  }
  
  String _getOrdinalText(int position) {
    switch (position) {
      case 1:
        return 'first';
      case 2:
        return 'second';
      case 3:
        return 'third';
      case 4:
        return 'fourth';
      case -1:
        return 'last';
      default:
        return position.toString();
    }
  }
  
  String _getDayName(String dayCode) {
    switch (dayCode) {
      case 'MO':
        return 'Monday';
      case 'TU':
        return 'Tuesday';
      case 'WE':
        return 'Wednesday';
      case 'TH':
        return 'Thursday';
      case 'FR':
        return 'Friday';
      case 'SA':
        return 'Saturday';
      case 'SU':
        return 'Sunday';
      default:
        return dayCode;
    }
  }
}