import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { Text, Card, Title, Button, ActivityIndicator, Divider } from 'react-native-paper';
import { useSelector } from 'react-redux';
import { collection, query, where, orderBy, limit, getDocs } from 'firebase/firestore';

import { db } from '../../services/firebase';
import { RootState } from '../../redux/store';
import { theme, typography, spacing } from '../../theme';
import CreditBalanceCard from '../../components/credits/CreditBalanceCard';

// Define interfaces for our data
interface Session {
  id: string;
  title: string;
  activityType: string;
  startTime: Date;
  endTime: Date;
  instructorName: string;
  instructorPhotoURL?: string;
  location?: string;
  requiredCredits: number;
}

const ClientDashboardScreen: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [upcomingSessions, setUpcomingSessions] = useState<Session[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  
  const { user, userData } = useSelector((state: RootState) => state.auth);

  // Calculate the next refresh date (for demo purposes - would usually come from backend)
  const calculateNextRefillDate = () => {
    const today = new Date();
    const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate();
    return new Date(today.getFullYear(), today.getMonth(), lastDay);
  };

  const fetchUpcomingSessions = async () => {
    if (!user) return;
    
    try {
      // Get user bookings
      const bookingsRef = collection(db, 'bookings');
      const bookingsQuery = query(
        bookingsRef,
        where('userId', '==', user.uid),
        where('status', '==', 'confirmed'),
        orderBy('startTime', 'asc'),
        limit(5)
      );
      
      const bookingsSnapshot = await getDocs(bookingsQuery);
      
      // For each booking, get the associated session
      const sessionPromises = bookingsSnapshot.docs.map(async (doc) => {
        const bookingData = doc.data();
        const sessionRef = collection(db, 'sessions');
        const sessionDoc = await getDocs(query(sessionRef, where('id', '==', bookingData.sessionId)));
        
        if (sessionDoc.empty) return null;
        
        const sessionData = sessionDoc.docs[0].data();
        return {
          id: sessionData.id,
          title: sessionData.title || sessionData.activityName,
          activityType: sessionData.activityType,
          startTime: sessionData.startTime.toDate(),
          endTime: sessionData.endTime.toDate(),
          instructorName: sessionData.instructorName,
          instructorPhotoURL: sessionData.instructorPhotoURL,
          location: sessionData.location,
          requiredCredits: bookingData.creditsUsed || 1,
        };
      });
      
      const sessions = (await Promise.all(sessionPromises)).filter(Boolean) as Session[];
      setUpcomingSessions(sessions);
    } catch (error) {
      console.error('Error fetching upcoming sessions:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchUpcomingSessions();
  };

  useEffect(() => {
    fetchUpcomingSessions();
  }, [user]);

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

  return (
    <ScrollView 
      style={styles.container}
      contentContainerStyle={styles.contentContainer}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <Text style={styles.welcomeText}>
        Hello, {userData?.name?.split(' ')[0] || 'there'}!
      </Text>
      
      <CreditBalanceCard
        gymCredits={userData?.credits || 0}
        intervalCredits={userData?.intervalCredits || 0}
        lastRefilled={userData?.lastRefilled ? new Date(userData.lastRefilled) : undefined}
        nextRefillDate={calculateNextRefillDate()}
        onPress={() => {/* Navigate to credit details */}}
      />
      
      <View style={styles.sectionHeader}>
        <Title style={styles.sectionTitle}>Upcoming Sessions</Title>
        <Button 
          mode="text" 
          compact 
          onPress={() => {/* Navigate to all sessions */}}
        >
          See All
        </Button>
      </View>
      
      {loading ? (
        <ActivityIndicator style={styles.loader} size="large" color={theme.colors.primary} />
      ) : upcomingSessions.length > 0 ? (
        upcomingSessions.map((session) => (
          <Card key={session.id} style={styles.sessionCard}>
            <Card.Content>
              <View style={styles.sessionHeader}>
                <Title style={styles.sessionTitle}>{session.title}</Title>
                <Text style={styles.creditBadge}>{session.requiredCredits} credit{session.requiredCredits !== 1 ? 's' : ''}</Text>
              </View>
              
              <Text style={styles.sessionTime}>
                {formatDate(session.startTime)}, {formatTime(session.startTime)} - {formatTime(session.endTime)}
              </Text>
              
              <Divider style={styles.divider} />
              
              <View style={styles.sessionDetails}>
                <View style={styles.detailItem}>
                  <Text style={styles.detailLabel}>Activity</Text>
                  <Text style={styles.detailValue}>{session.activityType}</Text>
                </View>
                
                <View style={styles.detailItem}>
                  <Text style={styles.detailLabel}>Instructor</Text>
                  <Text style={styles.detailValue}>{session.instructorName}</Text>
                </View>
                
                {session.location && (
                  <View style={styles.detailItem}>
                    <Text style={styles.detailLabel}>Location</Text>
                    <Text style={styles.detailValue}>{session.location}</Text>
                  </View>
                )}
              </View>
            </Card.Content>
          </Card>
        ))
      ) : (
        <Card style={styles.emptyCard}>
          <Card.Content>
            <Text style={styles.emptyText}>No upcoming sessions</Text>
            <Button 
              mode="contained" 
              style={styles.bookButton}
              onPress={() => {/* Navigate to sessions */}}
            >
              Book a Session
            </Button>
          </Card.Content>
        </Card>
      )}
      
      <View style={styles.sectionHeader}>
        <Title style={styles.sectionTitle}>Recommended Tutorials</Title>
        <Button 
          mode="text" 
          compact 
          onPress={() => {/* Navigate to tutorials */}}
        >
          See All
        </Button>
      </View>
      
      {/* Placeholder for tutorial recommendations */}
      <Card style={styles.tutorialCard}>
        <Card.Content>
          <Text style={styles.placeholderText}>Tutorial recommendations will appear here</Text>
        </Card.Content>
      </Card>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  contentContainer: {
    padding: spacing.m,
    paddingBottom: spacing.xxl,
  },
  welcomeText: {
    ...typography.h1,
    marginBottom: spacing.m,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: spacing.l,
    marginBottom: spacing.s,
  },
  sectionTitle: {
    ...typography.h3,
  },
  loader: {
    marginVertical: spacing.xl,
  },
  sessionCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
  },
  sessionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  sessionTitle: {
    fontSize: 18,
    flex: 1,
  },
  creditBadge: {
    backgroundColor: theme.colors.primary,
    color: 'white',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
    fontSize: 12,
    fontWeight: 'bold',
  },
  sessionTime: {
    marginTop: spacing.xs,
    color: theme.colors.placeholder,
  },
  divider: {
    marginVertical: spacing.s,
  },
  sessionDetails: {
    marginTop: spacing.xs,
  },
  detailItem: {
    flexDirection: 'row',
    marginBottom: spacing.xs,
  },
  detailLabel: {
    width: 80,
    color: theme.colors.placeholder,
  },
  detailValue: {
    flex: 1,
    fontWeight: '500',
  },
  emptyCard: {
    marginVertical: spacing.m,
    padding: spacing.s,
    backgroundColor: theme.colors.surface,
  },
  emptyText: {
    textAlign: 'center',
    marginBottom: spacing.m,
    color: theme.colors.placeholder,
  },
  bookButton: {
    marginTop: spacing.s,
  },
  tutorialCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
    padding: spacing.s,
  },
  placeholderText: {
    textAlign: 'center',
    color: theme.colors.placeholder,
    padding: spacing.m,
  },
});

export default ClientDashboardScreen;