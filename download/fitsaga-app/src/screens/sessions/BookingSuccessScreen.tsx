import React, { useEffect } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { Text, Button, Card, Avatar } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { useDispatch, useSelector } from 'react-redux';

import { RootState } from '../../redux/store';
import { fetchUserCredits } from '../../redux/features/creditsSlice';
import { theme, typography, spacing } from '../../theme';

// Define types for route params
type BookingSuccessRouteParams = {
  BookingSuccess: {
    sessionId: string;
    bookingId: string;
  };
};

type BookingSuccessRouteProp = RouteProp<BookingSuccessRouteParams, 'BookingSuccess'>;

const BookingSuccessScreen: React.FC = () => {
  const route = useRoute<BookingSuccessRouteProp>();
  const navigation = useNavigation();
  const dispatch = useDispatch();
  
  const { sessionId, bookingId } = route.params;
  const { user } = useSelector((state: RootState) => state.auth);
  const { credits } = useSelector((state: RootState) => state.credits);

  // Fetch updated credits on mount
  useEffect(() => {
    if (user) {
      dispatch(fetchUserCredits(user.uid));
    }
  }, [user]);

  const handleViewBooking = () => {
    navigation.navigate('BookingDetails', { bookingId });
  };

  const handleBackToSessions = () => {
    navigation.navigate('Sessions');
  };

  const handleBackToHome = () => {
    navigation.navigate('Home');
  };

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.successIconContainer}>
          <Avatar.Icon 
            icon="check-circle" 
            size={100} 
            style={styles.successIcon} 
            color="white" 
          />
        </View>
        
        <Text style={styles.successTitle}>Booking Confirmed!</Text>
        <Text style={styles.successMessage}>
          Your session has been successfully booked. You can view your booking details or return to browse more sessions.
        </Text>
        
        <Card style={styles.creditCard}>
          <Card.Content>
            <Text style={styles.creditTitle}>Credits</Text>
            <View style={styles.creditRow}>
              <MaterialCommunityIcons 
                name="ticket-percent" 
                size={24} 
                color={theme.colors.primary} 
                style={styles.creditIcon}
              />
              <View style={styles.creditInfo}>
                <Text style={styles.creditLabel}>Your remaining credits</Text>
                <Text style={styles.creditValue}>
                  {(credits.total || 0) + (credits.intervalCredits || 0)}
                </Text>
              </View>
            </View>
          </Card.Content>
        </Card>
        
        <Button
          mode="contained"
          onPress={handleViewBooking}
          style={styles.button}
        >
          View Booking
        </Button>
        
        <Button
          mode="outlined"
          onPress={handleBackToSessions}
          style={styles.button}
        >
          Browse More Sessions
        </Button>
        
        <Button
          mode="text"
          onPress={handleBackToHome}
          style={styles.textButton}
        >
          Back to Home
        </Button>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  scrollContent: {
    padding: spacing.m,
    alignItems: 'center',
  },
  successIconContainer: {
    marginTop: spacing.xl,
    marginBottom: spacing.l,
  },
  successIcon: {
    backgroundColor: theme.colors.success,
  },
  successTitle: {
    ...typography.h1,
    marginBottom: spacing.m,
    textAlign: 'center',
  },
  successMessage: {
    ...typography.body1,
    textAlign: 'center',
    marginBottom: spacing.xl,
    paddingHorizontal: spacing.m,
    color: theme.colors.placeholder,
  },
  creditCard: {
    width: '100%',
    marginBottom: spacing.xl,
    backgroundColor: theme.colors.surface,
  },
  creditTitle: {
    ...typography.subtitle1,
    marginBottom: spacing.m,
  },
  creditRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  creditIcon: {
    marginRight: spacing.m,
  },
  creditInfo: {
    flex: 1,
  },
  creditLabel: {
    fontSize: 14,
    color: theme.colors.placeholder,
    marginBottom: 4,
  },
  creditValue: {
    ...typography.h3,
    color: theme.colors.primary,
  },
  button: {
    width: '100%',
    marginBottom: spacing.m,
  },
  textButton: {
    marginTop: spacing.m,
  },
});

export default BookingSuccessScreen;