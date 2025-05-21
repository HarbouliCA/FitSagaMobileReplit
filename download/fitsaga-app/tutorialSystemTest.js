/**
 * Tests for the Tutorial System in FitSAGA app
 * Tests tutorial filtering, progress tracking, and video playback
 */

// Mock tutorial data
const tutorialData = [
  {
    id: 'tutorial-1',
    title: 'Proper Squat Form',
    description: 'Learn the correct form for squats to prevent injury',
    category: 'strength',
    difficulty: 'beginner',
    duration: 8, // minutes
    instructorId: 'instructor-1',
    instructorName: 'Jane Smith',
    thumbnailUrl: 'https://example.com/thumbnails/squat.jpg',
    videoUrl: 'https://storage.example.com/tutorials/squat-form.mp4',
    createdAt: new Date('2025-01-15'),
    tags: ['squat', 'form', 'technique', 'strength'],
    equipment: ['none'],
    muscleGroups: ['quadriceps', 'glutes', 'hamstrings'],
    steps: [
      { step: 1, title: 'Starting Position', timestamp: 0 },
      { step: 2, title: 'Descent Phase', timestamp: 120 },
      { step: 3, title: 'Bottom Position', timestamp: 210 },
      { step: 4, title: 'Ascent Phase', timestamp: 290 },
      { step: 5, title: 'Common Mistakes', timestamp: 380 }
    ]
  },
  {
    id: 'tutorial-2',
    title: 'Advanced Yoga Flow',
    description: 'A challenging yoga flow for experienced practitioners',
    category: 'yoga',
    difficulty: 'advanced',
    duration: 15, // minutes
    instructorId: 'instructor-2',
    instructorName: 'Mike Johnson',
    thumbnailUrl: 'https://example.com/thumbnails/yoga.jpg',
    videoUrl: 'https://storage.example.com/tutorials/advanced-yoga.mp4',
    createdAt: new Date('2025-02-20'),
    tags: ['yoga', 'flow', 'flexibility', 'balance'],
    equipment: ['yoga mat'],
    muscleGroups: ['core', 'arms', 'legs', 'back'],
    steps: [
      { step: 1, title: 'Warm-up', timestamp: 0 },
      { step: 2, title: 'Standing Sequence', timestamp: 180 },
      { step: 3, title: 'Balance Poses', timestamp: 360 },
      { step: 4, title: 'Floor Sequence', timestamp: 540 },
      { step: 5, title: 'Final Relaxation', timestamp: 780 }
    ]
  },
  {
    id: 'tutorial-3',
    title: 'HIIT Workout Introduction',
    description: 'Get started with high-intensity interval training',
    category: 'cardio',
    difficulty: 'beginner',
    duration: 10, // minutes
    instructorId: 'instructor-1',
    instructorName: 'Jane Smith',
    thumbnailUrl: 'https://example.com/thumbnails/hiit.jpg',
    videoUrl: 'https://storage.example.com/tutorials/hiit-intro.mp4',
    createdAt: new Date('2025-03-05'),
    tags: ['hiit', 'cardio', 'workout', 'interval'],
    equipment: ['none'],
    muscleGroups: ['full body'],
    steps: [
      { step: 1, title: 'What is HIIT?', timestamp: 0 },
      { step: 2, title: 'Warm-up Exercises', timestamp: 120 },
      { step: 3, title: 'Work/Rest Intervals', timestamp: 240 },
      { step: 4, title: 'Sample HIIT Circuit', timestamp: 360 },
      { step: 5, title: 'Cool Down', timestamp: 480 }
    ]
  }
];

// Mock user progress data
let userProgressData = {
  'client-1': [
    {
      tutorialId: 'tutorial-1',
      watched: true,
      completedAt: new Date('2025-05-10'),
      progress: 100, // percentage
      currentTimestamp: 480, // seconds
      lastWatched: new Date('2025-05-10')
    },
    {
      tutorialId: 'tutorial-3',
      watched: false,
      completedAt: null,
      progress: 60, // percentage
      currentTimestamp: 290, // seconds
      lastWatched: new Date('2025-05-15')
    }
  ]
};

