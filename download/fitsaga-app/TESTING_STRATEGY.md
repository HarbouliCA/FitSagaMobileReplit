# FitSAGA Testing Strategy

This document outlines a comprehensive testing strategy for the FitSAGA React Native application. It covers unit testing, integration testing, and end-to-end testing approaches for all major components.

## 1. Testing Tools & Framework

| Testing Type | Primary Tools |
|--------------|---------------|
| Unit Testing | Jest, React Native Testing Library |
| Integration Testing | Jest, React Native Testing Library, Mock Service Worker |
| End-to-End Testing | Detox |
| Manual Testing | Expo Go, Physical Devices |
| Firebase Testing | Firebase Local Emulator Suite |

## 2. Component-Specific Testing Strategies

### 2.1 Authentication & Role-Based Access Control (RBAC)

#### Unit Tests
- Test authentication reducers and actions
- Validate role-specific permission checks
- Test form validation logic

#### Integration Tests
- Test login flow with mock Firebase responses
- Verify registration process and error handling
- Test role selection and navigation changes
- Verify protected routes redirect correctly based on user role

#### E2E Tests
- Complete login process with test credentials
- Verify appropriate screens available per role
- Test unauthorized access attempts

#### Test Cases
1. User login with valid credentials
2. User login with invalid credentials
3. New user registration
4. Password reset flow
5. Role selection functionality
6. Admin access to admin-only screens
7. Instructor access to instructor-only screens
8. Client access to client-only screens
9. Unauthorized access attempts
10. Session persistence after app restart

### 2.2 Credit System

#### Unit Tests
- Test credit reducers and actions
- Validate credit calculation logic
- Test credit transaction creation

#### Integration Tests
- Test credit display components with various states
- Verify credit deduction during booking flow
- Test credit history retrieval and display

#### E2E Tests
- View credit balance
- Complete booking that deducts credits
- Verify updated balance after transactions

#### Test Cases
1. Display correct credit balance
2. Credit validation before booking
3. Successful credit deduction
4. Insufficient credits handling
5. Credit transaction history display
6. Credit refund on booking cancellation
7. Admin credit adjustment functionality
8. Credit reset functionality
9. Interval credits usage priority

### 2.3 Session & Booking System

#### Unit Tests
- Test session filtering and sorting functions
- Validate booking validation logic
- Test session state management

#### Integration Tests
- Test session list with filtering
- Verify booking confirmation process
- Test booking history retrieval

#### E2E Tests
- Browse and filter sessions
- Complete a session booking
- View booking history
- Cancel a booking

#### Test Cases
1. Session list display and filtering
2. Session details view
3. Session capacity validation
4. Booking creation process
5. Credit deduction during booking
6. Booking confirmation screen
7. Booking cancellation process
8. Instructor session management
9. Admin session creation/editing
10. Session schedule view with different time periods

### 2.4 Tutorial System

#### Unit Tests
- Test tutorial filtering functions
- Validate tutorial progress tracking logic
- Test video playback state management

#### Integration Tests
- Test tutorial list with filter options
- Verify tutorial details display
- Test tutorial day navigation
- Test exercise completion tracking

#### E2E Tests
- Browse and filter tutorials
- View tutorial details
- Navigate through tutorial days
- Play video content
- Mark exercises as complete

#### Test Cases
1. Tutorial library browsing
2. Tutorial filtering and sorting
3. Tutorial details display
4. Tutorial day navigation
5. Exercise list display
6. Video playback functionality
7. Exercise completion tracking
8. Progress persistence
9. Tutorial search functionality
10. Category filtering

### 2.5 Video Content & Storage Integration

#### Unit Tests
- Test video URL formatting
- Validate metadata parsing
- Test storage path construction

#### Integration Tests
- Test video player component with mock URLs
- Verify metadata retrieval from Firestore
- Test thumbnail loading

#### E2E Tests
- Load and play actual videos from storage
- Verify offline video playback if cached

#### Test Cases
1. Video metadata retrieval from Firestore
2. Azure Blob Storage URL generation
3. Video playback controls
4. Video caching for offline use
5. Video loading states and error handling
6. Video thumbnail display
7. Playback progress tracking
8. Full-screen video mode
9. Video quality selection
10. Video loading performance

## 3. End-to-End Testing Workflows

These test workflows combine multiple components to test complete user journeys.

### 3.1 New Client Onboarding
1. Register new account
2. Select client role
3. Complete profile information
4. View credit balance
5. Browse available sessions
6. View tutorial library

### 3.2 Session Booking Journey
1. Login as client
2. Check credit balance
3. Browse session list
4. Filter by activity type
5. Select a session
6. View session details
7. Book the session
8. Verify credit deduction
9. View booking in upcoming sessions

