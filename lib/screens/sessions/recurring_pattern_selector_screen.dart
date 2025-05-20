import 'package:flutter/material.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Screen for selecting and configuring recurring patterns for sessions
class RecurringPatternSelectorScreen extends StatefulWidget {
  final String? initialPattern;
  final DateTime referenceDate;

  const RecurringPatternSelectorScreen({
    Key? key,
    this.initialPattern,
    required this.referenceDate,
  }) : super(key: key);

  @override
  State<RecurringPatternSelectorScreen> createState() => _RecurringPatternSelectorScreenState();
}

class _RecurringPatternSelectorScreenState extends State<RecurringPatternSelectorScreen> {
  late String _frequencyType;
  late List<bool> _selectedDays;
  late int _monthlyOption;
  late int _occurrences;
  late bool _hasEndDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    
    // Default values
    _frequencyType = 'weekly';
    _selectedDays = List.filled(7, false);
    _monthlyOption = 0; // 0 = day of month, 1 = day of week
    _occurrences = 10;
    _hasEndDate = false;
    _endDate = widget.referenceDate.add(const Duration(days: 90)); // 3 months by default
    
    // Set selected day based on reference date
    final referenceWeekday = widget.referenceDate.weekday - 1; // 0-based index
    _selectedDays[referenceWeekday] = true;
    
