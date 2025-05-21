import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import { RootState } from '../redux/store';
import AuthNavigator from './AuthNavigator';
import MainNavigator from './MainNavigator';

// Define the root stack parameter list
type RootStackParamList = {
  Auth: undefined;
  Main: undefined;
};

// Create the stack navigator
const Stack = createNativeStackNavigator<RootStackParamList>();

const AppNavigator: React.FC = () => {
  const { isAuthenticated } = useSelector((state: RootState) => state.auth);
  const [isLoading, setIsLoading] = useState(true);

  // Simulating checking for stored credentials
  useEffect(() => {
    // In a real app, we would check for stored auth tokens here
    const checkAuth = async () => {
      // Simulate a short delay
      setTimeout(() => {
        setIsLoading(false);
      }, 1000);
    };
    
    checkAuth();
  }, []);

  if (isLoading) {
    // You could return a loading screen here
    return null;
  }

  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      {isAuthenticated ? (
        <Stack.Screen name="Main" component={MainNavigator} />
      ) : (
        <Stack.Screen name="Auth" component={AuthNavigator} />
      )}
    </Stack.Navigator>
  );
};

export default AppNavigator;