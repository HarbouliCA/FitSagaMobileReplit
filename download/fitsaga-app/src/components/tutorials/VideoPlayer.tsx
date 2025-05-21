import React, { useState, useRef, useEffect } from 'react';
import { View, StyleSheet, TouchableOpacity, ActivityIndicator } from 'react-native';
import { Text, Slider } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { Video, ResizeMode, AVPlaybackStatus } from 'expo-av';
import * as ScreenOrientation from 'expo-screen-orientation';

import { theme, spacing } from '../../theme';

interface VideoPlayerProps {
  uri: string;
  thumbnailUri?: string;
  title?: string;
  onProgress?: (progress: number) => void;
  onComplete?: () => void;
  autoPlay?: boolean;
}

const VideoPlayer: React.FC<VideoPlayerProps> = ({
  uri,
  thumbnailUri,
  title,
  onProgress,
  onComplete,
  autoPlay = false,
}) => {
  const videoRef = useRef<Video>(null);
  const [status, setStatus] = useState<AVPlaybackStatus | null>(null);
  const [isPlaying, setIsPlaying] = useState(autoPlay);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [sliderValue, setSliderValue] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  // Handle video status updates
  const onPlaybackStatusUpdate = (status: AVPlaybackStatus) => {
    if (!status.isLoaded) {
      // Handle error
      if (status.error) {
        console.error(`Error loading video: ${status.error}`);
        setError(`Failed to load video: ${status.error}`);
      }
      return;
    }
    
    setStatus(status);
    setIsPlaying(status.isPlaying);
    
    // Update slider value
    if (status.durationMillis) {
      const progress = status.positionMillis / status.durationMillis;
      setSliderValue(progress);
      
      if (onProgress) {
        onProgress(progress);
      }
    }
    
    // Check if video has finished
    if (status.didJustFinish && onComplete) {
      onComplete();
    }
    
    // Update loading state
    setLoading(status.isBuffering);
  };
  
  // Play/pause video
  const togglePlayPause = async () => {
    if (!videoRef.current) return;
    
    if (isPlaying) {
      await videoRef.current.pauseAsync();
    } else {
      await videoRef.current.playAsync();
    }
    
    setIsPlaying(!isPlaying);
  };
  
  // Toggle fullscreen mode
  const toggleFullscreen = async () => {
    if (isFullscreen) {
      await ScreenOrientation.lockAsync(
        ScreenOrientation.OrientationLock.PORTRAIT
      );
    } else {
      await ScreenOrientation.lockAsync(
        ScreenOrientation.OrientationLock.LANDSCAPE
      );
    }
    
    setIsFullscreen(!isFullscreen);
  };
  
  // Toggle mute
  const toggleMute = async () => {
    if (!videoRef.current || !status?.isLoaded) return;
    
    await videoRef.current.setIsMutedAsync(!isMuted);
    setIsMuted(!isMuted);
  };
  
  // Seek to position
  const seekToPosition = async (value: number) => {
    if (!videoRef.current || !status?.isLoaded || !status.durationMillis) return;
    
    const position = value * status.durationMillis;
    await videoRef.current.setPositionAsync(position);
  };
  
  // Format time display (mm:ss)
  const formatTime = (millis: number): string => {
    const totalSeconds = Math.floor(millis / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  };

  // Reset orientation on component unmount
  useEffect(() => {
    return () => {
      ScreenOrientation.lockAsync(ScreenOrientation.OrientationLock.PORTRAIT);
    };
  }, []);

  return (
    <View style={[styles.container, isFullscreen && styles.fullscreenContainer]}>
      <View style={styles.videoContainer}>
        <Video
          ref={videoRef}
          style={styles.video}
          source={{ uri }}
          resizeMode={ResizeMode.CONTAIN}
          usePoster={!!thumbnailUri}
          posterSource={{ uri: thumbnailUri }}
          posterStyle={styles.poster}
          onPlaybackStatusUpdate={onPlaybackStatusUpdate}
          useNativeControls={false}
        />
        
        {/* Loading indicator */}
        {loading && (
          <View style={styles.overlay}>
            <ActivityIndicator size="large" color="white" />
          </View>
        )}
        
        {/* Error message */}
        {error && (
          <View style={styles.errorOverlay}>
            <MaterialCommunityIcons name="alert-circle" size={40} color="white" />
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}
        
        {/* Play/pause button */}
        <TouchableOpacity 
          style={[styles.overlay, styles.controlsOverlay]}
          onPress={togglePlayPause}
          activeOpacity={0.8}
        >
          {!isPlaying && !loading && (
            <View style={styles.playButtonContainer}>
              <MaterialCommunityIcons name="play" size={40} color="white" />
            </View>
          )}
        </TouchableOpacity>
      </View>
      
      {/* Title */}
      {title && !isFullscreen && (
        <Text style={styles.title}>{title}</Text>
      )}
      
      {/* Controls */}
      <View style={styles.controlsContainer}>
        {/* Play/pause button */}
        <TouchableOpacity onPress={togglePlayPause} style={styles.controlButton}>
          <MaterialCommunityIcons 
            name={isPlaying ? 'pause' : 'play'} 
            size={24} 
            color={theme.colors.text} 
          />
        </TouchableOpacity>
        
        {/* Current time */}
        <Text style={styles.timeText}>
          {status?.isLoaded 
            ? formatTime(status.positionMillis) 
            : '00:00'}
        </Text>
        
        {/* Progress slider */}
        <Slider
          style={styles.slider}
          value={sliderValue}
          onValueChange={(value) => setSliderValue(value)}
          onSlidingComplete={(value) => seekToPosition(value)}
          minimumValue={0}
          maximumValue={1}
          thumbTintColor={theme.colors.primary}
        />
        
        {/* Duration */}
        <Text style={styles.timeText}>
          {status?.isLoaded && status.durationMillis 
            ? formatTime(status.durationMillis) 
            : '00:00'}
        </Text>
        
        {/* Mute button */}
        <TouchableOpacity onPress={toggleMute} style={styles.controlButton}>
          <MaterialCommunityIcons 
            name={isMuted ? 'volume-off' : 'volume-high'} 
            size={24} 
            color={theme.colors.text} 
          />
        </TouchableOpacity>
        
        {/* Fullscreen button */}
        <TouchableOpacity onPress={toggleFullscreen} style={styles.controlButton}>
          <MaterialCommunityIcons 
            name={isFullscreen ? 'fullscreen-exit' : 'fullscreen'} 
            size={24} 
            color={theme.colors.text} 
          />
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.surface,
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: spacing.m,
  },
  fullscreenContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 999,
    backgroundColor: 'black',
    borderRadius: 0,
  },
  videoContainer: {
    width: '100%',
    aspectRatio: 16 / 9,
    backgroundColor: 'black',
    position: 'relative',
  },
  video: {
    width: '100%',
    height: '100%',
  },
  poster: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
  },
  controlsOverlay: {
    backgroundColor: 'transparent',
  },
  errorOverlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    padding: spacing.m,
  },
  errorText: {
    color: 'white',
    textAlign: 'center',
    marginTop: spacing.s,
  },
  playButtonContainer: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 16,
    fontWeight: '500',
    padding: spacing.m,
  },
  controlsContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.s,
    borderTopWidth: 1,
    borderTopColor: '#EEEEEE',
  },
  controlButton: {
    padding: spacing.xs,
  },
  timeText: {
    fontSize: 12,
    marginHorizontal: spacing.xs,
    color: theme.colors.placeholder,
  },
  slider: {
    flex: 1,
    marginHorizontal: spacing.xs,
  },
});

export default VideoPlayer;