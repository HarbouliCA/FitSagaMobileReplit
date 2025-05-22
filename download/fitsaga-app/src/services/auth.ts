import { User, UserCredential } from 'firebase/auth';
import { 
  loginWithEmail, 
  registerWithEmail, 
  logoutUser, 
  getCurrentUser 
} from './firebase';
import AsyncStorage from '@react-native-async-storage/async-storage';

// User roles
export enum UserRole {
  CLIENT = 'client',
  INSTRUCTOR = 'instructor',
  ADMIN = 'admin'
}

// User model
export interface FitSagaUser {
  uid: string;
  email: string;
  displayName: string | null;
  role: UserRole;
  credits: number;
  intervalCredits: number;
}

// Login helper
export const login = async (email: string, password: string): Promise<{user: FitSagaUser | null, error: string | null}> => {
  try {
    const result = await loginWithEmail(email, password);
    
    if (result.error) {
      return { user: null, error: result.error };
    }
    
    if (!result.user) {
      return { user: null, error: 'Unknown error occurred during login' };
    }
    
    // Get user role and other data, or use defaults for new users
    const userData = await getUserData(result.user.uid);
    
    if (userData) {
      // Store user data in AsyncStorage for future use
      await AsyncStorage.setItem('user', JSON.stringify(userData));
      return { user: userData, error: null };
    } else {
      // If no user data, create default data for client role
      const newUser: FitSagaUser = {
        uid: result.user.uid,
        email: result.user.email || email,
        displayName: result.user.displayName,
        role: UserRole.CLIENT, // Default role
        credits: 10, // Default credits
        intervalCredits: 5 // Default interval credits
      };
      
      // Save new user data
      await saveUserData(newUser);
      
      // Store in AsyncStorage
      await AsyncStorage.setItem('user', JSON.stringify(newUser));
      
      return { user: newUser, error: null };
    }
  } catch (error: any) {
    return { user: null, error: error.message || 'Login failed' };
  }
};

// Register helper
export const register = async (
  email: string, 
  password: string, 
  displayName: string
): Promise<{user: FitSagaUser | null, error: string | null}> => {
  try {
    const result = await registerWithEmail(email, password);
    
    if (result.error) {
      return { user: null, error: result.error };
    }
    
    if (!result.user) {
      return { user: null, error: 'Unknown error occurred during registration' };
    }
    
    // Create new user with default values
    const newUser: FitSagaUser = {
      uid: result.user.uid,
      email: result.user.email || email,
      displayName: displayName,
      role: UserRole.CLIENT, // Default role for new users
      credits: 10, // Default starting credits
      intervalCredits: 5 // Default interval credits
    };
    
    // Save user data
    await saveUserData(newUser);
    
    // Store in AsyncStorage
    await AsyncStorage.setItem('user', JSON.stringify(newUser));
    
    return { user: newUser, error: null };
  } catch (error: any) {
    return { user: null, error: error.message || 'Registration failed' };
  }
};

// Logout helper
export const logout = async (): Promise<{success: boolean, error: string | null}> => {
  try {
    const result = await logoutUser();
    
    if (!result.success) {
      return { success: false, error: result.error };
    }
    
    // Clear AsyncStorage user data
    await AsyncStorage.removeItem('user');
    
    return { success: true, error: null };
  } catch (error: any) {
    return { success: false, error: error.message || 'Logout failed' };
  }
};

// Get current user from AsyncStorage
export const getCurrentUserFromStorage = async (): Promise<FitSagaUser | null> => {
  try {
    const userData = await AsyncStorage.getItem('user');
    
    if (userData) {
      return JSON.parse(userData) as FitSagaUser;
    }
    
    return null;
  } catch (error) {
    console.error('Error getting user from storage:', error);
    return null;
  }
};

// Mock function to save user data (would be replaced with Firestore in production)
const saveUserData = async (user: FitSagaUser): Promise<boolean> => {
  try {
    // In a real app, this would be a call to Firestore
    // For simplicity, we'll just mock it by saving it to AsyncStorage
    await AsyncStorage.setItem(`userdata_${user.uid}`, JSON.stringify(user));
    return true;
  } catch (error) {
    console.error('Error saving user data:', error);
    return false;
  }
};

// Mock function to get user data (would be replaced with Firestore in production)
const getUserData = async (uid: string): Promise<FitSagaUser | null> => {
  try {
    // In a real app, this would be a call to Firestore
    // For simplicity, we'll just mock it by getting it from AsyncStorage
    const userData = await AsyncStorage.getItem(`userdata_${uid}`);
    
    if (userData) {
      return JSON.parse(userData) as FitSagaUser;
    }
    
    return null;
  } catch (error) {
    console.error('Error getting user data:', error);
    return null;
  }
};

// Check if user has admin role
export const isAdmin = (user: FitSagaUser | null): boolean => {
  return !!user && user.role === UserRole.ADMIN;
};

// Check if user has instructor role
export const isInstructor = (user: FitSagaUser | null): boolean => {
  return !!user && (user.role === UserRole.INSTRUCTOR || user.role === UserRole.ADMIN);
};

// Check if user has client role
export const isClient = (user: FitSagaUser | null): boolean => {
  return !!user && user.role === UserRole.CLIENT;
};

// Check if user has enough credits for a session
export const hasEnoughCredits = (user: FitSagaUser | null, cost: number, isIntervalSession: boolean = false): boolean => {
  if (!user) return false;
  
  if (isIntervalSession) {
    return user.intervalCredits >= cost;
  } else {
    return user.credits >= cost;
  }
};

// Update user credits
export const updateCredits = async (
  uid: string, 
  credits: number, 
  intervalCredits?: number
): Promise<boolean> => {
  try {
    const userData = await getUserData(uid);
    
    if (!userData) {
      return false;
    }
    
    const updatedUser: FitSagaUser = {
      ...userData,
      credits,
      intervalCredits: intervalCredits !== undefined ? intervalCredits : userData.intervalCredits
    };
    
    // Save updated user
    await saveUserData(updatedUser);
    
    // Update AsyncStorage if this is the current user
    const currentUser = await getCurrentUserFromStorage();
    if (currentUser && currentUser.uid === uid) {
      await AsyncStorage.setItem('user', JSON.stringify(updatedUser));
    }
    
    return true;
  } catch (error) {
    console.error('Error updating credits:', error);
    return false;
  }
};