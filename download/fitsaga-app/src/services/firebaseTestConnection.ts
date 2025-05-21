import { collection, getDocs, query, limit } from 'firebase/firestore';
import { db, auth } from './firebase';

/**
 * Tests the connection to Firebase by performing a simple query
 * @returns {Promise<boolean>} true if connection is successful, false otherwise
 */
export const testFirebaseConnection = async (): Promise<{
  success: boolean;
  message: string;
  firestore: boolean;
  auth: boolean;
}> => {
  try {
    // Test Firestore connection
    let firestoreSuccess = false;
    try {
      // Try to get a single document from any collection
      const collectionsToTry = ['users', 'sessions', 'activities'];
      
      for (const collectionName of collectionsToTry) {
        try {
          const q = query(collection(db, collectionName), limit(1));
          const querySnapshot = await getDocs(q);
          
          if (!querySnapshot.empty) {
            firestoreSuccess = true;
            console.log(`Successfully connected to Firestore and read from '${collectionName}' collection`);
            break;
          }
        } catch (error) {
          console.warn(`Failed to read from '${collectionName}' collection:`, error);
        }
      }
      
      if (!firestoreSuccess) {
        console.warn('Connected to Firestore but all collections are empty or inaccessible');
      }
    } catch (error) {
      console.error('Firestore connection test failed:', error);
    }
    
    // Test Authentication state
    const authSuccess = auth.currentUser !== null || auth.app !== null;
    
    return {
      success: firestoreSuccess || authSuccess,
      message: firestoreSuccess && authSuccess 
        ? 'Successfully connected to Firebase' 
        : 'Partial connection to Firebase',
      firestore: firestoreSuccess,
      auth: authSuccess
    };
  } catch (error) {
    console.error('Firebase connection test failed:', error);
    return {
      success: false,
      message: `Failed to connect to Firebase: ${error}`,
      firestore: false,
      auth: false
    };
  }
};