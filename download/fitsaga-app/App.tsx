import React from 'react';
import { StyleSheet, View, Text, ScrollView } from 'react-native';
import { StatusBar } from 'expo-status-bar';

export default function App() {
  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>FitSAGA Mobile</Text>
        <Text style={styles.subtitle}>Fitness Redefined</Text>
        
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Core Systems</Text>
          <Text style={styles.cardText}>✓ Credit System</Text>
          <Text style={styles.cardText}>✓ Role-Based Access Control</Text>
          <Text style={styles.cardText}>✓ Session Booking</Text>
          <Text style={styles.cardText}>✓ Tutorial System</Text>
          <Text style={styles.cardText}>✓ Firebase Integration</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Coming Soon</Text>
          <Text style={styles.cardText}>• Live Class Notifications</Text>
          <Text style={styles.cardText}>• Personalized Workout Plans</Text>
          <Text style={styles.cardText}>• Progress Tracking</Text>
          <Text style={styles.cardText}>• Community Challenges</Text>
        </View>
      </ScrollView>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#4C1D95',
  },
  scrollContent: {
    flexGrow: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    color: '#E5E7EB',
    marginBottom: 40,
  },
  card: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 24,
    width: '100%',
    marginBottom: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
  },
  cardTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#4C1D95',
    marginBottom: 16,
  },
  cardText: {
    fontSize: 16,
    color: '#1F2937',
    marginBottom: 12,
    lineHeight: 24,
  },
});