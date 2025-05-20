import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showOnlyBooked = false;
  
  @override
  void initState() {
    super.initState();
    
    // Load sessions if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }
  
  Future<void> _loadSessions() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    if (authProvider.currentUser != null && !sessionProvider.isInitialized) {
      await sessionProvider.loadSessions(authProvider.currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (sessionProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final user = authProvider.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to view the calendar.'),
        ),
      );
    }
    
    // Get all sessions for the calendar
    final allSessions = _showOnlyBooked
        ? sessionProvider.userSessions
        : [...sessionProvider.sessions, ...sessionProvider.userSessions];
    
    // Remove duplicates (sessions may be in both lists)
    final uniqueSessions = <String, SessionModel>{};
    for (final session in allSessions) {
      uniqueSessions[session.id] = session;
    }
    
    // Create map of sessions by date
    final sessionsByDate = _groupSessionsByDate(uniqueSessions.values.toList());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Calendar'),
        actions: [
          Switch(
            value: _showOnlyBooked,
            onChanged: (value) {
              setState(() {
                _showOnlyBooked = value;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
          const Text('My Bookings'),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(sessionsByDate),
          const Divider(),
          Expanded(
            child: _buildSessionList(sessionsByDate[_selectedDay] ?? []),
          ),
        ],
      ),
      floatingActionButton: user.isInstructor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/sessions/create');
              },
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildCalendar(Map<DateTime, List<SessionModel>> sessionsByDate) {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      calendarFormat: _calendarFormat,
      eventLoader: (day) {
        return sessionsByDate[DateTime(day.year, day.month, day.day)] ?? [];
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
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
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonTextStyle: TextStyle(color: Colors.white),
        formatButtonDecoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
    );
  }
  
  Widget _buildSessionList(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: AppTheme.textLightColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions on ${DateFormat.yMMMMd().format(_selectedDay)}',
              style: const TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a different day or create a new session',
              style: TextStyle(
                color: AppTheme.textLightColor,
              ),
            ),
          ],
        ),
      );
    }
    
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    // Sort sessions by start time
    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isBooked = user != null && session.isUserRegistered(user.id);
        
        return _buildSessionCard(session, isBooked);
      },
    );
  }
  
  Widget _buildSessionCard(SessionModel session, bool isBooked) {
    final timeFormatter = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      elevation: AppTheme.elevationXSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        side: isBooked
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/sessions/details',
            arguments: session,
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getTypeColor(session.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(session.type),
                    color: _getTypeColor(session.type),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeMedium,
                      ),
                    ),
                    Text(
                      'with ${session.instructorName}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${timeFormatter.format(session.startTime)} - ${timeFormatter.format(session.endTime)}',
                          style: const TextStyle(
                            color: AppTheme.textLightColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            session.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textLightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isBooked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successLightColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Text(
                        'Booked',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: AppTheme.fontSizeXSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: session.isFull
                            ? AppTheme.errorLightColor
                            : AppTheme.infoLightColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        session.isFull
                            ? 'Full'
                            : '${session.availableSpots} left',
                        style: TextStyle(
                          color: session.isFull
                              ? AppTheme.errorColor
                              : AppTheme.infoColor,
                          fontSize: AppTheme.fontSizeXSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.participantIds.length}/${session.maxParticipants}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeXSmall,
                      color: AppTheme.textLightColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Map<DateTime, List<SessionModel>> _groupSessionsByDate(List<SessionModel> sessions) {
    final sessionsByDate = <DateTime, List<SessionModel>>{};
    
    for (final session in sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      
      if (!sessionsByDate.containsKey(sessionDate)) {
        sessionsByDate[sessionDate] = [];
      }
      
      sessionsByDate[sessionDate]!.add(session);
    }
    
    return sessionsByDate;
  }
  
  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return AppTheme.primaryColor;
      case SessionType.group:
        return AppTheme.accentColor;
      case SessionType.workshop:
        return AppTheme.infoColor;
      case SessionType.event:
        return AppTheme.successColor;
    }
  }
  
  IconData _getTypeIcon(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return Icons.person;
      case SessionType.group:
        return Icons.group;
      case SessionType.workshop:
        return Icons.school;
      case SessionType.event:
        return Icons.event;
    }
  }
}