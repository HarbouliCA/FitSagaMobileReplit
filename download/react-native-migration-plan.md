# FitSAGA Migration Plan: Flutter to React Native with Expo

## 1. Project Overview

FitSAGA is transitioning from Flutter to React Native with Expo while maintaining all core functionality:

- Role-based access (Admin, Instructor, Client)
- Firebase integration for authentication and data storage
- Credit-based booking system (Gym Credits and Interval Credits)
- Tutorial system with video content
- Session management and scheduling

## 2. Technology Stack

| Category | Technology |
|----------|------------|
| Framework | React Native |
| Development Platform | Expo |
| UI Library | React Native Paper |
| Navigation | React Navigation |
| State Management | Redux Toolkit |
| Authentication | Firebase Authentication |
| Database | Firestore |
| Storage | Firebase Storage |
| Form Handling | Formik + Yup |
| Video Playback | Expo AV |
| Offline Support | AsyncStorage + Redux Persist |
| Testing | Jest + React Native Testing Library |

## 3. Directory Structure

```
/src
  /assets              # Images, icons, and other static assets
  /components          # Reusable UI components
    /auth              # Authentication-related components
    /booking           # Session booking components
    /credits           # Credit system components
    /layout            # Layout components (headers, footers, etc.)
    /sessions          # Session management components  
    /tutorials         # Tutorial system components
    /ui                # Generic UI components
  /config              # Configuration files
  /constants           # App constants and enums
  /contexts            # React contexts
  /hooks               # Custom React hooks
  /navigation          # Navigation configuration
  /redux               # Redux store, slices, and actions
    /features          # Feature-specific slices
    /middleware        # Redux middleware
  /screens             # App screens
    /admin             # Admin role screens
    /auth              # Authentication screens
    /client            # Client role screens
    /instructor        # Instructor role screens
    /shared            # Screens shared across roles
  /services            # API and service integrations
  /theme               # App theming
  /types               # TypeScript type definitions
  /utils               # Utility functions
  App.tsx              # Root component
```

## 4. Implementation Plan

### Phase 1: Project Setup & Authentication (Week 1)

1. **Project Initialization**
   - Initialize Expo project using TypeScript template
   - Configure ESLint and Prettier
   - Set up directory structure
   - Install core dependencies

2. **Firebase Integration**
   - Initialize Firebase with React Native
   - Configure Firebase Authentication
   - Set up Firestore and storage connections
   - Create Firebase service utilities

3. **Authentication Flow**
   - Implement login screen
   - Create registration flow
   - Implement role selection and verification
   - Create protected routes based on user roles

### Phase 2: Core UI & Navigation Framework (Week 2)

1. **Theming & UI Components**
   - Set up global theme variables
   - Create core UI components (buttons, inputs, cards)
   - Implement responsive layouts
   - Create loading and error state components

2. **Navigation Structure**
   - Implement stack navigation for auth flow
   - Create role-based navigation (admin/instructor/client)
   - Implement tab navigation for main sections
   - Add deep linking support

3. **Role-based Dashboard**
   - Create dashboard screens for each role
   - Implement data fetching from Firestore
   - Create summary stats and metrics components
   - Implement user profile screens

### Phase 3: Credit System Implementation (Week 3)

1. **Credit Models & Services**
   - Define credit data structures
   - Create credit service for operations
   - Implement credit tracking and updates
   - Create credit history components

2. **Credit UI Components**
   - Build credit balance displays
   - Create credit usage summaries
   - Implement credit transaction history
   - Add low credit warnings and notifications

3. **Credit Management (Admin)**
   - Create credit adjustment interface
   - Implement credit allocation system
   - Build credit audit logging
   - Add credit reset functionality

### Phase 4: Session & Booking System (Week 4)

1. **Session Management**
   - Implement session listing and filtering
   - Create session detail views
   - Add session creation (admin/instructor)
   - Implement session editing and cancellation

2. **Booking System**
   - Create booking flow with credit validation
   - Implement booking confirmation
   - Add booking management interfaces
   - Create booking history views

3. **Calendar Integration**
   - Implement calendar views for sessions
   - Add scheduling components
   - Create availability management (instructor)
   - Implement recurring session handling

### Phase 5: Tutorial System (Week 5)

1. **Tutorial Data Structure**
   - Define tutorial models
   - Create Firebase service for tutorials
   - Implement tutorial metadata handling
   - Build tutorial data fetching logic

2. **Tutorial Listing & Navigation**
   - Create tutorial browsing interfaces
   - Implement tutorial filtering and sorting
   - Add tutorial detail views
   - Create tutorial progress tracking

