/**
 * Integration tests for the Tutorial Service
 * Tests the interaction between the tutorial service and Firebase
 */
import { 
  fetchTutorials, 
  fetchTutorialDetails,
  fetchTutorialProgress,
  updateExerciseProgress
} from '../../../services/tutorialService';
import { mockFirebase } from '../../mocks/firebaseMock';

// Mock the Firebase module
jest.mock('@react-native-firebase/app', () => mockFirebase);
jest.mock('@react-native-firebase/firestore', () => mockFirebase.firestore);
jest.mock('@react-native-firebase/storage', () => mockFirebase.storage);

describe('Tutorial Service', () => {
  // Mock user ID for tests
  const userId = 'test-user-id';
  
  describe('fetchTutorials', () => {
    test('returns list of available tutorials', async () => {
      const tutorials = await fetchTutorials();
      
      expect(tutorials).toBeDefined();
      expect(Array.isArray(tutorials)).toBe(true);
      expect(tutorials.length).toBeGreaterThan(0);
      
      // Check tutorial properties
      const tutorial = tutorials[0];
      expect(tutorial.id).toBeDefined();
      expect(tutorial.title).toBeDefined();
      expect(tutorial.category).toBeDefined();
      expect(tutorial.difficulty).toBeDefined();
      expect(tutorial.thumbnailUrl).toBeDefined();
    });
    
    test('filters tutorials by category', async () => {
      const yogaTutorials = await fetchTutorials({ category: 'yoga' });
      
      expect(yogaTutorials).toBeDefined();
      expect(Array.isArray(yogaTutorials)).toBe(true);
      
      // All returned tutorials should be in the yoga category
      yogaTutorials.forEach(tutorial => {
        expect(tutorial.category).toBe('yoga');
      });
    });
    
    test('filters tutorials by difficulty', async () => {
      const beginnerTutorials = await fetchTutorials({ difficulty: 'beginner' });
      
      expect(beginnerTutorials).toBeDefined();
      expect(Array.isArray(beginnerTutorials)).toBe(true);
      
      // All returned tutorials should be beginner difficulty
      beginnerTutorials.forEach(tutorial => {
        expect(tutorial.difficulty).toBe('beginner');
      });
    });
    
    test('sorts tutorials by specified field', async () => {
      const tutorials = await fetchTutorials({ 
        sortBy: 'title', 
        sortDirection: 'asc' 
      });
      
      expect(tutorials).toBeDefined();
      expect(Array.isArray(tutorials)).toBe(true);
      
      // Check if tutorials are sorted by title
      const titles = tutorials.map(t => t.title);
      const sortedTitles = [...titles].sort();
      expect(titles).toEqual(sortedTitles);
    });
  });
  
  describe('fetchTutorialDetails', () => {
    test('returns detailed tutorial information', async () => {
      const tutorialId = 'tutorial-1';
      const tutorialDetails = await fetchTutorialDetails(tutorialId);
      
      expect(tutorialDetails).toBeDefined();
      expect(tutorialDetails.id).toBe(tutorialId);
      expect(tutorialDetails.title).toBeDefined();
      expect(tutorialDetails.description).toBeDefined();
      expect(tutorialDetails.category).toBeDefined();
      expect(tutorialDetails.difficulty).toBeDefined();
      expect(tutorialDetails.totalDays).toBeGreaterThan(0);
    });
    
    test('includes days and exercises in tutorial details', async () => {
      const tutorialId = 'tutorial-1';
      const tutorialDetails = await fetchTutorialDetails(tutorialId);
      
      expect(tutorialDetails.days).toBeDefined();
      expect(Array.isArray(tutorialDetails.days)).toBe(true);
      
      if (tutorialDetails.days.length > 0) {
        const day = tutorialDetails.days[0];
        expect(day.dayNumber).toBeDefined();
        expect(day.exercises).toBeDefined();
        expect(Array.isArray(day.exercises)).toBe(true);
        
        if (day.exercises.length > 0) {
          const exercise = day.exercises[0];
          expect(exercise.id).toBeDefined();
          expect(exercise.title).toBeDefined();
          expect(exercise.videoUrl).toBeDefined();
          expect(exercise.thumbnailUrl).toBeDefined();
        }
      }
    });
    
    test('throws error for non-existent tutorial', async () => {
      const nonExistentId = 'non-existent-tutorial';
      
      await expect(fetchTutorialDetails(nonExistentId))
        .rejects.toThrow('Tutorial not found');
    });
  });
  
  describe('fetchTutorialProgress', () => {
    test('returns user progress for a tutorial', async () => {
      const tutorialId = 'tutorial-1';
      const progress = await fetchTutorialProgress(userId, tutorialId);
      
      expect(progress).toBeDefined();
      // Progress should be an object with exercise IDs as keys
      // and completion status as values
      expect(typeof progress).toBe('object');
    });
    
    test('returns empty object for new tutorial with no progress', async () => {
      const newTutorialId = 'tutorial-2'; // No progress recorded
      const progress = await fetchTutorialProgress(userId, newTutorialId);
      
      expect(progress).toBeDefined();
      expect(Object.keys(progress).length).toBe(0);
    });
  });
  
  describe('updateExerciseProgress', () => {
    test('updates progress for a specific exercise', async () => {
      const tutorialId = 'tutorial-1';
      const exerciseId = 'video-1';
      const completed = true;
      
      // Update progress
      await updateExerciseProgress(userId, tutorialId, exerciseId, completed);
      
      // Fetch updated progress
      const progress = await fetchTutorialProgress(userId, tutorialId);
      
      expect(progress).toBeDefined();
      expect(progress[exerciseId]).toBe(completed);
    });
    
    test('can mark exercise as incomplete', async () => {
      const tutorialId = 'tutorial-1';
      const exerciseId = 'video-1';
      const completed = false;
      
      // Update progress
      await updateExerciseProgress(userId, tutorialId, exerciseId, completed);
      
      // Fetch updated progress
      const progress = await fetchTutorialProgress(userId, tutorialId);
      
      expect(progress).toBeDefined();
      expect(progress[exerciseId]).toBe(completed);
    });
  });
});