import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { auth, db } from '../../services/firebase';

const initialState = {
  isAuthenticated: false,
  user: null,
  userData: null,
  loading: false,
  error: null,
};

// Login user action
export const loginUser = createAsyncThunk(
  'auth/login',
  async ({ email, password }, { rejectWithValue }) => {
    try {
      // Sign in with Firebase auth
      const userCredential = await auth().signInWithEmailAndPassword(email, password);
      
      // Get user data from Firestore
      const userDoc = await db().collection('users').doc(userCredential.user.uid).get();
      
      if (!userDoc.exists) {
        throw new Error('User data not found');
      }
      
      return {
        user: userCredential.user,
        userData: { id: userDoc.id, ...userDoc.data() }
      };
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Register user action
export const registerUser = createAsyncThunk(
  'auth/register',
  async ({ email, password, userData }, { rejectWithValue }) => {
    try {
      // Create user with Firebase auth
      const userCredential = await auth().createUserWithEmailAndPassword(email, password);
      
      // Add user data to Firestore
      const userRef = db().collection('users').doc(userCredential.user.uid);
      await userRef.set({
        ...userData,
        email,
        createdAt: new Date().toISOString(),
        credits: {
          gymCredits: 10, // Initial credits
          intervalCredits: 0,
          lastRefilled: new Date().toISOString(),
          nextRefillDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days from now
        }
      });
      
      // Get created user data
      const userDoc = await userRef.get();
      
      return {
        user: userCredential.user,
        userData: { id: userDoc.id, ...userDoc.data() }
      };
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Logout user action
export const logoutUser = createAsyncThunk(
  'auth/logout',
  async (_, { rejectWithValue }) => {
    try {
      await auth().signOut();
      return true;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Reset password action
export const resetPassword = createAsyncThunk(
  'auth/resetPassword',
  async (email, { rejectWithValue }) => {
    try {
      await auth().sendPasswordResetEmail(email);
      return 'Password reset email sent';
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Auth slice
const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    // Set user and auth state from session persistence
    setUser: (state, action) => {
      state.isAuthenticated = true;
      state.user = action.payload.user;
      state.userData = action.payload.userData;
    },
    // Clear any auth errors
    clearError: (state) => {
      state.error = null;
    },
    // Update user data (e.g., after profile update)
    updateUserData: (state, action) => {
      state.userData = { ...state.userData, ...action.payload };
    }
  },
  extraReducers: (builder) => {
    // Login cases
    builder.addCase(loginUser.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(loginUser.fulfilled, (state, action) => {
      state.isAuthenticated = true;
      state.user = action.payload.user;
      state.userData = action.payload.userData;
      state.loading = false;
      state.error = null;
    });
    builder.addCase(loginUser.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
    
    // Register cases
    builder.addCase(registerUser.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(registerUser.fulfilled, (state, action) => {
      state.isAuthenticated = true;
      state.user = action.payload.user;
      state.userData = action.payload.userData;
      state.loading = false;
      state.error = null;
    });
    builder.addCase(registerUser.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
    
    // Logout cases
    builder.addCase(logoutUser.pending, (state) => {
      state.loading = true;
    });
    builder.addCase(logoutUser.fulfilled, (state) => {
      state.isAuthenticated = false;
      state.user = null;
      state.userData = null;
      state.loading = false;
      state.error = null;
    });
    builder.addCase(logoutUser.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
    
    // Reset password cases
    builder.addCase(resetPassword.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(resetPassword.fulfilled, (state) => {
      state.loading = false;
      state.error = null;
    });
    builder.addCase(resetPassword.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
  },
});

export const { setUser, clearError, updateUserData } = authSlice.actions;

export default authSlice.reducer;