### 3.3 Tutorial Completion Journey
1. Login as client
2. Browse tutorial library
3. Select a tutorial
4. View details and start tutorial
5. Navigate through days
6. Play exercise videos
7. Mark exercises as complete
8. Verify progress tracking
9. Complete entire tutorial
10. Verify tutorial marked as complete

### 3.4 Instructor Session Management
1. Login as instructor
2. View scheduled sessions
3. Create new session
4. Edit session details
5. View enrolled clients
6. Mark attendance
7. Cancel a session

### 3.5 Admin User Management
1. Login as admin
2. View user list
3. Create new user account
4. Assign role
5. Adjust user credits
6. View user activity history

## 4. Firebase Integration Testing

### 4.1 Firebase Authentication
- Test login, logout, and registration with Firebase Auth
- Verify error handling for invalid credentials
- Test password reset flow

### 4.2 Firestore Data Operations
- Test data fetching operations
- Verify data creation and updates
- Test transaction handling for credit operations
- Verify query performance

### 4.3 Firebase Storage
- Test video and image asset retrieval
- Verify URL generation for videos
- Test upload functionality (for admin/instructor)

### 4.4 Local Emulator Testing
1. Set up Firebase Local Emulator Suite
2. Configure app to use emulators in test environment
3. Seed emulator with test data
4. Run integration tests against emulator

## 5. Testing External Content Sources

### 5.1 Azure Blob Storage Integration
- Test video URL construction from metadata
- Verify authentication for accessing private blobs
- Test video streaming from Azure
- Verify error handling for missing or inaccessible content

### 5.2 Video Metadata Collection
- Test retrieval from `/videoMetadata` collection
- Verify parsing of metadata fields
- Test relationship between metadata and actual video content
- Verify thumbnail URL construction

## 6. Performance Testing

### 6.1 Load Time Benchmarks
- App initial load time
- Screen transition times
- Video loading time
- Data fetching operations

### 6.2 Memory Usage
- Monitor memory usage during video playback
- Check for memory leaks during navigation
- Verify efficient list rendering for large datasets

### 6.3 Network Performance
- Test app behavior with various network conditions
- Verify bandwidth usage during video streaming
- Test offline capabilities

## 7. Cross-Platform Testing

### 7.1 iOS-Specific Tests
- Verify UI rendering on different iOS devices
- Test iOS-specific permissions handling
- Verify background video playback
- Test Apple authentication integration

### 7.2 Android-Specific Tests
- Verify UI rendering on different Android devices
- Test Android permissions handling
- Verify back button behavior
- Test deep linking functionality

## 8. Test Automation Setup

### 8.1 CI/CD Integration
```yaml
# Example GitHub Actions workflow
name: FitSAGA Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm install
      - name: Run unit tests
        run: npm run test:unit
      - name: Run integration tests
        run: npm run test:integration
      - name: Start Firebase emulators
        run: npm run emulators:start
      - name: Run Firebase tests
        run: npm run test:firebase
```

### 8.2 Test Scripts
Add these scripts to `package.json`:

```json
"scripts": {
  "test": "jest",
  "test:unit": "jest --testPathPattern=src/tests/unit",
  "test:integration": "jest --testPathPattern=src/tests/integration",
  "test:e2e": "detox test --configuration ios.sim.debug",
  "test:firebase": "jest --testPathPattern=src/tests/firebase",
  "emulators:start": "firebase emulators:start --only auth,firestore",
  "emulators:seed": "node scripts/seed-emulators.js"
}
```

## 9. Example Test Implementations

### 9.1 Unit Test Example (Redux Auth Slice)

```javascript
// src/tests/unit/redux/authSlice.test.js
import authReducer, { loginUser, logoutUser } from '../../../redux/features/authSlice';

describe('Auth Slice', () => {
  const initialState = {
    isAuthenticated: false,
    user: null,
    userData: null,
    loading: false,
    error: null,
  };

  test('should return the initial state', () => {
    expect(authReducer(undefined, {})).toEqual(initialState);
  });

  test('should handle pending login action', () => {
    const action = { type: loginUser.pending.type };
    const state = authReducer(initialState, action);
    expect(state.loading).toBe(true);
    expect(state.error).toBe(null);
  });

  test('should handle fulfilled login action', () => {
    const mockUser = { uid: '123' };
    const mockUserData = { name: 'Test User', role: 'client' };
    
    const action = { 
      type: loginUser.fulfilled.type, 
      payload: { user: mockUser, userData: mockUserData } 
    };
    
    const state = authReducer(initialState, action);
    expect(state.loading).toBe(false);
    expect(state.isAuthenticated).toBe(true);
    expect(state.user).toEqual(mockUser);
    expect(state.userData).toEqual(mockUserData);
    expect(state.error).toBe(null);
  });

  test('should handle rejected login action', () => {
    const mockError = 'Invalid credentials';
    const action = { 
      type: loginUser.rejected.type, 
      payload: mockError 
    };
    
    const state = authReducer(initialState, action);
    expect(state.loading).toBe(false);
    expect(state.isAuthenticated).toBe(false);
    expect(state.error).toBe(mockError);
  });

  test('should handle logout action', () => {
    const loggedInState = {
      isAuthenticated: true,
      user: { uid: '123' },
      userData: { name: 'Test User' },
      loading: false,
      error: null,
    };
    
    const action = { type: logoutUser.fulfilled.type };
    const state = authReducer(loggedInState, action);
    
    expect(state.isAuthenticated).toBe(false);
    expect(state.user).toBe(null);
    expect(state.userData).toBe(null);
  });
});
```

