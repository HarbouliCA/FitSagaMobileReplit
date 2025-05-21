const { device, element, by, expect, waitFor } = require('detox');
const {
  TEST_USER,
  restartApp,
  waitForLoadingToFinish,
  loginUser,
  navigateToTab
} = require('../init');

describe('Tutorials Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
    // Login before each test
    await loginUser();
    await waitForLoadingToFinish();
  });

  it('should display available tutorials', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Verify tutorials are displayed
    await expect(element(by.id('tutorials-screen'))).toBeVisible();
    await expect(element(by.id('tutorials-list'))).toBeVisible();
    
    // Check if at least one tutorial is visible
    await expect(element(by.id('tutorial-item'))).toBeVisible();
  });

  it('should filter tutorials by category', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Tap on filter button
    await element(by.id('filter-button')).tap();
    
    // Select 'Yoga' category
    await element(by.text('Yoga')).tap();
    
    // Apply filter
    await element(by.id('apply-filter-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify yoga tutorials are shown
    const firstTutorialCategory = await element(by.id('category-text')).getText();
    expect(firstTutorialCategory.toLowerCase()).toContain('yoga');
    
    // Reset filters
    await element(by.id('filter-button')).tap();
    await element(by.id('reset-filter-button')).tap();
  });

  it('should filter tutorials by difficulty', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Tap on filter button
    await element(by.id('filter-button')).tap();
    
    // Select 'Beginner' difficulty
    await element(by.text('Beginner')).tap();
    
    // Apply filter
    await element(by.id('apply-filter-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify beginner tutorials are shown
    const firstTutorialDifficulty = await element(by.id('difficulty-text')).getText();
    expect(firstTutorialDifficulty.toLowerCase()).toContain('beginner');
    
    // Reset filters
    await element(by.id('filter-button')).tap();
    await element(by.id('reset-filter-button')).tap();
  });

  it('should display tutorial details', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Select first tutorial
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Verify tutorial details are displayed
    await expect(element(by.id('tutorial-details-screen'))).toBeVisible();
    await expect(element(by.id('tutorial-title'))).toBeVisible();
    await expect(element(by.id('tutorial-description'))).toBeVisible();
    await expect(element(by.id('instructor-name'))).toBeVisible();
    await expect(element(by.id('difficulty-level'))).toBeVisible();
    await expect(element(by.id('start-tutorial-button'))).toBeVisible();
  });

  it('should navigate through tutorial days', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Select first tutorial
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Start tutorial
    await element(by.id('start-tutorial-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify day 1 is shown
    await expect(element(by.id('tutorial-day-screen'))).toBeVisible();
    await expect(element(by.id('day-number'))).toHaveText('Day 1');
    
    // Check if exercises are displayed
    await expect(element(by.id('exercise-list'))).toBeVisible();
    await expect(element(by.id('exercise-item'))).toBeVisible();
    
    // Navigate to next day if available
    const hasNextDay = await element(by.id('next-day-button')).isVisible();
    
    if (hasNextDay) {
      await element(by.id('next-day-button')).tap();
      await waitForLoadingToFinish();
      
      // Verify day 2 is shown
      await expect(element(by.id('day-number'))).toHaveText('Day 2');
      
      // Go back to previous day
      await element(by.id('previous-day-button')).tap();
      await waitForLoadingToFinish();
      
      // Verify back on day 1
      await expect(element(by.id('day-number'))).toHaveText('Day 1');
    }
  });

  it('should play tutorial video', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Select first tutorial
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Start tutorial
    await element(by.id('start-tutorial-button')).tap();
    await waitForLoadingToFinish();
    
    // Select first exercise
    await element(by.id('exercise-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Verify video player is shown
    await expect(element(by.id('video-player-screen'))).toBeVisible();
    await expect(element(by.id('video-title'))).toBeVisible();
    await expect(element(by.id('play-button'))).toBeVisible();
    
    // Tap play button
    await element(by.id('play-button')).tap();
    
    // Wait a bit for video to play
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Tap pause button
    await element(by.id('pause-button')).tap();
    
    // Go back to exercise list
    await element(by.id('back-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify back on day screen
    await expect(element(by.id('tutorial-day-screen'))).toBeVisible();
  });

  it('should mark exercise as complete', async () => {
    // Navigate to tutorials tab
    await navigateToTab('Tutorials');
    
    // Select first tutorial
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Start tutorial
    await element(by.id('start-tutorial-button')).tap();
    await waitForLoadingToFinish();
    
    // Select first exercise
    await element(by.id('exercise-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Play video for a bit
    await element(by.id('play-button')).tap();
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Mark as complete
    await element(by.id('mark-complete-button')).tap();
    
    // Go back to exercise list
    await element(by.id('back-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify exercise is marked as complete
    await expect(element(by.id('completed-indicator')).atIndex(0)).toBeVisible();
  });

  it('should show progress on tutorial card', async () => {
    // First mark an exercise as complete
    await navigateToTab('Tutorials');
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    await element(by.id('start-tutorial-button')).tap();
    await waitForLoadingToFinish();
    await element(by.id('exercise-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    await element(by.id('mark-complete-button')).tap();
    
    // Go back to tutorials list
    await element(by.id('back-button')).tap();
    await waitForLoadingToFinish();
    await element(by.id('back-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify progress indicator is shown on the tutorial card
    await expect(element(by.id('progress-indicator')).atIndex(0)).toBeVisible();
  });

  it('should resume tutorial from last position', async () => {
    // First complete an exercise
    await navigateToTab('Tutorials');
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    await element(by.id('start-tutorial-button')).tap();
    await waitForLoadingToFinish();
    await element(by.id('exercise-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    await element(by.id('mark-complete-button')).tap();
    await element(by.id('back-button')).tap();
    await waitForLoadingToFinish();
    
    // Go back to tutorial list and reopen the same tutorial
    await element(by.id('back-button')).tap();
    await waitForLoadingToFinish();
    await element(by.id('tutorial-item')).atIndex(0).tap();
    await waitForLoadingToFinish();
    
    // Verify 'Resume' button is shown instead of 'Start'
    await expect(element(by.id('resume-tutorial-button'))).toBeVisible();
    
    // Tap resume
    await element(by.id('resume-tutorial-button')).tap();
    await waitForLoadingToFinish();
    
    // Verify we're on the correct day
    await expect(element(by.id('tutorial-day-screen'))).toBeVisible();
    
    // Verify completed indicator is shown for first exercise
    await expect(element(by.id('completed-indicator')).atIndex(0)).toBeVisible();
  });
});