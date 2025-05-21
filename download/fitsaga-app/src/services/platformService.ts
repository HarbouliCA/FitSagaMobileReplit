import { Platform, Dimensions, StatusBar } from 'react-native';
import Constants from 'expo-constants';
import * as Device from 'expo-device';

/**
 * Platform service to handle platform-specific functionality and values
 */
export const platformService = {
  /**
   * Check if the app is running on iOS
   */
  isIOS: Platform.OS === 'ios',

  /**
   * Check if the app is running on Android
   */
  isAndroid: Platform.OS === 'android',

  /**
   * Check if the app is running on web
   */
  isWeb: Platform.OS === 'web',

  /**
   * Get the platform name ('ios', 'android', 'web')
   */
  platformName: Platform.OS,

  /**
   * Get platform version
   */
  platformVersion: Platform.Version,

  /**
   * Get screen dimensions
   */
  screenDimensions: {
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height,
    scale: Dimensions.get('window').scale,
    fontScale: Dimensions.get('window').fontScale,
  },

  /**
   * Get the status bar height (particularly useful for iOS notches)
   */
  statusBarHeight: StatusBar.currentHeight || 0,

  /**
   * Get app version
   */
  appVersion: Constants.expoConfig?.version || '1.0.0',

  /**
   * Get app build number
   */
  buildNumber: 
    Platform.OS === 'ios' 
      ? Constants.expoConfig?.ios?.buildNumber || '1' 
      : Constants.expoConfig?.android?.versionCode || 1,

  /**
   * Get device brand name
   */
  deviceBrand: Device.brand,

  /**
   * Check if device is a tablet
   */
  isTablet: Device.deviceType === Device.DeviceType.TABLET,

  /**
   * Check if the app is running in development mode
   */
  isDevelopment: __DEV__,

  /**
   * Get the platform-specific shadow styling
   */
  getShadowStyle: (elevation: number = 4) => {
    return Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: elevation / 2 },
        shadowOpacity: 0.2,
        shadowRadius: elevation / 2,
      },
      android: {
        elevation,
      },
      default: {
        // Web shadows
        boxShadow: `0px ${elevation / 2}px ${elevation}px rgba(0, 0, 0, 0.1)`,
      },
    });
  },

  /**
   * Get platform-specific font family
   */
  getDefaultFontFamily: () => {
    return Platform.select({
      ios: 'System',
      android: 'Roboto',
      default: 'Roboto, Arial, sans-serif',
    });
  },

  /**
   * Android back handler setup helper
   * @param callback Function to run when back button is pressed
   * @returns Cleanup function
   */
  setupAndroidBackHandler: (callback: () => boolean) => {
    if (Platform.OS === 'android') {
      const { BackHandler } = require('react-native');
      const subscription = BackHandler.addEventListener(
        'hardwareBackPress',
        callback
      );
      
      // Return a cleanup function
      return () => subscription.remove();
    }
    
    // Return a no-op cleanup for other platforms
    return () => {};
  },

  /**
   * Get platform-specific keyboardAvoidingView behavior
   */
  keyboardBehavior: Platform.OS === 'ios' ? 'padding' : 'height',

  /**
   * Detect device notch (iOS-specific)
   */
  hasNotch: Platform.OS === 'ios' && !Platform.isPad && !Platform.isTVOS && (
    (Dimensions.get('window').height === 812 || Dimensions.get('window').width === 812) || // X/XS
    (Dimensions.get('window').height === 896 || Dimensions.get('window').width === 896) || // XR/XS Max
    (Dimensions.get('window').height >= 844) // iPhone 12 and newer
  ),

  /**
   * Helper to get platform-specific zIndex
   * (Android requires elevation for z-index effects)
   */
  getZIndex: (zIndex: number) => {
    return Platform.select({
      ios: { zIndex },
      android: { elevation: zIndex },
      default: { zIndex },
    });
  },
};

export default platformService;