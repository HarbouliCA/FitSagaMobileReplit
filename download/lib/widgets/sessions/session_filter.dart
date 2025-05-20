import 'package:flutter/material.dart';
import 'package:fitsaga/config/constants.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/utils/date_formatter.dart';
import 'package:intl/intl.dart';

class SessionFilter extends StatefulWidget {
  final String? selectedActivityType;
  final DateTime? selectedDate;
  final Function(String?) onActivityTypeChanged;
  final Function(DateTime?) onDateChanged;
  final Function() onClearFilters;
  
  const SessionFilter({
    Key? key,
    this.selectedActivityType,
    this.selectedDate,
    required this.onActivityTypeChanged,
    required this.onDateChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<SessionFilter> createState() => _SessionFilterState();
}

class _SessionFilterState extends State<SessionFilter> {
  late List<DateTime> _dateOptions;
  
  @override
  void initState() {
    super.initState();
    _generateDateOptions();
  }
  
  void _generateDateOptions() {
    // Generate date options for the next 7 days
    final now = DateTime.now();
    _dateOptions = List.generate(7, (index) {
      return DateTime(now.year, now.month, now.day + index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter by activity type
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingRegular,
            ),
            child: Row(
              children: [
                _buildTypeFilterChip(
                  'All', 
                  null,
                  Icons.fitness_center,
                ),
                _buildTypeFilterChip(
                  'Personal Training', 
                  AppConstants.activityTypePersonalTraining,
                  Icons.person,
                ),
                _buildTypeFilterChip(
                  'Kick Boxing', 
                  AppConstants.activityTypeKickBoxing,
                  Icons.sports_mma,
                ),
                _buildTypeFilterChip(
                  'Sale Fitness', 
                  AppConstants.activityTypeSaleFitness,
                  Icons.fitness_center,
                ),
                _buildTypeFilterChip(
                  'Directed Classes', 
                  AppConstants.activityTypeClasesDerigidas,
                  Icons.groups,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // Filter by date
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingRegular,
            ),
            child: Row(
              children: [
                // Reset filter button
                if (widget.selectedActivityType != null || 
                    widget.selectedDate != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
                    child: ActionChip(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      avatar: const Icon(
                        Icons.clear,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      label: const Text('Clear Filters'),
                      onPressed: widget.onClearFilters,
                    ),
                  ),
                ],
                
                // Date filters
                for (var date in _dateOptions)
                  _buildDateFilterChip(date),
                
                // Custom date picker
                Padding(
                  padding: const EdgeInsets.only(left: AppTheme.paddingSmall),
                  child: ActionChip(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppTheme.textColor,
                    ),
                    avatar: const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textColor,
                    ),
                    label: const Text('Pick Date'),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: widget.selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppTheme.primaryColor,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                      if (picked != null) {
                        widget.onDateChanged(picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypeFilterChip(String label, String? activityType, IconData icon) {
    final isSelected = widget.selectedActivityType == activityType;
    
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
      child: FilterChip(
        selected: isSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        backgroundColor: Colors.grey.withOpacity(0.1),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
        ),
        label: Text(label),
        onSelected: (selected) {
          widget.onActivityTypeChanged(selected ? activityType : null);
        },
      ),
    );
  }
  
  Widget _buildDateFilterChip(DateTime date) {
    final isSelected = widget.selectedDate != null &&
        DateFormatter.isSameDay(widget.selectedDate!, date);
    
    String label = '';
    if (DateFormatter.isToday(date)) {
      label = 'Today';
    } else if (DateFormatter.isTomorrow(date)) {
      label = 'Tomorrow';
    } else {
      label = DateFormat('E, MMM d').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
      child: FilterChip(
        selected: isSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        backgroundColor: Colors.grey.withOpacity(0.1),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        label: Text(label),
        onSelected: (selected) {
          widget.onDateChanged(selected ? date : null);
        },
      ),
    );
  }
}