3. **Video Integration**
   - Implement video player components
   - Add video caching for offline viewing
   - Create video thumbnails and previews
   - Build exercise instruction components

### Phase 6: Admin & Management Features (Week 6)

1. **User Management**
   - Create user listing and search
   - Implement user detail views
   - Add user role management
   - Build user metrics and reporting

2. **Instructor Tools**
   - Implement session creation workflow
   - Create attendance tracking
   - Add client progress monitoring
   - Build schedule management tools

3. **Analytics & Reports**
   - Implement usage analytics
   - Create credit usage reports
   - Add session popularity metrics
   - Build instructor performance tracking

### Phase 7: Testing & Optimization (Week 7)

1. **Unit & Integration Testing**
   - Write tests for core services
   - Create component test suite
   - Implement navigation tests
   - Add form validation tests

2. **Performance Optimization**
   - Implement list virtualization
   - Add image optimization
   - Create lazy loading strategies
   - Optimize Firebase queries

3. **Offline Support**
   - Implement data caching
   - Add offline action queueing
   - Create offline UI indicators
   - Build sync conflict resolution

### Phase 8: Deployment & Documentation (Week 8)

1. **Expo Build Configuration**
   - Configure app.json
   - Set up environment variables
   - Create build profiles
   - Configure notifications

2. **CI/CD Pipeline**
   - Set up GitHub Actions workflow
   - Create automated tests
   - Configure deployment pipelines
   - Add version management

3. **Documentation**
   - Create technical documentation
   - Add code comments and JSDoc
   - Create user guides
   - Build developer onboarding

## 5. Key Components Mapping

### Authentication

| Flutter Component | React Native Equivalent |
|-------------------|-------------------------|
| `AuthProvider` | Redux auth slice + Firebase service |
| `LoginScreen` | `AuthScreen` with login form |
| `RegisterScreen` | `RegisterScreen` with multi-step form |
| `RoleSelectionScreen` | `RoleSelectionScreen` with role cards |

### Credit System

| Flutter Component | React Native Equivalent |
|-------------------|-------------------------|
| `CreditProvider` | Redux credits slice + middleware |
| `CreditDisplay` | `CreditBalanceCard` component |
| `CreditHistory` | `TransactionHistoryScreen` with virtualized list |
| `CreditAdjuster` | `AdminCreditAdjustmentScreen` with form |

### Booking System

| Flutter Component | React Native Equivalent |
|-------------------|-------------------------|
| `SessionProvider` | Redux sessions slice + Firebase service |
| `BookingScreen` | `BookingProcessScreen` with credit validation |
| `SessionList` | `SessionListScreen` with filters and search |
| `SessionDetail` | `SessionDetailScreen` with booking options |

### Tutorial System

| Flutter Component | React Native Equivalent |
|-------------------|-------------------------|
| `TutorialProvider` | Redux tutorials slice + Firebase service |
| `TutorialScreen` | `TutorialLibraryScreen` with categories |
| `TutorialDetail` | `TutorialDetailScreen` with progress tracking |
| `VideoPlayer` | Custom `VideoPlayerComponent` using Expo AV |

## 6. Data Migration Strategy

### Firebase Data Structures

No migration needed for the data itself as we'll continue using the same Firebase project. The Firestore schema will remain unchanged:

- `users` collection for authentication and profiles
- `instructors` collection for instructor profiles
- `activities` collection for activity types
- `sessions` collection for scheduled sessions
- `tutorials` collection for tutorial content
- `forum_threads` collection for community discussions
- `clients` collection for client data
- `contracts` collection for legal agreements
- `videoMetadata` collection for video information

### Model Adapters

We'll create adapter functions to map between Firebase documents and TypeScript interfaces:

```typescript
// Example adapter for UserModel
export const userFromFirestore = (doc: FirebaseFirestore.DocumentSnapshot): UserModel => {
  const data = doc.data();
  return {
    uid: doc.id,
    email: data?.email || '',
    name: data?.name || '',
    photoURL: data?.photoURL,
    credits: data?.credits || 0,
    role: data?.role || 'user',
    memberSince: data?.memberSince?.toDate() || new Date(),
    lastActive: data?.lastActive?.toDate() || new Date(),
    // ... map remaining fields
  };
};
```

## 7. Firebase Integration

### Authentication Setup

