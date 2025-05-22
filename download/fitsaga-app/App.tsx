import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import { Provider as PaperProvider } from 'react-native-paper';
import { Text, View, StyleSheet } from 'react-native';

// Import navigators
import TabNavigator from './src/navigation/TabNavigator';

// Create stack navigator
const Stack = createNativeStackNavigator();

// Placeholder components for screens we haven't fully implemented yet
const SessionDetailScreen = ({ route }) => {
  const { sessionId } = route.params;
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Session Detail</Text>
      <Text style={styles.subtitle}>Session ID: {sessionId}</Text>
    </View>
  );
};

const TutorialDetailScreen = ({ route }) => {
  const { tutorialId } = route.params;
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Tutorial Detail</Text>
      <Text style={styles.subtitle}>Tutorial ID: {tutorialId}</Text>
    </View>
  );
};

const PlaceholderScreen = ({ route }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{route.name}</Text>
      <Text style={styles.subtitle}>This screen is under development</Text>
    </View>
  );
};

export default function App() {
  return (
    <SafeAreaProvider>
      <PaperProvider>
        <NavigationContainer>
          <StatusBar style="auto" />
          <Stack.Navigator
            screenOptions={{
              headerShown: true,
              headerTitleStyle: { color: '#4C1D95' },
              headerTintColor: '#4C1D95',
            }}
          >
            <Stack.Screen 
              name="Main" 
              component={TabNavigator} 
              options={{ headerShown: false }}
            />
            <Stack.Screen name="SessionDetail" component={SessionDetailScreen} />
            <Stack.Screen name="TutorialDetail" component={TutorialDetailScreen} />
            <Stack.Screen name="PersonalInfo" component={PlaceholderScreen} />
            <Stack.Screen name="Credits" component={PlaceholderScreen} />
            <Stack.Screen name="BookedSessions" component={PlaceholderScreen} />
            <Stack.Screen name="Progress" component={PlaceholderScreen} />
            <Stack.Screen name="SavedTutorials" component={PlaceholderScreen} />
            <Stack.Screen name="Help" component={PlaceholderScreen} />
          </Stack.Navigator>
        </NavigationContainer>
      </PaperProvider>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f7f7f7',
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
});