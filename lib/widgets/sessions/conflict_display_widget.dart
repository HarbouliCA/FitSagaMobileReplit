import 'package:flutter/material.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Widget to display session conflicts with visual indicators
class ConflictDisplayWidget extends StatelessWidget {
  final List<SessionModel> conflicts;
  final SessionModel proposedSession;
  final VoidCallback? onResolve;

  const ConflictDisplayWidget({
    Key? key,
    required this.conflicts,
    required this.proposedSession,
    this.onResolve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conflicts.length == 1
                          ? '1 Scheduling Conflict Detected'
                          : '${conflicts.length} Scheduling Conflicts Detected',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeMedium,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getConflictDescription(),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Timeline visualization
          _buildTimelineVisual(),
          
          const SizedBox(height: 16),
          
          // Conflict details
          ..._buildConflictList(),
          
          const SizedBox(height: 16),
          
          if (onResolve != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Change Time/Date'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  String _getConflictDescription() {
    bool hasInstructorConflict = false;
    bool hasParticipantConflict = false;
    
    for (final conflict in conflicts) {
      if (conflict.instructorId == proposedSession.instructorId) {
        hasInstructorConflict = true;
      }
      
      if (conflict.participantIds.any((id) => proposedSession.participantIds.contains(id))) {
        hasParticipantConflict = true;
      }
    }
    
    if (hasInstructorConflict && hasParticipantConflict) {
      return 'Both instructor and participant schedule conflicts';
    } else if (hasInstructorConflict) {
      return 'Instructor is already scheduled for another session';
    } else if (hasParticipantConflict) {
      return 'Some participants are already booked for another session';
    } else {
      return 'Time conflict with existing sessions';
    }
  }
  
  Widget _buildTimelineVisual() {
    // Sort conflicts by start time
    final sortedSessions = [...conflicts, proposedSession]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Find earliest and latest session times for our timeline
    final earliestTime = sortedSessions.first.startTime;
    final latestEndTime = sortedSessions
        .map((s) => s.endTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    
    // Calculate total duration in minutes
    final totalMinutes = latestEndTime.difference(earliestTime).inMinutes;
    if (totalMinutes <= 0) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Overlap',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.fontSizeSmall,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Stack(
            children: [
              // Time markers
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        DateFormat('h:mm a').format(earliestTime),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        DateFormat('h:mm a').format(latestEndTime),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Session bars
              ...sortedSessions.map((session) {
                // Calculate position and width based on time
                final startOffset = session.startTime
                    .difference(earliestTime)
                    .inMinutes / totalMinutes;
                final duration = session.endTime
                    .difference(session.startTime)
                    .inMinutes / totalMinutes;
                
                final left = startOffset * 100; // Percentage
                final width = duration * 100; // Percentage
                
                // Determine color based on if this is proposed session
                final isProposed = session.id == proposedSession.id;
                final color = isProposed ? AppTheme.warningColor : AppTheme.errorColor;
                
                return Positioned(
                  left: left * 0.01 * MediaQuery.of(context).size.width,
                  top: isProposed ? 10 : 30,
                  child: Container(
                    width: width * 0.01 * MediaQuery.of(context).size.width,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(
                        color: color,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Center(
                      child: Text(
                        isProposed ? 'New Session' : 'Existing',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildConflictList() {
    return conflicts.map((conflict) {
      // Determine conflict type icon
      IconData icon;
      if (conflict.instructorId == proposedSession.instructorId) {
        icon = Icons.person;
      } else if (conflict.participantIds.any((id) => proposedSession.participantIds.contains(id))) {
        icon = Icons.group;
      } else {
        icon = Icons.access_time;
      }
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.errorColor,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conflict.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instructor: ${conflict.instructorName}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('EEE, MMM d').format(conflict.startTime)} • '
                    '${DateFormat('h:mm a').format(conflict.startTime)} - '
                    '${DateFormat('h:mm a').format(conflict.endTime)}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}