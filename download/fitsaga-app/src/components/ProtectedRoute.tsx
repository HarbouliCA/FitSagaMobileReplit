import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useAuth } from '../context/AuthContext';
import { UserRole } from '../services/auth';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: UserRole[];
  fallbackComponent?: React.ReactNode;
}

/**
 * A component that renders its children only if the current user
 * has one of the allowed roles. Otherwise, it renders a fallback component.
 */
const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  allowedRoles = [],
  fallbackComponent
}) => {
  const { user, isLoggedIn } = useAuth();

  // If user is not logged in, show the fallback component or a default message
  if (!isLoggedIn) {
    if (fallbackComponent) {
      return <>{fallbackComponent}</>;
    }
    
    return (
      <View style={styles.container}>
        <Text style={styles.message}>Please log in to access this content</Text>
      </View>
    );
  }

  // If there are no specific allowed roles, or the user's role is allowed, render the children
  if (allowedRoles.length === 0 || (user && allowedRoles.includes(user.role))) {
    return <>{children}</>;
  }

  // If user is logged in but doesn't have the required role, show the fallback or a default message
  if (fallbackComponent) {
    return <>{fallbackComponent}</>;
  }

  return (
    <View style={styles.container}>
      <Text style={styles.message}>You don't have permission to access this content</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#f7f7f7',
  },
  message: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#4C1D95',
    textAlign: 'center',
    marginBottom: 20,
  },
});

export default ProtectedRoute;