### 9.2 Component Test Example (CreditBalanceCard)

```javascript
// src/tests/integration/components/CreditBalanceCard.test.js
import React from 'react';
import { render, screen } from '@testing-library/react-native';
import CreditBalanceCard from '../../../components/credits/CreditBalanceCard';

describe('CreditBalanceCard Component', () => {
  test('renders correctly with provided props', () => {
    const props = {
      gymCredits: 8,
      intervalCredits: 4,
      maxCredits: 12,
      lastRefilled: new Date('2025-05-01'),
      nextRefillDate: new Date('2025-06-01'),
      showDetails: true,
      onPress: jest.fn(),
    };
    
    render(<CreditBalanceCard {...props} />);
    
    expect(screen.getByText('Your Credits')).toBeTruthy();
    expect(screen.getByText('8')).toBeTruthy(); // Gym credits
    expect(screen.getByText('4')).toBeTruthy(); // Interval credits
    expect(screen.getByText(/Next refresh:/)).toBeTruthy();
  });
  
  test('handles credit color based on amount', () => {
    // Test with low credits
    render(<CreditBalanceCard gymCredits={2} intervalCredits={0} />);
    const lowCreditsElement = screen.getByText('2');
    // Check color style - implementation depends on how you're applying color
    
    // Test with medium credits
    render(<CreditBalanceCard gymCredits={5} intervalCredits={0} />);
    const mediumCreditsElement = screen.getByText('5');
    // Check color style
    
    // Test with high credits
    render(<CreditBalanceCard gymCredits={10} intervalCredits={0} />);
    const highCreditsElement = screen.getByText('10');
    // Check color style
  });
  
  test('calls onPress when card is pressed', () => {
    const onPressMock = jest.fn();
    render(<CreditBalanceCard gymCredits={8} intervalCredits={4} onPress={onPressMock} />);
    
    // Find touchable component and fire press event
    // Implementation depends on how your component is structured
    
    expect(onPressMock).toHaveBeenCalledTimes(1);
  });
});
```

### 9.3 E2E Test Example (Login Flow)

```javascript
// e2e/loginFlow.test.js
describe('Login Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should login successfully with valid credentials', async () => {
    // Navigate to login screen if needed
    await element(by.id('login-button')).tap();
    
    // Enter credentials
    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    
    // Submit login form
    await element(by.id('submit-login')).tap();
    
    // Verify successful login by checking for dashboard element
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
    
    // Verify user name is displayed
    await expect(element(by.text('Welcome, Test User'))).toBeVisible();
  });

  it('should show error message with invalid credentials', async () => {
    // Navigate to login screen if needed
    await element(by.id('login-button')).tap();
    
    // Enter invalid credentials
    await element(by.id('email-input')).typeText('invalid@example.com');
    await element(by.id('password-input')).typeText('wrongpassword');
    
    // Submit login form
    await element(by.id('submit-login')).tap();
    
    // Verify error message is displayed
    await expect(element(by.text('Invalid email or password'))).toBeVisible();
  });
});
```

## 10. Manual Testing Checklist

### 10.1 Authentication & RBAC
- [ ] Successful login with test accounts for each role
- [ ] Registration process completes successfully
- [ ] Password reset functionality works
- [ ] Role-specific screens are accessible only to appropriate roles
- [ ] Session persistence works after app restart

### 10.2 Credit System
- [ ] Credit balance displays correctly
- [ ] Credit history shows transaction details
- [ ] Credits deducted correctly when booking sessions
- [ ] Insufficient credit handling works as expected
- [ ] Admin can adjust user credits

