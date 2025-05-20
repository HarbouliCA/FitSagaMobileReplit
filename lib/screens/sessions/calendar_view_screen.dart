import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  
  // Current view type (day, week, month)
  String _currentView = 'month';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize calendar state
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    
    // Load sessions when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }
  
  // Load sessions data
  Future<void> _loadSessions() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    if (!sessionProvider.isInitialized) {
      await sessionProvider.loadSessions();
    }
  }
  
  // Get events for a given day
  List<SessionModel> _getEventsForDay(DateTime day) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    return sessionProvider.getSessionsForDay(day);
  }
  
  void _onViewChanged(String view) {
    setState(() {
      _currentView = view;
      
      // Update calendar format based on selected view
      switch (view) {
        case 'day':
          _calendarFormat = CalendarFormat.month; // Still show month for context
          break;
        case 'week':
          _calendarFormat = CalendarFormat.week;
          break;
        case 'month':
          _calendarFormat = CalendarFormat.month;
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Calendar'),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Sessions',
            onPressed: _showFilterDialog,
          ),
          
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: sessionProvider.isLoading
          ? const LoadingIndicator(message: 'Loading sessions...')
          : sessionProvider.error != null
              ? CustomErrorWidget(
                  message: sessionProvider.error!,
                  onRetry: _loadSessions,
                )
              : _buildBody(sessionProvider),
      floatingActionButton: authProvider.isAuthenticated && 
                          (authProvider.currentUser!.isAdmin || 
                           authProvider.currentUser!.isInstructor)
          ? FloatingActionButton(
              onPressed: _showCreateSessionDialog,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
  
  Widget _buildBody(SessionProvider sessionProvider) {
    return Column(
      children: [
        // View selector
        _buildViewSelector(),
        
        // Calendar
        _buildCalendar(sessionProvider),
        
        // Session list for selected day/period
        Expanded(
          child: _buildSessionList(sessionProvider),
        ),
      ],
    );
  }
  
  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          _buildViewOption('day', 'Day'),
          _buildViewOption('week', 'Week'),
          _buildViewOption('month', 'Month'),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: const Icon(Icons.today, size: 16),
            label: const Text('Today'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildViewOption(String view, String label) {
    final isSelected = _currentView == view;
    
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _onViewChanged(view),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 20,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalendar(SessionProvider sessionProvider) {
    // Get events for the calendar
    final events = <DateTime, List<SessionModel>>{};
    
    // Pre-populate events for better performance
    // For the current month and next month
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final followingMonth = DateTime(now.year, now.month + 2, 1);
    
    for (var d = currentMonth; d.isBefore(followingMonth); d = d.add(const Duration(days: 1))) {
      final day = DateTime(d.year, d.month, d.day);
      events[day] = sessionProvider.getSessionsForDay(day);
    }
    
    return TableCalendar<SessionModel>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: _getEventsForDay,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _currentView = 'day'; // Switch to day view when a day is selected
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
          
          // Update view based on format
          if (format == CalendarFormat.month) {
            _currentView = 'month';
          } else if (format == CalendarFormat.week) {
            _currentView = 'week';
          }
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
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryLightColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppTheme.primaryColor,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
  
  Widget _buildSessionList(SessionProvider sessionProvider) {
    List<SessionModel> sessionsToShow = [];
    String periodLabel = '';
    
    // Get sessions based on current view
    switch (_currentView) {
      case 'day':
        sessionsToShow = sessionProvider.getSessionsForDay(_selectedDay);
        periodLabel = DateFormat('EEEE, MMMM d, y').format(_selectedDay);
        break;
      case 'week':
        // Calculate the start of the week containing the selected day
        final weekStart = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
        sessionsToShow = sessionProvider.getSessionsForWeek(weekStart);
        final weekEnd = weekStart.add(const Duration(days: 6));
        periodLabel = 'Week of ${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, y').format(weekEnd)}';
        break;
      case 'month':
        // Get first day of the selected month
        final monthStart = DateTime(_selectedDay.year, _selectedDay.month, 1);
        sessionsToShow = sessionProvider.getSessionsForMonth(monthStart);
        periodLabel = DateFormat('MMMM y').format(_selectedDay);
        break;
    }
    
    // Sort sessions by start time
    sessionsToShow.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    if (sessionsToShow.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              periodLabel,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'No sessions scheduled for this period',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            children: [
              Text(
                periodLabel,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${sessionsToShow.length} ${sessionsToShow.length == 1 ? 'session' : 'sessions'}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sessionsToShow.length,
            itemBuilder: (context, index) {
              final session = sessionsToShow[index];
              return _buildSessionCard(session);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSessionCard(SessionModel session) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Color based on session status
    Color statusColor;
    switch (session.status) {
      case SessionStatus.upcoming:
        statusColor = AppTheme.primaryColor;
        break;
      case SessionStatus.ongoing:
        statusColor = AppTheme.infoColor;
        break;
      case SessionStatus.completed:
        statusColor = AppTheme.successColor;
        break;
      case SessionStatus.cancelled:
        statusColor = AppTheme.errorColor;
        break;
    }
    
    // Check if user is enrolled
    bool isUserEnrolled = false;
    if (authProvider.isAuthenticated) {
      isUserEnrolled = session.isUserEnrolled(authProvider.currentUser!.id);
    }
    
    // Check if session is full
    final isFull = session.isFull;
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      elevation: AppTheme.elevationSmall,
      child: InkWell(
        onTap: () => _showSessionDetails(session),
        child: Column(
          children: [
            // Time indicator with status color
            Container(
              color: statusColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: AppTheme.paddingSmall,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('h:mm a').format(session.startTime),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' - ${DateFormat('h:mm a').format(session.endTime)}',
                    style: TextStyle(
                      color: statusColor,
                    ),
                  ),
                  const Spacer(),
                  if (isUserEnrolled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Enrolled',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.fontSizeXSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (session.isRecurring)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat,
                            color: AppTheme.infoColor,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Recurring',
                            style: TextStyle(
                              color: AppTheme.infoColor,
                              fontSize: AppTheme.fontSizeXSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Session details
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session title and instructor
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
                        const SizedBox(height: 4),
                        Text(
                          'with ${session.instructorName}',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        if (session.location != null && session.location!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppTheme.textLightColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.location!,
                                style: const TextStyle(
                                  color: AppTheme.textLightColor,
                                  fontSize: AppTheme.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Capacity and credit cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isFull
                              ? AppTheme.warningColor.withOpacity(0.1)
                              : AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          border: Border.all(
                            color: isFull
                                ? AppTheme.warningColor.withOpacity(0.5)
                                : AppTheme.successColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '${session.participantIds.length}/${session.maxParticipants} spots',
                          style: TextStyle(
                            color: isFull
                                ? AppTheme.warningColor
                                : AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '${session.creditCost} ${session.creditCost == 1 ? 'credit' : 'credits'}',
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action buttons
            if (session.status == SessionStatus.upcoming)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.paddingMedium,
                  0,
                  AppTheme.paddingMedium,
                  AppTheme.paddingMedium,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isUserEnrolled)
                      TextButton.icon(
                        onPressed: () => _cancelBooking(session),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                      )
                    else if (!isFull && authProvider.isAuthenticated)
                      ElevatedButton.icon(
                        onPressed: () => _bookSession(session),
                        icon: const Icon(Icons.add),
                        label: const Text('Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
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
  
  void _showSessionDetails(SessionModel session) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                _buildStatusBadge(session.status),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Time and date
                _buildDetailItem(
                  icon: Icons.event,
                  label: 'Date',
                  value: DateFormat('EEEE, MMMM d, y').format(session.startTime),
                ),
                
                const SizedBox(height: 12),
                
                _buildDetailItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '${DateFormat('h:mm a').format(session.startTime)} - ${DateFormat('h:mm a').format(session.endTime)}',
                ),
                
                const SizedBox(height: 12),
                
                _buildDetailItem(
                  icon: Icons.timelapse,
                  label: 'Duration',
                  value: '${session.durationMinutes} minutes',
                ),
                
                if (session.location != null && session.location!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  
                  _buildDetailItem(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: session.location!,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                _buildDetailItem(
                  icon: Icons.person,
                  label: 'Instructor',
                  value: session.instructorName,
                ),
                
                const SizedBox(height: 12),
                
                _buildDetailItem(
                  icon: Icons.group,
                  label: 'Capacity',
                  value: '${session.participantIds.length}/${session.maxParticipants} spots filled',
                ),
                
                const SizedBox(height: 12),
                
                _buildDetailItem(
                  icon: Icons.credit_card,
                  label: 'Credit Cost',
                  value: '${session.creditCost} ${session.creditCost == 1 ? 'credit' : 'credits'}',
                ),
                
                if (session.isRecurring) ...[
                  const SizedBox(height: 12),
                  
                  _buildDetailItem(
                    icon: Icons.repeat,
                    label: 'Recurring',
                    value: 'This is a recurring session',
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  session.description,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryColor,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action buttons
                if (session.status == SessionStatus.upcoming)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (authProvider.isAuthenticated && 
                         session.isUserEnrolled(authProvider.currentUser!.id))
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _cancelBooking(session);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel Booking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingLarge,
                              vertical: AppTheme.paddingMedium,
                            ),
                          ),
                        )
                      else if (authProvider.isAuthenticated && 
                              !session.isFull)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _bookSession(session);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Book Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingLarge,
                              vertical: AppTheme.paddingMedium,
                            ),
                          ),
                        ),
                    ],
                  ),
                
                // Admin/Instructor actions
                if (authProvider.isAuthenticated && 
                   (authProvider.currentUser!.isAdmin || 
                    (authProvider.currentUser!.isInstructor && 
                     authProvider.currentUser!.id == session.instructorId)))
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      const Divider(),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Admin Actions',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _editSession(session);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                          if (session.status == SessionStatus.upcoming)
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _cancelSession(session);
                              },
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                                side: const BorderSide(color: AppTheme.errorColor),
                              ),
                            ),
                        ],
                      ),
                      
                      if (session.isRecurring && session.parentRecurringSessionId == null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _manageRecurringSessions(session);
                          },
                          icon: const Icon(Icons.repeat),
                          label: const Text('Manage Recurring Sessions'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(SessionStatus status) {
    String statusText;
    Color statusColor;
    
    switch (status) {
      case SessionStatus.upcoming:
        statusText = 'Upcoming';
        statusColor = AppTheme.primaryColor;
        break;
      case SessionStatus.ongoing:
        statusText = 'In Progress';
        statusColor = AppTheme.infoColor;
        break;
      case SessionStatus.completed:
        statusText = 'Completed';
        statusColor = AppTheme.successColor;
        break;
      case SessionStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = AppTheme.errorColor;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: AppTheme.fontSizeSmall,
        ),
      ),
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 16),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showFilterDialog() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    SessionStatus? tempStatusFilter = sessionProvider.statusFilter;
    bool tempOnlyUserSessions = sessionProvider.onlyUserSessions;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Sessions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status filter
              const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: tempStatusFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        tempStatusFilter = null;
                      });
                    },
                  ),
                  ...SessionStatus.values.map((status) {
                    String label;
                    switch (status) {
                      case SessionStatus.upcoming:
                        label = 'Upcoming';
                        break;
                      case SessionStatus.ongoing:
                        label = 'In Progress';
                        break;
                      case SessionStatus.completed:
                        label = 'Completed';
                        break;
                      case SessionStatus.cancelled:
                        label = 'Cancelled';
                        break;
                    }
                    
                    return FilterChip(
                      label: Text(label),
                      selected: tempStatusFilter == status,
                      onSelected: (selected) {
                        setState(() {
                          tempStatusFilter = selected ? status : null;
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Only user sessions filter
              if (Provider.of<AuthProvider>(context, listen: false).isAuthenticated)
                SwitchListTile(
                  title: const Text('Show only my sessions'),
                  value: tempOnlyUserSessions,
                  onChanged: (value) {
                    setState(() {
                      tempOnlyUserSessions = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tempStatusFilter = null;
                  tempOnlyUserSessions = false;
                });
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply filters
                sessionProvider.setFilters(
                  status: tempStatusFilter,
                  onlyUserSessions: tempOnlyUserSessions,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _bookSession(SessionModel session) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to sign in to book sessions'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Confirm dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to book "${session.title}"?',
            ),
            const SizedBox(height: 16),
            Text(
              'This will use ${session.creditCost} ${session.creditCost == 1 ? 'credit' : 'credits'} from your account.',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              setState(() {
                sessionProvider.isLoading = true;
              });
              
              try {
                final success = await sessionProvider.bookSession(
                  sessionId: session.id,
                  userId: authProvider.currentUser!.id,
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session booked successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sessionProvider.error ?? 'Failed to book session'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    sessionProvider.isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
  
  void _cancelBooking(SessionModel session) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      return;
    }
    
    // Confirm dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel your booking for "${session.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              setState(() {
                sessionProvider.isLoading = true;
              });
              
              try {
                final success = await sessionProvider.cancelBooking(
                  sessionId: session.id,
                  userId: authProvider.currentUser!.id,
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sessionProvider.error ?? 'Failed to cancel booking'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    sessionProvider.isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _editSession(SessionModel session) {
    // This would navigate to the session editing screen
    // For now, just show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing session: ${session.title}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  void _cancelSession(SessionModel session) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // Confirm dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel "${session.title}"?',
            ),
            const SizedBox(height: 16),
            const Text(
              'This will notify all enrolled participants and refund their credits.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              setState(() {
                sessionProvider.isLoading = true;
              });
              
              try {
                final success = await sessionProvider.cancelSession(session.id);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session cancelled successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sessionProvider.error ?? 'Failed to cancel session'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    sessionProvider.isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _manageRecurringSessions(SessionModel session) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // Get all instances of this recurring session
    final instances = sessionProvider.getRecurringSessionInstances(session.id);
    
    // Manage recurring sessions dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Recurring Sessions'),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recurring pattern: ${session.recurringRule}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${instances.length} recurring instances',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Options for managing recurring sessions
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit all upcoming sessions'),
                subtitle: const Text('Apply changes to all future occurrences'),
                onTap: () {
                  Navigator.of(context).pop();
                  // This would navigate to an editing screen for recurring sessions
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Editing all upcoming recurring sessions'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.edit_calendar),
                title: const Text('Edit only this session'),
                subtitle: const Text('Apply changes only to this occurrence'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editSession(session);
                },
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.cancel, color: AppTheme.errorColor),
                title: const Text(
                  'Cancel all upcoming sessions',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                subtitle: const Text('Cancel this and all future occurrences'),
                onTap: () {
                  Navigator.of(context).pop();
                  _cancelAllRecurringSessions(session);
                },
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
  
  void _cancelAllRecurringSessions(SessionModel session) {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // Confirm dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Recurring Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel all upcoming instances of "${session.title}"?',
            ),
            const SizedBox(height: 16),
            const Text(
              'This will cancel all future occurrences and notify all enrolled participants.',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              setState(() {
                sessionProvider.isLoading = true;
              });
              
              try {
                final success = await sessionProvider.cancelAllRecurringInstances(session.id);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All recurring sessions cancelled successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(sessionProvider.error ?? 'Failed to cancel recurring sessions'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    sessionProvider.isLoading = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );
  }
  
  void _showCreateSessionDialog() {
    // This would navigate to a session creation screen
    // For now, just show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating a new session'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}