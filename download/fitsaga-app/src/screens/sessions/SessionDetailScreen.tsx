import React, { useState, useEffect } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  Image, 
  TouchableOpacity,
  ActivityIndicator,
  Alert
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../context/AuthContext';
import { getSessionById, bookSession, Session } from '../../services/sessionService';

const SessionDetailScreen = ({ route, navigation }: { route: any, navigation: any }) => {
  const { sessionId } = route.params;
  const { user } = useAuth();
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [booking, setBooking] = useState(false);

  // Load session data
  useEffect(() => {
    const loadSession = async () => {
      try {
        setLoading(true);
        const sessionData = await getSessionById(sessionId);
        setSession(sessionData);
      } catch (error) {
        console.error('Error loading session:', error);
        Alert.alert('Error', 'Failed to load session details');
      } finally {
        setLoading(false);
      }
    };
    
    loadSession();
  }, [sessionId]);

  // Handle booking session
  const handleBooking = async () => {
    if (!user) {
      Alert.alert('Error', 'You must be logged in to book a session');
      return;
    }
    
    if (!session) {
      Alert.alert('Error', 'Session details not available');
      return;
    }
    
    setBooking(true);
    
    try {
      // Check if the user has enough credits
      const creditsType = session.isIntervalSession ? 'interval credits' : 'credits';
      const userCredits = session.isIntervalSession ? user.intervalCredits : user.credits;
      
      if (userCredits < session.creditCost) {
        Alert.alert('Insufficient Credits', `You don't have enough ${creditsType} to book this session`);
        return;
      }
      
      // Book the session
      const result = await bookSession(user.uid, session.id);
      
      if (!result.success) {
        Alert.alert('Booking Failed', result.error || 'Failed to book session');
        return;
      }
      
      Alert.alert(
        'Booking Confirmed', 
        `Your booking for ${session.title} has been confirmed! ${session.creditCost} ${creditsType} have been deducted from your account.`,
        [
          { 
            text: 'OK', 
            onPress: () => navigation.goBack()
          }
        ]
      );
    } catch (error: any) {
      Alert.alert('Error', error.message || 'An error occurred while booking');
    } finally {
      setBooking(false);
    }
  };

  // Show loading indicator
  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4C1D95" />
        <Text style={styles.loadingText}>Loading session details...</Text>
      </View>
    );
  }

  // Handle case where session is not found
  if (!session) {
    return (
      <View style={styles.errorContainer}>
        <Ionicons name="alert-circle-outline" size={64} color="#EF4444" />
        <Text style={styles.errorText}>Session not found</Text>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <ScrollView style={styles.detailScrollView}>
      <Image 
        source={{ uri: session.image }} 
        style={styles.detailImage} 
      />
      
      <View style={styles.detailContent}>
        <Text style={styles.detailTitle}>{session.title}</Text>
        
        <View style={styles.detailRow}>
          <Ionicons name="calendar-outline" size={20} color="#4C1D95" />
          <Text style={styles.detailText}>{session.date}</Text>
        </View>
        
        <View style={styles.detailRow}>
          <Ionicons name="time-outline" size={20} color="#4C1D95" />
          <Text style={styles.detailText}>{session.time} • {session.duration}</Text>
        </View>
        
        <View style={styles.detailRow}>
          <Ionicons name="person-outline" size={20} color="#4C1D95" />
          <Text style={styles.detailText}>Instructor: {session.instructor}</Text>
        </View>
        
        <View style={styles.detailRow}>
          <Ionicons name="location-outline" size={20} color="#4C1D95" />
          <Text style={styles.detailText}>{session.location}</Text>
        </View>

        {session.isIntervalSession && (
          <View style={styles.intervalBadge}>
            <Text style={styles.intervalBadgeText}>Interval Session</Text>
          </View>
        )}
        
        <View style={styles.detailSeparator} />
        
        <Text style={styles.detailSectionTitle}>About this Session</Text>
        <Text style={styles.detailDescription}>{session.description}</Text>
        
        <View style={styles.detailSeparator} />
        
        <View style={styles.bookingInfo}>
          <View>
            <Text style={styles.detailSectionTitle}>Booking Status</Text>
            <Text style={styles.bookingStatusText}>
              {session.currentBookings}/{session.capacity.split(' ')[0]} participants
            </Text>
          </View>
          
          <View>
            <Text style={styles.detailSectionTitle}>Credit Cost</Text>
            <Text style={styles.creditCostText}>
              {session.creditCost} {session.isIntervalSession ? 'interval credits' : 'credits'}
            </Text>
          </View>
        </View>
        
        <TouchableOpacity 
          style={[
            styles.bookButton,
            booking && styles.bookingButton,
            session.currentBookings >= parseInt(session.capacity.split(' ')[0]) && styles.disabledButton
          ]}
          onPress={handleBooking}
          disabled={booking || session.currentBookings >= parseInt(session.capacity.split(' ')[0])}
        >
          {booking ? (
            <>
              <ActivityIndicator size="small" color="white" />
              <Text style={styles.bookButtonText}> Processing...</Text>
            </>
          ) : session.currentBookings >= parseInt(session.capacity.split(' ')[0]) ? (
            <Text style={styles.bookButtonText}>Session Full</Text>
          ) : (
            <Text style={styles.bookButtonText}>Book Session</Text>
          )}
        </TouchableOpacity>

        {user && (
          <Text style={styles.yourCreditsText}>
            Your {session.isIntervalSession ? 'interval credits' : 'credits'}: {session.isIntervalSession ? user.intervalCredits : user.credits}
          </Text>
        )}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f7f7f7',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#4B5563',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f7f7f7',
    padding: 20,
  },
  errorText: {
    fontSize: 18,
    color: '#111827',
    marginTop: 16,
    marginBottom: 24,
  },
  backButton: {
    backgroundColor: '#4C1D95',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  backButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  detailScrollView: {
    flex: 1,
    backgroundColor: '#f7f7f7',
  },
  detailImage: {
    width: '100%',
    height: 220,
    resizeMode: 'cover',
  },
  detailContent: {
    padding: 20,
  },
  detailTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  detailText: {
    fontSize: 16,
    color: '#4B5563',
    marginLeft: 10,
  },
  detailSeparator: {
    height: 1,
    backgroundColor: '#E5E7EB',
    marginVertical: 20,
  },
  detailSectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 8,
  },
  detailDescription: {
    fontSize: 16,
    color: '#4B5563',
    lineHeight: 24,
  },
  bookingInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  bookingStatusText: {
    fontSize: 16,
    color: '#4B5563',
  },
  creditCostText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#4C1D95',
  },
  bookButton: {
    backgroundColor: '#4C1D95',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 12,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  bookingButton: {
    backgroundColor: '#8B5CF6',
  },
  disabledButton: {
    backgroundColor: '#9CA3AF',
  },
  bookButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  yourCreditsText: {
    marginTop: 12,
    textAlign: 'center',
    fontSize: 14,
    color: '#6B7280',
  },
  intervalBadge: {
    alignSelf: 'flex-start',
    backgroundColor: '#8B5CF6',
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 12,
    marginTop: 10,
  },
  intervalBadgeText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
});

export default SessionDetailScreen;