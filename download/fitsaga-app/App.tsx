import React, { useState } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import { Provider as PaperProvider } from 'react-native-paper';
import { Text, View, StyleSheet, ScrollView, Image, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

// Import screens and navigators
import TabNavigator from './src/navigation/TabNavigator';
import LoginScreen from './src/screens/auth/LoginScreen';
import RegisterScreen from './src/screens/auth/RegisterScreen';
import SessionDetailScreen from './src/screens/sessions/SessionDetailScreen';

// Import auth provider
import { AuthProvider, useAuth } from './src/context/AuthContext';

// Create stack navigator
const Stack = createNativeStackNavigator();

// Types for navigation and routes
type RouteParams = {
  SessionDetail: { sessionId: number };
  TutorialDetail: { tutorialId: number };
};

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
            <Text style={styles.creditCostText}>{session.creditCost} credits</Text>
          </View>
        </View>
        
        <TouchableOpacity 
          style={styles.bookButton}
          onPress={handleBooking}
        >
          <Text style={styles.bookButtonText}>Book Session</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

// Tutorial Detail Screen with video player
const TutorialDetailScreen = ({ route }: { route: any }) => {
  const { tutorialId } = route.params;
  
  // Mock tutorial data based on tutorial ID
  const tutorial = {
    id: tutorialId,
    title: tutorialId % 2 === 0 ? 'Full Body Workout' : 'HIIT Cardio Training',
    instructor: 'Alex Johnson',
    duration: '25 min',
    level: tutorialId % 3 === 0 ? 'Advanced' : 'Intermediate',
    description: 'This comprehensive workout targets all major muscle groups. Follow along for a complete routine that will help improve strength and endurance.',
    category: tutorialId % 2 === 0 ? 'Strength' : 'Cardio',
    videoUrl: 'https://example.com/video.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?q=80&w=2069',
    equipment: ['Dumbbells', 'Exercise mat', 'Resistance bands']
  };

  return (
    <ScrollView style={styles.detailScrollView}>
      <View style={styles.videoContainer}>
        <Image 
          source={{ uri: tutorial.thumbnail }} 
          style={styles.videoPlaceholder} 
        />
        <View style={styles.playButtonLarge}>
          <Ionicons name="play" size={40} color="white" />
        </View>
      </View>
      
      <View style={styles.detailContent}>
        <Text style={styles.detailTitle}>{tutorial.title}</Text>
        
        <View style={styles.tutorialInfo}>
          <View style={styles.tutorialInfoItem}>
            <Ionicons name="person" size={16} color="#6B7280" />
            <Text style={styles.tutorialInfoText}>{tutorial.instructor}</Text>
          </View>
          
          <View style={styles.tutorialInfoItem}>
            <Ionicons name="time" size={16} color="#6B7280" />
            <Text style={styles.tutorialInfoText}>{tutorial.duration}</Text>
          </View>
          
          <View style={styles.tutorialInfoItem}>
            <Ionicons name="fitness" size={16} color="#6B7280" />
            <Text style={styles.tutorialInfoText}>{tutorial.level}</Text>
          </View>
        </View>
        
        <View style={styles.detailSeparator} />
        
        <Text style={styles.detailSectionTitle}>Description</Text>
        <Text style={styles.detailDescription}>{tutorial.description}</Text>
        
        <View style={styles.detailSeparator} />
        
        <Text style={styles.detailSectionTitle}>Equipment Needed</Text>
        {tutorial.equipment.map((item, index) => (
          <View key={index} style={styles.equipmentItem}>
            <Ionicons name="checkmark-circle" size={18} color="#4C1D95" />
            <Text style={styles.equipmentText}>{item}</Text>
          </View>
        ))}
        
        <TouchableOpacity style={styles.saveButton}>
          <Ionicons name="bookmark-outline" size={20} color="white" />
          <Text style={styles.saveButtonText}>Save Tutorial</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

// Credits Screen
const CreditsScreen = () => {
  // Mock credit data
  const credits = {
    total: 24,
    intervalCredits: 8,
    lastRefilled: 'May 15, 2025',
    transactions: [
      { id: 1, date: 'May 20, 2025', description: 'HIIT Training Session', amount: -3, type: 'deduction' },
      { id: 2, date: 'May 18, 2025', description: 'Personal Training Session', amount: -5, type: 'deduction' },
      { id: 3, date: 'May 15, 2025', description: 'Monthly Credit Refill', amount: 20, type: 'addition' },
      { id: 4, date: 'May 10, 2025', description: 'Group Fitness Class', amount: -2, type: 'deduction' },
      { id: 5, date: 'May 5, 2025', description: 'Admin Credit Adjustment', amount: 5, type: 'addition' },
    ]
  };

  return (
    <ScrollView style={styles.screenContainer}>
      <View style={styles.creditSummaryCard}>
        <Text style={styles.creditSummaryTitle}>Credit Balance</Text>
        
        <View style={styles.creditBalanceContainer}>
          <View style={styles.creditBalanceItem}>
            <Text style={styles.creditBalanceValue}>{credits.total}</Text>
            <Text style={styles.creditBalanceLabel}>Total Credits</Text>
          </View>
          
          <View style={styles.creditBalanceDivider} />
          
          <View style={styles.creditBalanceItem}>
            <Text style={styles.creditBalanceValue}>{credits.intervalCredits}</Text>
            <Text style={styles.creditBalanceLabel}>Interval Credits</Text>
          </View>
        </View>
        
        <Text style={styles.lastRefilledText}>Last refilled: {credits.lastRefilled}</Text>
      </View>
      
      <View style={styles.transactionSection}>
        <Text style={styles.transactionTitle}>Transaction History</Text>
        
        {credits.transactions.map(transaction => (
          <View key={transaction.id} style={styles.transactionItem}>
            <View>
              <Text style={styles.transactionDescription}>{transaction.description}</Text>
              <Text style={styles.transactionDate}>{transaction.date}</Text>
            </View>
            
            <Text style={[
              styles.transactionAmount,
              transaction.type === 'addition' ? styles.transactionAddition : styles.transactionDeduction
            ]}>
              {transaction.type === 'addition' ? '+' : ''}{transaction.amount}
            </Text>
          </View>
        ))}
      </View>
    </ScrollView>
  );
};

// PlaceholderScreen for other screens
const PlaceholderScreen = ({ route }: { route: any }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{route.name}</Text>
      <Text style={styles.subtitle}>This screen is coming soon!</Text>
      <Ionicons name="construct-outline" size={80} color="#8B5CF6" style={{ marginTop: 20, opacity: 0.5 }} />
    </View>
  );
};

// Navigation component with auth state
const AppNavigator = () => {
  const { isLoggedIn, isLoading } = useAuth();

  // Show loading spinner while auth state is being determined
  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4C1D95" />
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    );
  }

  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: true,
        headerTitleStyle: { color: '#4C1D95' },
        headerTintColor: '#4C1D95',
        headerShadowVisible: false,
        headerStyle: { backgroundColor: '#F7F7F7' },
      }}
      initialRouteName={isLoggedIn ? "Main" : "Login"}
    >
      {!isLoggedIn ? (
        // Authentication Screens (only shown when not logged in)
        <>
          <Stack.Screen 
            name="Login" 
            component={LoginScreen} 
            options={{ headerShown: false }}
          />
          <Stack.Screen 
            name="Register" 
            component={RegisterScreen}
            options={{ headerShown: false }}
          />
        </>
      ) : (
        // Main App Screens (only shown when logged in)
        <>
          <Stack.Screen 
            name="Main" 
            component={TabNavigator} 
            options={{ headerShown: false }}
          />
          
          {/* Detail and Profile Screens */}
          <Stack.Screen name="SessionDetail" component={SessionDetailScreen} options={{ title: 'Session Details' }} />
          <Stack.Screen name="TutorialDetail" component={TutorialDetailScreen} options={{ title: 'Tutorial Details' }} />
          <Stack.Screen name="PersonalInfo" component={PlaceholderScreen} />
          <Stack.Screen name="Credits" component={CreditsScreen} />
          <Stack.Screen name="BookedSessions" component={PlaceholderScreen} />
          <Stack.Screen name="Progress" component={PlaceholderScreen} />
          <Stack.Screen name="SavedTutorials" component={PlaceholderScreen} />
          <Stack.Screen name="Help" component={PlaceholderScreen} />
        </>
      )}
    </Stack.Navigator>
  );
};