```typescript
// firebase.ts
import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: "AIzaSyD3MAuIYZ2dGq5hspUvxK4KeNIbVzw6EaQ",
  authDomain: "saga-fitness.firebaseapp.com",
  projectId: "saga-fitness",
  storageBucket: "saga-fitness.appspot.com",
  messagingSenderId: "360667066098",
  appId: "1:360667066098:web:93bef4a0c957968c67aa6b",
  measurementId: "G-GCZRZ22EYL"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

export { app, auth, db, storage };
```

### Authentication Services

```typescript
// authService.ts
import { auth, db } from '../firebase';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { 
  createUserWithEmailAndPassword, 
  signInWithEmailAndPassword, 
  signOut 
} from 'firebase/auth';

export const signIn = async (email: string, password: string) => {
  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;
    
    // Get additional user data from Firestore
    const userDoc = await getDoc(doc(db, 'users', user.uid));
    return { user, userData: userDoc.data() };
  } catch (error) {
    throw error;
  }
};

export const registerUser = async (email: string, password: string, userData: any) => {
  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;
    
    // Save additional user data to Firestore
    await setDoc(doc(db, 'users', user.uid), {
      ...userData,
      memberSince: new Date(),
      lastActive: new Date(),
    });
    
    return { user };
  } catch (error) {
    throw error;
  }
};

export const logout = async () => {
  try {
    await signOut(auth);
  } catch (error) {
    throw error;
  }
};
```

## 8. Key Redux Slices

### Auth Slice

```typescript
// authSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { signIn, registerUser, logout } from '../../services/authService';

export const loginUser = createAsyncThunk(
  'auth/login',
  async ({ email, password }: { email: string, password: string }, { rejectWithValue }) => {
    try {
      const response = await signIn(email, password);
      return response;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const registerNewUser = createAsyncThunk(
  'auth/register',
  async ({ email, password, userData }: { email: string, password: string, userData: any }, { rejectWithValue }) => {
    try {
      const response = await registerUser(email, password, userData);
      return response;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const logoutUser = createAsyncThunk(
  'auth/logout',
  async (_, { rejectWithValue }) => {
    try {
      await logout();
      return null;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState: {
    user: null,
    userData: null,
    status: 'idle',
    error: null,
  },
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(loginUser.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(loginUser.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.user = action.payload.user;
        state.userData = action.payload.userData;
        state.error = null;
      })
      .addCase(loginUser.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload;
      })
      // Similar patterns for registerNewUser and logoutUser
  },
});

export const { clearError } = authSlice.actions;
export default authSlice.reducer;
```

### Credits Slice

```typescript
// creditsSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { 
  getUserCredits, 
  updateUserCredits, 
  getCreditHistory 
} from '../../services/creditService';

export const fetchUserCredits = createAsyncThunk(
  'credits/fetchUserCredits',
  async (userId: string, { rejectWithValue }) => {
    try {
      const credits = await getUserCredits(userId);
      return credits;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const adjustCredits = createAsyncThunk(
  'credits/adjustCredits',
  async ({ userId, amount, reason }: { userId: string, amount: number, reason: string }, { rejectWithValue }) => {
    try {
      const result = await updateUserCredits(userId, amount, reason);
      return result;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const fetchCreditHistory = createAsyncThunk(
  'credits/fetchCreditHistory',
  async (userId: string, { rejectWithValue }) => {
    try {
      const history = await getCreditHistory(userId);
      return history;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

const creditsSlice = createSlice({
  name: 'credits',
  initialState: {
    balance: {
      total: 0,
      intervalCredits: 0,
      lastRefilled: null,
    },
    history: [],
    status: 'idle',
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchUserCredits.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchUserCredits.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.balance = action.payload;
      })
      .addCase(fetchUserCredits.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload;
      })
      // Similar patterns for adjustCredits and fetchCreditHistory
  },
});

export default creditsSlice.reducer;
```

## 9. Core Components

### Role Selection Screen

