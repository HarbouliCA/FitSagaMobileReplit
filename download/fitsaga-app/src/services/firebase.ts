import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';
import { getAnalytics } from 'firebase/analytics';

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCvfH-loyKanakWeQhHCIBfeAIVF-aFW5o", // Android API key
  authDomain: "saga-fitness.firebaseapp.com",
  projectId: "saga-fitness",
  storageBucket: "saga-fitness.firebasestorage.app", // Updated storage bucket
  messagingSenderId: "360667066098",
  appId: "1:360667066098:web:93bef4a0c957968c67aa6b",
  measurementId: "G-GCZRZ22EYL"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

// Only initialize analytics in web environments that support it
let analytics = null;
if (typeof window !== 'undefined') {
  try {
    analytics = getAnalytics(app);
  } catch (e) {
    console.log('Analytics not supported in this environment');
  }
}
export { analytics };

export default app;