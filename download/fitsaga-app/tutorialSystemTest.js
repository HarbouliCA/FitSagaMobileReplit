/**
 * Tests for the Tutorial System in FitSAGA app
 * Tests tutorial browsing, filtering, progress tracking and video playback
 */

// Mock tutorial data
const tutorialData = [
  {
    id: 'tutorial-1',
    title: 'Beginner Yoga Series',
    description: 'Perfect introduction to yoga fundamentals',
    category: 'yoga',
    difficulty: 'beginner',
    instructor: 'Jane Smith',
    thumbnailUrl: 'https://example.com/thumbnails/yoga-beginner.jpg',
    totalDays: 7,
    days: [
      {
        dayNumber: 1,
        title: 'Introduction and Basics',
        description: 'Learn the fundamental positions and breathing techniques',
        exercises: [
          {
            id: 'exercise-1-1',
            title: 'Breathing Techniques',
            description: 'Learn proper breathing for yoga practice',
            duration: 180, // seconds
            thumbnailUrl: 'https://example.com/thumbnails/breathing.jpg',
            videoUrl: 'https://storage.example.com/videos/breathing.mp4',
          },
          {
            id: 'exercise-1-2',
            title: 'Basic Poses',
            description: 'Introduction to fundamental yoga poses',
            duration: 300, // seconds
            thumbnailUrl: 'https://example.com/thumbnails/basic-poses.jpg',
            videoUrl: 'https://storage.example.com/videos/basic-poses.mp4',
          }
        ]
      },
      {
        dayNumber: 2,
        title: 'Balance and Flexibility',
        description: 'Improve your balance and flexibility',
        exercises: [
          {
            id: 'exercise-2-1',
            title: 'Balance Poses',
            description: 'Simple balance poses for beginners',
            duration: 240, // seconds
            thumbnailUrl: 'https://example.com/thumbnails/balance.jpg',
            videoUrl: 'https://storage.example.com/videos/balance.mp4',
          }
        ]
      }
    ]
  },
  {
    id: 'tutorial-2',
    title: 'HIIT Fundamentals',
    description: 'High-intensity interval training basics',
    category: 'cardio',
    difficulty: 'intermediate',
    instructor: 'Mike Johnson',
    thumbnailUrl: 'https://example.com/thumbnails/hiit.jpg',
    totalDays: 5,
    days: [
      {
        dayNumber: 1,
        title: 'HIIT Basics',
        description: 'Introduction to HIIT principles',
        exercises: [
          {
            id: 'exercise-3-1',
            title: 'Warm-up Routine',
            description: 'Essential warm-up for HIIT workouts',
            duration: 180, // seconds
            thumbnailUrl: 'https://example.com/thumbnails/warmup.jpg',
            videoUrl: 'https://storage.example.com/videos/warmup.mp4',
          }
        ]
      }
    ]
  }
];

// User progress data
let userProgress = {
  'tutorial-1': {
    lastAccessedDay: 1,
    completedExercises: {
      'exercise-1-1': {
        completed: true,
        lastWatched: '2025-05-20T14:30:00Z',
        watchProgress: 180 // seconds
      }
    }
  }
};

// Tutorial system utilities
const tutorialUtils = {
  // Get all tutorials
  getAllTutorials: () => {
    return [...tutorialData];
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
    
    if (filters.searchTerm) {
      const term = filters.searchTerm.toLowerCase();
      filtered = filtered.filter(tutorial => 
        tutorial.title.toLowerCase().includes(term) || 
        tutorial.description.toLowerCase().includes(term)
      );
    }
    
    return filtered;
  },
  
  // Get tutorial details by ID
  getTutorialById: (tutorialId) => {
    const tutorial = tutorialData.find(t => t.id === tutorialId);
    if (!tutorial) {
      throw new Error('Tutorial not found');
    }
    return tutorial;
  },
  
  // Get specific day from tutorial
  getTutorialDay: (tutorialId, dayNumber) => {
    const tutorial = tutorialUtils.getTutorialById(tutorialId);
    const day = tutorial.days.find(d => d.dayNumber === dayNumber);
    if (!day) {
      throw new Error('Tutorial day not found');
    }
    return day;
  },
  
  // Get user progress for a tutorial
  getUserProgress: (userId, tutorialId) => {
    return userProgress[tutorialId] || { lastAccessedDay: 1, completedExercises: {} };
  },
  
  // Mark exercise as completed
  markExerciseCompleted: (userId, tutorialId, exerciseId, completed = true) => {
    // Initialize progress if it doesn't exist
    if (!userProgress[tutorialId]) {
      userProgress[tutorialId] = {
        lastAccessedDay: 1,
        completedExercises: {}
      };
    }
    
    // Update exercise completion status
    userProgress[tutorialId].completedExercises[exerciseId] = {
      completed,
      lastWatched: new Date().toISOString(),
      watchProgress: completed ? 999 : 0 // If completed, set to a large value
    };
    
    return userProgress[tutorialId];
  },
  
  // Update exercise watch progress
  updateWatchProgress: (userId, tutorialId, exerciseId, secondsWatched, duration) => {
    // Initialize progress if it doesn't exist
    if (!userProgress[tutorialId]) {
      userProgress[tutorialId] = {
        lastAccessedDay: 1,
        completedExercises: {}
      };
    }
    
    if (!userProgress[tutorialId].completedExercises[exerciseId]) {
      userProgress[tutorialId].completedExercises[exerciseId] = {
        completed: false,
        lastWatched: new Date().toISOString(),
        watchProgress: 0
      };
    }
    
    // Update watch progress
    userProgress[tutorialId].completedExercises[exerciseId].watchProgress = secondsWatched;
    userProgress[tutorialId].completedExercises[exerciseId].lastWatched = new Date().toISOString();
    
    // Auto-mark as completed if watched more than 90% of the video
    if (duration && secondsWatched >= duration * 0.9) {
      userProgress[tutorialId].completedExercises[exerciseId].completed = true;
    }
    
    return userProgress[tutorialId].completedExercises[exerciseId];
  },
  
  // Calculate tutorial completion percentage
  calculateTutorialCompletion: (userId, tutorialId) => {
    const tutorial = tutorialUtils.getTutorialById(tutorialId);
    const progress = tutorialUtils.getUserProgress(userId, tutorialId);
    
    // Count total exercises
    let totalExercises = 0;
    tutorial.days.forEach(day => {
      totalExercises += day.exercises.length;
    });
    
    // Count completed exercises
    let completedExercises = 0;
    Object.values(progress.completedExercises).forEach(exercise => {
      if (exercise.completed) {
        completedExercises++;
      }
    });
    
    // Calculate percentage
    return totalExercises > 0 ? Math.round((completedExercises / totalExercises) * 100) : 0;
  },
  
  // Play video (mock function)
  playVideo: (videoUrl, startPosition = 0) => {
    return {
      url: videoUrl,
      startPosition,
      isPlaying: true,
      duration: 300, // Default duration
      currentPosition: startPosition,
      // Mock player controls
      play: () => true,
      pause: () => true,
      stop: () => true,
      seekTo: (position) => position
    };
  }
};

