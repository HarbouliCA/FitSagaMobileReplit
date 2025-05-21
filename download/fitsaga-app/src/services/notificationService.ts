import { Platform } from 'react-native';
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import Constants from 'expo-constants';

/**
 * Notification Service for handling push notifications in the FitSAGA app
 */
export class NotificationService {
  /**
   * Register for push notifications
   * @returns Push token or null if registration failed
   */
  static async registerForPushNotifications() {
    // Check if the device is physical (not a simulator)
    if (!Device.isDevice) {
      console.log('Push notifications are not available on simulators/emulators');
      return null;
    }

    // Check for existing permissions
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;

    // If we don't have permission, ask for it
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }

    // If we still don't have permission, exit
    if (finalStatus !== 'granted') {
      console.log('Failed to get push token: permission not granted');
      return null;
    }

    // Get the token
    try {
      const token = await Notifications.getExpoPushTokenAsync({
        projectId: Constants.expoConfig?.extra?.eas?.projectId,
      });
      
      console.log('Push token:', token);
      
      // Platform-specific notification setup
      if (Platform.OS === 'android') {
        // Android-specific notification channel
        await Notifications.setNotificationChannelAsync('default', {
          name: 'Default',
          importance: Notifications.AndroidImportance.MAX,
          vibrationPattern: [0, 250, 250, 250],
          lightColor: '#4A58C0',
        });
      }
      
      return token;
    } catch (error) {
      console.error('Error getting push token:', error);
      return null;
    }
  }

  /**
   * Configure notification handlers
   * @param onNotification Function to handle received notifications
   * @param onNotificationResponse Function to handle user responses to notifications
   */
  static configureNotificationHandlers(
    onNotification?: (notification: Notifications.Notification) => void,
    onNotificationResponse?: (response: Notifications.NotificationResponse) => void
  ) {
    // Set notification handler
    Notifications.setNotificationHandler({
      handleNotification: async () => ({
        shouldShowAlert: true,
        shouldPlaySound: true,
        shouldSetBadge: true,
      }),
    });

    // Set up notification received handler
    if (onNotification) {
      const subscription = Notifications.addNotificationReceivedListener(onNotification);
      return () => subscription.remove();
    }

    // Set up notification response handler
    if (onNotificationResponse) {
      const subscription = Notifications.addNotificationResponseReceivedListener(onNotificationResponse);
      return () => subscription.remove();
    }

    return () => {};
  }

  /**
   * Schedule a local notification
   * @param title Notification title
   * @param body Notification body
   * @param data Additional data payload
   * @param trigger When to show the notification
   * @returns Notification identifier
   */
  static async scheduleLocalNotification(
    title: string,
    body: string,
    data?: any,
    trigger?: Notifications.NotificationTriggerInput
  ) {
    try {
      const notificationId = await Notifications.scheduleNotificationAsync({
        content: {
          title,
          body,
          data: data || {},
          sound: true,
          badge: 1,
        },
        trigger: trigger || null,
      });
      
      return notificationId;
    } catch (error) {
      console.error('Error scheduling notification:', error);
      return null;
    }
  }

  /**
   * Schedule a notification for a specific session
   * @param sessionId Session ID
   * @param sessionTitle Session title
   * @param startTime Session start time
   * @param minutesBefore Minutes before the session to send the notification
   * @returns Notification identifier
   */
  static async scheduleSessionReminder(
    sessionId: string,
    sessionTitle: string,
    startTime: Date,
    minutesBefore: number = 30
  ) {
    // Calculate notification time (session time minus minutesBefore)
    const notificationTime = new Date(startTime);
    notificationTime.setMinutes(notificationTime.getMinutes() - minutesBefore);
    
    // Don't schedule if it's in the past
    if (notificationTime <= new Date()) {
      console.log('Not scheduling notification for past session');
      return null;
    }
    
    return this.scheduleLocalNotification(
      'Session Reminder',
      `Your ${sessionTitle} session starts in ${minutesBefore} minutes`,
      { sessionId },
      { date: notificationTime }
    );
  }

  /**
   * Cancel a scheduled notification
   * @param notificationId Notification identifier
   */
  static async cancelNotification(notificationId: string) {
    try {
      await Notifications.cancelScheduledNotificationAsync(notificationId);
    } catch (error) {
      console.error('Error canceling notification:', error);
    }
  }

  /**
   * Cancel all scheduled notifications
   */
  static async cancelAllNotifications() {
    try {
      await Notifications.cancelAllScheduledNotificationsAsync();
    } catch (error) {
      console.error('Error canceling all notifications:', error);
    }
  }

  /**
   * Get all pending notification requests
   * @returns Array of pending notification requests
   */
  static async getPendingNotifications() {
    try {
      return await Notifications.getAllScheduledNotificationsAsync();
    } catch (error) {
      console.error('Error getting pending notifications:', error);
      return [];
    }
  }

  /**
   * Set app badge count (iOS only)
   * @param count Badge count number
   */
  static async setBadgeCount(count: number) {
    try {
      await Notifications.setBadgeCountAsync(count);
    } catch (error) {
      console.error('Error setting badge count:', error);
    }
  }
}

export default NotificationService;