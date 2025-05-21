import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Text, Card, Title, Avatar } from 'react-native-paper';
import { useDispatch, useSelector } from 'react-redux';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { doc, updateDoc } from 'firebase/firestore';

import { RootState } from '../../redux/store';
import { db } from '../../services/firebase';
import { theme, typography, spacing } from '../../theme';

type RoleSelectionScreenProp = NativeStackNavigationProp<any>;

const RoleSelectionScreen: React.FC = () => {
  const [selectedRole, setSelectedRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  
  const dispatch = useDispatch();
  const navigation = useNavigation<RoleSelectionScreenProp>();
  const { user, userData } = useSelector((state: RootState) => state.auth);

  const handleRoleSelect = async (role: 'admin' | 'instructor' | 'client') => {
    if (!user) return;
    
    setSelectedRole(role);
    setLoading(true);
    
    try {
      // Update user role in Firestore
      await updateDoc(doc(db, 'users', user.uid), {
        role,
        lastActive: new Date()
      });
      
      // Navigate to the appropriate dashboard
      switch (role) {
        case 'admin':
          navigation.navigate('Main', { screen: 'Home' });
          break;
        case 'instructor':
          navigation.navigate('Main', { screen: 'Home' });
          break;
        case 'client':
          navigation.navigate('Main', { screen: 'Home' });
          break;
      }
    } catch (error) {
      console.error('Error updating role:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.logoContainer}>
        <Avatar.Icon 
          size={80} 
          icon="dumbbell" 
          color="#fff" 
          style={{ backgroundColor: theme.colors.primary }} 
        />
        <Title style={styles.logoTitle}>FitSAGA</Title>
        <Text style={styles.subtitle}>Gym Management App</Text>
      </View>

      <Text style={styles.selectionTitle}>Select Your Role</Text>

      <TouchableOpacity 
        onPress={() => handleRoleSelect('admin')}
        disabled={loading}
      >
        <Card 
          style={[
            styles.roleCard, 
            { borderColor: '#E53935' },
            selectedRole === 'admin' && styles.selectedCard
          ]}
        >
          <Card.Content style={styles.roleCardContent}>
            <Avatar.Icon 
              size={40} 
              icon="shield-account" 
              color="#fff" 
              style={{ backgroundColor: '#E53935' }} 
            />
            <View style={styles.roleTextContainer}>
              <Title style={styles.roleTitle}>Admin</Title>
              <Text style={styles.roleDescription}>Manage users, sessions, and system settings</Text>
            </View>
          </Card.Content>
        </Card>
      </TouchableOpacity>

      <TouchableOpacity 
        onPress={() => handleRoleSelect('instructor')}
        disabled={loading}
      >
        <Card 
          style={[
            styles.roleCard, 
            { borderColor: '#4CAF50' },
            selectedRole === 'instructor' && styles.selectedCard
          ]}
        >
          <Card.Content style={styles.roleCardContent}>
            <Avatar.Icon 
              size={40} 
              icon="account-tie" 
              color="#fff" 
              style={{ backgroundColor: '#4CAF50' }} 
            />
            <View style={styles.roleTextContainer}>
              <Title style={styles.roleTitle}>Instructor</Title>
              <Text style={styles.roleDescription}>Create sessions, manage clients, and track progress</Text>
            </View>
          </Card.Content>
        </Card>
      </TouchableOpacity>

      <TouchableOpacity 
        onPress={() => handleRoleSelect('client')}
        disabled={loading}
      >
        <Card 
          style={[
            styles.roleCard, 
            { borderColor: '#2196F3' },
            selectedRole === 'client' && styles.selectedCard
          ]}
        >
          <Card.Content style={styles.roleCardContent}>
            <Avatar.Icon 
              size={40} 
              icon="account" 
              color="#fff" 
              style={{ backgroundColor: '#2196F3' }} 
            />
            <View style={styles.roleTextContainer}>
              <Title style={styles.roleTitle}>Client</Title>
              <Text style={styles.roleDescription}>Book sessions, access tutorials, and track your fitness</Text>
            </View>
          </Card.Content>
        </Card>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: spacing.m,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: theme.colors.background,
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  logoTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: theme.colors.primary,
    marginTop: spacing.m,
  },
  subtitle: {
    color: theme.colors.placeholder,
    marginTop: spacing.xs,
  },
  selectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: spacing.l,
  },
  roleCard: {
    marginBottom: spacing.m,
    width: 320,
    borderWidth: 2,
    elevation: 3,
  },
  selectedCard: {
    backgroundColor: '#F5F5F5',
    borderWidth: 3,
  },
  roleCardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.m,
  },
  roleTextContainer: {
    marginLeft: spacing.m,
    flex: 1,
  },
  roleTitle: {
    fontSize: 18,
    marginBottom: spacing.xs,
  },
  roleDescription: {
    fontSize: 12,
    color: theme.colors.placeholder,
  },
});

export default RoleSelectionScreen;