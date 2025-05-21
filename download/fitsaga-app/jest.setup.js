// Setup file for Jest tests
import '@testing-library/jest-native/extend-expect';
import { NativeModules } from 'react-native';
import 'react-native-gesture-handler/jestSetup';

// Mock external modules
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');
  Reanimated.default.call = () => {};
  return Reanimated;
});

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(() => Promise.resolve()),
  getItem: jest.fn(() => Promise.resolve(null)),
  removeItem: jest.fn(() => Promise.resolve()),
  clear: jest.fn(() => Promise.resolve()),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([]))
}));

// Mock Expo modules
jest.mock('expo-secure-store', () => ({
  getItemAsync: jest.fn(() => Promise.resolve()),
  setItemAsync: jest.fn(() => Promise.resolve()),
  deleteItemAsync: jest.fn(() => Promise.resolve())
}));

jest.mock('expo-file-system', () => ({
  documentDirectory: 'file:///fake/path/',
  cacheDirectory: 'file:///fake/cache/path/',
  downloadAsync: jest.fn(() => Promise.resolve({ uri: 'file:///fake/path/download.mp4' })),
  getInfoAsync: jest.fn(() => Promise.resolve({ exists: true, size: 1000 })),
  readAsStringAsync: jest.fn(() => Promise.resolve('{"fake":"json"}')),
  writeAsStringAsync: jest.fn(() => Promise.resolve()),
  deleteAsync: jest.fn(() => Promise.resolve()),
  makeDirectoryAsync: jest.fn(() => Promise.resolve()),
  readDirectoryAsync: jest.fn(() => Promise.resolve([]))
}));

jest.mock('expo-av', () => ({
  Audio: {
    Sound: {
      createAsync: jest.fn(() => Promise.resolve({ sound: { 
        playAsync: jest.fn(),
        stopAsync: jest.fn(),
        unloadAsync: jest.fn(),
        setPositionAsync: jest.fn(),
        setVolumeAsync: jest.fn()
      }}))
    }
  },
  Video: jest.fn().mockImplementation(() => ({
    playAsync: jest.fn(),
    pauseAsync: jest.fn(),
    stopAsync: jest.fn(),
    unloadAsync: jest.fn(),
    setPositionAsync: jest.fn(),
    setVolumeAsync: jest.fn(),
    setIsMutedAsync: jest.fn()
  })),
  ResizeMode: {
    CONTAIN: 'contain',
    COVER: 'cover',
    STRETCH: 'stretch'
  }
}));

jest.mock('expo-notifications', () => ({
  getPermissionsAsync: jest.fn(() => Promise.resolve({ status: 'granted' })),
  requestPermissionsAsync: jest.fn(() => Promise.resolve({ status: 'granted' })),
  setNotificationHandler: jest.fn(),
  scheduleNotificationAsync: jest.fn(() => Promise.resolve('notification-id')),
  cancelScheduledNotificationAsync: jest.fn(() => Promise.resolve()),
  cancelAllScheduledNotificationsAsync: jest.fn(() => Promise.resolve()),
  getExpoPushTokenAsync: jest.fn(() => Promise.resolve({ data: 'fake-token' })),
  addNotificationReceivedListener: jest.fn(() => ({ remove: jest.fn() })),
  addNotificationResponseReceivedListener: jest.fn(() => ({ remove: jest.fn() })),
  AndroidImportance: { MAX: 5 }
}));

// Mock device info
jest.mock('expo-device', () => ({
  isDevice: true,
  brand: 'Apple',
  manufacturer: 'Apple',
  modelName: 'iPhone 12',
  modelId: 'iPhone13,2',
  osName: 'iOS',
  osVersion: '15.0',
  platformApiLevel: 15
}));

// Mock Firebase
jest.mock('@react-native-firebase/app', () => {
  const firebaseMock = require('./src/tests/mocks/firebaseMock').mockFirebase;
  return firebaseMock;
});

jest.mock('@react-native-firebase/auth', () => {
  const firebaseMock = require('./src/tests/mocks/firebaseMock').mockFirebase.auth;
  return firebaseMock;
});

jest.mock('@react-native-firebase/firestore', () => {
  const firebaseMock = require('./src/tests/mocks/firebaseMock').mockFirebase.firestore;
  return firebaseMock;
});

jest.mock('@react-native-firebase/storage', () => {
  const firebaseMock = require('./src/tests/mocks/firebaseMock').mockFirebase.storage;
  return firebaseMock;
});

// Mock react-navigation
jest.mock('@react-navigation/native', () => {
  return {
    ...jest.requireActual('@react-navigation/native'),
    useNavigation: () => ({
      navigate: jest.fn(),
      goBack: jest.fn(),
      setOptions: jest.fn(),
      reset: jest.fn(),
      addListener: jest.fn(() => ({ remove: jest.fn() }))
    }),
    useRoute: () => ({
      params: {},
    }),
    useIsFocused: () => true,
  };
});

// Create a simple mock for navigation container components
jest.mock('@react-navigation/native-stack', () => ({
  createNativeStackNavigator: jest.fn(() => ({
    Navigator: 'MockNavigator',
    Screen: 'MockScreen',
  })),
}));

jest.mock('@react-navigation/bottom-tabs', () => ({
  createBottomTabNavigator: jest.fn(() => ({
    Navigator: 'MockTabNavigator',
    Screen: 'MockTabScreen',
  })),
}));

// Mock Platform specific values
NativeModules.RNCNetInfo = {
  getCurrentState: jest.fn(() => Promise.resolve()),
  addListener: jest.fn(),
  removeListeners: jest.fn(),
};

// Set up global console mocks to make tests cleaner
global.console = {
  ...console,
  error: jest.fn(),
  warn: jest.fn(),
  log: jest.fn(),
  info: jest.fn(),
  debug: jest.fn(),
};

// Setup timezone for consistent date testing
process.env.TZ = 'UTC';

// Add fetch mock
global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({}),
    text: () => Promise.resolve(''),
    blob: () => Promise.resolve(new Blob()),
    ok: true,
    status: 200,
    headers: {
      get: jest.fn(),
      forEach: jest.fn(),
    },
  })
);