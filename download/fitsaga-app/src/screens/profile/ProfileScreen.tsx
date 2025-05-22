import React from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  TouchableOpacity, 
  ScrollView, 
  Image,
  Alert
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useAuth } from '../../context/AuthContext';
import { UserRole } from '../../services/auth';

const ProfileScreen = () => {
  const navigation = useNavigation();
  const { user, logout, isAdmin, isInstructor } = useAuth();

  // Handle logout
  const handleLogout = async () => {
    try {
      const result = await logout();
      
      if (!result.success) {
        Alert.alert('Logout Error', result.error || 'Something went wrong during logout');
        return;
      }
      
    } catch (error: any) {
      Alert.alert('Logout Error', error.message || 'An error occurred during logout');
    }
  };

  // Profile menu items
  const menuItems = [
    {
      id: 'personal_info',
      title: 'Personal Information',
      icon: 'person-outline',
      onPress: () => navigation.navigate('PersonalInfo' as never),
    },
    {
      id: 'credits',
      title: 'Credits & Transactions',
      icon: 'card-outline',
      onPress: () => navigation.navigate('Credits' as never),
    },
    {
      id: 'booked_sessions',
      title: 'Booked Sessions',
      icon: 'calendar-outline',
      onPress: () => navigation.navigate('BookedSessions' as never),
    },
    {
      id: 'progress',
      title: 'Progress',
      icon: 'trending-up-outline',
      onPress: () => navigation.navigate('Progress' as never),
    },
    {
      id: 'saved_tutorials',
      title: 'Saved Tutorials',
      icon: 'bookmark-outline',
      onPress: () => navigation.navigate('SavedTutorials' as never),
    },
    {
      id: 'help',
      title: 'Help & Support',
      icon: 'help-circle-outline',
      onPress: () => navigation.navigate('Help' as never),
    },
  ];

  // Admin menu items
  const adminMenuItems = [
    {
      id: 'manage_users',
      title: 'Manage Users',
      icon: 'people-outline',
      onPress: () => Alert.alert('Coming Soon', 'This feature will be available in the next update!'),
    },
    {
      id: 'manage_sessions',
      title: 'Manage Sessions',
      icon: 'calendar-outline',
      onPress: () => Alert.alert('Coming Soon', 'This feature will be available in the next update!'),
    },
    {
      id: 'manage_tutorials',
      title: 'Manage Tutorials',
      icon: 'videocam-outline',
      onPress: () => Alert.alert('Coming Soon', 'This feature will be available in the next update!'),
    },
  ];

  // Instructor menu items
  const instructorMenuItems = [
    {
      id: 'my_sessions',
      title: 'My Sessions',
      icon: 'calendar-outline',
      onPress: () => Alert.alert('Coming Soon', 'This feature will be available in the next update!'),
    },
    {
      id: 'create_session',
      title: 'Create New Session',
      icon: 'add-circle-outline',
      onPress: () => Alert.alert('Coming Soon', 'This feature will be available in the next update!'),
    },
  ];

  // Render a menu item
  const renderMenuItem = (item: any) => (
    <TouchableOpacity 
      key={item.id} 
      style={styles.menuItem} 
      onPress={item.onPress}
    >
      <View style={styles.menuItemContent}>
        <Ionicons name={item.icon} size={24} color="#4C1D95" />
        <Text style={styles.menuItemText}>{item.title}</Text>
      </View>
      <Ionicons name="chevron-forward" size={20} color="#9CA3AF" />
    </TouchableOpacity>
  );

  return (
    <ScrollView style={styles.container}>
      {/* Profile Header */}
      <View style={styles.profileHeader}>
        <View style={styles.profileImageContainer}>
          <Image 
            source={{ uri: 'https://randomuser.me/api/portraits/men/32.jpg' }} 
            style={styles.profileImage} 
          />
          {isAdmin && (
            <View style={styles.roleIndicator}>
              <Text style={styles.roleText}>Admin</Text>
            </View>
          )}
          
          {!isAdmin && isInstructor && (
            <View style={styles.roleIndicator}>
              <Text style={styles.roleText}>Instructor</Text>
            </View>
          )}
        </View>
        
        <Text style={styles.profileName}>{user?.displayName || 'FitSAGA User'}</Text>
        <Text style={styles.profileEmail}>{user?.email || 'user@example.com'}</Text>
        
        <View style={styles.statsContainer}>
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{user?.credits || 0}</Text>
            <Text style={styles.statLabel}>Credits</Text>
          </View>
          
          <View style={styles.statDivider} />
          
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{user?.intervalCredits || 0}</Text>
            <Text style={styles.statLabel}>Interval Credits</Text>
          </View>
        </View>
      </View>

      {/* Main Menu */}
      <View style={styles.menuSection}>
        <Text style={styles.menuTitle}>Account</Text>
        {menuItems.map(renderMenuItem)}
      </View>
      
      {/* Admin Menu (if user is admin) */}
      {isAdmin && (
        <View style={styles.menuSection}>
          <Text style={styles.menuTitle}>Admin Panel</Text>
          {adminMenuItems.map(renderMenuItem)}
        </View>
      )}
      
      {/* Instructor Menu (if user is instructor) */}
      {isInstructor && !isAdmin && (
        <View style={styles.menuSection}>
          <Text style={styles.menuTitle}>Instructor Panel</Text>
          {instructorMenuItems.map(renderMenuItem)}
        </View>
      )}
      
      {/* Logout Button */}
      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Ionicons name="log-out-outline" size={24} color="white" style={styles.logoutIcon} />
        <Text style={styles.logoutText}>Logout</Text>
      </TouchableOpacity>
      
      {/* App Version */}
      <Text style={styles.versionText}>FitSAGA v1.0.0</Text>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7f7f7',
  },
  profileHeader: {
    padding: 24,
    backgroundColor: 'white',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: '#E5E7EB',
  },
  profileImageContainer: {
    position: 'relative',
    marginBottom: 16,
  },
  profileImage: {
    width: 100,
    height: 100,
    borderRadius: 50,
  },
  roleIndicator: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    backgroundColor: '#4C1D95',
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 12,
  },
  roleText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  profileName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 4,
  },
  profileEmail: {
    fontSize: 16,
    color: '#6B7280',
    marginBottom: 16,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    width: '80%',
    paddingVertical: 16,
    backgroundColor: '#F9FAFB',
    borderRadius: 12,
  },
  statItem: {
    alignItems: 'center',
    flex: 1,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#4C1D95',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 14,
    color: '#6B7280',
  },
  statDivider: {
    width: 1,
    height: '80%',
    backgroundColor: '#E5E7EB',
  },
  menuSection: {
    marginTop: 24,
    backgroundColor: 'white',
    borderRadius: 12,
    marginHorizontal: 16,
    padding: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
    marginBottom: 16,
  },
  menuTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
  },
  menuItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  menuItemText: {
    fontSize: 16,
    color: '#4B5563',
    marginLeft: 12,
  },
  logoutButton: {
    backgroundColor: '#EF4444',
    marginHorizontal: 16,
    padding: 16,
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 24,
  },
  logoutIcon: {
    marginRight: 8,
  },
  logoutText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: 'white',
  },
  versionText: {
    textAlign: 'center',
    fontSize: 14,
    color: '#9CA3AF',
    marginBottom: 32,
  },
});

export default ProfileScreen;