    // Parse initial pattern if provided
    if (widget.initialPattern != null) {
      _parseInitialPattern(widget.initialPattern!);
    }
  }
  
  // Parse RRULE format
  void _parseInitialPattern(String pattern) {
    Map<String, String> ruleMap = {};
    for (var part in pattern.split(';')) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        ruleMap[keyValue[0]] = keyValue[1];
      }
    }
    
    // Get frequency
    final freq = ruleMap['FREQ']?.toLowerCase();
    if (freq != null) {
      _frequencyType = freq;
    }
    
    // Get selected days for weekly frequency
    if (_frequencyType == 'weekly' && ruleMap.containsKey('BYDAY')) {
      const dayMap = {
        'MO': 0,
        'TU': 1,
        'WE': 2,
        'TH': 3,
        'FR': 4,
        'SA': 5,
        'SU': 6,
      };
      
      _selectedDays = List.filled(7, false);
      final days = ruleMap['BYDAY']?.split(',') ?? [];
      
      for (final day in days) {
        final index = dayMap[day];
        if (index != null) {
          _selectedDays[index] = true;
        }
      }
    }
    
    // TODO: Parse more complex patterns like monthly by position, etc.
  }
  
  // Build RRULE string
  String _buildRecurringRule() {
    String rule = 'FREQ=${_frequencyType.toUpperCase()}';
    
    // Add day selection for weekly frequency
    if (_frequencyType == 'weekly') {
      const dayAbbreviations = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      List<String> selectedDayAbbreviations = [];
      
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) {
          selectedDayAbbreviations.add(dayAbbreviations[i]);
        }
      }
      
      if (selectedDayAbbreviations.isNotEmpty) {
        rule += ';BYDAY=${selectedDayAbbreviations.join(',')}';
      }
    }
    
    // Add monthly recurrence type
    if (_frequencyType == 'monthly' && _monthlyOption == 1) {
      final weekday = widget.referenceDate.weekday;
      final weekNumber = (widget.referenceDate.day / 7).ceil();
      
      const dayAbbreviations = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
      final dayAbbr = dayAbbreviations[weekday - 1];
      
      rule += ';BYSETPOS=$weekNumber;BYDAY=$dayAbbr';
    }
    
    // Add count or end date
    if (_hasEndDate) {
      rule += ';UNTIL=${DateFormat('yyyyMMdd').format(_endDate)}T000000Z';
    } else {
      rule += ';COUNT=$_occurrences';
    }
    
    return rule;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Pattern'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop(_buildRecurringRule());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session reference info
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Creating a recurring pattern',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.infoColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Based on: ${DateFormat('EEEE, MMMM d, y').format(widget.referenceDate)} at ${DateFormat('h:mm a').format(widget.referenceDate)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Frequency type
            const Text(
              'Frequency',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Radio buttons for frequency
            _buildFrequencyOption('daily', 'Daily'),
            _buildFrequencyOption('weekly', 'Weekly'),
            _buildFrequencyOption('monthly', 'Monthly'),
            _buildFrequencyOption('yearly', 'Yearly'),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Weekly options
            if (_frequencyType == 'weekly') _buildWeeklyOptions(),
            
            // Monthly options
            if (_frequencyType == 'monthly') _buildMonthlyOptions(),
            
            // Yearly options
            if (_frequencyType == 'yearly') _buildYearlyOptions(),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // End options
            const Text(
              'End',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Occurrences
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _hasEndDate,
                  onChanged: (value) {
                    setState(() {
                      _hasEndDate = value!;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                const Text('After'),
                const SizedBox(width: 16),
                SizedBox(
                  width: 60,
                  child: DropdownButton<int>(
                    value: _occurrences,
                    onChanged: _hasEndDate
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _occurrences = value;
                              });
                            }
                          },
                    items: List.generate(
                      50,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('occurrences'),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // End date
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _hasEndDate,
                  onChanged: (value) {
                    setState(() {
                      _hasEndDate = value!;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                const Text('On date'),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _hasEndDate ? _selectEndDate : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _hasEndDate
                              ? AppTheme.primaryColor
                              : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: Text(
                        DateFormat('MMM d, y').format(_endDate),
                        style: TextStyle(
                          color: _hasEndDate
                              ? AppTheme.textPrimaryColor
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Preview
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPatternDescription(),
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                  ),
                  
                  if (_frequencyType == 'weekly' && !_selectedDays.any((selected) => selected)) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Warning: No days selected for weekly recurrence.',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  const Text(
                    'Rule Format:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildRecurringRule(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textSecondaryColor,
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
  
  Widget _buildFrequencyOption(String value, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _frequencyType = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _frequencyType,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _frequencyType = newValue;
                  });
                }
              },
              activeColor: AppTheme.primaryColor,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyOptions() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat on',
          style: TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(7, (index) {
            return _buildDaySelector(index, dayNames[index]);
          }),
        ),
      ],
    );
  }
  
  Widget _buildDaySelector(int index, String label) {
    final isSelected = _selectedDays[index];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDays[index] = !_selectedDays[index];
        });
      },
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.fontSizeSmall,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMonthlyOptions() {
    final dayOfMonth = widget.referenceDate.day;
    final weekday = DateFormat('EEEE').format(widget.referenceDate);
    final weekNumber = (widget.referenceDate.day / 7).ceil();
    String ordinal;
    
    switch (weekNumber) {
      case 1:
        ordinal = 'first';
        break;
      case 2:
        ordinal = 'second';
        break;
      case 3:
        ordinal = 'third';
        break;
      case 4:
        ordinal = 'fourth';
        break;
      default:
        ordinal = 'last';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat by',
          style: TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Day of month option
        InkWell(
          onTap: () {
            setState(() {
              _monthlyOption = 0;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Radio<int>(
                  value: 0,
                  groupValue: _monthlyOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _monthlyOption = value;
                      });
                    }
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                Text('Day $dayOfMonth of every month'),
              ],
            ),
          ),
        ),
        
        // Day of week option
        InkWell(
          onTap: () {
            setState(() {
              _monthlyOption = 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Radio<int>(
                  value: 1,
                  groupValue: _monthlyOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _monthlyOption = value;
                      });
                    }
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                Text('The $ordinal $weekday of every month'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildYearlyOptions() {
    final monthDay = DateFormat('MMMM d').format(widget.referenceDate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeats yearly on',
          style: TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            monthDay,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.fontSizeMedium,
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: widget.referenceDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // 5 years ahead
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
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }
  
  String _getPatternDescription() {
    final startDateFormatted = DateFormat.MMMMd().format(widget.referenceDate);
    final timeFormatted = DateFormat.jm().format(widget.referenceDate);
    
    switch (_frequencyType) {
      case 'daily':
        return 'Repeats every day at $timeFormatted';
        
      case 'weekly':
        if (!_selectedDays.any((selected) => selected)) {
          return 'Please select at least one day of the week';
        }
        
        final List<String> selectedDayNames = [];
        const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        
        for (int i = 0; i < _selectedDays.length; i++) {
          if (_selectedDays[i]) {
            selectedDayNames.add(dayNames[i]);
          }
        }
        
        String daysText;
        if (selectedDayNames.length == 1) {
          daysText = selectedDayNames.first;
        } else if (selectedDayNames.length == 2) {
          daysText = '${selectedDayNames.first} and ${selectedDayNames.last}';
        } else {
          final last = selectedDayNames.removeLast();
          daysText = '${selectedDayNames.join(', ')}, and $last';
        }
        
        return 'Repeats weekly on $daysText at $timeFormatted';
        
      case 'monthly':
        final dayOfMonth = widget.referenceDate.day;
        
        if (_monthlyOption == 0) {
          return 'Repeats monthly on day $dayOfMonth at $timeFormatted';
        } else {
          final weekday = DateFormat('EEEE').format(widget.referenceDate);
          final weekNumber = (widget.referenceDate.day / 7).ceil();
          String ordinal;
          
          switch (weekNumber) {
            case 1:
              ordinal = 'first';
              break;
            case 2:
              ordinal = 'second';
              break;
            case 3:
              ordinal = 'third';
              break;
            case 4:
              ordinal = 'fourth';
              break;
            default:
              ordinal = 'last';
          }
          
          return 'Repeats monthly on the $ordinal $weekday at $timeFormatted';
        }
        
      case 'yearly':
        return 'Repeats annually on $startDateFormatted at $timeFormatted';
        
      default:
        return 'Invalid frequency type';
    }
  }
}