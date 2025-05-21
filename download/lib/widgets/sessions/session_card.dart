import 'package:flutter/material.dart';
import 'package:fitsaga/models/session_model.dart';
import 'package:fitsaga/theme/app_theme.dart';
import 'package:fitsaga/utils/date_formatter.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;
  final bool showBookingStatus;
  final bool isBooked;
  
  const SessionCard({
    Key? key,
    required this.session,
    required this.onTap,
    this.showBookingStatus = false,
    this.isBooked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine background color based on activity type
    Color cardColor = AppTheme.cardColor;
    Color tagColor;
    IconData activityIcon;
    
    switch (session.activityType) {
      case 'ENTREMIENTO_PERSONAL':
        tagColor = Colors.purple;
        activityIcon = Icons.person;
        break;
      case 'KICK_BOXING':
        tagColor = Colors.red;
        activityIcon = Icons.sports_mma;
        break;
      case 'SALE_FITNESS':
        tagColor = Colors.green;
        activityIcon = Icons.fitness_center;
        break;
      case 'CLASES_DERIGIDAS':
        tagColor = Colors.blue;
        activityIcon = Icons.groups;
        break;
      default:
        tagColor = AppTheme.primaryColor;
        activityIcon = Icons.fitness_center;
    }
    
    // Session status indicator
    Color statusColor;
    String statusText;
    
    if (session.status == 'cancelled') {
      statusColor = AppTheme.errorColor;
      statusText = 'Cancelled';
    } else if (session.isFull) {
      statusColor = AppTheme.warningColor;
      statusText = 'Full';
    } else if (session.isAvailable) {
      statusColor = AppTheme.successColor;
      statusText = 'Available';
    } else {
      statusColor = AppTheme.secondaryColor;
      statusText = 'In progress';
    }
    
    return Card(
      elevation: AppTheme.elevationSmall,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingRegular,
        vertical: AppTheme.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        side: BorderSide(
          color: isBooked ? AppTheme.primaryColor : Colors.transparent,
          width: isBooked ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session header with activity type and date
            Container(
              decoration: BoxDecoration(
                color: tagColor.withValues(color: tagColor, opacity: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusRegular),
                  topRight: Radius.circular(AppTheme.borderRadiusRegular),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingRegular,
                vertical: AppTheme.paddingSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Activity type
                  Row(
                    children: [
                      Icon(
                        activityIcon,
                        size: 18,
                        color: tagColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.activityName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // Date
                  Text(
                    DateFormatter.formatSessionDate(session.startTime),
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            
            // Session details
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingRegular),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session title or name
                  Text(
                    session.title ?? session.activityName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  // Instructor info
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Instructor: ${session.instructorName}',
                          style: const TextStyle(
                            color: AppTheme.textLightColor,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingSmall),
                  
                  // Time info
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatSessionTimeRange(
                          session.startTime, 
                          session.endTime
                        ),
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.timelapse,
                        size: 16,
                        color: AppTheme.textLightColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDuration(
                          session.sessionDuration.inMinutes
                        ),
                        style: const TextStyle(
                          color: AppTheme.textLightColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingRegular),
                  
                  // Status footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status and availability
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: AppTheme.fontSizeSmall,
                            ),
                          ),
                          if (session.isAvailable) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${session.availableSpots} spots left',
                              style: const TextStyle(
                                color: AppTheme.textLightColor,
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // Credit cost
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(color: AppTheme.primaryColor, opacity: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${session.requiredCredits}',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Booking status badge
                  if (showBookingStatus && isBooked) ...[
                    const SizedBox(height: AppTheme.spacingRegular),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'BOOKED',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppTheme.fontSizeSmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactSessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;
  
  const CompactSessionCard({
    Key? key,
    required this.session,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Choose color based on activity type
    Color tagColor;
    
    switch (session.activityType) {
      case 'ENTREMIENTO_PERSONAL':
        tagColor = Colors.purple;
        break;
      case 'KICK_BOXING':
        tagColor = Colors.red;
        break;
      case 'SALE_FITNESS':
        tagColor = Colors.green;
        break;
      case 'CLASES_DERIGIDAS':
        tagColor = Colors.blue;
        break;
      default:
        tagColor = AppTheme.primaryColor;
    }
    
    return Card(
      elevation: AppTheme.elevationSmall,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingSmall,
        vertical: AppTheme.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingRegular),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time column
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormatter.formatTime(session.startTime),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.fontSizeRegular,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 2,
                    height: 8,
                    color: AppTheme.textLightColor.withValues(color: AppTheme.textLightColor, opacity: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatTime(session.endTime),
                    style: TextStyle(
                      color: AppTheme.textLightColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: AppTheme.spacingLarge),
              
              // Session details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Activity tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(color: tagColor, opacity: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall
                        ),
                      ),
                      child: Text(
                        session.activityName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppTheme.fontSizeSmall,
                          color: tagColor,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Session title
                    Text(
                      session.title ?? 'Session with ${session.instructorName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontSizeRegular,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Instructor
                    Text(
                      'Instructor: ${session.instructorName}',
                      style: const TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: AppTheme.fontSizeSmall,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: AppTheme.spacingRegular),
              
              // Credits
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.stars,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  Text(
                    '${session.requiredCredits}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
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
}
