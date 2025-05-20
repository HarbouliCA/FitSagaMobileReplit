import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/theme/app_theme.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<SessionModel>> _sessions;
  late List<SessionModel> _selectedSessions;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String _filter = 'all'; // 'all', 'yoga', 'hiit', 'strength', 'pilates', 'cardio'
  
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadSessions();
    _selectedSessions = _getSessionsForDay(_selectedDay);
  }
  
  void _loadSessions() {
    // In a real app, this would fetch from a provider or API
    // For demo purposes, we'll use sample data
    final List<SessionModel> allSessions = SessionModel.getSampleSessions();
    
    // Group sessions by day
    _sessions = {};
    for (final session in allSessions) {
      final dateKey = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      
      if (!_sessions.containsKey(dateKey)) {
        _sessions[dateKey] = [];
      }
      
      _sessions[dateKey]!.add(session);
    }
  }
  
  List<SessionModel> _getSessionsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    
    // Filter by session type if needed
    if (_filter == 'all' || _filter.isEmpty) {
      return _sessions[dateKey] ?? [];
    } else {
      return (_sessions[dateKey] ?? [])
          .where((session) => session.sessionType.toLowerCase() == _filter.toLowerCase())
          .toList();
    }
  }
  
  bool _hasSessionsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    
    if (_filter == 'all' || _filter.isEmpty) {
      return (_sessions[dateKey]?.isNotEmpty ?? false);
    } else {
      return (_sessions[dateKey]?.any(
            (session) => session.sessionType.toLowerCase() == _filter.toLowerCase(),
          ) ??
          false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildCalendar(),
          const Divider(height: 1),
          Expanded(
            child: _buildSessionsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to all sessions view
        },
        icon: const Icon(Icons.view_list),
        label: const Text('All Sessions'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  Widget _buildFilterChips() {
    // Define filter options
    final filterOptions = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Yoga', 'value': 'yoga'},
      {'label': 'HIIT', 'value': 'hiit'},
      {'label': 'Strength', 'value': 'strength'},
      {'label': 'Pilates', 'value': 'pilates'},
      {'label': 'Cardio', 'value': 'cardio'},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterOptions.map((option) {
            final label = option['label'] as String;
            final value = option['value'] as String;
            final isSelected = _filter == value;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filter = selected ? value : 'all';
                    _selectedSessions = _getSessionsForDay(_selectedDay);
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) {
        // This is used to mark days with events
        return _hasSessionsForDay(day) ? [1] : [];
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: '2 weeks',
        CalendarFormat.week: 'Week',
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _selectedSessions = _getSessionsForDay(selectedDay);
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }
  
  Widget _buildSessionsList() {
    if (_selectedSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions on ${DateFormat('EEEE, MMMM d').format(_selectedDay)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a different day or change filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedSessions.length,
      itemBuilder: (context, index) {
        final session = _selectedSessions[index];
        return _buildSessionCard(session);
      },
    );
  }
  
  Widget _buildSessionCard(SessionModel session) {
    final bool hasAvailableSlots = session.hasAvailableSlots;
    final String timeRange = session.formattedTimeRange;
    final String instructor = session.instructorName ?? 'Unknown Instructor';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showSessionDetails(session);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with session type and availability
            _buildSessionHeader(session),
            
            // Session details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Time and instructor
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeRange,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        instructor,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Short description
                  Text(
                    session.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Capacity and book button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${session.bookedCount}/${session.capacity} booked',
                        style: TextStyle(
                          color: hasAvailableSlots ? Colors.grey[600] : Colors.red,
                          fontWeight: hasAvailableSlots ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: hasAvailableSlots ? () => _bookSession(session) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          hasAvailableSlots ? 'Book (${session.creditsRequired} credits)' : 'Full',
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
  }
  
  Widget _buildSessionHeader(SessionModel session) {
    Color headerColor;
    
    // Set color based on session type
    switch (session.sessionType.toLowerCase()) {
      case 'yoga':
        headerColor = Colors.purple;
        break;
      case 'hiit':
        headerColor = Colors.orange;
        break;
      case 'strength':
        headerColor = Colors.blue;
        break;
      case 'pilates':
        headerColor = Colors.teal;
        break;
      case 'cardio':
        headerColor = Colors.red;
        break;
      default:
        headerColor = AppTheme.primaryColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            session.sessionType.toUpperCase(),
            style: TextStyle(
              color: headerColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: session.hasAvailableSlots ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              session.hasAvailableSlots
                  ? '${session.availableSlots} spots left'
                  : 'Full',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    // Show more advanced filter options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filter = 'all';
                        Navigator.pop(context);
                        _selectedSessions = _getSessionsForDay(_selectedDay);
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Session Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('All', 'all'),
                  _filterChip('Yoga', 'yoga'),
                  _filterChip('HIIT', 'hiit'),
                  _filterChip('Strength', 'strength'),
                  _filterChip('Pilates', 'pilates'),
                  _filterChip('Cardio', 'cardio'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Duration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('30 mins', '30'),
                  _filterChip('45 mins', '45'),
                  _filterChip('60 mins', '60'),
                  _filterChip('90+ mins', '90+'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedSessions = _getSessionsForDay(_selectedDay);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _filterChip(String label, String value) {
    final bool isSelected = _filter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filter = selected ? value : 'all';
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
  
  void _showSessionDetails(SessionModel session) {
    // Navigate to the session detail screen
    Navigator.of(context).pushNamed('/sessions/detail', arguments: session);
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value),
      ],
    );
  }
  
  void _bookSession(SessionModel session) {
    // Show booking confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session: ${session.title}'),
            const SizedBox(height: 8),
            Text('Date: ${session.formattedDate}'),
            const SizedBox(height: 8),
            Text('Time: ${session.formattedTimeRange}'),
            const SizedBox(height: 8),
            Text('Credits Required: ${session.creditsRequired}'),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to book this session?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, we would call a booking service here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booked ${session.title} successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}