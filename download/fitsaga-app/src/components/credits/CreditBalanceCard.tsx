import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Card, Title, Text, ProgressBar } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { theme, typography, spacing } from '../../theme';

interface CreditBalanceCardProps {
  gymCredits: number;
  intervalCredits: number;
  maxCredits?: number;
  lastRefilled?: Date;
  nextRefillDate?: Date;
  showDetails?: boolean;
  onPress?: () => void;
}

const CreditBalanceCard: React.FC<CreditBalanceCardProps> = ({
  gymCredits,
  intervalCredits,
  maxCredits = 12,
  lastRefilled,
  nextRefillDate,
  showDetails = true,
  onPress,
}) => {
  // Calculate percentage for progress bar
  const creditPercentage = Math.min(gymCredits / maxCredits, 1);
  
  // Determine color based on credit amount
  const getColorByCredit = () => {
    if (gymCredits <= 2) return theme.colors.error; // Red
    if (gymCredits <= 5) return theme.colors.warning; // Yellow
    return theme.colors.success; // Green
  };

  // Format date for display
  const formatDate = (date?: Date) => {
    if (!date) return 'N/A';
    
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  return (
    <Card 
      style={styles.card} 
      onPress={onPress}
      mode="elevated"
    >
      <Card.Content>
        <View style={styles.header}>
          <MaterialCommunityIcons 
            name="ticket-percent" 
            size={24} 
            color={theme.colors.primary} 
          />
          <Title style={styles.title}>Your Credits</Title>
        </View>
        
        <View style={styles.creditContainer}>
          <Text style={styles.creditLabel}>Gym Credits</Text>
          <Text style={[styles.creditValue, { color: getColorByCredit() }]}>
            {gymCredits}
          </Text>
        </View>
        
        <ProgressBar
          progress={creditPercentage}
          color={getColorByCredit()}
          style={styles.progressBar}
        />
        
        <View style={styles.intervalContainer}>
          <Text style={styles.intervalLabel}>Interval Credits</Text>
          <Text style={styles.intervalValue}>{intervalCredits}</Text>
        </View>
        
        {showDetails && (
          <View style={styles.detailsContainer}>
            {lastRefilled && (
              <Text style={styles.detailText}>
                Last refilled: {formatDate(lastRefilled)}
              </Text>
            )}
            {nextRefillDate && (
              <Text style={styles.refreshDate}>
                Next refresh: {formatDate(nextRefillDate)}
              </Text>
            )}
          </View>
        )}
      </Card.Content>
    </Card>
  );
};

const styles = StyleSheet.create({
  card: {
    margin: spacing.m,
    elevation: 4,
    backgroundColor: theme.colors.surface,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.m,
  },
  title: {
    marginLeft: spacing.s,
    fontSize: 18,
  },
  creditContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.s,
  },
  creditLabel: {
    fontSize: 16,
  },
  creditValue: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
    marginBottom: spacing.m,
  },
  intervalContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: spacing.s,
    marginBottom: spacing.m,
  },
  intervalLabel: {
    fontSize: 16,
  },
  intervalValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: theme.colors.accent,
  },
  detailsContainer: {
    marginTop: spacing.s,
  },
  detailText: {
    fontSize: 12,
    color: theme.colors.placeholder,
  },
  refreshDate: {
    fontSize: 12,
    color: theme.colors.placeholder,
    marginTop: spacing.xs,
  },
});

export default CreditBalanceCard;