// Main App component
export default function App() {
  return (
    <SafeAreaProvider>
      <PaperProvider>
        <AuthProvider>
          <NavigationContainer>
            <StatusBar style="auto" />
            <AppNavigator />
          </NavigationContainer>
        </AuthProvider>
      </PaperProvider>
    </SafeAreaProvider>
  );
}

// Enhanced styles for all screens
const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f7f7f7',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f7f7f7',
  },
  loadingText: {
    marginTop: 10,
    fontSize: 16,
    color: '#4C1D95',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#4C1D95',
  },
  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
  },
  // Session Detail Screen Styles
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
  },
  bookButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  // Tutorial Detail Screen Styles
  videoContainer: {
    position: 'relative',
    width: '100%',
    height: 220,
  },
  videoPlaceholder: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  playButtonLarge: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -35 }, { translateY: -35 }],
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  tutorialInfo: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  tutorialInfoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 16,
  },
  tutorialInfoText: {
    fontSize: 14,
    color: '#6B7280',
    marginLeft: 4,
  },
  equipmentItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  equipmentText: {
    fontSize: 16,
    color: '#4B5563',
    marginLeft: 8,
  },
  saveButton: {
    backgroundColor: '#4C1D95',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  saveButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    marginLeft: 8,
  },
  // Credits Screen Styles
  screenContainer: {
    flex: 1,
    backgroundColor: '#f7f7f7',
    padding: 16,
  },
  creditSummaryCard: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  creditSummaryTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  creditBalanceContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 16,
  },
  creditBalanceItem: {
    alignItems: 'center',
  },
  creditBalanceValue: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#4C1D95',
    marginBottom: 4,
  },
  creditBalanceLabel: {
    fontSize: 14,
    color: '#6B7280',
  },
  creditBalanceDivider: {
    width: 1,
    backgroundColor: '#E5E7EB',
  },
  lastRefilledText: {
    fontSize: 14,
    color: '#6B7280',
    textAlign: 'center',
  },
  transactionSection: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  transactionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  transactionItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  transactionDescription: {
    fontSize: 16,
    color: '#111827',
    marginBottom: 4,
  },
  transactionDate: {
    fontSize: 14,
    color: '#6B7280',
  },
  transactionAmount: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  transactionAddition: {
    color: '#10B981',
  },
  transactionDeduction: {
    color: '#EF4444',
  },
});