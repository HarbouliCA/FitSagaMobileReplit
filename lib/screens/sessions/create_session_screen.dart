import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateSessionScreen extends StatefulWidget {
  final String userRole;
  final Function(Map<String, dynamic>) onSessionCreated;

  const CreateSessionScreen({
    Key? key,
    required this.userRole,
    required this.onSessionCreated,
  }) : super(key: key);

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _creditsRequiredController = TextEditingController();
  final _durationController = TextEditingController();
  
  // Form values
  DateTime _sessionDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _sessionTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedCategory = 'Yoga';
  String _selectedInstructor = '';
  
  // Lists for dropdowns
  final List<String> _categories = [
    'Yoga',
    'HIIT',
    'Strength',
    'Cardio',
    'Pilates',
    'CrossFit',
    'Kickboxing',
    'Zumba',
  ];
  
  List<String> _instructors = [
    'Sara Johnson',
    'Mike Torres',
    'David Clark',
    'Lisa Wong',
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Set default values
    _capacityController.text = '12';
    _creditsRequiredController.text = '1';
    _durationController.text = '60';
    
    // For admin users, show all instructors
    // For instructor users, only show themselves
    if (widget.userRole == 'instructor') {
      _instructors = ['Current Instructor'];
      _selectedInstructor = 'Current Instructor';
    } else {
      _selectedInstructor = _instructors[0];
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _creditsRequiredController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Session Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a session title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Session category
              DropdownButtonFormField<String>(
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
              
              const SizedBox(height: 16),
              
              // Session instructor
              DropdownButtonFormField<String>(
                value: _selectedInstructor,
                decoration: const InputDecoration(
                  labelText: 'Instructor',
                  border: OutlineInputBorder(),
                ),
                items: _instructors.map((instructor) {
                  return DropdownMenuItem<String>(
                    value: instructor,
                    child: Text(instructor),
                  );
                }).toList(),
                onChanged: widget.userRole == 'instructor' 
                    ? null 
                    : (value) {
                        setState(() {
                          _selectedInstructor = value!;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an instructor';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date and time row
              Row(
                children: [
                  // Date picker
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          controller: TextEditingController(
                            text: DateFormat('EEE, MMM d, y').format(_sessionDate),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Time picker
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a time';
                            }
                            return null;
                          },
                          controller: TextEditingController(
                            text: _sessionTime.format(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Duration, capacity, credits row
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
                  
                  // Capacity
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacity',
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
                  
                  // Credits required
                  Expanded(
                    child: TextFormField(
                      controller: _creditsRequiredController,
                      decoration: const InputDecoration(
                        labelText: 'Credits',
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
                ],
              ),
              
              const SizedBox(height: 16),
              
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
                  child: const Text('Create Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _sessionDate) {
      setState(() {
        _sessionDate = picked;
      });
    }
  }
  
  // Time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sessionTime,
    );
    
    if (picked != null && picked != _sessionTime) {
      setState(() {
        _sessionTime = picked;
      });
    }
  }
  
  // Submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final DateTime sessionDateTime = DateTime(
        _sessionDate.year,
        _sessionDate.month,
        _sessionDate.day,
        _sessionTime.hour,
        _sessionTime.minute,
      );
      
      // Create session data
      final Map<String, dynamic> sessionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'category': _selectedCategory,
        'instructor': _selectedInstructor,
        'dateTime': sessionDateTime,
        'location': _locationController.text,
        'duration': int.parse(_durationController.text),
        'capacity': int.parse(_capacityController.text),
        'enrolled': 0,
        'creditsRequired': int.parse(_creditsRequiredController.text),
        'description': _descriptionController.text,
      };
      
      // Pass data back to parent
      widget.onSessionCreated(sessionData);
      
      // Show success message and close
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session created successfully!')),
      );
      Navigator.of(context).pop();
    }
  }
}