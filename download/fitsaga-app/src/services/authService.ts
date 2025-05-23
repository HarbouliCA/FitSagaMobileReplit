// Authentication service for handling user authentication and account management

import { initializeApp } from "firebase/app";
import { 
  getAuth, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signOut,
  User as FirebaseUser,
  updateProfile
} from "firebase/auth";
import { getFirestore, doc, setDoc, getDoc, updateDoc } from "firebase/firestore";

// Define user roles
export type UserRole = 'admin' | 'instructor' | 'client';

// Define user interface
export interface FitSagaUser {
  uid: string;
  email: string;
  displayName: string;
  role: UserRole;
  credits: number;
  intervalCredits: number;
  memberSince: string;
  profileImageUrl?: string;
}

// Define response interfaces
interface AuthResponse {
  success: boolean;
  user?: FitSagaUser;
  error?: string;
}

// Initialize Firebase (using environment variables in a real app)
const firebaseConfig = {
  apiKey: process.env.VITE_FIREBASE_API_KEY || "mock-api-key",
  projectId: process.env.VITE_FIREBASE_PROJECT_ID || "mock-project-id",
  appId: process.env.VITE_FIREBASE_APP_ID || "mock-app-id",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

/**
 * Register a new user
 */
export const registerUser = async (
  email: string,
  password: string,
  displayName: string
): Promise<AuthResponse> => {
  try {
    // Create user with email and password
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const { user } = userCredential;
    
    // Update user profile with display name
    await updateProfile(user, { displayName });
    
    // Create user document in Firestore
    const newUser: FitSagaUser = {
      uid: user.uid,
      email: user.email || email,
      displayName: displayName,
      role: 'client', // Default role
      credits: 20, // Starting credits
      intervalCredits: 5, // Starting interval credits
      memberSince: new Date().toISOString(),
    };
    
    // In a real app, this would create a document in Firestore
    // await setDoc(doc(db, "users", user.uid), newUser);
    
    // For now, we'll just store in localStorage
    localStorage.setItem(`user_${user.uid}`, JSON.stringify(newUser));
    
    return { success: true, user: newUser };
  } catch (error: any) {
    console.error('Error registering user:', error);
    return {
      success: false,
      error: error.message || 'Failed to register user'
    };
  }
};

/**
 * Log in existing user
 */
export const loginUser = async (
  email: string,
  password: string
): Promise<AuthResponse> => {
  try {
    // Sign in with email and password
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const { user } = userCredential;
    
    // Get user data from Firestore (or localStorage in this mock implementation)
    const userData = await getUserData(user);
    
    if (!userData) {
      return {
        success: false,
        error: 'User data not found'
      };
    }
    
    return { success: true, user: userData };
  } catch (error: any) {
    console.error('Error logging in:', error);
    return {
      success: false,
      error: error.message || 'Failed to log in'
    };
  }
};

/**
 * Log out current user
 */
export const logoutUser = async (): Promise<{ success: boolean, error?: string }> => {
  try {
    await signOut(auth);
    return { success: true };
  } catch (error: any) {
    console.error('Error logging out:', error);
    return {
      success: false,
      error: error.message || 'Failed to log out'
    };
  }
};

/**
 * Get user data from Firestore or localStorage
 */
export const getUserData = async (user: FirebaseUser): Promise<FitSagaUser | null> => {
  try {
    // In a real app, this would get the document from Firestore
    // const docRef = doc(db, "users", user.uid);
    // const docSnap = await getDoc(docRef);
    // if (docSnap.exists()) {
    //   return docSnap.data() as FitSagaUser;
    // }
    
    // For now, we'll just get from localStorage
    const userData = localStorage.getItem(`user_${user.uid}`);
    if (userData) {
      return JSON.parse(userData) as FitSagaUser;
    }
    
    // If no data found, create a default user profile
    const defaultUser: FitSagaUser = {
      uid: user.uid,
      email: user.email || '',
      displayName: user.displayName || 'FitSAGA User',
      role: 'client',
      credits: 20,
      intervalCredits: 5,
      memberSince: new Date().toISOString(),
    };
    
    // Store default user in localStorage
    localStorage.setItem(`user_${user.uid}`, JSON.stringify(defaultUser));
    
    return defaultUser;
  } catch (error) {
    console.error('Error getting user data:', error);
    return null;
  }
};

/**
 * Update user credits
 */
export const updateUserCredits = async (
  userId: string,
  newCredits: number,
  newIntervalCredits: number
): Promise<{ success: boolean, error?: string }> => {
  try {
    // In a real app, this would update the document in Firestore
    // const userRef = doc(db, "users", userId);
    // await updateDoc(userRef, { 
    //   credits: newCredits,
    //   intervalCredits: newIntervalCredits
    // });
    
    // For now, we'll just update in localStorage
    const userData = localStorage.getItem(`user_${userId}`);
    if (userData) {
      const user = JSON.parse(userData) as FitSagaUser;
      user.credits = newCredits;
      user.intervalCredits = newIntervalCredits;
      localStorage.setItem(`user_${userId}`, JSON.stringify(user));
      return { success: true };
    }
    
    return { 
      success: false,
      error: 'User not found'
    };
  } catch (error: any) {
    console.error('Error updating user credits:', error);
    return {
      success: false,
      error: error.message || 'Failed to update credits'
    };
  }
};

/**
 * Update user profile information
 */
export const updateUserProfile = async (
  userId: string,
  updates: Partial<FitSagaUser>
): Promise<{ success: boolean, error?: string }> => {
  try {
    // In a real app, this would update the document in Firestore
    // const userRef = doc(db, "users", userId);
    // await updateDoc(userRef, updates);
    
    // For now, we'll just update in localStorage
    const userData = localStorage.getItem(`user_${userId}`);
    if (userData) {
      const user = JSON.parse(userData) as FitSagaUser;
      const updatedUser = { ...user, ...updates };
      localStorage.setItem(`user_${userId}`, JSON.stringify(updatedUser));
      return { success: true };
    }
    
    return { 
      success: false,
      error: 'User not found'
    };
  } catch (error: any) {
    console.error('Error updating user profile:', error);
    return {
      success: false,
      error: error.message || 'Failed to update profile'
    };
  }
};