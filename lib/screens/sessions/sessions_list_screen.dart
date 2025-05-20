import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/providers/auth_provider.dart';
import 'package:fitsaga/providers/credit_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:fitsaga/widgets/common/error_widget.dart';
import 'package:intl/intl.dart';

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({Key? key}) : super(key: key);

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SessionType? _selectedType;
  String? _searchQuery;
  bool _showOnlyAvailable = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load sessions when screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final creditProvider = Provider.of<CreditProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Sessions'),
            Tab(text: 'My Bookings'),
            Tab(text: 'Calendar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: sessionProvider.isLoading
          ? const LoadingIndicator(message: 'Loading sessions...')
          : sessionProvider.error != null
              ? CustomErrorWidget(
                  message: sessionProvider.error!,
                  onRetry: () => _loadSessions(),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // All Sessions Tab
                    _buildAllSessionsTab(sessionProvider, creditProvider, authProvider),
                    
                    // My Bookings Tab
                    _buildMyBookingsTab(sessionProvider, authProvider),
                    
                    // Calendar View Tab
                    _buildCalendarTab(sessionProvider, authProvider),
                  ],
                ),
      floatingActionButton: authProvider.currentUser?.isInstructor == true
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
  
  Widget _buildAllSessionsTab(
    SessionProvider sessionProvider,
    CreditProvider creditProvider,
    AuthProvider authProvider,
  ) {
    final sessions = _getFilteredSessions(sessionProvider.upcomingSessions);
    
    if (sessions.isEmpty) {
      return EmptyStateWidget(
        title: 'No Sessions Found',
        message: 'No upcoming sessions match your filters. Adjust your filters or check back later for new sessions.',
        icon: Icons.event_busy,
        showAction: false,
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildSessionCard(
            session: session,
            isBooked: session.isUserRegistered(authProvider.currentUser!.id),
            hasEnoughCredits: creditProvider.hasSufficientCredits(1),
            onBook: () => _bookSession(session, authProvider, creditProvider, sessionProvider),
          );
        },
      ),
    );
  }
  
  Widget _buildMyBookingsTab(
    SessionProvider sessionProvider,
    AuthProvider authProvider,
  ) {
    final bookedSessions = sessionProvider.userSessions;
    
    if (bookedSessions.isEmpty) {
      return EmptyStateWidget(
        title: 'No Bookings',
        message: 'You haven\'t booked any sessions yet. Browse available sessions and book your first session!',
        icon: Icons.calendar_today,
        actionText: 'Find Sessions',
        onAction: () {
          _tabController.animateTo(0);
        },
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemCount: bookedSessions.length,
        itemBuilder: (context, index) {
          final session = bookedSessions[index];
          return _buildBookedSessionCard(
            session: session,
            onCancel: () => _cancelBooking(session, authProvider, sessionProvider),
            onViewDetails: () => _viewSessionDetails(session),
          );
        },
      ),
    );
  }
  
  Widget _buildCalendarTab(
    SessionProvider sessionProvider,
    AuthProvider authProvider,
  ) {
    // For simplicity, we'll show a basic calendar view
    // A more advanced implementation would use a calendar package
    
    // Group sessions by date
    final Map<DateTime, List<SessionModel>> sessionsByDate = {};
    final allRelevantSessions = [
      ...sessionProvider.upcomingSessions,
      ...sessionProvider.userSessions,
    ];
    
    // Remove duplicates
    final uniqueSessions = <String, SessionModel>{};
    for (final session in allRelevantSessions) {
      uniqueSessions[session.id] = session;
    }
    
    // Group by date (ignoring time)
    for (final session in uniqueSessions.values) {
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
    
    // Sort dates
    final dates = sessionsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    if (dates.isEmpty) {
      return EmptyStateWidget(
        title: 'No Upcoming Sessions',
        message: 'There are no upcoming sessions scheduled. Check back later for new sessions.',
        icon: Icons.event_busy,
        showAction: false,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final sessions = sessionsByDate[date]!;
        
        return _buildDateSessionsGroup(date, sessions, authProvider);
      },
    );
  }
  
  Widget _buildDateSessionsGroup(
    DateTime date,
    List<SessionModel> sessions,
    AuthProvider authProvider,
  ) {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final isToday = _isToday(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.paddingSmall,
            horizontal: AppTheme.paddingMedium,
          ),
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
          decoration: BoxDecoration(
            color: isToday ? AppTheme.primaryColor : AppTheme.textLightColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isToday ? Icons.today : Icons.calendar_today,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isToday ? 'Today - ${dateFormatter.format(date)}' : dateFormatter.format(date),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...sessions.map((session) {
          final isUserRegistered = session.isUserRegistered(authProvider.currentUser!.id);
          return _buildCompactSessionCard(
            session: session,
            isBooked: isUserRegistered,
            onTap: () => _viewSessionDetails(session),
          );
        }),
        const Divider(height: 32),
      ],
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  List<SessionModel> _getFilteredSessions(List<SessionModel> sessions) {
    // Apply type filter
    var filteredSessions = _selectedType != null
        ? sessions.where((s) => s.type == _selectedType).toList()
        : sessions;
    
    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      filteredSessions = filteredSessions.where((s) {
        return s.title.toLowerCase().contains(query) || 
               s.description.toLowerCase().contains(query) ||
               s.instructorName.toLowerCase().contains(query);
      }).toList();
    }
    
    // Show only available sessions if filter is enabled
    if (_showOnlyAvailable) {
      filteredSessions = filteredSessions.where((s) => !s.isFull).toList();
    }
    
    return filteredSessions;
  }
  
  Widget _buildSessionCard({
    required SessionModel session,
    required bool isBooked,
    required bool hasEnoughCredits,
    required VoidCallback onBook,
  }) {
    final dateFormatter = DateFormat('E, MMM d');
    final timeFormatter = DateFormat('h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      elevation: AppTheme.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        side: isBooked 
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session type banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.paddingSmall,
              horizontal: AppTheme.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: _getTypeColor(session.type),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusRegular),
                topRight: Radius.circular(AppTheme.borderRadiusRegular),
              ),
            ),
            child: Text(
              _getTypeText(session.type),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Session details
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                      ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingSmall),
                
                Text(
                  'by ${session.instructorName}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormatter.format(session.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormatter.format(session.startTime)} - ${timeFormatter.format(session.endTime)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingSmall),
                
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.location,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                Text(
                  session.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                Row(
                  children: [
                    if (session.level != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.paddingSmall,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(session.level!),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          session.level!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSizeXSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSmall),
                    ],
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: session.isFull ? AppTheme.errorLightColor : AppTheme.successLightColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        session.isFull 
                            ? 'Full'
                            : '${session.availableSpots} spot${session.availableSpots != 1 ? 's' : ''} left',
                        style: TextStyle(
                          color: session.isFull ? AppTheme.errorColor : AppTheme.successColor,
                          fontSize: AppTheme.fontSizeXSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    const Icon(
                      Icons.credit_card,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '1 Credit',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _viewSessionDetails(session),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingRegular),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBooked || session.isFull || !hasEnoughCredits
                            ? null
                            : onBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(isBooked 
                            ? 'Already Booked' 
                            : session.isFull 
                                ? 'Session Full'
                                : !hasEnoughCredits
                                    ? 'Need Credits'
                                    : 'Book Session'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookedSessionCard({
    required SessionModel session,
    required VoidCallback onCancel,
    required VoidCallback onViewDetails,
  }) {
    final dateFormatter = DateFormat('E, MMM d');
    final timeFormatter = DateFormat('h:mm a');
    final now = DateTime.now();
    final canCancel = session.startTime.isAfter(now);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      elevation: AppTheme.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        side: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session type banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.paddingSmall,
              horizontal: AppTheme.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: _getTypeColor(session.type),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadiusRegular),
                topRight: Radius.circular(AppTheme.borderRadiusRegular),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getTypeText(session.type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    'Booked',
                    style: TextStyle(
                      color: _getTypeColor(session.type),
                      fontSize: AppTheme.fontSizeXSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Session details
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingSmall),
                
                Text(
                  'by ${session.instructorName}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormatter.format(session.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${timeFormatter.format(session.startTime)} - ${timeFormatter.format(session.endTime)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingSmall),
                
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.location,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingRegular),
                
                // Time left until session
                if (session.startTime.isAfter(now)) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.infoLightColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: AppTheme.infoColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Starts in ${_getTimeUntil(session.startTime)}',
                            style: const TextStyle(
                              color: AppTheme.infoColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingRegular),
                ],
                
                // Session is in the past
                if (session.isPast) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.textLightColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: AppTheme.textSecondaryColor,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This session has ended',
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingRegular),
                ],
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewDetails,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingRegular),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canCancel ? onCancel : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(canCancel ? 'Cancel Booking' : 'Cannot Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactSessionCard({
    required SessionModel session,
    required bool isBooked,
    required VoidCallback onTap,
  }) {
    final timeFormatter = DateFormat('h:mm a');
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
        elevation: AppTheme.elevationXSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
          side: isBooked 
              ? const BorderSide(color: AppTheme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(session.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Icon(
                  _getTypeIcon(session.type),
                  color: _getTypeColor(session.type),
                ),
              ),
              const SizedBox(width: AppTheme.spacingRegular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${timeFormatter.format(session.startTime)} - ${timeFormatter.format(session.endTime)} • ${session.location}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
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
                    color: session.isFull ? AppTheme.errorLightColor : AppTheme.successLightColor,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    session.isFull 
                        ? 'Full'
                        : '${session.availableSpots} left',
                    style: TextStyle(
                      color: session.isFull ? AppTheme.errorColor : AppTheme.successColor,
                      fontSize: AppTheme.fontSizeXSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _bookSession(
    SessionModel session,
    AuthProvider authProvider,
    CreditProvider creditProvider,
    SessionProvider sessionProvider,
  ) async {
    // Check prerequisites before showing dialog
    if (session.isFull) {
      _showErrorDialog('This session is already full.');
      return;
    }
    
    if (!creditProvider.hasSufficientCredits(1)) {
      _showInsufficientCreditsDialog();
      return;
    }
    
    // Show booking confirmation dialog
    final shouldBook = await showDialog<bool>(
      context: context,
      builder: (context) => _buildBookingConfirmationDialog(session),
    );
    
    if (shouldBook == true && mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppTheme.spacingMedium),
              Text('Booking your session...'),
            ],
          ),
        ),
      );
      
      // Attempt to book session
      final success = await sessionProvider.bookSession(
        session.id,
        authProvider.currentUser!.id,
      );
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Show result
      if (success && mounted) {
        _showSuccessDialog(
          'Session Booked!',
          'You have successfully booked "${session.title}". You can view your booking details in the My Bookings tab.',
          () {
            // Navigate to my bookings tab
            _tabController.animateTo(1);
          },
        );
      } else if (mounted) {
        _showErrorDialog(
          sessionProvider.error ?? 'Failed to book session. Please try again later.',
        );
      }
    }
  }
  
  void _cancelBooking(
    SessionModel session,
    AuthProvider authProvider,
    SessionProvider sessionProvider,
  ) async {
    // Confirm cancellation
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => _buildCancellationConfirmationDialog(session),
    );
    
    if (shouldCancel == true && mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppTheme.spacingMedium),
              Text('Cancelling your booking...'),
            ],
          ),
        ),
      );
      
      // Attempt to cancel booking
      final success = await sessionProvider.cancelBooking(
        session.id,
        authProvider.currentUser!.id,
      );
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Show result
      if (success && mounted) {
        _showSuccessDialog(
          'Booking Cancelled',
          'Your booking for "${session.title}" has been cancelled successfully.',
          null,
        );
      } else if (mounted) {
        _showErrorDialog(
          sessionProvider.error ?? 'Failed to cancel booking. Please try again later.',
        );
      }
    }
  }
  
  void _viewSessionDetails(SessionModel session) {
    Navigator.pushNamed(
      context,
      '/sessions/details',
      arguments: session,
    );
  }
  
  Widget _buildBookingConfirmationDialog(SessionModel session) {
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    
    return AlertDialog(
      title: const Text('Confirm Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'re about to book the following session:',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            session.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.fontSizeMedium,
            ),
          ),
          Text('by ${session.instructorName}'),
          const SizedBox(height: AppTheme.spacingRegular),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.textLightColor,
              ),
              const SizedBox(width: 8),
              Text(dateFormatter.format(session.startTime)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.textLightColor,
              ),
              const SizedBox(width: 8),
              Text('${timeFormatter.format(session.startTime)} - ${timeFormatter.format(session.endTime)}'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.textLightColor,
              ),
              const SizedBox(width: 8),
              Text(session.location),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          const Divider(),
          const SizedBox(height: AppTheme.spacingSmall),
          Row(
            children: [
              const Icon(
                Icons.credit_card,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'This booking will cost:',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const Spacer(),
              const Text(
                '1 Credit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            decoration: BoxDecoration(
              color: AppTheme.infoLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppTheme.infoColor,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can cancel up to 24 hours before the session starts for a full refund.',
                    style: TextStyle(
                      color: AppTheme.infoColor,
                      fontSize: AppTheme.fontSizeSmall,
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
            backgroundColor: AppTheme.primaryColor,
          ),
          child: const Text('Confirm Booking'),
        ),
      ],
    );
  }
  
  Widget _buildCancellationConfirmationDialog(SessionModel session) {
    final now = DateTime.now();
    final hoursDifference = session.startTime.difference(now).inHours;
    final willGetRefund = hoursDifference >= 24;
    
    return AlertDialog(
      title: const Text('Cancel Booking?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to cancel your booking for "${session.title}"?',
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            decoration: BoxDecoration(
              color: willGetRefund 
                  ? AppTheme.successLightColor
                  : AppTheme.warningLightColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  willGetRefund ? Icons.check_circle : Icons.warning,
                  color: willGetRefund ? AppTheme.successColor : AppTheme.warningColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    willGetRefund
                        ? 'You will receive a full refund of 1 credit.'
                        : 'Cancellations less than 24 hours before the session do not qualify for a refund.',
                    style: TextStyle(
                      color: willGetRefund ? AppTheme.successColor : AppTheme.warningColor,
                      fontSize: AppTheme.fontSizeSmall,
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
          child: const Text('Keep Booking'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('Cancel Booking'),
        ),
      ],
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    SessionType? tempSelectedType = _selectedType;
    bool tempShowOnlyAvailable = _showOnlyAvailable;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Sessions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Wrap(
                spacing: AppTheme.spacingSmall,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: tempSelectedType == null,
                    onSelected: (selected) {
                      setState(() {
                        tempSelectedType = null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Personal'),
                    selected: tempSelectedType == SessionType.personal,
                    onSelected: (selected) {
                      setState(() {
                        tempSelectedType = selected ? SessionType.personal : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Group'),
                    selected: tempSelectedType == SessionType.group,
                    onSelected: (selected) {
                      setState(() {
                        tempSelectedType = selected ? SessionType.group : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Workshop'),
                    selected: tempSelectedType == SessionType.workshop,
                    onSelected: (selected) {
                      setState(() {
                        tempSelectedType = selected ? SessionType.workshop : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Event'),
                    selected: tempSelectedType == SessionType.event,
                    onSelected: (selected) {
                      setState(() {
                        tempSelectedType = selected ? SessionType.event : null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Row(
                children: [
                  Checkbox(
                    value: tempShowOnlyAvailable,
                    onChanged: (value) {
                      setState(() {
                        tempShowOnlyAvailable = value ?? false;
                      });
                    },
                  ),
                  const Text('Show only available sessions'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tempSelectedType = null;
                  tempShowOnlyAvailable = true;
                });
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedType = tempSelectedType;
                  _showOnlyAvailable = tempShowOnlyAvailable;
                });
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
  
  void _showSearchDialog(BuildContext context) {
    final textController = TextEditingController(text: _searchQuery);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Sessions'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter keywords to search...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = textController.text.isNotEmpty
                    ? textController.text
                    : null;
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    ).then((_) {
      textController.dispose();
    });
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showInsufficientCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Credits'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card_off,
              color: AppTheme.errorColor,
              size: 48,
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'You don\'t have enough credits to book this session.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Each session requires 1 credit to book.',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: AppTheme.fontSizeSmall,
              ),
              textAlign: TextAlign.center,
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
              Navigator.pushNamed(context, '/credits/purchase');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessDialog(String title, String message, VoidCallback? onClose) {
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
            const SizedBox(height: AppTheme.spacingMedium),
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
              if (onClose != null) {
                onClose();
              }
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
  
  String _getTypeText(SessionType type) {
    switch (type) {
      case SessionType.personal:
        return 'Personal Training';
      case SessionType.group:
        return 'Group Session';
      case SessionType.workshop:
        return 'Workshop';
      case SessionType.event:
        return 'Special Event';
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
  
  Color _getLevelColor(String level) {
    final lowerLevel = level.toLowerCase();
    if (lowerLevel.contains('beginner')) {
      return Colors.green;
    } else if (lowerLevel.contains('intermediate')) {
      return Colors.orange;
    } else if (lowerLevel.contains('advanced')) {
      return Colors.red;
    } else {
      return AppTheme.primaryColor;
    }
  }
  
  String _getTimeUntil(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''}';
    }
  }
}