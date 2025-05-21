import React from 'react';
import { StyleSheet, View, TouchableOpacity } from 'react-native';
import { Card, Text, Avatar, Badge, Chip } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { theme, typography, spacing } from '../../theme';

interface SessionCardProps {
  id: string;
  title: string;
  activityType: string;
  startTime: Date;
  endTime: Date;
  instructorName: string;
  instructorPhotoURL?: string;
  capacity: number;
  enrolledCount: number;
  creditCost: number;
  location?: string;
  onPress?: () => void;
  compact?: boolean;
}

const SessionCard: React.FC<SessionCardProps> = ({
  id,
  title,
  activityType,
  startTime,
  endTime,
  instructorName,
  instructorPhotoURL,
  capacity,
  enrolledCount,
  creditCost,
  location,
  onPress,
  compact = false,
}) => {
  // Format time for display
  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    });
  };

  // Format date for display
  const formatDate = (date: Date) => {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === tomorrow.toDateString()) {
      return 'Tomorrow';
    } else {
      return date.toLocaleDateString('en-US', {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
      });
    }
  };

  // Get color for activity type
  const getActivityColor = (type: string) => {
    switch (type.toLowerCase()) {
      case 'yoga':
        return '#8E44AD';
      case 'cardio':
        return '#E74C3C';
      case 'strength':
        return '#3498DB';
      case 'crossfit':
        return '#F39C12';
      case 'kickboxing':
        return '#D35400';
      default:
        return theme.colors.primary;
    }
  };

  // Calculate availability
  const availableSpots = capacity - enrolledCount;
  const availabilityText = availableSpots === 0 
    ? 'Full' 
    : `${availableSpots} spot${availableSpots !== 1 ? 's' : ''} left`;
  
  // Determine availability color
  const getAvailabilityColor = () => {
    if (availableSpots === 0) return theme.colors.error;
    if (availableSpots <= 3) return theme.colors.warning;
    return theme.colors.success;
  };

  if (compact) {
    // Compact version for lists
    return (
      <TouchableOpacity onPress={onPress} style={styles.touchable}>
        <Card style={styles.compactCard}>
          <Card.Content style={styles.compactContent}>
            <View style={styles.compactTimeContainer}>
              <Text style={styles.compactTime}>{formatTime(startTime)}</Text>
              <Text style={styles.compactDay}>{formatDate(startTime)}</Text>
            </View>
            <View style={styles.compactDetailsContainer}>
              <Text style={styles.compactTitle}>{title}</Text>
              <Text style={styles.compactInstructor}>{instructorName}</Text>
              <View style={styles.compactFooter}>
                <Chip 
                  style={[styles.compactChip, { backgroundColor: getActivityColor(activityType) }]}
                  textStyle={styles.chipText}
                >
                  {activityType}
                </Chip>
                <Badge style={[styles.badge, { backgroundColor: getAvailabilityColor() }]}>
                  {availabilityText}
                </Badge>
              </View>
            </View>
            <View style={styles.compactCreditsContainer}>
              <Text style={styles.creditText}>{creditCost}</Text>
              <Text style={styles.creditLabel}>credit{creditCost !== 1 ? 's' : ''}</Text>
            </View>
          </Card.Content>
        </Card>
      </TouchableOpacity>
    );
  }

  // Full version for detailed view
  return (
    <TouchableOpacity onPress={onPress} style={styles.touchable}>
      <Card style={styles.card}>
        <Card.Content>
          <View style={styles.header}>
            <Chip 
              style={[styles.activityChip, { backgroundColor: getActivityColor(activityType) }]}
              textStyle={styles.chipText}
            >
              {activityType}
            </Chip>
            <Badge style={[styles.creditBadge, { backgroundColor: theme.colors.primary }]}>
              {creditCost} credit{creditCost !== 1 ? 's' : ''}
            </Badge>
          </View>
          
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.timeText}>
            {formatDate(startTime)}, {formatTime(startTime)} - {formatTime(endTime)}
          </Text>
          
          {location && (
            <View style={styles.locationContainer}>
              <MaterialCommunityIcons name="map-marker" size={16} color={theme.colors.placeholder} />
              <Text style={styles.locationText}>{location}</Text>
            </View>
          )}
          
          <View style={styles.footer}>
            <View style={styles.instructorContainer}>
              {instructorPhotoURL ? (
                <Avatar.Image 
                  source={{ uri: instructorPhotoURL }} 
                  size={24} 
                  style={styles.instructorImage}
                />
              ) : (
                <Avatar.Icon 
                  icon="account" 
                  size={24} 
                  style={styles.instructorIcon} 
                  color="white" 
                />
              )}
              <Text style={styles.instructorText}>{instructorName}</Text>
            </View>
            
            <View style={styles.capacityContainer}>
              <Text style={[styles.capacityText, { color: getAvailabilityColor() }]}>
                {availabilityText}
              </Text>
              <Text style={styles.totalCapacity}>
                ({enrolledCount}/{capacity})
              </Text>
            </View>
          </View>
        </Card.Content>
      </Card>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  touchable: {
    marginBottom: spacing.m,
  },
  card: {
    backgroundColor: theme.colors.surface,
    elevation: 2,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.s,
  },
  activityChip: {
    height: 24,
  },
  chipText: {
    color: 'white',
    fontSize: 12,
  },
  creditBadge: {
    fontSize: 12,
  },
  title: {
    ...typography.h3,
    marginBottom: spacing.xs,
  },
  timeText: {
    color: theme.colors.placeholder,
    marginBottom: spacing.s,
  },
  locationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.s,
  },
  locationText: {
    color: theme.colors.placeholder,
    marginLeft: spacing.xs,
    fontSize: 12,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: spacing.s,
  },
  instructorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  instructorImage: {
    marginRight: spacing.xs,
  },
  instructorIcon: {
    marginRight: spacing.xs,
    backgroundColor: theme.colors.primary,
  },
  instructorText: {
    fontSize: 12,
    fontWeight: '500',
  },
  capacityContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  capacityText: {
    fontSize: 12,
    fontWeight: '500',
  },
  totalCapacity: {
    fontSize: 12,
    color: theme.colors.placeholder,
    marginLeft: spacing.xs,
  },
  // Compact styles
  compactCard: {
    backgroundColor: theme.colors.surface,
    elevation: 2,
  },
  compactContent: {
    flexDirection: 'row',
    padding: spacing.s,
  },
  compactTimeContainer: {
    width: 60,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.m,
  },
  compactTime: {
    fontWeight: 'bold',
    fontSize: 14,
  },
  compactDay: {
    fontSize: 12,
    color: theme.colors.placeholder,
  },
  compactDetailsContainer: {
    flex: 1,
  },
  compactTitle: {
    ...typography.subtitle1,
    marginBottom: 2,
  },
  compactInstructor: {
    fontSize: 12,
    color: theme.colors.placeholder,
    marginBottom: spacing.xs,
  },
  compactChip: {
    height: 20,
    marginRight: spacing.s,
  },
  compactFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.xs,
  },
  badge: {
    fontSize: 10,
  },
  compactCreditsContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 50,
  },
  creditText: {
    fontWeight: 'bold',
    fontSize: 18,
    color: theme.colors.primary,
  },
  creditLabel: {
    fontSize: 10,
    color: theme.colors.placeholder,
  },
});

export default SessionCard;