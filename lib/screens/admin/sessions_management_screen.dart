import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class SessionsManagementScreen extends StatefulWidget {
  const SessionsManagementScreen({Key? key}) : super(key: key);

  @override
  State<SessionsManagementScreen> createState() => _SessionsManagementScreenState();
}

class _SessionsManagementScreenState extends State<SessionsManagementScreen> {
  bool _isLoading = false;
  String? _error;
  
  // Selected date range
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 7)),
  );
  
  // Selected status filter
  String _statusFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    _loadSessionsData();
  }
  
  Future<void> _loadSessionsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // In a real implementation, this would fetch sessions data from Firebase
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
    
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadSessionsData();
    }
  }
  
  void _filterByStatus(String status) {
    setState(() {
      _statusFilter = status;
    });
    _loadSessionsData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessionsData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                )
              : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create session screen
          _showCreateSessionDialog();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          _buildFiltersHeader(),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Calendar view (placeholder)
          _buildCalendarView(),
          
          const SizedBox(height: AppTheme.spacingMedium),
          
          // Sessions list
          Expanded(
            child: _buildSessionsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFiltersHeader() {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Row(
      children: [
        // Date range selector
        Expanded(
          child: Card(
            elevation: AppTheme.elevationSmall,
            child: InkWell(
              onTap: _selectDateRange,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date Range',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                          Text(
                            '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingMedium),
        
        // Status filter
        Expanded(
          child: Card(
            elevation: AppTheme.elevationSmall,
            child: PopupMenuButton<String>(
              onSelected: _filterByStatus,
              itemBuilder: (context) => [
                'All',
                'Upcoming',
                'Ongoing',
                'Completed',
                'Cancelled',
              ].map((status) => PopupMenuItem<String>(
                value: status,
                child: Text(status),
              )).toList(),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                          Text(
                            _statusFilter,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingMedium),
        
        // Search
        Expanded(
          child: Card(
            elevation: AppTheme.elevationSmall,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: AppTheme.paddingSmall,
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search sessions...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Search functionality would be implemented here
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCalendarView() {
    // This would be replaced with a proper calendar widget
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Calendar View',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeMedium,
                  ),
                ),
                Spacer(),
                Text(
                  'Week View',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Expanded(
              child: Center(
                child: Text(
                  'Calendar view would be implemented here with a proper calendar widget',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionsList() {
    // Sample sessions data
    final sessions = [
      {
        'id': '1',
        'title': 'Yoga Class',
        'instructor': 'Emily Davis',
        'datetime': DateTime.now().add(const Duration(days: 1, hours: 2)),
        'duration': 60,
        'enrolledClients': 8,
        'maxClients': 15,
        'status': 'Upcoming',
      },
      {
        'id': '2',
        'title': 'HIIT Workout',
        'instructor': 'Michael Brown',
        'datetime': DateTime.now().add(const Duration(hours: 3)),
        'duration': 45,
        'enrolledClients': 12,
        'maxClients': 12,
        'status': 'Full',
      },
      {
        'id': '3',
        'title': 'Pilates Fundamentals',
        'instructor': 'Sarah Johnson',
        'datetime': DateTime.now().add(const Duration(days: 2)),
        'duration': 90,
        'enrolledClients': 5,
        'maxClients': 10,
        'status': 'Upcoming',
      },
      {
        'id': '4',
        'title': 'Strength Training',
        'instructor': 'John Doe',
        'datetime': DateTime.now().subtract(const Duration(days: 1)),
        'duration': 60,
        'enrolledClients': 10,
        'maxClients': 10,
        'status': 'Completed',
      },
      {
        'id': '5',
        'title': 'Cardio Blast',
        'instructor': 'Robert Taylor',
        'datetime': DateTime.now().add(const Duration(days: 3, hours: 5)),
        'duration': 30,
        'enrolledClients': 7,
        'maxClients': 20,
        'status': 'Upcoming',
      },
    ];
    
    return Card(
      elevation: AppTheme.elevationSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Session',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Instructor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date & Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Duration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Capacity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Session rows
          Expanded(
            child: ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionRow(session);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionRow(Map<String, dynamic> session) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final datetime = session['datetime'] as DateTime;
    final enrolledClients = session['enrolledClients'] as int;
    final maxClients = session['maxClients'] as int;
    final status = session['status'] as String;
    
    Color statusColor;
    switch (status) {
      case 'Upcoming':
        statusColor = AppTheme.primaryColor;
        break;
      case 'Full':
        statusColor = AppTheme.warningColor;
        break;
      case 'Completed':
        statusColor = AppTheme.successColor;
        break;
      case 'Cancelled':
        statusColor = AppTheme.errorColor;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
    }
    
    return InkWell(
      onTap: () {
        // Show session details
        _showSessionDetailsDialog(session);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: AppTheme.paddingSmall,
        ),
        child: Row(
          children: [
            // Session title
            Expanded(
              flex: 3,
              child: Text(
                session['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Instructor
            Expanded(
              flex: 2,
              child: Text(session['instructor'] as String),
            ),
            
            // Date & Time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatter.format(datetime),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeFormatter.format(datetime),
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            
            // Duration
            Expanded(
              child: Text(
                '${session['duration']} min',
                textAlign: TextAlign.center,
              ),
            ),
            
            // Capacity
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$enrolledClients/$maxClients',
                    textAlign: TextAlign.center,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    child: LinearProgressIndicator(
                      value: enrolledClients / maxClients,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        enrolledClients == maxClients
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Actions
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: AppTheme.primaryColor,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      // Edit session
                      _showEditSessionDialog(session);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.people),
                    color: AppTheme.accentColor,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      // View participants
                      _showParticipantsDialog(session);
                    },
                  ),
                  IconButton(
                    icon: status == 'Cancelled'
                        ? const Icon(Icons.restore)
                        : const Icon(Icons.cancel),
                    color: status == 'Cancelled'
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      // Cancel or restore session
                      _toggleSessionStatus(session);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreateSessionDialog() {
    // Controller for form fields
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    final maxClientsController = TextEditingController(text: '10');
    
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedInstructor = 'Emily Davis';
    
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Session'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Session Title',
                      hintText: 'Enter session title',
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
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter session description',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Instructor
                  DropdownButtonFormField<String>(
                    value: selectedInstructor,
                    decoration: const InputDecoration(
                      labelText: 'Instructor',
                    ),
                    items: [
                      'Emily Davis',
                      'John Doe',
                      'Sarah Johnson',
                      'Michael Brown',
                      'Robert Taylor',
                    ].map((name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedInstructor = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('MMM d, yyyy').format(selectedDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              selectedTime.format(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Duration and Capacity
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration (minutes)',
                            suffixText: 'min',
                          ),
                          keyboardType: TextInputType.number,
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
                          controller: maxClientsController,
                          decoration: const InputDecoration(
                            labelText: 'Max Clients',
                            suffixText: 'clients',
                          ),
                          keyboardType: TextInputType.number,
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // In a real app, this would save the session to Firebase
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session created successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  // Refresh the list
                  _loadSessionsData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Create Session'),
            ),
          ],
        ),
      ),
    ).then((_) {
      titleController.dispose();
      descriptionController.dispose();
      durationController.dispose();
      maxClientsController.dispose();
    });
  }
  
  void _showEditSessionDialog(Map<String, dynamic> session) {
    // Implement edit session dialog similar to create session dialog
    // but pre-populated with session data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing session: ${session['title']}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _showSessionDetailsDialog(Map<String, dynamic> session) {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final datetime = session['datetime'] as DateTime;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          session['title'] as String,
          style: const TextStyle(
            color: AppTheme.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session info
            _buildDetailItem(
              icon: Icons.person,
              label: 'Instructor',
              value: session['instructor'] as String,
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: 'Date',
              value: dateFormatter.format(datetime),
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.access_time,
              label: 'Time',
              value: timeFormatter.format(datetime),
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.timelapse,
              label: 'Duration',
              value: '${session['duration']} minutes',
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.people,
              label: 'Enrollment',
              value: '${session['enrolledClients']}/${session['maxClients']} clients',
            ),
            const SizedBox(height: 12),
            _buildDetailItem(
              icon: Icons.info,
              label: 'Status',
              value: session['status'] as String,
              valueColor: _getStatusColor(session['status'] as String),
            ),
            const SizedBox(height: 20),
            
            // Description placeholder
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppTheme.fontSizeMedium,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a placeholder for the session description. In a real app, this would show the actual description of the session.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
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
              _showEditSessionDialog(session);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showParticipantsDialog(Map<String, dynamic> session) {
    // Sample participants data
    final participants = [
      {
        'id': '1',
        'name': 'Alex Johnson',
        'email': 'alex.johnson@example.com',
        'phone': '(555) 123-4567',
        'bookingTime': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '2',
        'name': 'Taylor Smith',
        'email': 'taylor.smith@example.com',
        'phone': '(555) 234-5678',
        'bookingTime': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '3',
        'name': 'Jordan Williams',
        'email': 'jordan.williams@example.com',
        'phone': '(555) 345-6789',
        'bookingTime': DateTime.now().subtract(const Duration(hours: 12)),
      },
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Participants: ${session['title']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: ${participants.length} of ${session['maxClients']} clients',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: participants.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryLightColor,
                        child: Text(
                          participant['name']![0] as String,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        participant['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant['email'] as String,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                          Text(
                            'Booked ${_formatTimeAgo(participant['bookingTime'] as DateTime)}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSizeXSmall,
                              color: AppTheme.textLightColor,
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel, color: AppTheme.errorColor),
                        onPressed: () {
                          // Remove participant
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${participant['name']} from session'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        },
                      ),
                    );
                  },
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
          ElevatedButton(
            onPressed: () {
              // Add participant dialog
              Navigator.of(context).pop();
              _showAddParticipantDialog(session);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Add Participant'),
          ),
        ],
      ),
    );
  }
  
  void _showAddParticipantDialog(Map<String, dynamic> session) {
    // This would show a dialog to search for and add clients to the session
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adding participant to: ${session['title']}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _toggleSessionStatus(Map<String, dynamic> session) {
    final status = session['status'] as String;
    final newStatus = status == 'Cancelled' ? 'Upcoming' : 'Cancelled';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'Cancelled' ? 'Restore Session' : 'Cancel Session',
        ),
        content: Text(
          status == 'Cancelled'
              ? 'Are you sure you want to restore this session? It will be visible to clients again.'
              : 'Are you sure you want to cancel this session? This will notify all enrolled clients.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, this would update the session status in Firebase
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    status == 'Cancelled'
                        ? 'Session restored successfully'
                        : 'Session cancelled successfully',
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              // Refresh the list
              _loadSessionsData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Cancelled'
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
            ),
            child: Text(
              status == 'Cancelled' ? 'Restore' : 'Cancel',
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return AppTheme.primaryColor;
      case 'Full':
        return AppTheme.warningColor;
      case 'Completed':
        return AppTheme.successColor;
      case 'Cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}