```jsx
// RoleSelectionScreen.jsx
import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Text, Card, Title, Paragraph, Avatar } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useDispatch } from 'react-redux';
import { setUserRole } from '../redux/features/authSlice';
import { theme } from '../theme';

const RoleSelectionScreen = () => {
  const navigation = useNavigation();
  const dispatch = useDispatch();

  const handleRoleSelect = (role) => {
    dispatch(setUserRole(role));
    
    // Navigate to the appropriate dashboard based on role
    switch (role) {
      case 'admin':
        navigation.navigate('AdminDashboard');
        break;
      case 'instructor':
        navigation.navigate('InstructorDashboard');
        break;
      case 'client':
        navigation.navigate('ClientDashboard');
        break;
      default:
        break;
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
        <Paragraph style={styles.subtitle}>Gym Management App</Paragraph>
      </View>

      <Text style={styles.selectionTitle}>Select Your Role</Text>

      <TouchableOpacity onPress={() => handleRoleSelect('admin')}>
        <Card style={[styles.roleCard, { borderColor: '#E53935' }]}>
          <Card.Content style={styles.roleCardContent}>
            <Avatar.Icon 
              size={40} 
              icon="shield-account" 
              color="#fff" 
              style={{ backgroundColor: '#E53935' }} 
            />
            <Title style={styles.roleTitle}>Admin</Title>
          </Card.Content>
        </Card>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => handleRoleSelect('instructor')}>
        <Card style={[styles.roleCard, { borderColor: '#4CAF50' }]}>
          <Card.Content style={styles.roleCardContent}>
            <Avatar.Icon 
              size={40} 
              icon="account-tie" 
              color="#fff" 
              style={{ backgroundColor: '#4CAF50' }} 
            />
            <Title style={styles.roleTitle}>Instructor</Title>
          </Card.Content>
        </Card>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => handleRoleSelect('client')}>
        <Card style={[styles.roleCard, { borderColor: '#2196F3' }]}>
          <Card.Content style={styles.roleCardContent}>
            <Avatar.Icon 
              size={40} 
              icon="account" 
              color="#fff" 
              style={{ backgroundColor: '#2196F3' }} 
            />
            <Title style={styles.roleTitle}>Client</Title>
          </Card.Content>
        </Card>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  logoContainer: {
    alignItems: 'center',
    marginBottom: 40,
  },
  logoTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: theme.colors.primary,
    marginTop: 16,
  },
  subtitle: {
    color: '#888',
    marginTop: 4,
  },
  selectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 24,
  },
  roleCard: {
    marginBottom: 16,
    width: 280,
    borderWidth: 2,
    elevation: 3,
  },
  roleCardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
  },
  roleTitle: {
    marginLeft: 16,
    fontSize: 18,
  },
});

export default RoleSelectionScreen;
```

### Credit Balance Card

```jsx
// CreditBalanceCard.jsx
import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Card, Title, Text, ProgressBar } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { theme } from '../theme';

const CreditBalanceCard = ({ credits, intervalCredits, maxCredits = 12, onPress }) => {
  // Calculate percentage for progress bar
  const creditPercentage = Math.min(credits / maxCredits, 1);
  
  // Determine color based on credit amount
  const getColorByCredit = () => {
    if (credits <= 2) return '#F44336'; // Red
    if (credits <= 5) return '#FFC107'; // Yellow
    return '#4CAF50'; // Green
  };

  return (
    <Card style={styles.card} onPress={onPress}>
      <Card.Content>
        <View style={styles.header}>
          <MaterialCommunityIcons name="ticket-percent" size={24} color={theme.colors.primary} />
          <Title style={styles.title}>Your Credits</Title>
        </View>
        
        <View style={styles.creditContainer}>
          <Text style={styles.creditLabel}>Gym Credits</Text>
          <Text style={[styles.creditValue, { color: getColorByCredit() }]}>
            {credits}
          </Text>
        </View>
        
        <ProgressBar
          progress={creditPercentage}
          color={getColorByCredit()}
          style={styles.progressBar}
        />
        
        {intervalCredits > 0 && (
          <View style={styles.intervalContainer}>
            <Text style={styles.intervalLabel}>Interval Credits</Text>
            <Text style={styles.intervalValue}>{intervalCredits}</Text>
          </View>
        )}
        
        <Text style={styles.refreshDate}>
          Next refresh: May 31, 2025
        </Text>
      </Card.Content>
    </Card>
  );
};

const styles = StyleSheet.create({
  card: {
    margin: 16,
    elevation: 4,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  title: {
    marginLeft: 8,
    fontSize: 18,
  },
  creditContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  creditLabel: {
    fontSize: 16,
  },
  creditValue: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
    marginBottom: 16,
  },
  intervalContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 16,
  },
  intervalLabel: {
    fontSize: 16,
  },
  intervalValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: theme.colors.accent,
  },
  refreshDate: {
    fontSize: 12,
    color: '#666',
    textAlign: 'right',
    marginTop: 8,
  },
});

export default CreditBalanceCard;
```

### Tutorial Video Player