// Mock user data
const userData = {
  'client-1': {
    id: 'client-1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'client',
    preferences: {
      favoriteTutorialCategories: ['strength', 'cardio'],
      favoriteInstructors: ['instructor-1']
    }
  }
};

// Mock video player
const videoPlayer = {
  play: (videoUrl, startTime = 0) => {
    console.log(`Playing video: ${videoUrl} from ${startTime} seconds`);
    return { playing: true, url: videoUrl, currentTime: startTime };
  },
  
  pause: () => {
    console.log('Video paused');
    return { playing: false };
  },
  
  seekTo: (timestamp) => {
    console.log(`Seeking to timestamp: ${timestamp} seconds`);
    return { currentTime: timestamp };
  },
  
  getCurrentTime: () => {
    return 300; // Mock current time (5 minutes)
  }
};

// Tutorial system utilities
const tutorialUtils = {
  // Get all tutorials
  getAllTutorials: () => {
    return [...tutorialData];
  },
  
  // Get tutorial by ID
  getTutorialById: (tutorialId) => {
    const tutorial = tutorialData.find(t => t.id === tutorialId);
    if (!tutorial) {
      throw new Error('Tutorial not found');
    }
    return tutorial;
  },
  
  // Filter tutorials by criteria
  filterTutorials: (filters = {}) => {
    let filtered = [...tutorialData];
    
    if (filters.category) {
      filtered = filtered.filter(tutorial => tutorial.category === filters.category);
    }
    
    if (filters.difficulty) {
      filtered = filtered.filter(tutorial => tutorial.difficulty === filters.difficulty);
    }
    
    if (filters.instructorId) {
      filtered = filtered.filter(tutorial => tutorial.instructorId === filters.instructorId);
    }
    
    if (filters.equipment) {
      filtered = filtered.filter(tutorial => 
        tutorial.equipment.some(eq => filters.equipment.includes(eq))
      );
    }
    
    if (filters.muscleGroups) {
      filtered = filtered.filter(tutorial => 
        tutorial.muscleGroups.some(mg => filters.muscleGroups.includes(mg))
      );
    }
    
    if (filters.maxDuration) {
      filtered = filtered.filter(tutorial => tutorial.duration <= filters.maxDuration);
    }
    
    return filtered;
  },
  
  // Get user progress for all tutorials
  getUserProgress: (userId) => {
    return userProgressData[userId] || [];
  },
  
  // Get user progress for a specific tutorial
  getTutorialProgress: (userId, tutorialId) => {
    const userProgress = userProgressData[userId] || [];
    return userProgress.find(p => p.tutorialId === tutorialId) || {
      tutorialId,
      watched: false,
      completedAt: null,
      progress: 0,
      currentTimestamp: 0,
      lastWatched: null
    };
  },
  
  // Update tutorial progress
  updateTutorialProgress: (userId, tutorialId, progressData) => {
    // Get user progress array, or create if it doesn't exist
    if (!userProgressData[userId]) {
      userProgressData[userId] = [];
    }
    
    // Find existing progress entry
    const progressIndex = userProgressData[userId].findIndex(
      p => p.tutorialId === tutorialId
    );
    
    const now = new Date();
    const newProgress = {
      tutorialId,
      watched: progressData.progress >= 90, // Mark as watched if progress >= 90%
      completedAt: progressData.progress >= 90 ? now : null,
      progress: progressData.progress,
      currentTimestamp: progressData.currentTimestamp,
      lastWatched: now
    };
    
    // Update or add progress entry
    if (progressIndex !== -1) {
      userProgressData[userId][progressIndex] = newProgress;
    } else {
      userProgressData[userId].push(newProgress);
    }
    
    return newProgress;
  },
  
  // Play tutorial video
  playTutorial: (tutorialId, startTime = 0) => {
    const tutorial = tutorialUtils.getTutorialById(tutorialId);
    return videoPlayer.play(tutorial.videoUrl, startTime);
  },
  
  // Get recommended tutorials for user
  getRecommendedTutorials: (userId) => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    // Get user preferences
    const preferences = user.preferences || {};
    
    // Create filters based on preferences
    const filters = {};
    
    if (preferences.favoriteTutorialCategories?.length > 0) {
      // Filter by any of user's favorite categories
      return tutorialData.filter(tutorial => 
        preferences.favoriteTutorialCategories.includes(tutorial.category)
      );
    }
    
    // If no specific preferences, return all tutorials
    return tutorialData;
  }
};

