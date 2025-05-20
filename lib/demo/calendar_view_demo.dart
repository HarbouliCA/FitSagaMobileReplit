import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/demo/session_detail_demo.dart';

class CalendarViewDemo extends StatefulWidget {
  final List<SessionModel> sessions;

  const CalendarViewDemo({
    Key? key,
    required this.sessions,
  }) : super(key: key);

  @override
  State<CalendarViewDemo> createState() => _CalendarViewDemoState();
}

class _CalendarViewDemoState extends State<CalendarViewDemo> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeekDays();
  }

  void _generateWeekDays() {
    // Find the previous Monday (or today if it's Monday)
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    
    // Generate days from Monday to Sunday
    _weekDays = List.generate(7, (index) {
      final startOfWeek = now.subtract(Duration(days: dayOfWeek - 1));
      return startOfWeek.add(Duration(days: index));
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter sessions for the selected date
    final filteredSessions = widget.sessions
        .where((session) => _isSameDay(session.date, _selectedDate))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Filter Options'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterOption('All Activities', true),
                      _buildFilterOption('HIIT', false),
                      _buildFilterOption('Yoga', false),
                      _buildFilterOption('Strength', false),
                      _buildFilterOption('Cardio', false),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekly calendar header
          _buildWeeklyCalendar(),
          
          // Filter chips
          _buildFilterChips(),
          
          // Heading for today/selected day
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  _isSameDay(_selectedDate, DateTime.now()) 
                      ? 'Today' 
                      : DateFormat('EEEE, MMMM d').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          
          // Session list
          Expanded(
            child: filteredSessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(filteredSessions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _weekDays.map((day) {
          final isSelected = _isSameDay(day, _selectedDate);
          final isToday = _isSameDay(day, DateTime.now());
          
          return GestureDetector(
            onTap: () => _selectDate(day),
            child: Container(
              width: 40,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.2) 
                    : (isToday ? Colors.amber.shade200 : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).toLowerCase().substring(0, 2),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.black,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('All Classes', true),
          _buildChip('HIIT', false),
          _buildChip('Yoga', false),
          _buildChip('Strength', false),
          _buildChip('Instructors', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          // Would implement filter logic here
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailDemo(
                session: session,
                user: UserModel(
                  id: 'user123',
                  name: 'John Doe',
                  gymCredits: 10,
                  intervalCredits: 5,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Session image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: session.imageUrl != null
                    ? Image.network(
                        session.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                        ),
                      ),
              ),
              
              const SizedBox(width: 12),
              
              // Session details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${session.formattedStartTime} • ${session.durationMinutes} min',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${session.bookedCount}/${session.capacity} participants',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Session tag/status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: session.hasAvailableSlots
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: session.hasAvailableSlots
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  session.hasAvailableSlots ? 'OPEN' : 'FULL',
                  style: TextStyle(
                    color: session.hasAvailableSlots ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
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
                'No sessions scheduled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting another day',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}