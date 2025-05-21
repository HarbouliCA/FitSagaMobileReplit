import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Text, Button, Card, Divider, Avatar, Badge, ActivityIndicator } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { doc, getDoc } from 'firebase/firestore';
import { useSelector, useDispatch } from 'react-redux';

import { db } from '../../services/firebase';
import { RootState } from '../../redux/store';
import { fetchUserCredits } from '../../redux/features/creditsSlice';
import { theme, typography, spacing } from '../../theme';

// Define types for route params
type SessionDetailRouteParams = {
  SessionDetail: {
    sessionId: string;
  };
};

type SessionDetailScreenRouteProp = RouteProp<SessionDetailRouteParams, 'SessionDetail'>;

// Session interface
interface Session {
  id: string;
  title: string;
  description?: string;
  activityType: string;
  startTime: Date;
  endTime: Date;
  instructorId: string;
  instructorName: string;
  instructorPhotoURL?: string;
  capacity: number;
  enrolledCount: number;
  creditCost: number;
  location?: string;
  status: string;
  notes?: string;
}

const SessionDetailScreen: React.FC = () => {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [alreadyBooked, setAlreadyBooked] = useState(false);
  
  const route = useRoute<SessionDetailScreenRouteProp>();
  const navigation = useNavigation();
  const dispatch = useDispatch();
  
  const { sessionId } = route.params;
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
      year: 'numeric',
    });
  };

  // Format duration for display
  const formatDuration = (startTime: Date, endTime: Date) => {
    const duration = (endTime.getTime() - startTime.getTime()) / (1000 * 60);
    return `${duration} min`;
  };

  // Check if user has already booked this session
  const checkIfBooked = async () => {
    if (!user) return;
    
    try {
      const bookingsRef = doc(db, 'bookings', `${user.uid}_${sessionId}`);
      const bookingDoc = await getDoc(bookingsRef);
      
      setAlreadyBooked(bookingDoc.exists());
    } catch (error) {
      console.error('Error checking booking status:', error);
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
          description: data.description,
          activityType: data.activityType || 'Other',
          startTime: data.startTime.toDate(),
          endTime: data.endTime.toDate(),
          instructorId: data.instructorId,
          instructorName: data.instructorName || 'Unknown Instructor',
          instructorPhotoURL: data.instructorPhotoURL,
          capacity: data.capacity || 10,
          enrolledCount: data.enrolledCount || 0,
          creditCost: data.creditValue || 1,
          location: data.location,
          status: data.status,
          notes: data.notes,
        });
      }
    } catch (error) {
      console.error('Error fetching session details:', error);
    } finally {
      setLoading(false);
    }
  };

  // Handle booking
  const handleBookSession = () => {
    if (!session || !user || !userData) return;
    
    // Check for session validity
    const currentTime = new Date();
    if (session.startTime < currentTime) {
      Alert.alert('Booking Error', 'This session has already started.');
      return;
    }
    
    if (session.enrolledCount >= session.capacity) {
      Alert.alert('Booking Error', 'This session is already full.');
      return;
    }
    
    // Check for sufficient credits
    const totalCredits = (credits.total || 0) + (credits.intervalCredits || 0);
    if (totalCredits < session.creditCost) {
      Alert.alert(
        'Insufficient Credits',
        `You need ${session.creditCost} credits to book this session, but you only have ${totalCredits}.`,
        [
          { text: 'Cancel', style: 'cancel' },
          { 
            text: 'View Plans', 
            onPress: () => navigation.navigate('Plans')
          }
        ]
      );
      return;
    }
    
    // Navigate to booking confirmation screen
    navigation.navigate('BookingConfirmation', {
      sessionId: session.id,
      creditCost: session.creditCost,
    });
  };

  // Fetch session data and check booking status on mount
  useEffect(() => {
    fetchSessionDetails();
    checkIfBooked();
    
    // Fetch user credits to ensure they're up to date
    if (user) {
      dispatch(fetchUserCredits(user.uid));
    }
  }, [sessionId, user]);

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

  const availableSpots = session.capacity - session.enrolledCount;
  
  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Card style={styles.headerCard}>
          <Card.Content>
            <View style={styles.activityTypeContainer}>
              <Badge style={styles.activityBadge}>
                {session.activityType}
              </Badge>
              <Badge style={styles.creditBadge}>
                {session.creditCost} credit{session.creditCost !== 1 ? 's' : ''}
              </Badge>
            </View>
            
            <Text style={styles.title}>{session.title}</Text>
            
            <View style={styles.timeContainer}>
              <MaterialCommunityIcons 
                name="calendar-clock" 
                size={16} 
                color={theme.colors.placeholder}
                style={styles.icon}
              />
              <Text style={styles.timeText}>
                {formatDate(session.startTime)}
              </Text>
            </View>
            
            <View style={styles.timeContainer}>
              <MaterialCommunityIcons 
                name="clock-outline" 
                size={16} 
                color={theme.colors.placeholder}
                style={styles.icon}
              />
              <Text style={styles.timeText}>
                {formatTime(session.startTime)} - {formatTime(session.endTime)} ({formatDuration(session.startTime, session.endTime)})
              </Text>
            </View>
            
            {session.location && (
              <View style={styles.timeContainer}>
                <MaterialCommunityIcons 
                  name="map-marker-outline" 
                  size={16} 
                  color={theme.colors.placeholder}
                  style={styles.icon}
                />
                <Text style={styles.timeText}>
                  {session.location}
                </Text>
              </View>
            )}
          </Card.Content>
        </Card>
        
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>Instructor</Text>
            <View style={styles.instructorContainer}>
              {session.instructorPhotoURL ? (
                <Avatar.Image 
                  source={{ uri: session.instructorPhotoURL }} 
                  size={48} 
                  style={styles.instructorImage}
                />
              ) : (
                <Avatar.Icon 
                  icon="account" 
                  size={48} 
                  style={styles.instructorIcon} 
                  color="white" 
                />
              )}
              <View style={styles.instructorDetails}>
                <Text style={styles.instructorName}>{session.instructorName}</Text>
                <Button mode="text" compact style={styles.instructorButton}>
                  View Profile
                </Button>
              </View>
            </View>
          </Card.Content>
        </Card>
        
        <Card style={styles.card}>
          <Card.Content>
            <Text style={styles.sectionTitle}>Availability</Text>
            <View style={styles.availabilityContainer}>
              <View style={styles.availabilityBox}>
                <Text style={styles.availabilityCount}>{session.enrolledCount}</Text>
                <Text style={styles.availabilityLabel}>Enrolled</Text>
              </View>
              <View style={styles.availabilityDivider} />
              <View style={styles.availabilityBox}>
                <Text style={styles.availabilityCount}>{availableSpots}</Text>
                <Text style={styles.availabilityLabel}>Available</Text>
              </View>
              <View style={styles.availabilityDivider} />
              <View style={styles.availabilityBox}>
                <Text style={styles.availabilityCount}>{session.capacity}</Text>
                <Text style={styles.availabilityLabel}>Capacity</Text>
              </View>
            </View>
          </Card.Content>
        </Card>
        
        {session.description && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>About this Session</Text>
              <Text style={styles.descriptionText}>{session.description}</Text>
            </Card.Content>
          </Card>
        )}
        
        {session.notes && (
          <Card style={styles.card}>
            <Card.Content>
              <Text style={styles.sectionTitle}>Notes</Text>
              <Text style={styles.descriptionText}>{session.notes}</Text>
            </Card.Content>
          </Card>
        )}
      </ScrollView>
      
      <View style={styles.bookingContainer}>
        <View style={styles.creditsContainer}>
          <Text style={styles.creditInfoText}>Your credits:</Text>
          <Text style={styles.creditInfoValue}>
            {(credits.total || 0) + (credits.intervalCredits || 0)}
          </Text>
        </View>
        <Divider style={styles.bookingDivider} />
        <Button
          mode="contained"
          onPress={handleBookSession}
          disabled={alreadyBooked || availableSpots === 0}
          style={styles.bookingButton}
          contentStyle={styles.bookingButtonContent}
          labelStyle={styles.bookingButtonLabel}
        >
          {alreadyBooked 
            ? 'Already Booked' 
            : availableSpots === 0 
              ? 'Session Full' 
              : 'Book Now'}
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
    paddingBottom: 100, // Extra padding for the booking button
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
  headerCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  card: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  activityTypeContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: spacing.s,
  },
  activityBadge: {
    backgroundColor: theme.colors.primary,
    color: 'white',
    fontSize: 12,
  },
  creditBadge: {
    backgroundColor: theme.colors.accent,
    color: 'white',
    fontSize: 12,
  },
  title: {
    ...typography.h2,
    marginBottom: spacing.m,
  },
  timeContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  icon: {
    marginRight: spacing.xs,
  },
  timeText: {
    color: theme.colors.placeholder,
  },
  sectionTitle: {
    ...typography.subtitle1,
    marginBottom: spacing.s,
  },
  instructorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  instructorImage: {
    marginRight: spacing.m,
  },
  instructorIcon: {
    marginRight: spacing.m,
    backgroundColor: theme.colors.primary,
  },
  instructorDetails: {
    flex: 1,
  },
  instructorName: {
    ...typography.subtitle2,
    marginBottom: spacing.xs,
  },
  instructorButton: {
    alignSelf: 'flex-start',
    paddingLeft: 0,
    paddingVertical: 0,
  },
  availabilityContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  availabilityBox: {
    flex: 1,
    alignItems: 'center',
  },
  availabilityCount: {
    ...typography.h2,
    marginBottom: spacing.xs,
  },
  availabilityLabel: {
    color: theme.colors.placeholder,
    fontSize: 12,
  },
  availabilityDivider: {
    width: 1,
    height: '80%',
    backgroundColor: '#EEEEEE',
  },
  descriptionText: {
    lineHeight: 22,
  },
  bookingContainer: {
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
    alignItems: 'center',
  },
  creditsContainer: {
    alignItems: 'center',
  },
  creditInfoText: {
    fontSize: 12,
    color: theme.colors.placeholder,
    marginBottom: 2,
  },
  creditInfoValue: {
    ...typography.h3,
    color: theme.colors.primary,
  },
  bookingDivider: {
    height: '80%',
    width: 1,
    marginHorizontal: spacing.m,
  },
  bookingButton: {
    flex: 1,
    borderRadius: 8,
  },
  bookingButtonContent: {
    height: 48,
  },
  bookingButtonLabel: {
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default SessionDetailScreen;