// Run Tutorial System Tests
console.log("Running FitSAGA Tutorial System Tests:");

// Test tutorial filtering
console.log("\nTest: Tutorial Filtering");
const yogaTutorials = tutorialUtils.filterTutorials({ category: 'yoga' });
console.log("Filter by yoga category:", 
  yogaTutorials.length === 1 && yogaTutorials[0].id === 'tutorial-2' ? "PASS" : "FAIL");

const beginnerTutorials = tutorialUtils.filterTutorials({ difficulty: 'beginner' });
console.log("Filter by beginner difficulty:", 
  beginnerTutorials.length === 2 && 
  beginnerTutorials.some(t => t.id === 'tutorial-1') && 
  beginnerTutorials.some(t => t.id === 'tutorial-3') ? "PASS" : "FAIL");

const shortTutorials = tutorialUtils.filterTutorials({ maxDuration: 10 });
console.log("Filter by max duration (10 min):", 
  shortTutorials.length === 2 && 
  shortTutorials.some(t => t.id === 'tutorial-1') && 
  shortTutorials.some(t => t.id === 'tutorial-3') ? "PASS" : "FAIL");

// Test user progress tracking
console.log("\nTest: Progress Tracking");
const userId = 'client-1';

// Get initial progress
const initialProgress = tutorialUtils.getUserProgress(userId);
console.log("Get user progress:", initialProgress.length === 2 ? "PASS" : "FAIL");

// Get progress for a specific tutorial
const squat1Progress = tutorialUtils.getTutorialProgress(userId, 'tutorial-1');
console.log("Get tutorial progress:", 
  squat1Progress.tutorialId === 'tutorial-1' && squat1Progress.progress === 100 ? "PASS" : "FAIL");

// Update tutorial progress
const updatedProgress = tutorialUtils.updateTutorialProgress(userId, 'tutorial-2', {
  progress: 45,
  currentTimestamp: 320
});

console.log("Update tutorial progress:", 
  updatedProgress.progress === 45 && updatedProgress.currentTimestamp === 320 ? "PASS" : "FAIL");

// Check if progress was saved
const savedProgress = tutorialUtils.getTutorialProgress(userId, 'tutorial-2');
console.log("Verify progress saved:", 
  savedProgress.progress === 45 && savedProgress.currentTimestamp === 320 ? "PASS" : "FAIL");

// Test video playback
console.log("\nTest: Video Playback");
const playbackResult = tutorialUtils.playTutorial('tutorial-1');
console.log("Play tutorial video:", 
  playbackResult.playing === true && 
  playbackResult.url === tutorialUtils.getTutorialById('tutorial-1').videoUrl ? "PASS" : "FAIL");

// Test resume from last position
const resumeResult = tutorialUtils.playTutorial('tutorial-3', squat1Progress.currentTimestamp);
console.log("Resume tutorial from last position:", 
  resumeResult.currentTime === squat1Progress.currentTimestamp ? "PASS" : "FAIL");

// Test recommendations
console.log("\nTest: Tutorial Recommendations");
const recommendations = tutorialUtils.getRecommendedTutorials(userId);
console.log("Get personalized recommendations:", 
  recommendations.length === 2 &&
  recommendations.some(t => t.category === 'strength') && 
  recommendations.some(t => t.category === 'cardio') ? "PASS" : "FAIL");

console.log("\nAll tutorial system tests completed!");