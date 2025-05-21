const { device, element, by, expect, waitFor } = require('detox');
const {
  restartApp,
  waitForLoadingToFinish,
  loginUser,
  navigateToTab
} = require('../init');

describe('Role-Based Access Control', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  describe('Client Role Access', () => {
    beforeEach(async () => {
      // Login as client
      await loginUser('client@example.com', 'Password123!');
      await waitForLoadingToFinish();
    });

    it('should show client dashboard with credit balance', async () => {
      await expect(element(by.id('dashboard-screen'))).toBeVisible();
      await expect(element(by.id('credits-balance'))).toBeVisible();
      await expect(element(by.id('upcoming-bookings'))).toBeVisible();
    });

    it('should allow session booking', async () => {
      await navigateToTab('Sessions');
      await expect(element(by.id('sessions-screen'))).toBeVisible();
      await expect(element(by.id('book-button'))).toBeVisible();
    });

    it('should allow tutorial access', async () => {
      await navigateToTab('Tutorials');
      await expect(element(by.id('tutorials-screen'))).toBeVisible();
    });

    it('should NOT show instructor or admin screens', async () => {
      // Check navigation options
      await navigateToTab('Profile');
      
      // Verify admin/instructor options are not visible
      await expect(element(by.id('user-management-option'))).not.toBeVisible();
      await expect(element(by.id('create-session-option'))).not.toBeVisible();
      await expect(element(by.id('manage-tutorials-option'))).not.toBeVisible();
    });
  });

  describe('Instructor Role Access', () => {
    beforeEach(async () => {
      // Login as instructor
      await loginUser('instructor@fitsaga.com', 'Password123!');
      await waitForLoadingToFinish();
    });

    it('should show instructor dashboard with sessions overview', async () => {
      await expect(element(by.id('dashboard-screen'))).toBeVisible();
      await expect(element(by.id('my-sessions'))).toBeVisible();
      await expect(element(by.id('today-schedule'))).toBeVisible();
    });

    it('should allow creating and managing sessions', async () => {
      await navigateToTab('Sessions');
      
      // Check for create session button
      await expect(element(by.id('create-session-button'))).toBeVisible();
      
      // Tap on create session
      await element(by.id('create-session-button')).tap();
      await waitForLoadingToFinish();
      
      // Verify session creation form
      await expect(element(by.id('session-form-screen'))).toBeVisible();
      await expect(element(by.id('session-title-input'))).toBeVisible();
      await expect(element(by.id('session-date-picker'))).toBeVisible();
      
      // Go back
      await element(by.id('back-button')).tap();
    });

    it('should allow viewing client list', async () => {
      await navigateToTab('Clients');
      
      // Verify clients list is visible
      await expect(element(by.id('clients-screen'))).toBeVisible();
      await expect(element(by.id('clients-list'))).toBeVisible();
    });

    it('should NOT show admin screens', async () => {
      // Check navigation options
      await navigateToTab('Profile');
      
      // Verify admin options are not visible
      await expect(element(by.id('user-management-option'))).not.toBeVisible();
      await expect(element(by.id('adjust-credits-option'))).not.toBeVisible();
    });
  });

  describe('Admin Role Access', () => {
    beforeEach(async () => {
      // Login as admin
      await loginUser('admin@fitsaga.com', 'Password123!');
      await waitForLoadingToFinish();
    });

    it('should show admin dashboard with system overview', async () => {
      await expect(element(by.id('dashboard-screen'))).toBeVisible();
      await expect(element(by.id('system-stats'))).toBeVisible();
      await expect(element(by.id('user-stats'))).toBeVisible();
      await expect(element(by.id('session-stats'))).toBeVisible();
    });

    it('should allow user management', async () => {
      await navigateToTab('Admin');
      
      // Tap on user management
      await element(by.id('user-management-option')).tap();
      await waitForLoadingToFinish();
      
      // Verify user management screen
      await expect(element(by.id('user-management-screen'))).toBeVisible();
      await expect(element(by.id('create-user-button'))).toBeVisible();
      await expect(element(by.id('users-list'))).toBeVisible();
      
      // Check user actions are available
      await element(by.id('user-item')).atIndex(0).tap();
      await expect(element(by.id('edit-user-button'))).toBeVisible();
      await expect(element(by.id('reset-password-button'))).toBeVisible();
      
      // Go back
      await element(by.id('back-button')).tap();
    });

    it('should allow credit management', async () => {
      await navigateToTab('Admin');
      
      // Tap on credit management
      await element(by.id('credit-management-option')).tap();
      await waitForLoadingToFinish();
      
      // Verify credit management screen
      await expect(element(by.id('credit-management-screen'))).toBeVisible();
      await expect(element(by.id('adjust-credits-button'))).toBeVisible();
      
      // Go back
      await element(by.id('back-button')).tap();
    });

    it('should allow tutorial management', async () => {
      await navigateToTab('Admin');
      
      // Tap on tutorial management
      await element(by.id('tutorial-management-option')).tap();
      await waitForLoadingToFinish();
      
      // Verify tutorial management screen
      await expect(element(by.id('tutorial-management-screen'))).toBeVisible();
      await expect(element(by.id('create-tutorial-button'))).toBeVisible();
      await expect(element(by.id('edit-tutorial-button'))).toBeVisible();
      
      // Go back
      await element(by.id('back-button')).tap();
    });
  });

  describe('Role Switching', () => {
    it('should handle admin viewing app as client', async () => {
      // Login as admin
      await loginUser('admin@fitsaga.com', 'Password123!');
      await waitForLoadingToFinish();
      
      await navigateToTab('Admin');
      
      // Tap on "View as Client" option
      await element(by.id('view-as-client-option')).tap();
      await waitForLoadingToFinish();
      
      // Verify client view is shown
      await expect(element(by.id('client-view-banner'))).toBeVisible();
      await expect(element(by.id('credits-balance'))).toBeVisible();
      
      // Return to admin view
      await element(by.id('return-to-admin-view-button')).tap();
      await waitForLoadingToFinish();
      
      // Verify back to admin view
      await expect(element(by.id('dashboard-screen'))).toBeVisible();
      await expect(element(by.id('system-stats'))).toBeVisible();
    });
  });
});