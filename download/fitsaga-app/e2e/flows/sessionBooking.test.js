const { device, element, by, expect, waitFor } = require('detox');
const {
  TEST_USER,
  restartApp,
  waitForLoadingToFinish,
  loginUser,
  navigateToTab
} = require('../init');

describe('Session Booking Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
    // Login before each test
    await loginUser();
    await waitForLoadingToFinish();
  });

  it('should display available sessions', async () => {
    // Navigate to sessions tab
    await navigateToTab('Sessions');
    
    // Verify sessions are displayed
    await expect(element(by.id('sessions-screen'))).toBeVisible();
    await expect(element(by.id('sessions-list'))).toBeVisible();
    
    // Check if at least one session is visible
    await expect(element(by.id('session-item'))).toBeVisible();
  });

  it('should filter sessions by activity type', async () => {
    // Navigate to sessions tab
    await navigateToTab('Sessions');
    
    // Tap on filter button
    await element(by.id('filter-button')).tap();
    
    // Select 'Yoga' filter
    await element(by.text('Yoga')).tap();
    
    // Apply filter
    await element(by.id('apply-filter-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify only yoga sessions are shown
    const firstSessionType = await element(by.id('activity-type-text')).getText();
    expect(firstSessionType.toLowerCase()).toContain('yoga');
    
    // Reset filters
    await element(by.id('filter-button')).tap();
    await element(by.id('reset-filter-button')).tap();
  });

  it('should display session details', async () => {
    // Navigate to sessions tab
    await navigateToTab('Sessions');
    
    // Select first session
    await element(by.id('session-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Verify session details are displayed
    await expect(element(by.id('session-details-screen'))).toBeVisible();
    await expect(element(by.id('session-title'))).toBeVisible();
    await expect(element(by.id('session-time'))).toBeVisible();
    await expect(element(by.id('session-location'))).toBeVisible();
    await expect(element(by.id('instructor-name'))).toBeVisible();
    await expect(element(by.id('credit-cost'))).toBeVisible();
    
    // Go back to sessions list
    await element(by.id('back-button')).tap();
  });

  it('should book a session successfully', async () => {
    // Navigate to sessions tab
    await navigateToTab('Sessions');
    
    // Select first available (non-full) session
    await element(by.id('session-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Check if session is available for booking
    if (await element(by.id('book-button')).isVisible()) {
      // Book the session
      await element(by.id('book-button')).tap();
      
      // Confirm booking
      await element(by.id('confirm-booking-button')).tap();
      await waitForLoadingToFinish();
      
      // Verify booking confirmation
      await expect(element(by.text('Booking Confirmed'))).toBeVisible();
      await expect(element(by.id('view-bookings-button'))).toBeVisible();
      
      // Go to bookings tab
      await element(by.id('view-bookings-button')).tap();
      await waitForLoadingToFinish();
      
      // Verify the booking appears in upcoming bookings
      await expect(element(by.id('bookings-screen'))).toBeVisible();
      await expect(element(by.id('booking-item'))).toBeVisible();
    } else {
      console.log('No available sessions for booking. Test skipped.');
    }
  });

  it('should show appropriate error when booking full session', async () => {
    // Navigate to sessions tab
    await navigateToTab('Sessions');
    
    // Look for a full session indicator
    const fullSessionExists = await element(by.text('Full')).atIndex(0).isVisible();
    
    if (fullSessionExists) {
      // Tap on the full session
      await element(by.text('Full')).atIndex(0).tap();
      await waitForLoadingToFinish();
      
      // Verify full session details
      await expect(element(by.id('session-details-screen'))).toBeVisible();
      
      // Verify booking button is disabled or shows appropriate message
      await expect(element(by.text('Session Full'))).toBeVisible();
      
      // Go back
      await element(by.id('back-button')).tap();
    } else {
      console.log('No full sessions available. Test skipped.');
    }
  });

  it('should cancel a booking', async () => {
    // Navigate to bookings tab
    await navigateToTab('Bookings');
    
    // Check if there are any bookings
    const hasBookings = await element(by.id('booking-item')).atIndex(0).isVisible();
    
    if (hasBookings) {
      // Tap on first booking
      await element(by.id('booking-item')).atIndex(0).tap();
      await waitForLoadingToFinish();
      
      // Verify booking details screen
      await expect(element(by.id('booking-details-screen'))).toBeVisible();
      
      // Cancel booking
      await element(by.id('cancel-booking-button')).tap();
      
      // Confirm cancellation
      await element(by.text('Yes, Cancel')).tap();
      await waitForLoadingToFinish();
      
      // Verify cancellation confirmation
      await expect(element(by.text('Booking Cancelled'))).toBeVisible();
      
      // Credits should be refunded
      await navigateToTab('Dashboard');
      await expect(element(by.id('credits-balance'))).toBeVisible();
    } else {
      console.log('No bookings to cancel. Test skipped.');
    }
  });

  it('should verify credit deduction after booking', async () => {
    // First check initial credit balance
    await navigateToTab('Dashboard');
    const initialCreditsText = await element(by.id('credits-balance')).getText();
    const initialCredits = parseInt(initialCreditsText.match(/\d+/)[0], 10);
    
    // Navigate to sessions tab and book a session
    await navigateToTab('Sessions');
    await element(by.id('session-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Check if session is available for booking
    if (await element(by.id('book-button')).isVisible()) {
      // Get credit cost
      const creditCostText = await element(by.id('credit-cost')).getText();
      const creditCost = parseInt(creditCostText.match(/\d+/)[0], 10);
      
      // Book the session
      await element(by.id('book-button')).tap();
      await element(by.id('confirm-booking-button')).tap();
      await waitForLoadingToFinish();
      
      // Go back to dashboard
      await navigateToTab('Dashboard');
      
      // Check updated credits
      const updatedCreditsText = await element(by.id('credits-balance')).getText();
      const updatedCredits = parseInt(updatedCreditsText.match(/\d+/)[0], 10);
      
      // Verify credits were deducted
      expect(updatedCredits).toBe(initialCredits - creditCost);
    } else {
      console.log('No available sessions for booking. Test skipped.');
    }
  });
});