const { device, element, by, waitFor } = require('detox');
const { execSync } = require('child_process');

// Reusable test credentials
const TEST_USER = {
  email: 'testuser@example.com',
  password: 'Password123!',
  name: 'Test User'
};

// Helper function to restart the app
async function restartApp() {
  await device.reloadReactNative();
}

// Helper function to cleanup between tests
async function cleanupDatabase() {
  try {
    console.log('Cleaning up test database...');
    execSync('cd .. && node ./scripts/reset-test-database.js');
  } catch (error) {
    console.error('Error cleaning up test database:', error.message);
  }
}

// Helper to wait for loading to finish
async function waitForLoadingToFinish() {
  try {
    await waitFor(element(by.id('loading-indicator')))
      .toBeNotVisible()
      .withTimeout(5000);
  } catch (error) {
    // Loading might have already finished
    console.log('No loading indicator found or already gone');
  }
}

// Helper function to login
async function loginUser(email = TEST_USER.email, password = TEST_USER.password) {
  await element(by.id('email-input')).replaceText(email);
  await element(by.id('password-input')).replaceText(password);
  await element(by.id('login-button')).tap();
  await waitForLoadingToFinish();
}

// Helper function to logout
async function logoutUser() {
  await element(by.id('profile-tab')).tap();
  await element(by.id('logout-button')).tap();
  await element(by.text('Yes')).tap(); // Confirm logout
  await waitForLoadingToFinish();
}

// Helper function to register a new user
async function registerNewUser(email, password, name, role = 'client') {
  await element(by.id('register-link')).tap();
  await element(by.id('name-input')).replaceText(name);
  await element(by.id('email-input')).replaceText(email);
  await element(by.id('password-input')).replaceText(password);
  await element(by.id('confirm-password-input')).replaceText(password);
  
  // Select role
  await element(by.id('role-dropdown')).tap();
  await element(by.text(role.charAt(0).toUpperCase() + role.slice(1))).tap();
  
  await element(by.id('register-button')).tap();
  await waitForLoadingToFinish();
}

// Helper to navigate to a specific tab
async function navigateToTab(tabName) {
  await element(by.id(`${tabName.toLowerCase()}-tab`)).tap();
  await waitForLoadingToFinish();
}

module.exports = {
  TEST_USER,
  restartApp,
  cleanupDatabase,
  waitForLoadingToFinish,
  loginUser,
  logoutUser,
  registerNewUser,
  navigateToTab
};