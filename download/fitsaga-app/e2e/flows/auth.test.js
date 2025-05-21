const { device, element, by, expect, waitFor } = require('detox');
const {
  TEST_USER,
  restartApp,
  cleanupDatabase,
  waitForLoadingToFinish,
  loginUser,
  logoutUser,
  registerNewUser
} = require('../init');

describe('Authentication Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  afterAll(async () => {
    await cleanupDatabase();
  });

  it('should display login screen on app launch', async () => {
    await expect(element(by.id('login-screen'))).toBeVisible();
    await expect(element(by.id('email-input'))).toBeVisible();
    await expect(element(by.id('password-input'))).toBeVisible();
    await expect(element(by.id('login-button'))).toBeVisible();
  });

  it('should login with valid credentials', async () => {
    await loginUser();
    
    // Verify we're on the dashboard screen
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
    await expect(element(by.text('Welcome'))).toBeVisible();
  });

  it('should show error with invalid credentials', async () => {
    await loginUser('wrong@example.com', 'wrongpassword');
    
    // Verify error message is shown
    await expect(element(by.text('Invalid email or password'))).toBeVisible();
    
    // Verify we're still on the login screen
    await expect(element(by.id('login-screen'))).toBeVisible();
  });

  it('should register a new user account', async () => {
    const newUser = {
      email: `test${Date.now()}@example.com`,
      password: 'Password123!',
      name: 'New Test User'
    };
    
    await registerNewUser(newUser.email, newUser.password, newUser.name);
    
    // Verify we're on the dashboard after successful registration
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
    await expect(element(by.text('Welcome'))).toBeVisible();
    await expect(element(by.text(newUser.name))).toBeVisible();
  });

  it('should navigate to forgot password screen', async () => {
    await element(by.id('forgot-password-link')).tap();
    
    // Verify we're on the forgot password screen
    await expect(element(by.id('forgot-password-screen'))).toBeVisible();
    await expect(element(by.id('email-input'))).toBeVisible();
    await expect(element(by.id('reset-password-button'))).toBeVisible();
  });

  it('should logout successfully', async () => {
    // Login first
    await loginUser();
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
    
    // Then logout
    await logoutUser();
    
    // Verify we're back at the login screen
    await expect(element(by.id('login-screen'))).toBeVisible();
  });

  it('should register with different roles', async () => {
    // Test client role registration
    const clientUser = {
      email: `client${Date.now()}@example.com`,
      password: 'Password123!',
      name: 'Client User',
      role: 'client'
    };
    
    await registerNewUser(
      clientUser.email, 
      clientUser.password, 
      clientUser.name, 
      clientUser.role
    );
    
    // Verify we see client-specific screens
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
    await expect(element(by.id('credits-balance'))).toBeVisible();
    
    // Logout
    await logoutUser();
    
    // Test instructor role registration
    const instructorUser = {
      email: `instructor${Date.now()}@example.com`,
      password: 'Password123!',
      name: 'Instructor User',
      role: 'instructor'
    };
    
    await registerNewUser(
      instructorUser.email, 
      instructorUser.password, 
      instructorUser.name, 
      instructorUser.role
    );
    
    // Verify we see instructor-specific screens
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
    await expect(element(by.id('my-sessions'))).toBeVisible();
    
    // Logout
    await logoutUser();
  });
});