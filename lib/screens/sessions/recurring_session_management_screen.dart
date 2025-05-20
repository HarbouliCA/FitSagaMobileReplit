import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/providers/session_provider.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

class RecurringSessionManagementScreen extends StatefulWidget {
  final String parentSessionId;

  const RecurringSessionManagementScreen({
    Key? key,
    required this.parentSessionId,
  }) : super(key: key);

  @override
  State<RecurringSessionManagementScreen> createState() => _RecurringSessionManagementScreenState();
}

class _RecurringSessionManagementScreenState extends State<RecurringSessionManagementScreen> {
  bool _isLoading = false;
  String? _error;
  
  // For bulk edit
  String _title = '';
  String _description = '';
  int _durationMinutes = 60;
  int _maxParticipants = 10;
  int _creditCost = 1;
  String? _location;
  
  // Selected sessions for batch operations
  final Set<String> _selectedSessions = {};
  bool _selectAll = false;
  
  @override
  void initState() {
    super.initState();
    _loadParentSession();
  }
  
  Future<void> _loadParentSession() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      
      // Get parent session
      final parentSession = sessionProvider.getSessionById(widget.parentSessionId);
      if (parentSession == null) {
        throw Exception('Parent session not found');
      }
      
      // Initialize form values with parent session data
      setState(() {
        _title = parentSession.title;
        _description = parentSession.description;
        _durationMinutes = parentSession.durationMinutes;
        _maxParticipants = parentSession.maxParticipants;
        _creditCost = parentSession.creditCost;
        _location = parentSession.location;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateAllSessions() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final success = await sessionProvider.updateAllRecurringInstances(
        widget.parentSessionId,
        title: _title,
        description: _description,
        durationMinutes: _durationMinutes,
        maxParticipants: _maxParticipants,
        creditCost: _creditCost,
        location: _location,
      );
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All sessions updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        throw Exception(sessionProvider.error ?? 'Failed to update sessions');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _cancelSelectedSessions() async {
    if (_selectedSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sessions selected'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Selected Sessions'),
        content: Text(
          'Are you sure you want to cancel ${_selectedSessions.length} selected sessions?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel Selected'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      
      // Cancel each selected session
      for (final sessionId in _selectedSessions) {
        await sessionProvider.cancelSession(sessionId);
      }
      
      setState(() {
        _isLoading = false;
        _selectedSessions.clear();
        _selectAll = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected sessions cancelled successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _cancelAllSessions() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Sessions'),
        content: const Text(
          'Are you sure you want to cancel this and all future recurring sessions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      
      final success = await sessionProvider.cancelAllRecurringInstances(widget.parentSessionId);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All recurring sessions cancelled'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        throw Exception(sessionProvider.error ?? 'Failed to cancel sessions');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _toggleSelectAll(bool? value) {
    if (value == null) return;
    
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final childSessions = sessionProvider.getRecurringSessionInstances(widget.parentSessionId);
    
    setState(() {
      _selectAll = value;
      _selectedSessions.clear();
      
      if (value) {
        // Only add upcoming sessions to selection
        for (final session in childSessions) {
          if (session.status == SessionStatus.upcoming) {
            _selectedSessions.add(session.id);
          }
        }
      }
    });
  }
  
  void _toggleSessionSelection(String sessionId, bool selected) {
    setState(() {
      if (selected) {
        _selectedSessions.add(sessionId);
      } else {
        _selectedSessions.remove(sessionId);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final parentSession = sessionProvider.getSessionById(widget.parentSessionId);
    
    if (parentSession == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recurring Sessions'),
        ),
        body: const Center(
          child: Text('Session not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Recurring Sessions'),
        actions: [
          if (_selectedSessions.isNotEmpty)
            TextButton.icon(
              onPressed: _cancelSelectedSessions,
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: Text(
                'Cancel Selected (${_selectedSessions.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Processing...')
          : _buildBody(sessionProvider, parentSession),
    );
  }
  
  Widget _buildBody(SessionProvider sessionProvider, SessionModel parentSession) {
    final instances = sessionProvider.getRecurringSessionInstances(widget.parentSessionId);
    final upcomingInstances = instances.where((s) => s.status == SessionStatus.upcoming).toList();
    
    return Column(
      children: [
        // Parent session info
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parentSession.title,
                style: const TextStyle(
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.repeat,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recurring Pattern: ${_formatRecurringRule(parentSession.recurringRule)}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${instances.length} total instances, ${upcomingInstances.length} upcoming',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // Bulk operations
        if (upcomingInstances.isNotEmpty)
          Card(
            margin: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bulk Edit Upcoming Sessions',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _title,
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Other fields could be added here
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Duration (min)',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _durationMinutes.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _durationMinutes = int.tryParse(value) ?? _durationMinutes;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Max Participants',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _maxParticipants.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _maxParticipants = int.tryParse(value) ?? _maxParticipants;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Credit Cost',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _creditCost.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _creditCost = int.tryParse(value) ?? _creditCost;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _cancelAllSessions,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                        child: const Text('Cancel All Sessions'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _updateAllSessions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Update All Sessions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        
        // Session instances list
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium, 
            vertical: AppTheme.paddingSmall,
          ),
          child: Row(
            children: [
              const Text(
                'Session Instances',
                style: TextStyle(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Select all checkbox
              if (upcomingInstances.isNotEmpty)
                Row(
                  children: [
                    Checkbox(
                      value: _selectAll,
                      onChanged: _toggleSelectAll,
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Text('Select All Upcoming'),
                  ],
                ),
            ],
          ),
        ),
        
        Expanded(
          child: instances.isEmpty
              ? const Center(
                  child: Text(
                    'No recurring sessions found',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: instances.length,
                  itemBuilder: (context, index) {
                    final session = instances[index];
                    return _buildSessionItem(session);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildSessionItem(SessionModel session) {
    final bool canSelect = session.status == SessionStatus.upcoming;
    final bool isSelected = _selectedSessions.contains(session.id);
    
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
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          children: [
            // Checkbox for selection
            if (canSelect)
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleSessionSelection(session.id, value ?? false),
                activeColor: AppTheme.primaryColor,
              ),
            
            // Session info
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
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: statusColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEE, MMM d, y').format(session.startTime),
                        style: TextStyle(
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        color: statusColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(session.startTime),
                        style: TextStyle(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        child: Text(
                          _getStatusText(session.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: AppTheme.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${session.participantIds.length}/${session.maxParticipants} enrolled',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action button
            if (canSelect)
              IconButton(
                icon: const Icon(Icons.edit),
                color: AppTheme.primaryColor,
                onPressed: () {
                  // Navigate to edit a single instance
                  Navigator.pushNamed(
                    context,
                    '/sessions/edit',
                    arguments: session,
                  ).then((value) {
                    if (value == true) {
                      // Refresh the list
                      setState(() {});
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
  
  String _formatRecurringRule(String? rule) {
    if (rule == null || rule.isEmpty) {
      return 'Unknown';
    }
    
    // Parse the RRULE format
    Map<String, String> ruleMap = {};
    for (var part in rule.split(';')) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        ruleMap[keyValue[0]] = keyValue[1];
      }
    }
    
    final freq = ruleMap['FREQ'];
    if (freq == null) {
      return 'Unknown';
    }
    
    String result = '';
    
    switch (freq) {
      case 'DAILY':
        result = 'Daily';
        break;
      case 'WEEKLY':
        result = 'Weekly';
        
        final byDay = ruleMap['BYDAY']?.split(',');
        if (byDay != null && byDay.isNotEmpty) {
          const dayNames = {
            'MO': 'Monday',
            'TU': 'Tuesday',
            'WE': 'Wednesday',
            'TH': 'Thursday',
            'FR': 'Friday',
            'SA': 'Saturday',
            'SU': 'Sunday',
          };
          
          final days = byDay.map((day) => dayNames[day] ?? day).join(', ');
          result += ' on $days';
        }
        break;
      case 'MONTHLY':
        result = 'Monthly';
        break;
      case 'YEARLY':
        result = 'Yearly';
        break;
      default:
        result = freq;
    }
    
    return result;
  }
  
  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.upcoming:
        return 'Upcoming';
      case SessionStatus.ongoing:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }
}