### 10.3 Session & Booking
- [ ] Session list loads and displays correctly
- [ ] Filtering and sorting work as expected
- [ ] Session details display all relevant information
- [ ] Booking process completes successfully
- [ ] Booking appears in user's upcoming sessions
- [ ] Cancellation process works correctly

### 10.4 Tutorial System
- [ ] Tutorial list loads and displays correctly
- [ ] Filtering by category and difficulty works
- [ ] Tutorial details show comprehensive information
- [ ] Day navigation works smoothly
- [ ] Video content loads and plays correctly
- [ ] Exercise completion tracking works
- [ ] Progress is saved between app sessions

### 10.5 Video Integration
- [ ] Videos from Azure Blob Storage load correctly
- [ ] Video player controls work as expected
- [ ] Video quality is appropriate
- [ ] Thumbnails display correctly
- [ ] Error handling works for unreachable content

## 11. Test Data Requirements

### Firebase Test Data

Create a seed script to populate Firebase emulator:

```javascript
// scripts/seed-emulators.js
const firebase = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase admin
firebase.initializeApp({
  projectId: 'demo-project-id',
});

const db = firebase.firestore();

// Load test data from JSON files
const users = JSON.parse(fs.readFileSync('./test-data/users.json'));
const sessions = JSON.parse(fs.readFileSync('./test-data/sessions.json'));
const tutorials = JSON.parse(fs.readFileSync('./test-data/tutorials.json'));
const videoMetadata = JSON.parse(fs.readFileSync('./test-data/video-metadata.json'));

// Seed users collection
const seedUsers = async () => {
  const batch = db.batch();
  
  users.forEach(user => {
    const ref = db.collection('users').doc(user.uid);
    batch.set(ref, user);
  });
  
  await batch.commit();
  console.log('Seeded users collection');
};

// Seed sessions collection
const seedSessions = async () => {
  const batch = db.batch();
  
  sessions.forEach(session => {
    const ref = db.collection('sessions').doc(session.id);
    batch.set(ref, session);
  });
  
  await batch.commit();
  console.log('Seeded sessions collection');
};

// Seed tutorials collection
const seedTutorials = async () => {
  const batch = db.batch();
  
  tutorials.forEach(tutorial => {
    const ref = db.collection('tutorials').doc(tutorial.id);
    batch.set(ref, tutorial);
  });
  
  await batch.commit();
  console.log('Seeded tutorials collection');
};

// Seed videoMetadata collection
const seedVideoMetadata = async () => {
  const batch = db.batch();
  
  videoMetadata.forEach(video => {
    const ref = db.collection('videoMetadata').doc(video.id);
    batch.set(ref, video);
  });
  
  await batch.commit();
  console.log('Seeded videoMetadata collection');
};

// Run all seed operations
const seedAll = async () => {
  try {
    await seedUsers();
    await seedSessions();
    await seedTutorials();
    await seedVideoMetadata();
    console.log('All collections seeded successfully');
  } catch (error) {
    console.error('Error seeding data:', error);
  } finally {
    process.exit(0);
  }
};

seedAll();
```

## 12. Test Environment Configuration

### 12.1 Setting Up Firebase Emulators
```
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase in your project
firebase init emulators

# Start emulators
firebase emulators:start
```

### 12.2 React Native Testing Configuration
In `jest.config.js`:

```javascript
module.exports = {
  preset: 'react-native',
  setupFiles: ['./jest.setup.js'],
  transformIgnorePatterns: [
    'node_modules/(?!(react-native|@react-native|react-native-vector-icons|@react-navigation)/)',
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  moduleNameMapper: {
    '\\.(jpg|jpeg|png|gif|webp|svg)$': '<rootDir>/__mocks__/fileMock.js',
  },
  testPathIgnorePatterns: ['/node_modules/', '/e2e/'],
};
```

In `jest.setup.js`:

```javascript
import 'react-native-gesture-handler/jestSetup';

// Mock Firebase
jest.mock('@react-native-firebase/app', () => ({
  // Mock implementation
}));

// Mock Expo modules
jest.mock('expo-av', () => ({
  // Mock implementation for video player
}));

// Mock React Navigation
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    navigate: jest.fn(),
    goBack: jest.fn(),
  }),
  useRoute: () => ({
    params: {
      // Default params for tests
    },
  }),
}));

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  // Mock implementation
}));
```

## 13. Continuous Improvement

### 13.1 Test Coverage Goals
- Unit tests: > 80% coverage
- Integration tests: Key user flows covered
- E2E tests: Critical business processes covered

### 13.2 Test Reporting
- Generate coverage reports after test runs
- Track test failures in CI/CD pipeline
- Document manual test results

### 13.3 Regression Testing
- Run full test suite before each release
- Maintain a set of smoke tests for quick verification
- Automate critical path testing