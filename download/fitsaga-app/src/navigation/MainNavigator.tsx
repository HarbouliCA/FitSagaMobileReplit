import React from 'react';
import { useSelector } from 'react-redux';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { MaterialCommunityIcons } from '@expo/vector-icons';

import { RootState } from '../redux/store';
import { theme } from '../theme';

// We'll use placeholder components until we create the actual screens
const HomeScreen = () => null;
const SessionsScreen = () => null;
const TutorialsScreen = () => null;
const ProfileScreen = () => null;
const AdminDashboardScreen = () => null;
const InstructorDashboardScreen = () => null;
const ClientDashboardScreen = () => null;

// Define the main tab navigator parameters
type MainTabParamList = {
  Home: undefined;
  Sessions: undefined;
  Tutorials: undefined;
  Profile: undefined;
};

// Define stack parameters for each role-specific flow
type AdminStackParamList = {
  AdminDashboard: undefined;
  // Other admin screens will be added here
};

type InstructorStackParamList = {
  InstructorDashboard: undefined;
  // Other instructor screens will be added here
};

type ClientStackParamList = {
  ClientDashboard: undefined;
  // Other client screens will be added here
};

// Create navigators
const Tab = createBottomTabNavigator<MainTabParamList>();
const AdminStack = createNativeStackNavigator<AdminStackParamList>();
const InstructorStack = createNativeStackNavigator<InstructorStackParamList>();
const ClientStack = createNativeStackNavigator<ClientStackParamList>();

// Role-specific stack navigators
const AdminNavigator = () => (
  <AdminStack.Navigator>
    <AdminStack.Screen name="AdminDashboard" component={AdminDashboardScreen} />
    {/* Add other admin screens here */}
  </AdminStack.Navigator>
);

const InstructorNavigator = () => (
  <InstructorStack.Navigator>
    <InstructorStack.Screen name="InstructorDashboard" component={InstructorDashboardScreen} />
    {/* Add other instructor screens here */}
  </InstructorStack.Navigator>
);

const ClientNavigator = () => (
  <ClientStack.Navigator>
    <ClientStack.Screen name="ClientDashboard" component={ClientDashboardScreen} />
    {/* Add other client screens here */}
  </ClientStack.Navigator>
);

// Main tab navigator
const MainNavigator: React.FC = () => {
  const { userData } = useSelector((state: RootState) => state.auth);
  const userRole = userData?.role || 'client';

  // Function to get the appropriate home component based on user role
  const getHomeComponent = () => {
    switch (userRole) {
      case 'admin':
        return AdminNavigator;
      case 'instructor':
        return InstructorNavigator;
      case 'client':
      default:
        return ClientNavigator;
    }
  };

  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.disabled,
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
        tabBarStyle: {
          backgroundColor: theme.colors.surface,
          borderTopWidth: 1,
          borderTopColor: '#e0e0e0',
          paddingTop: 5,
          paddingBottom: 5,
          height: 60,
        },
        headerShown: false,
      }}
    >
      <Tab.Screen
        name="Home"
        component={getHomeComponent()}
        options={{
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="home" color={color} size={size} />
          ),
        }}
      />
      <Tab.Screen
        name="Sessions"
        component={SessionsScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="calendar" color={color} size={size} />
          ),
        }}
      />
      <Tab.Screen
        name="Tutorials"
        component={TutorialsScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="play-circle" color={color} size={size} />
          ),
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="account-circle" color={color} size={size} />
          ),
        }}
      />
    </Tab.Navigator>
  );
};

export default MainNavigator;