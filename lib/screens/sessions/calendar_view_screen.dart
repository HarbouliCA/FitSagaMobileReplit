import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fitsaga/models/booking_model.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/services/booking_service.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  bool _isLoading = false;
  String? _error;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> _selectedEvents = [];
  
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // In a real app, we would fetch sessions from Firebase
      // For demo purposes, generate sample sessions
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate sessions for the next 14 days
      final now = DateTime.now();
      final events = <DateTime, List<Map<String, dynamic>>>{};
      
      for (int i = -1; i < 14; i++) {
        final day = DateTime(now.year, now.month, now.day + i);
        
        // Skip generating sessions for past days except today and yesterday
        if (i < -1) continue;
        
        // Generate 2-4 sessions per day
        final sessionCount = 2 + (day.day % 3); // 2-4 sessions per day
        final daySessions = <Map<String, dynamic>>[];
        
        for (int j = 0; j < sessionCount; j++) {
          // Create varied session times throughout the day
          final startHour = 8 + ((j * 3) % 12); // 8am, 11am, 2pm, 5pm
          final sessionDuration = 60; // minutes
          
          // Session capacity and booking status
          final capacity = 10 + (day.day % 5); // 10-14 capacity
          final bookedCount = (capacity * 0.7).floor() + (day.day % 4); // 70%-100% booked
          final spaceAvailable = bookedCount < capacity;
          
          // Create session
          daySessions.add({
            'id': 'session-${day.year}-${day.month}-${day.day}-$j',
            'title': _getSessionTitle(j),
            'instructor': _getInstructorName(j),
            'startTime': DateTime(day.year, day.month, day.day, startHour, 0),
            'endTime': DateTime(day.year, day.month, day.day, startHour, sessionDuration),
            'capacity': capacity,
            'bookedCount': bookedCount,
            'spaceAvailable': spaceAvailable,
            'creditsRequired': j == 0 ? 1 : 2, // Regular or premium session
            'isBooked': day.isAfter(now) && j == 1, // Pretend some sessions are booked
            'isPast': day.isBefore(DateTime(now.year, now.month, now.day)),
          });
        }
        
        events[day] = daySessions;
      }
      
      setState(() {
        _events = events;
        _updateSelectedEvents();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load sessions: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _updateSelectedEvents() {
    if (_selectedDay != null) {
      // Get the day-only version of the selected date (no time component)
      final selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _selectedEvents = _events[selectedDate] ?? [];
    } else {
      _selectedEvents = [];
    }
  }
  
  String _getSessionTitle(int index) {
    final titles = [
      'Morning Yoga',
      'HIIT Training',
      'Spin Class',
      'Strength Training',
      'Kickboxing',
      'Pilates',
      'Zumba Dance',
      'CrossFit'
    ];
    return titles[index % titles.length];
  }
  
  String _getInstructorName(int index) {
    final names = [
      'Sarah Johnson',
      'Mike Torres',
      'Emma Williams',
      'Alex Chen',
      'David Kim',
      'Lisa Rodriguez'
    ];
    return names[index % names.length];
  }
  
  Future<void> _bookSession(Map<String, dynamic> session) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to book a session'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('EEEE, MMMM d').format(session['startTime'])} • '
              '${DateFormat('h:mm a').format(session['startTime'])} - '
              '${DateFormat('h:mm a').format(session['endTime'])}',
            ),
            const SizedBox(height: 8),
            Text('Instructor: ${session['instructor']}'),
            const SizedBox(height: 16),
            Text(
              'Credits required: ${session['creditsRequired']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Do you want to book this session?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Book Session'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookingService = Provider.of<BookingService>(context, listen: false);
      final result = await bookingService.bookSession(
        userId: authProvider.currentUser!.id,
        sessionId: session['id'],
        sessionTitle: session['title'],
        instructorId: null,
        instructorName: session['instructor'],
        sessionDate: session['startTime'],
        startTime: session['startTime'],
        endTime: session['endTime'],
        creditsRequired: session['creditsRequired'],
      );
      
      if (result.success) {
        // Update UI
        setState(() {
          session['isBooked'] = true;
          session['bookedCount'] = (session['bookedCount'] as int) + 1;
          session['spaceAvailable'] = session['bookedCount'] < session['capacity'];
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully booked ${session['title']}'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Failed to book session'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking session: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading sessions...')
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadSessions,
                )
              : Column(
                  children: [
                    _buildCalendar(),
                    const Divider(height: 0),
                    Expanded(
                      child: _buildSessionList(),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 7)),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: '2 Weeks',
        CalendarFormat.week: 'Week',
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _updateSelectedEvents();
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      // Styling
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppTheme.accentColor,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonTextStyle: TextStyle(fontSize: 14),
        titleCentered: true,
      ),
      eventLoader: (day) {
        final dayEvents = _events[DateTime(day.year, day.month, day.day)] ?? [];
        return dayEvents;
      },
    );
  }
  
  Widget _buildSessionList() {
    if (_selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions on ${DateFormat.yMMMMd().format(_selectedDay!)}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Change selected day to next day with sessions
                for (int i = 1; i < 14; i++) {
                  final nextDay = _selectedDay!.add(Duration(days: i));
                  final nextDayEvents = _events[DateTime(nextDay.year, nextDay.month, nextDay.day)];
                  
                  if (nextDayEvents != null && nextDayEvents.isNotEmpty) {
                    setState(() {
                      _selectedDay = nextDay;
                      _focusedDay = nextDay;
                      _updateSelectedEvents();
                    });
                    break;
                  }
                }
              },
              child: const Text('Find Next Available'),
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          DateFormat.yMMMMEEEEd().format(_selectedDay!),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._selectedEvents.map((session) => _buildSessionCard(session)),
      ],
    );
  }
  
  Widget _buildSessionCard(Map<String, dynamic> session) {
    final bool isBooked = session['isBooked'] as bool;
    final bool isPast = session['isPast'] as bool;
    final bool isAvailable = session['spaceAvailable'] as bool;
    final bool isFull = !isAvailable;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Time header
          Container(
            color: isPast 
                ? Colors.grey 
                : (isBooked ? AppTheme.primaryColor : AppTheme.accentColor),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('h:mm a').format(session['startTime'])} - '
                  '${DateFormat('h:mm a').format(session['endTime'])}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isBooked && !isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Booked',
                      style: TextStyle(
                        color: isPast ? Colors.grey : AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Session details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and credits
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppTheme.accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${session['creditsRequired']} credits',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Instructor
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Instructor: ${session['instructor']}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Available spots
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: isFull ? AppTheme.errorColor : AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Available: ${session['capacity'] - session['bookedCount']} / ${session['capacity']}',
                      style: TextStyle(
                        color: isFull ? AppTheme.errorColor : AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Booking button
                if (!isPast)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isBooked || !isAvailable
                            ? null // Disable if already booked or full
                            : () => _bookSession(session),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBooked
                              ? Colors.grey
                              : AppTheme.primaryColor,
                          disabledBackgroundColor: isBooked
                              ? AppTheme.primaryColor.withOpacity(0.5)
                              : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isBooked
                              ? 'Already Booked'
                              : (isAvailable ? 'Book Session' : 'Session Full'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}