// Run Tutorial System Tests
console.log("Running FitSAGA Tutorial System Tests:");

// Test tutorial filtering
console.log("\nTest: Tutorial Filtering");
const yogaTutorials = tutorialUtils.filterTutorials({ category: 'yoga' });
console.log("Filter by yoga category:", 
  yogaTutorials.length === 1 && yogaTutorials[0].id === 'tutorial-1' ? "PASS" : "FAIL");

const beginnerTutorials = tutorialUtils.filterTutorials({ difficulty: 'beginner' });
console.log("Filter by beginner difficulty:", 
  beginnerTutorials.length === 1 && beginnerTutorials[0].id === 'tutorial-1' ? "PASS" : "FAIL");

const searchResults = tutorialUtils.filterTutorials({ searchTerm: 'yoga' });
console.log("Search for 'yoga':", 
  searchResults.length === 1 && searchResults[0].id === 'tutorial-1' ? "PASS" : "FAIL");

// Test tutorial details retrieval
console.log("\nTest: Tutorial Details");
try {
  const tutorial = tutorialUtils.getTutorialById('tutorial-1');
  console.log("Get tutorial by ID:", 
    tutorial.id === 'tutorial-1' && tutorial.title === 'Beginner Yoga Series' ? "PASS" : "FAIL");
  
  const day = tutorialUtils.getTutorialDay('tutorial-1', 1);
  console.log("Get tutorial day:", 
    day.dayNumber === 1 && day.exercises.length === 2 ? "PASS" : "FAIL");
} catch (error) {
  console.log("Tutorial details retrieval: FAIL -", error.message);
}

// Test progress tracking
console.log("\nTest: Progress Tracking");
const userId = 'test-user';

// Initial progress check
const initialProgress = tutorialUtils.getUserProgress(userId, 'tutorial-1');
console.log("Get initial progress:", 
  initialProgress && initialProgress.completedExercises['exercise-1-1']?.completed === true ? "PASS" : "FAIL");

// Mark exercise as completed
const updatedProgress = tutorialUtils.markExerciseCompleted(userId, 'tutorial-1', 'exercise-1-2', true);
console.log("Mark exercise as completed:", 
  updatedProgress.completedExercises['exercise-1-2']?.completed === true ? "PASS" : "FAIL");

// Calculate completion percentage
const completionPercentage = tutorialUtils.calculateTutorialCompletion(userId, 'tutorial-1');
console.log("Calculate completion percentage:", 
  completionPercentage === 67 ? "PASS" : "FAIL"); // 2 out of 3 exercises = 67%

// Test watch progress
console.log("\nTest: Video Watch Progress");
const watchProgress = tutorialUtils.updateWatchProgress(userId, 'tutorial-2', 'exercise-3-1', 100, 180);
console.log("Update watch progress:", 
  watchProgress.watchProgress === 100 && watchProgress.completed === false ? "PASS" : "FAIL");

// Auto-complete when watched 90%
const autoCompleteProgress = tutorialUtils.updateWatchProgress(userId, 'tutorial-2', 'exercise-3-1', 170, 180);
console.log("Auto-complete at 90% watched:", 
  autoCompleteProgress.completed === true ? "PASS" : "FAIL");

// Test video playback
console.log("\nTest: Video Playback");
const videoPlayer = tutorialUtils.playVideo('https://storage.example.com/videos/basic-poses.mp4', 30);
console.log("Video playback:", 
  videoPlayer.url === 'https://storage.example.com/videos/basic-poses.mp4' && 
  videoPlayer.isPlaying === true &&
  videoPlayer.startPosition === 30 ? "PASS" : "FAIL");

// Test resume from last position
const lastPosition = userProgress['tutorial-1'].completedExercises['exercise-1-1'].watchProgress;
const resumedVideo = tutorialUtils.playVideo('https://storage.example.com/videos/breathing.mp4', lastPosition);
console.log("Resume video from last position:", 
  resumedVideo.startPosition === lastPosition ? "PASS" : "FAIL");

console.log("\nAll tutorial system tests completed!");