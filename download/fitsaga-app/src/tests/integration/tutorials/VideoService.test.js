/**
 * Integration tests for the Video Service
 * Tests functionality related to video metadata retrieval and playback
 */
import { 
  fetchVideoMetadata, 
  getVideoUrl,
  updateWatchProgress,
  getWatchHistory
} from '../../../services/videoService';
import { mockFirebase } from '../../mocks/firebaseMock';

// Mock the Firebase module
jest.mock('@react-native-firebase/app', () => mockFirebase);
jest.mock('@react-native-firebase/firestore', () => mockFirebase.firestore);
jest.mock('@react-native-firebase/storage', () => mockFirebase.storage);

// Mock Azure Blob Storage module
jest.mock('../../../services/azureStorageService', () => ({
  generateSasUrl: jest.fn((blobUrl) => {
    // Simply append a fake SAS token to the URL for testing
    return `${blobUrl}?sv=2023-01-01&st=2025-05-21&se=2025-05-22&sr=b&sp=r&sig=fakesastoken`;
  }),
  getBlobNameFromUrl: jest.fn((url) => {
    // Extract the blob name from the URL
    const parts = url.split('/');
    return parts[parts.length - 1];
  }),
}));

describe('Video Service', () => {
  // Mock user ID for tests
  const userId = 'test-user-id';
  const videoId = 'video-1'; // From mock data
  
  describe('Video Metadata', () => {
    test('fetches video metadata by ID', async () => {
      const metadata = await fetchVideoMetadata(videoId);
      
      expect(metadata).toBeDefined();
      expect(metadata.id).toBe(videoId);
      expect(metadata.title).toBeDefined();
      expect(metadata.description).toBeDefined();
      expect(metadata.tutorialId).toBeDefined();
      expect(metadata.thumbnailUrl).toBeDefined();
      expect(metadata.videoUrl).toBeDefined();
      expect(metadata.duration).toBeGreaterThan(0);
    });
    
    test('throws error for non-existent video', async () => {
      const nonExistentId = 'non-existent-video';
      
      await expect(fetchVideoMetadata(nonExistentId))
        .rejects.toThrow('Video metadata not found');
    });
    
    test('fetches videos for a specific tutorial day', async () => {
      const tutorialId = 'tutorial-1';
      const dayNumber = 1;
      
      const videos = await fetchVideoMetadata(null, { tutorialId, dayNumber });
      
      expect(videos).toBeDefined();
      expect(Array.isArray(videos)).toBe(true);
      
      // All videos should be for the specified tutorial and day
      videos.forEach(video => {
        expect(video.tutorialId).toBe(tutorialId);
        expect(video.dayNumber).toBe(dayNumber);
      });
    });
  });
  
  describe('Video URL Generation', () => {
    test('generates playback URL from Firebase storage', async () => {
      // Set up a video with Firebase storage URL
      const firebaseVideo = {
        id: 'firebase-video',
        videoUrl: 'gs://fitsaga-app.appspot.com/videos/sample.mp4',
        title: 'Firebase Storage Video',
      };
      
      mockFirebase.firestore()._collections.videoMetadata['firebase-video'] = firebaseVideo;
      
      // Add to Firebase storage mocks
      mockFirebase.storage()._files['videos/sample.mp4'] = {
        url: 'https://firebasestorage.googleapis.com/v0/b/fitsaga-app.appspot.com/o/videos%2Fsample.mp4?alt=media',
        metadata: {
          contentType: 'video/mp4',
          size: 5000000,
        },
      };
      
      const url = await getVideoUrl(firebaseVideo);
      
      expect(url).toBeDefined();
      expect(url).toContain('firebasestorage.googleapis.com');
      expect(url).toContain('sample.mp4');
    });
    
    test('generates playback URL from Azure blob storage', async () => {
      // Set up a video with Azure blob storage URL
      const azureVideo = {
        id: 'azure-video',
        videoUrl: 'https://fitsagastorage.blob.core.windows.net/tutorials/yoga-basics.mp4',
        title: 'Azure Storage Video',
      };
      
      mockFirebase.firestore()._collections.videoMetadata['azure-video'] = azureVideo;
      
      const url = await getVideoUrl(azureVideo);
      
      expect(url).toBeDefined();
      expect(url).toContain('fitsagastorage.blob.core.windows.net');
      expect(url).toContain('yoga-basics.mp4');
      expect(url).toContain('fakesastoken'); // Our mock SAS token
    });
    
    test('handles direct HTTP URLs', async () => {
      // Set up a video with direct HTTP URL
      const httpVideo = {
        id: 'http-video',
        videoUrl: 'https://example.com/videos/sample.mp4',
        title: 'HTTP Video',
      };
      
      mockFirebase.firestore()._collections.videoMetadata['http-video'] = httpVideo;
      
      const url = await getVideoUrl(httpVideo);
      
      expect(url).toBeDefined();
      expect(url).toBe('https://example.com/videos/sample.mp4');
    });
  });
  
  describe('Watch Progress Tracking', () => {
    test('updates watch progress for a video', async () => {
      // Progress data to save
      const progressData = {
        position: 45, // seconds
        duration: 180, // seconds
        completed: false,
      };
      
      // Update watch progress
      await updateWatchProgress(userId, videoId, progressData);
      
      // Fetch watch history to verify
      const watchHistory = await getWatchHistory(userId);
      
      expect(watchHistory).toBeDefined();
      expect(watchHistory[videoId]).toBeDefined();
      expect(watchHistory[videoId].position).toBe(progressData.position);
      expect(watchHistory[videoId].duration).toBe(progressData.duration);
      expect(watchHistory[videoId].completed).toBe(progressData.completed);
      expect(watchHistory[videoId].lastWatched).toBeDefined();
    });
    
    test('marks video as completed when watching 90% or more', async () => {
      // Progress data with 90% completion
      const progressData = {
        position: 162, // 90% of 180 seconds
        duration: 180,
        completed: false, // Explicitly set to false
      };
      
      // Update watch progress
      await updateWatchProgress(userId, videoId, progressData);
      
      // Fetch watch history to verify
      const watchHistory = await getWatchHistory(userId);
      
      expect(watchHistory).toBeDefined();
      expect(watchHistory[videoId]).toBeDefined();
      // Should be automatically marked as completed at ≥90%
      expect(watchHistory[videoId].completed).toBe(true);
    });
    
    test('retrieves watch history for a user', async () => {
      // Update progress for multiple videos
      await updateWatchProgress(userId, 'video-1', { position: 30, duration: 180 });
      await updateWatchProgress(userId, 'azure-video', { position: 60, duration: 240 });
      
      // Fetch watch history
      const watchHistory = await getWatchHistory(userId);
      
      expect(watchHistory).toBeDefined();
      expect(Object.keys(watchHistory).length).toBeGreaterThanOrEqual(2);
      expect(watchHistory['video-1']).toBeDefined();
      expect(watchHistory['azure-video']).toBeDefined();
    });
    
    test('retrieves watch progress for specific video', async () => {
      // Update progress
      const progressData = { position: 75, duration: 180 };
      await updateWatchProgress(userId, videoId, progressData);
      
      // Fetch specific video progress
      const progress = await getWatchHistory(userId, videoId);
      
      expect(progress).toBeDefined();
      expect(progress.position).toBe(progressData.position);
      expect(progress.duration).toBe(progressData.duration);
    });
  });
  
  describe('Offline Video Access', () => {
    test('marks video for offline access', async () => {
      // Mock function to mark video for offline access
      const markVideoForOffline = jest.fn(async (userId, videoId) => {
        const metadata = await fetchVideoMetadata(videoId);
        
        // Mock implementation - in a real app, this would download the video
        // and store reference in a local database
        return {
          id: videoId,
          localUri: `file:///data/user/0/com.fitsaga.app/files/videos/${videoId}.mp4`,
          title: metadata.title,
          thumbnailUrl: metadata.thumbnailUrl,
          size: 15000000, // Bytes
          savedAt: new Date(),
        };
      });
      
      const result = await markVideoForOffline(userId, videoId);
      
      expect(result).toBeDefined();
      expect(result.id).toBe(videoId);
      expect(result.localUri).toContain(videoId);
      expect(result.localUri).toContain('.mp4');
      expect(result.title).toBeDefined();
    });
    
    test('prioritizes offline video over network video', async () => {
      // Mock function to check if video is available offline
      const isVideoAvailableOffline = jest.fn((videoId) => {
        // Mock implementation - pretend video-1 is available offline
        return videoId === 'video-1';
      });
      
      // Mock function to get offline video URI
      const getOfflineVideoUri = jest.fn((videoId) => {
        if (isVideoAvailableOffline(videoId)) {
          return `file:///data/user/0/com.fitsaga.app/files/videos/${videoId}.mp4`;
        }
        return null;
      });
      
      // Custom implementation of getVideoUrl that checks offline availability
      const getVideoUrlWithOfflineSupport = async (videoMetadata) => {
        // Check if available offline first
        if (isVideoAvailableOffline(videoMetadata.id)) {
          return getOfflineVideoUri(videoMetadata.id);
        }
        
        // Fall back to online URL
        return getVideoUrl(videoMetadata);
      };
      
      // Test with a video that's available offline
      const offlineVideoMetadata = await fetchVideoMetadata(videoId);
      const offlineUrl = await getVideoUrlWithOfflineSupport(offlineVideoMetadata);
      
      expect(offlineUrl).toBeDefined();
      expect(offlineUrl).toContain('file:///');
      expect(offlineUrl).toContain(videoId);
      
      // Test with a video that's not available offline
      const onlineVideoMetadata = await fetchVideoMetadata('azure-video');
      const onlineUrl = await getVideoUrlWithOfflineSupport(onlineVideoMetadata);
      
      expect(onlineUrl).toBeDefined();
      expect(onlineUrl).toContain('fitsagastorage.blob.core.windows.net');
    });
  });
});