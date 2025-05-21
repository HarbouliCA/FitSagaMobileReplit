import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert, ActivityIndicator } from 'react-native';
import { Text, Card, Button, Divider, Avatar } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { doc, getDoc, setDoc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { useSelector, useDispatch } from 'react-redux';

import { db } from '../../services/firebase';
import { RootState } from '../../redux/store';
import { fetchUserCredits, adjustCredits } from '../../redux/features/creditsSlice';
import { theme, typography, spacing } from '../../theme';

// Define types for route params
type BookingConfirmationRouteParams = {
  BookingConfirmation: {
    sessionId: string;
    creditCost: number;
  };
};

type BookingConfirmationRouteProp = RouteProp<BookingConfirmationRouteParams, 'BookingConfirmation'>;

// Session interface
interface Session {
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
}

const BookingConfirmationScreen: React.FC = () => {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [bookingLoading, setBookingLoading] = useState(false);
  const [creditsAfterBooking, setCreditsAfterBooking] = useState({
    total: 0,
    intervalCredits: 0,
  });
  
  const route = useRoute<BookingConfirmationRouteProp>();
  const navigation = useNavigation();
  const dispatch = useDispatch();
  
  const { sessionId, creditCost } = route.params;
  const { user, userData } = useSelector((state: RootState) => state.auth);
  const { credits } = useSelector((state: RootState) => state.credits);

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
    return date.toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'long',
      day: 'numeric',
    });
  };

  // Calculate credits after booking
  const calculateRemainingCredits = () => {
    const totalCredits = (credits.total || 0);
    const intervalCredits = (credits.intervalCredits || 0);
    
    // First use interval credits, then standard credits
    if (intervalCredits >= creditCost) {
      setCreditsAfterBooking({
        total: totalCredits,
        intervalCredits: intervalCredits - creditCost,
      });
    } else {
      const remainingNeeded = creditCost - intervalCredits;
      setCreditsAfterBooking({
        total: totalCredits - remainingNeeded,
        intervalCredits: 0,
      });
    }
  };

  // Fetch session details
  const fetchSessionDetails = async () => {
    if (!sessionId) return;
    
    try {
      setLoading(true);
      
      const sessionRef = doc(db, 'sessions', sessionId);
      const sessionDoc = await getDoc(sessionRef);
      
      if (sessionDoc.exists()) {
        const data = sessionDoc.data();
        
        setSession({
          id: sessionDoc.id,
          title: data.title || data.activityName || 'Unnamed Session',
          activityType: data.activityType || 'Other',
          startTime: data.startTime.toDate(),
          endTime: data.endTime.toDate(),
          instructorName: data.instructorName || 'Unknown Instructor',
          instructorPhotoURL: data.instructorPhotoURL,
          capacity: data.capacity || 10,
          enrolledCount: data.enrolledCount || 0,
          creditCost: data.creditValue || creditCost,
          location: data.location,
        });
      }
    } catch (error) {
      console.error('Error fetching session details:', error);
      Alert.alert('Error', 'Failed to load session details.');
      navigation.goBack();
    } finally {
      setLoading(false);
    }
  };

  // Handle booking confirmation
  const handleConfirmBooking = async () => {
    if (!session || !user || !userData) return;
    
    const totalAvailableCredits = (credits.total || 0) + (credits.intervalCredits || 0);
    
    if (totalAvailableCredits < creditCost) {
      Alert.alert('Insufficient Credits', 'You do not have enough credits to book this session.');
      return;
    }
    
    setBookingLoading(true);
    
    try {
      // Generate a booking ID that's deterministic to avoid duplicates
      const bookingId = `${user.uid}_${sessionId}`;
      
      // Create booking document
      await setDoc(doc(db, 'bookings', bookingId), {
        userId: user.uid,
        userName: userData.name,
        userEmail: userData.email,
        sessionId: session.id,
        sessionTitle: session.title,
        startTime: session.startTime,
        endTime: session.endTime,
        creditCost: creditCost,
        status: 'confirmed',
        bookedAt: serverTimestamp(),
      });
      
      // Update session enrollment count
      await updateDoc(doc(db, 'sessions', sessionId), {
        enrolledCount: session.enrolledCount + 1,
      });
      
      // Deduct credits
      await dispatch(adjustCredits({
        userId: user.uid,
        amount: creditCost,
        reason: `Booking for ${session.title}`,
        type: 'deduction',
      }));
      
      // Navigate to success screen
      navigation.replace('BookingSuccess', {
        sessionId: sessionId,
        bookingId: bookingId,
      });
    } catch (error) {
      console.error('Error confirming booking:', error);
      Alert.alert('Booking Failed', 'There was a problem booking the session. Please try again.');
      setBookingLoading(false);
    }
  };

  // Handle cancellation
  const handleCancel = () => {
    navigation.goBack();
  };

  // Fetch session data and calculate credits on mount
  useEffect(() => {
    fetchSessionDetails();
    
    // Fetch user credits to ensure they're up to date
    if (user) {
      dispatch(fetchUserCredits(user.uid));
    }
  }, [sessionId, user]);

  // Calculate remaining credits when credits or session changes
  useEffect(() => {
    if (session) {
      calculateRemainingCredits();
    }
  }, [credits, session]);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={styles.loadingText}>Loading session details...</Text>
      </View>
    );
  }

  if (!session) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Session not found</Text>
        <Button 
          mode="contained"
          onPress={() => navigation.goBack()}
          style={styles.errorButton}
        >
          Go Back
        </Button>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>Booking Confirmation</Text>
        
        <Card style={styles.sessionCard}>
          <Card.Content>
            <Text style={styles.sessionTitle}>{session.title}</Text>
            <Text style={styles.sessionActivity}>{session.activityType}</Text>
            
            <View style={styles.detailRow}>
              <MaterialCommunityIcons 
                name="calendar" 
                size={20} 
                color={theme.colors.primary}
                style={styles.detailIcon}
              />
              <Text style={styles.detailText}>{formatDate(session.startTime)}</Text>
            </View>
            
            <View style={styles.detailRow}>
              <MaterialCommunityIcons 
                name="clock-outline" 
                size={20} 
                color={theme.colors.primary}
                style={styles.detailIcon}
              />
              <Text style={styles.detailText}>
                {formatTime(session.startTime)} - {formatTime(session.endTime)}
              </Text>
            </View>
            
            {session.location && (
              <View style={styles.detailRow}>
                <MaterialCommunityIcons 
                  name="map-marker" 
                  size={20} 
                  color={theme.colors.primary}
                  style={styles.detailIcon}
                />
                <Text style={styles.detailText}>{session.location}</Text>
              </View>
            )}
            
            <View style={styles.detailRow}>
              <MaterialCommunityIcons 
                name="account" 
                size={20} 
                color={theme.colors.primary}
                style={styles.detailIcon}
              />
              <Text style={styles.detailText}>{session.instructorName}</Text>
            </View>
          </Card.Content>
        </Card>
        
        <Card style={styles.creditCard}>
          <Card.Content>
            <Text style={styles.creditTitle}>Credit Information</Text>
            
            <View style={styles.creditRow}>
              <Text style={styles.creditLabel}>Current Credits:</Text>
              <Text style={styles.creditValue}>
                {(credits.total || 0) + (credits.intervalCredits || 0)}
              </Text>
            </View>
            
            <View style={styles.creditRow}>
              <Text style={styles.creditLabel}>Session Cost:</Text>
              <Text style={styles.creditCost}>
                {creditCost} credit{creditCost !== 1 ? 's' : ''}
              </Text>
            </View>
            
            <Divider style={styles.divider} />
            
            <View style={styles.creditRow}>
              <Text style={styles.creditLabel}>Remaining Credits:</Text>
              <Text style={styles.creditRemaining}>
                {creditsAfterBooking.total + creditsAfterBooking.intervalCredits}
              </Text>
            </View>
          </Card.Content>
        </Card>
        
        <Card style={styles.instructionsCard}>
          <Card.Content>
            <Text style={styles.instructionsTitle}>Booking Information</Text>
            <Text style={styles.instructionsText}>
              By confirming this booking, {creditCost} credit{creditCost !== 1 ? 's' : ''} will be 
              deducted from your account. You can cancel your booking up to 24 hours before the session 
              starts for a full credit refund.
            </Text>
          </Card.Content>
        </Card>
      </ScrollView>
      
      <View style={styles.buttonsContainer}>
        <Button
          mode="outlined"
          onPress={handleCancel}
          style={styles.cancelButton}
          disabled={bookingLoading}
        >
          Cancel
        </Button>
        <Button
          mode="contained"
          onPress={handleConfirmBooking}
          style={styles.confirmButton}
          loading={bookingLoading}
          disabled={bookingLoading}
        >
          Confirm Booking
        </Button>
      </View>
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
    paddingBottom: 100, // Extra padding for buttons
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  loadingText: {
    marginTop: spacing.m,
    color: theme.colors.placeholder,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  errorText: {
    ...typography.h3,
    marginBottom: spacing.m,
  },
  errorButton: {
    marginTop: spacing.m,
  },
  title: {
    ...typography.h2,
    marginBottom: spacing.m,
    textAlign: 'center',
  },
  sessionCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  sessionTitle: {
    ...typography.h3,
    marginBottom: spacing.xs,
  },
  sessionActivity: {
    color: theme.colors.placeholder,
    marginBottom: spacing.m,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.s,
  },
  detailIcon: {
    marginRight: spacing.s,
  },
  detailText: {
    fontSize: 16,
  },
  creditCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  creditTitle: {
    ...typography.subtitle1,
    marginBottom: spacing.m,
  },
  creditRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.s,
  },
  creditLabel: {
    fontSize: 16,
  },
  creditValue: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  creditCost: {
    fontSize: 16,
    fontWeight: 'bold',
    color: theme.colors.error,
  },
  divider: {
    marginVertical: spacing.m,
  },
  creditRemaining: {
    fontSize: 16,
    fontWeight: 'bold',
    color: theme.colors.primary,
  },
  instructionsCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  instructionsTitle: {
    ...typography.subtitle1,
    marginBottom: spacing.s,
  },
  instructionsText: {
    lineHeight: 22,
  },
  buttonsContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'white',
    padding: spacing.m,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 3,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  cancelButton: {
    flex: 1,
    marginRight: spacing.s,
    borderColor: theme.colors.primary,
  },
  confirmButton: {
    flex: 1,
    marginLeft: spacing.s,
  },
});

export default BookingConfirmationScreen;