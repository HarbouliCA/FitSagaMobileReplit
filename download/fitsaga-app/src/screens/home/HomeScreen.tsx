import React from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  TouchableOpacity, 
  ScrollView,
  ImageBackground,
  SafeAreaView 
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';

const HomeScreen = () => {
  const navigation = useNavigation();

  const menuItems = [
    { 
      id: 1, 
      title: 'Calendar', 
      subtitle: 'View upcoming sessions', 
      icon: 'calendar', 
      screen: 'Sessions'
    },
    { 
      id: 2, 
      title: 'My Bookings', 
      subtitle: 'Manage your reservations', 
      icon: 'list', 
      screen: 'Sessions' 
    },
    { 
      id: 3, 
      title: 'Workouts', 
      subtitle: 'Browse training routines', 
      icon: 'barbell', 
      screen: 'Tutorials' 
    },
    { 
      id: 4, 
      title: 'My Profile', 
      subtitle: 'View your information', 
      icon: 'person', 
      screen: 'Profile' 
    },
    { 
      id: 5, 
      title: 'Progress', 
      subtitle: 'Track your fitness journey', 
      icon: 'trending-up', 
      screen: 'Profile' 
    },
    { 
      id: 6, 
      title: 'Community', 
      subtitle: 'Connect with others', 
      icon: 'people', 
      screen: 'Profile' 
    },
    { 
      id: 7, 
      title: 'QR Access', 
      subtitle: 'Gym entry code', 
      icon: 'qr-code', 
      screen: 'Profile' 
    },
    { 
      id: 8, 
      title: 'Settings', 
      subtitle: 'Account preferences', 
      icon: 'settings', 
      screen: 'Profile' 
    },
    { 
      id: 9, 
      title: 'Credits', 
      subtitle: 'Manage your gym credits', 
      icon: 'cash', 
      screen: 'Profile' 
    },
  ];

  const handleMenuPress = (screen: string) => {
    navigation.navigate(screen as never);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ImageBackground 
        source={{ uri: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2940' }}
        style={styles.headerBackground}
      >
        <View style={styles.headerContent}>
          <Text style={styles.headerTitle}>FitSAGA</Text>
          <Text style={styles.headerSubtitle}>Welcome back, Alex</Text>
        </View>
      </ImageBackground>

      <ScrollView style={styles.scrollView}>
        <View style={styles.infoBox}>
          <View style={styles.infoItem}>
            <Text style={styles.infoTitle}>24</Text>
            <Text style={styles.infoLabel}>Credits</Text>
          </View>
          <View style={styles.infoItem}>
            <Text style={styles.infoTitle}>5</Text>
            <Text style={styles.infoLabel}>Bookings</Text>
          </View>
          <View style={styles.infoItem}>
            <Text style={styles.infoTitle}>12</Text>
            <Text style={styles.infoLabel}>Workouts</Text>
          </View>
        </View>

        <Text style={styles.sectionTitle}>Quick Access</Text>
        
        <View style={styles.menuGrid}>
          {menuItems.map((item) => (
            <TouchableOpacity 
              key={item.id}
              style={styles.menuItem}
              onPress={() => handleMenuPress(item.screen)}
            >
              <View style={styles.menuIconContainer}>
                <Ionicons name={item.icon} size={28} color="#4C1D95" />
              </View>
              <Text style={styles.menuTitle}>{item.title}</Text>
              <Text style={styles.menuSubtitle}>{item.subtitle}</Text>
            </TouchableOpacity>
          ))}
        </View>

        <View style={styles.upcomingContainer}>
          <View style={styles.upcomingHeader}>
            <Text style={styles.upcomingTitle}>Today's Sessions</Text>
            <TouchableOpacity onPress={() => navigation.navigate('Sessions')}>
              <Text style={styles.seeAllText}>See All</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.sessionCard}>
            <View style={styles.sessionTime}>
              <Text style={styles.timeText}>15:00</Text>
              <Text style={styles.durationText}>60 min</Text>
            </View>
            <View style={styles.sessionInfo}>
              <Text style={styles.sessionTitle}>Personal Training</Text>
              <Text style={styles.sessionDetail}>with Coach Sarah</Text>
              <View style={styles.sessionStatusContainer}>
                <View style={styles.statusIndicator} />
                <Text style={styles.statusText}>Confirmed</Text>
              </View>
            </View>
          </View>

          <View style={styles.sessionCard}>
            <View style={styles.sessionTime}>
              <Text style={styles.timeText}>17:00</Text>
              <Text style={styles.durationText}>45 min</Text>
            </View>
            <View style={styles.sessionInfo}>
              <Text style={styles.sessionTitle}>Group Fitness</Text>
              <Text style={styles.sessionDetail}>HIIT Workout</Text>
              <View style={styles.sessionStatusContainer}>
                <View style={[styles.statusIndicator, styles.statusWaiting]} />
                <Text style={styles.statusText}>Waiting List (2/8)</Text>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7f7f7',
  },
  headerBackground: {
    height: 200,
    justifyContent: 'flex-end',
  },
  headerContent: {
    backgroundColor: 'rgba(0,0,0,0.4)',
    padding: 20,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
  },
  headerSubtitle: {
    fontSize: 16,
    color: 'white',
    opacity: 0.9,
  },
  scrollView: {
    flex: 1,
  },
  infoBox: {
    flexDirection: 'row',
    backgroundColor: 'white',
    borderRadius: 12,
    margin: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  infoItem: {
    flex: 1,
    alignItems: 'center',
  },
  infoTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#4C1D95',
  },
  infoLabel: {
    fontSize: 14,
    color: '#6B7280',
    marginTop: 4,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginLeft: 16,
    marginBottom: 16,
    marginTop: 8,
  },
  menuGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: 8,
  },
  menuItem: {
    width: '33.33%',
    padding: 8,
    marginBottom: 16,
  },
  menuIconContainer: {
    width: 60,
    height: 60,
    backgroundColor: '#EDE9FE',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  menuTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#111827',
  },
  menuSubtitle: {
    fontSize: 12,
    color: '#6B7280',
  },
  upcomingContainer: {
    marginTop: 16,
    padding: 16,
  },
  upcomingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  upcomingTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
  },
  seeAllText: {
    fontSize: 14,
    color: '#4C1D95',
    fontWeight: '500',
  },
  sessionCard: {
    flexDirection: 'row',
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  sessionTime: {
    width: 60,
    marginRight: 16,
  },
  timeText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#111827',
  },
  durationText: {
    fontSize: 14,
    color: '#6B7280',
  },
  sessionInfo: {
    flex: 1,
  },
  sessionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#111827',
  },
  sessionDetail: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 8,
  },
  sessionStatusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusIndicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#10B981',
    marginRight: 6,
  },
  statusWaiting: {
    backgroundColor: '#F59E0B',
  },
  statusText: {
    fontSize: 12,
    color: '#6B7280',
  },
});

export default HomeScreen;