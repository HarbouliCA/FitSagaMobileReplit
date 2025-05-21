import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  FlatList
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';

const SessionsScreen = () => {
  const navigation = useNavigation();
  const [selectedDay, setSelectedDay] = useState(3); // Index of the selected day (Wednesday)
  const [selectedFilter, setSelectedFilter] = useState('all');

  // Mock data for the week days
  const weekDays = [
    { id: 0, day: 'lu', date: 7, isHighlighted: true },
    { id: 1, day: 'ma', date: 8 },
    { id: 2, day: 'mi', date: 9 },
    { id: 3, day: 'ju', date: 10 },
    { id: 4, day: 'vi', date: 11 },
    { id: 5, day: 'sá', date: 12 },
    { id: 6, day: 'do', date: 13 },
  ];

  // Mock session data
  const sessions = [
    {
      id: 1,
      title: 'Entreno personal',
      time: '15:00',
      duration: '60 min',
      participants: '1/2 participantes',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
    },
    {
      id: 2,
      title: 'SALA FITNESS',
      time: '15:00',
      duration: '60 min',
      participants: '0/40 participantes',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
    },
    {
      id: 3,
      title: 'Entreno personal',
      time: '16:00',
      duration: '60 min',
      participants: '0/1 participantes',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
    },
    {
      id: 4,
      title: 'SALA FITNESS',
      time: '16:00',
      duration: '60 min',
      participants: '1/40 participantes',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
    },
    {
      id: 5,
      title: 'SALA FITNESS',
      time: '17:00',
      duration: '60 min',
      participants: '2/40 participantes',
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
    },
  ];

  const handleSessionPress = (sessionId: any) => {
    // Navigate to session detail screen
    navigation.navigate('SessionDetail' as never, { sessionId } as never);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()}>
          <Ionicons name="arrow-back" size={24} color="black" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Horario clientes</Text>
        <View style={styles.headerButtons}>
          <TouchableOpacity style={styles.headerButton} onPress={() => {}}>
            <Ionicons name="create-outline" size={24} color="#D4C400" />
          </TouchableOpacity>
          <TouchableOpacity style={styles.headerButton} onPress={() => {}}>
            <Ionicons name="calendar-outline" size={24} color="black" />
          </TouchableOpacity>
        </View>
      </View>

      {/* Calendar Days */}
      <View style={styles.calendarContainer}>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          data={weekDays}
          keyExtractor={(item) => item.id.toString()}
          renderItem={({ item }) => (
            <TouchableOpacity 
              style={[
                styles.dayItem, 
                selectedDay === item.id && styles.selectedDayItem,
                item.isHighlighted && styles.highlightedDayItem
              ]}
              onPress={() => setSelectedDay(item.id)}
            >
              <Text style={[
                styles.dayText, 
                selectedDay === item.id && styles.selectedDayText,
                item.isHighlighted && selectedDay !== item.id && styles.highlightedDayText
              ]}>
                {item.day}
              </Text>
              <Text style={[
                styles.dateText, 
                selectedDay === item.id && styles.selectedDateText,
                item.isHighlighted && selectedDay !== item.id && styles.highlightedDateText
              ]}>
                {item.date}
              </Text>
            </TouchableOpacity>
          )}
        />
      </View>

      {/* Filters */}
      <View style={styles.filterContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          <TouchableOpacity 
            style={[styles.filterButton, selectedFilter === 'schedules' && styles.selectedFilterButton]}
            onPress={() => setSelectedFilter('schedules')}
          >
            <Text style={styles.filterText}>Horarios</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.filterButton, selectedFilter === 'all' && styles.selectedFilterButton]}
            onPress={() => setSelectedFilter('all')}
          >
            <Text style={styles.filterText}>Todas las actividades</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.filterButton, selectedFilter === 'instructors' && styles.selectedFilterButton]}
            onPress={() => setSelectedFilter('instructors')}
          >
            <Text style={styles.filterText}>Instructores</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>

      {/* Today's Sessions */}
      <View style={styles.todayContainer}>
        <Text style={styles.todayTitle}>Hoy</Text>
        
        <ScrollView showsVerticalScrollIndicator={false}>
          {sessions.map(session => (
            <TouchableOpacity 
              key={session.id} 
              style={styles.sessionCard}
              onPress={() => handleSessionPress(session.id)}
            >
              <Image 
                source={{ uri: session.image }} 
                style={styles.sessionImage} 
              />
              <View style={styles.sessionContent}>
                <Text style={styles.sessionTitle}>{session.title}</Text>
                <View style={styles.sessionDetails}>
                  <Text style={styles.sessionTime}>{session.time} • {session.duration}</Text>
                  <Text style={styles.sessionParticipants}>{session.participants}</Text>
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7f7f7',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#111827',
  },
  headerButtons: {
    flexDirection: 'row',
  },
  headerButton: {
    marginLeft: 16,
  },
  calendarContainer: {
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  dayItem: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 50,
    height: 70,
    marginHorizontal: 8,
    borderRadius: 30,
    backgroundColor: 'transparent',
  },
  selectedDayItem: {
    backgroundColor: '#333333',
  },
  highlightedDayItem: {
    backgroundColor: '#D4C400',
  },
  dayText: {
    fontSize: 14,
    color: '#6B7280',
  },
  selectedDayText: {
    color: 'white',
  },
  highlightedDayText: {
    color: 'white',
  },
  dateText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginTop: 4,
  },
  selectedDateText: {
    color: 'white',
  },
  highlightedDateText: {
    color: 'white',
  },
  filterContainer: {
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  filterButton: {
    paddingHorizontal: 20,
    paddingVertical: 10,
    marginHorizontal: 6,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    backgroundColor: 'white',
  },
  selectedFilterButton: {
    backgroundColor: '#f0f0f0',
    borderColor: '#D1D5DB',
  },
  filterText: {
    fontSize: 14,
    color: '#6B7280',
  },
  todayContainer: {
    flex: 1,
    padding: 16,
  },
  todayTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  sessionCard: {
    flexDirection: 'row',
    backgroundColor: 'white',
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  sessionImage: {
    width: 100,
    height: 100,
  },
  sessionContent: {
    flex: 1,
    padding: 12,
    justifyContent: 'center',
  },
  sessionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 8,
  },
  sessionDetails: {
    gap: 4,
  },
  sessionTime: {
    fontSize: 14,
    color: '#6B7280',
  },
  sessionParticipants: {
    fontSize: 14,
    color: '#9CA3AF',
  },
});

export default SessionsScreen;