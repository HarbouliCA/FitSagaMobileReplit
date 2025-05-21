import React, { useState, useEffect } from 'react';
import { View, StyleSheet, FlatList, TouchableOpacity, RefreshControl } from 'react-native';
import { Text, Searchbar, Chip, ActivityIndicator, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useSelector } from 'react-redux';
import { collection, query, where, orderBy, getDocs } from 'firebase/firestore';

import { db } from '../../services/firebase';
import { RootState } from '../../redux/store';
import SessionCard from '../../components/sessions/SessionCard';
import { theme, spacing } from '../../theme';

// Session type definition
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
  status: string;
}

const SessionsScreen: React.FC = () => {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [filteredSessions, setFilteredSessions] = useState<Session[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedActivityType, setSelectedActivityType] = useState<string | null>(null);
  const [activityTypes, setActivityTypes] = useState<string[]>([]);
  
  const navigation = useNavigation();
  const { user } = useSelector((state: RootState) => state.auth);

  // Fetch sessions from Firestore
  const fetchSessions = async () => {
    if (!user) return;
    
    try {
      setLoading(true);
      
      // Get current date at midnight to filter for future sessions
      const now = new Date();
      
      // Set up the query for sessions
      const sessionsRef = collection(db, 'sessions');
      const sessionsQuery = query(
        sessionsRef,
        where('status', '==', 'scheduled'),
        where('startTime', '>=', now),
        orderBy('startTime', 'asc')
      );
      
      const snapshot = await getDocs(sessionsQuery);
      
      const sessionsData: Session[] = [];
      const activityTypesSet = new Set<string>();
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        
        // Add to set of activity types
        if (data.activityType) {
          activityTypesSet.add(data.activityType);
        }
        
        sessionsData.push({
          id: doc.id,
          title: data.title || data.activityName || 'Unnamed Session',
          activityType: data.activityType || 'Other',
          startTime: data.startTime.toDate(),
          endTime: data.endTime.toDate(),
          instructorName: data.instructorName || 'Unknown Instructor',
          instructorPhotoURL: data.instructorPhotoURL,
          capacity: data.capacity || 10,
          enrolledCount: data.enrolledCount || 0,
          creditCost: data.creditValue || 1,
          location: data.location,
          status: data.status,
        });
      });
      
      setSessions(sessionsData);
      setFilteredSessions(sessionsData);
      setActivityTypes(Array.from(activityTypesSet));
    } catch (error) {
      console.error('Error fetching sessions:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  // Initial fetch
  useEffect(() => {
    fetchSessions();
  }, [user]);

  // Filter sessions when search query or activity type changes
  useEffect(() => {
    filterSessions();
  }, [searchQuery, selectedActivityType, sessions]);

  // Filter sessions based on search query and activity type
  const filterSessions = () => {
    let filtered = [...sessions];
    
    // Filter by search query
    if (searchQuery.trim() !== '') {
      const query = searchQuery.toLowerCase().trim();
      filtered = filtered.filter(session => 
        session.title.toLowerCase().includes(query) ||
        session.instructorName.toLowerCase().includes(query) ||
        session.activityType.toLowerCase().includes(query)
      );
    }
    
    // Filter by activity type
    if (selectedActivityType) {
      filtered = filtered.filter(session => 
        session.activityType === selectedActivityType
      );
    }
    
    setFilteredSessions(filtered);
  };

  // Refresh sessions
  const onRefresh = () => {
    setRefreshing(true);
    fetchSessions();
  };

  // Navigate to session details
  const handleSessionPress = (sessionId: string) => {
    navigation.navigate('SessionDetail', { sessionId });
  };

  // Toggle activity type filter
  const toggleActivityType = (type: string) => {
    if (selectedActivityType === type) {
      setSelectedActivityType(null);
    } else {
      setSelectedActivityType(type);
    }
  };

  // Render activity type filters
  const renderActivityTypeFilters = () => {
    return (
      <View style={styles.filtersContainer}>
        <Text style={styles.filtersLabel}>Filter by:</Text>
        <FlatList
          data={activityTypes}
          keyExtractor={(item) => item}
          horizontal
          showsHorizontalScrollIndicator={false}
          renderItem={({ item }) => (
            <Chip
              style={[
                styles.activityChip,
                selectedActivityType === item && styles.selectedChip,
              ]}
              textStyle={[
                styles.activityChipText,
                selectedActivityType === item && styles.selectedChipText,
              ]}
              onPress={() => toggleActivityType(item)}
              mode={selectedActivityType === item ? 'flat' : 'outlined'}
              selected={selectedActivityType === item}
            >
              {item}
            </Chip>
          )}
        />
      </View>
    );
  };

  // Render empty state
  const renderEmptyState = () => {
    if (loading) {
      return (
        <View style={styles.emptyContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
          <Text style={styles.emptyText}>Loading sessions...</Text>
        </View>
      );
    }
    
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No sessions found</Text>
        <Text style={styles.emptySubtext}>
          {searchQuery || selectedActivityType
            ? 'Try adjusting your filters'
            : 'Check back later for new sessions'}
        </Text>
        {(searchQuery || selectedActivityType) && (
          <Button
            mode="contained"
            onPress={() => {
              setSearchQuery('');
              setSelectedActivityType(null);
            }}
            style={styles.clearButton}
          >
            Clear Filters
          </Button>
        )}
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.searchContainer}>
        <Searchbar
          placeholder="Search sessions..."
          onChangeText={setSearchQuery}
          value={searchQuery}
          style={styles.searchbar}
          iconColor={theme.colors.primary}
        />
      </View>
      
      {renderActivityTypeFilters()}
      
      <FlatList
        data={filteredSessions}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <SessionCard
            id={item.id}
            title={item.title}
            activityType={item.activityType}
            startTime={item.startTime}
            endTime={item.endTime}
            instructorName={item.instructorName}
            instructorPhotoURL={item.instructorPhotoURL}
            capacity={item.capacity}
            enrolledCount={item.enrolledCount}
            creditCost={item.creditCost}
            location={item.location}
            onPress={() => handleSessionPress(item.id)}
          />
        )}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={renderEmptyState}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  searchContainer: {
    padding: spacing.m,
    backgroundColor: theme.colors.primary,
  },
  searchbar: {
    elevation: 0,
    backgroundColor: 'white',
  },
  filtersContainer: {
    paddingHorizontal: spacing.m,
    paddingVertical: spacing.s,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  },
  filtersLabel: {
    marginBottom: spacing.xs,
    color: theme.colors.placeholder,
  },
  activityChip: {
    marginRight: spacing.s,
    marginBottom: spacing.xs,
  },
  activityChipText: {
    color: theme.colors.primary,
  },
  selectedChip: {
    backgroundColor: theme.colors.primary,
  },
  selectedChipText: {
    color: 'white',
  },
  listContent: {
    padding: spacing.m,
    paddingBottom: spacing.xl,
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
    marginTop: spacing.xl,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: 'bold',
    marginVertical: spacing.s,
  },
  emptySubtext: {
    textAlign: 'center',
    color: theme.colors.placeholder,
    marginBottom: spacing.m,
  },
  clearButton: {
    marginTop: spacing.m,
  },
});

export default SessionsScreen;