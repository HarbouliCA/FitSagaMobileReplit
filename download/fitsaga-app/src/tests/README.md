# FitSAGA Testing Guide

This directory contains tests for the FitSAGA React Native application. This README will help you understand how to run tests and add new ones.

## Test Structure

```
/src/tests
  /unit                   # Unit tests for isolated functions and components
    /components           # Tests for individual UI components
    /redux                # Tests for Redux slices and actions
    /services             # Tests for service functions
    /utils                # Tests for utility functions
  /integration            # Integration tests for connected components
    /auth                 # Authentication flow tests
    /credits              # Credit system tests
    /sessions             # Session booking tests
    /tutorials            # Tutorial system tests
  /firebase               # Tests with Firebase emulator
  /fixtures               # Test data
  /mocks                  # Mock implementations
```

## Running Tests

### Unit Tests
```bash
npm run test:unit
```

### Integration Tests
```bash
npm run test:integration
```

### Firebase Tests (requires emulator)
```bash
# Start Firebase emulators first
npm run emulators:start

# In another terminal
npm run test:firebase
```

### All Tests
```bash
npm test
```

## Writing Tests

### Unit Test Example

```javascript
// src/tests/unit/utils/formatters.test.js
import { formatTime, formatDate } from '../../../utils/formatters';

describe('Formatter Utils', () => {
  test('formatTime formats time correctly', () => {
    const date = new Date(2025, 4, 21, 15, 30, 0); // May 21, 2025, 15:30:00
    expect(formatTime(date)).toBe('3:30 PM');
  });

  test('formatDate formats date correctly', () => {
    const date = new Date(2025, 4, 21); // May 21, 2025
    expect(formatDate(date)).toBe('May 21, 2025');
  });
});
```

### Component Test Example

```javascript
// src/tests/unit/components/SessionCard.test.js
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import SessionCard from '../../../components/sessions/SessionCard';

describe('SessionCard', () => {
  const mockProps = {
    id: '123',
    title: 'Yoga Class',
    activityType: 'yoga',
    startTime: new Date(2025, 4, 21, 15, 30, 0),
    endTime: new Date(2025, 4, 21, 16, 30, 0),
    instructorName: 'Jane Doe',
    capacity: 20,
    enrolledCount: 15,
    creditCost: 2,
    onPress: jest.fn(),
  };

  test('renders correctly with given props', () => {
    const { getByText } = render(<SessionCard {...mockProps} />);
    
    expect(getByText('Yoga Class')).toBeTruthy();
    expect(getByText('Jane Doe')).toBeTruthy();
    expect(getByText('2')).toBeTruthy(); // Credit cost
  });

  test('calls onPress when pressed', () => {
    const { getByTestId } = render(<SessionCard {...mockProps} />);
    
    fireEvent.press(getByTestId('session-card'));
    expect(mockProps.onPress).toHaveBeenCalledTimes(1);
  });
});
```

### Redux Test Example

```javascript
// src/tests/unit/redux/creditsSlice.test.js
import creditsReducer, { 
  fetchUserCredits, 
  adjustCredits 
} from '../../../redux/features/creditsSlice';

describe('Credits Slice', () => {
  const initialState = {
    credits: {
      total: 0,
      intervalCredits: 0,
    },
    transactions: [],
    loading: false,
    error: null,
  };

  test('should handle fetchUserCredits.fulfilled', () => {
    const mockCredits = {
      total: 10,
      intervalCredits: 5,
      lastRefilled: new Date(),
    };

    const action = {
      type: fetchUserCredits.fulfilled.type,
      payload: mockCredits,
    };

    const newState = creditsReducer(initialState, action);
    expect(newState.credits).toEqual(mockCredits);
    expect(newState.loading).toBe(false);
  });

  test('should handle adjustCredits.fulfilled', () => {
    const mockPayload = {
      credits: {
        total: 8,
        intervalCredits: 5,
      },
      transaction: {
        id: 'tx123',
        amount: -2,
        type: 'deduction',
        timestamp: new Date(),
      },
    };

    const action = {
      type: adjustCredits.fulfilled.type,
      payload: mockPayload,
    };

    const newState = creditsReducer(initialState, action);
    expect(newState.credits).toEqual(mockPayload.credits);
    expect(newState.transactions.length).toBe(1);
    expect(newState.transactions[0]).toEqual(mockPayload.transaction);
  });
});
```

## Testing Firebase Integration

```javascript
// src/tests/firebase/auth.test.js
import { signIn, registerUser } from '../../services/authService';
import { auth, db } from '../../services/firebase';

// These tests require Firebase emulator
describe('Auth Service with Firebase', () => {
  const testUser = {
    email: 'test@example.com',
    password: 'password123',
    name: 'Test User',
  };

  beforeAll(async () => {
    // Connect to Firebase emulator
    auth.useEmulator('http://localhost:9099');
    db.useEmulator('localhost', 8080);
  });

  test('should register a new user', async () => {
    const result = await registerUser(
      testUser.email, 
      testUser.password, 
      { name: testUser.name, role: 'client' }
    );
    
    expect(result.user).toBeTruthy();
    expect(result.user.email).toBe(testUser.email);
  });

  test('should sign in existing user', async () => {
    const result = await signIn(testUser.email, testUser.password);
    
    expect(result.user).toBeTruthy();
    expect(result.user.email).toBe(testUser.email);
    expect(result.userData.name).toBe(testUser.name);
  });
});
```

## Testing Video Integration

```javascript
// src/tests/integration/tutorials/VideoPlayer.test.js
import React from 'react';
import { render, act, fireEvent } from '@testing-library/react-native';
import VideoPlayer from '../../../components/tutorials/VideoPlayer';

describe('VideoPlayer Component', () => {
  const mockProps = {
    uri: 'https://storage.example.com/videos/workout1.mp4',
    thumbnailUri: 'https://storage.example.com/thumbnails/workout1.jpg',
    title: 'Test Exercise Video',
    onProgress: jest.fn(),
    onComplete: jest.fn(),
  };

  test('renders correctly with given props', () => {
    const { getByText } = render(<VideoPlayer {...mockProps} />);
    expect(getByText('Test Exercise Video')).toBeTruthy();
  });

  test('handles play/pause functionality', async () => {
    const { getByTestId } = render(<VideoPlayer {...mockProps} />);
    
    // Play button should be visible initially
    const playButton = getByTestId('play-button');
    expect(playButton).toBeTruthy();
    
    // Press play button
    fireEvent.press(playButton);
    
    // Check if play was called
    // Note: Implementation would verify this using mocks
  });
});
```

## Test Fixtures

Create sample data files for tests in `src/tests/fixtures` directory. For example:

```javascript
// src/tests/fixtures/sessions.js
export const mockSessions = [
  {
    id: 'session1',
    title: 'Morning Yoga',
    activityType: 'yoga',
    startTime: new Date(2025, 4, 21, 9, 0, 0),
    endTime: new Date(2025, 4, 21, 10, 0, 0),
    instructorName: 'Jane Doe',
    instructorId: 'instructor1',
    capacity: 20,
    enrolledCount: 15,
    creditCost: 2,
    status: 'scheduled',
  },
  {
    id: 'session2',
    title: 'HIIT Training',
    activityType: 'cardio',
    startTime: new Date(2025, 4, 21, 18, 0, 0),
    endTime: new Date(2025, 4, 21, 19, 0, 0),
    instructorName: 'John Smith',
    instructorId: 'instructor2',
    capacity: 15,
    enrolledCount: 10,
    creditCost: 3,
    status: 'scheduled',
  },
];
```