```jsx
// TutorialVideoPlayer.jsx
import React, { useState, useRef, useEffect } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import { Text, IconButton, ActivityIndicator, ProgressBar } from 'react-native-paper';
import { Video, ResizeMode } from 'expo-av';
import Slider from '@react-native-community/slider';
import { formatDuration } from '../../utils/timeFormatter';

const { width } = Dimensions.get('window');

const TutorialVideoPlayer = ({ videoUrl, thumbnailUrl, title }) => {
  const videoRef = useRef(null);
  const [status, setStatus] = useState({});
  const [isBuffering, setIsBuffering] = useState(false);
  
  const handlePlaybackStatusUpdate = (playbackStatus) => {
    setStatus(playbackStatus);
    setIsBuffering(playbackStatus.isBuffering);
  };
  
  const handlePlayPause = async () => {
    if (status.isPlaying) {
      await videoRef.current.pauseAsync();
    } else {
      await videoRef.current.playAsync();
    }
  };
  
  const handleSliderValueChange = async (value) => {
    if (videoRef.current) {
      await videoRef.current.setPositionAsync(value * status.durationMillis);
    }
  };
  
  useEffect(() => {
    return () => {
      if (videoRef.current) {
        videoRef.current.unloadAsync();
      }
    };
  }, []);

  return (
    <View style={styles.container}>
      <View style={styles.videoContainer}>
        <Video
          ref={videoRef}
          source={{ uri: videoUrl }}
          posterSource={{ uri: thumbnailUrl }}
          usePoster={true}
          style={styles.video}
          resizeMode={ResizeMode.CONTAIN}
          onPlaybackStatusUpdate={handlePlaybackStatusUpdate}
          useNativeControls={false}
        />
        
        {isBuffering && (
          <View style={styles.bufferingOverlay}>
            <ActivityIndicator size="large" color="#FFFFFF" />
          </View>
        )}
        
        <View style={styles.controlsOverlay}>
          <IconButton
            icon={status.isPlaying ? "pause" : "play"}
            size={40}
            iconColor="#FFFFFF"
            onPress={handlePlayPause}
            style={styles.playButton}
          />
        </View>
      </View>
      
      <View style={styles.controlsContainer}>
        <Text>{formatDuration(status.positionMillis || 0)}</Text>
        
        <Slider
          style={styles.slider}
          minimumValue={0}
          maximumValue={1}
          value={status.durationMillis ? (status.positionMillis / status.durationMillis) : 0}
          onValueChange={handleSliderValueChange}
          minimumTrackTintColor="#2196F3"
          maximumTrackTintColor="#CCCCCC"
          thumbTintColor="#2196F3"
        />
        
        <Text>{formatDuration(status.durationMillis || 0)}</Text>
      </View>
      
      <Text style={styles.videoTitle}>{title}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 16,
  },
  videoContainer: {
    width: width - 32,
    height: (width - 32) * 9 / 16, // 16:9 aspect ratio
    backgroundColor: '#000',
    borderRadius: 8,
    overflow: 'hidden',
    position: 'relative',
  },
  video: {
    width: '100%',
    height: '100%',
  },
  controlsOverlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
  },
  bufferingOverlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
  },
  playButton: {
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  controlsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 8,
    paddingHorizontal: 8,
  },
  slider: {
    flex: 1,
    marginHorizontal: 8,
  },
  videoTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 8,
    paddingHorizontal: 8,
  },
});

export default TutorialVideoPlayer;
```

## 10. React Native Advantages

1. **Performance Benefits**
   - More efficient native bridge with JSI
   - Automatic code splitting with Expo
   - Better memory management
   - Native platform optimizations

2. **Developer Experience**
   - Larger community and ecosystem
   - Better documentation and resources
   - Faster hot reloading
   - Single language (JavaScript/TypeScript)

3. **Ecosystem Integration**
   - Better Firebase integration tools
   - More third-party libraries
   - Stronger native module support
   - Advanced debugging tools

4. **Maintenance**
   - Easier to find React Native developers
   - More regular framework updates
   - Stable upgrade paths
   - Better TypeScript support

## 11. Next Steps

1. **Setup Development Environment**
   - Install Node.js and npm
   - Install Expo CLI
   - Configure editor extensions
   - Set up version control

2. **Create Project Structure**
   - Initialize project with Expo
   - Set up TypeScript configuration
   - Create initial directory structure
   - Configure ESLint and Prettier

3. **Firebase Configuration**
   - Create Firebase configuration
   - Set up authentication services
   - Configure Firestore access
   - Set up Firebase Storage

4. **Begin Phase 1 Implementation**
   - Create authentication screens
   - Set up navigation structure
   - Implement role-based routing
   - Create initial dashboard screens