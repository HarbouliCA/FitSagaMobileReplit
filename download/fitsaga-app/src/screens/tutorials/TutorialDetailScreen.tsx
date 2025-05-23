import React, { useState, useEffect } from 'react';
import { 
  View, 
  Text, 
  StyleSheet, 
  ScrollView, 
  Image, 
  TouchableOpacity,
  ActivityIndicator,
  Alert
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Video, ResizeMode } from 'expo-av';
import { useAuth } from '../../context/AuthContext';
import { 
  getTutorialById as fetchTutorialById, 
  saveTutorial, 
  unsaveTutorial, 
  Tutorial
} from '../../services/tutorialService';

const TutorialDetailScreen = ({ route, navigation }: { route: any, navigation: any }) => {
  const { tutorialId } = route.params;
  const { user } = useAuth();
  const [tutorial, setTutorial] = useState<Tutorial | null>(null);
  const [loading, setLoading] = useState(true);
  const [videoStatus, setVideoStatus] = useState({ isPlaying: false });
  const [videoLoading, setVideoLoading] = useState(false);
  const [isSaved, setIsSaved] = useState(false);
  const [savingTutorial, setSavingTutorial] = useState(false);
  
  // Load tutorial data from service
  useEffect(() => {
    const loadTutorial = async () => {
      setLoading(true);
      try {
        const tutorialData = await fetchTutorialById(tutorialId);
        if (tutorialData) {
          setTutorial(tutorialData);
          setIsSaved(tutorialData.isSaved || false);
        }
      } catch (error) {
        console.error('Error loading tutorial:', error);
        Alert.alert('Error', 'Failed to load tutorial details');
      } finally {
        setLoading(false);
      }
    };
    
    loadTutorial();
  }, [tutorialId]);

  // Handle video playback
  const handlePlayVideo = () => {
    setVideoLoading(true);
    setVideoStatus({ isPlaying: true });
  };

  // Handle save/unsave tutorial
  const handleSaveTutorial = async () => {
    if (!user) {
      Alert.alert('Error', 'You must be logged in to save tutorials');
      return;
    }
    
    if (!tutorial) return;
    
    setSavingTutorial(true);
    
    try {
      if (isSaved) {
        await unsaveTutorial(user.uid, tutorial.id);
        setIsSaved(false);
        Alert.alert('Success', 'Tutorial removed from saved list');
      } else {
        await saveTutorial(user.uid, tutorial.id);
        setIsSaved(true);
        Alert.alert('Success', 'Tutorial saved to your list');
      }
    } catch (error) {
      console.error('Error saving tutorial:', error);
      Alert.alert('Error', 'Failed to save tutorial');
    } finally {
      setSavingTutorial(false);
    }
  };

  // Show loading indicator
  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4C1D95" />
        <Text style={styles.loadingText}>Loading tutorial details...</Text>
      </View>
    );
  }

  // Handle case where tutorial is not found
  if (!tutorial) {
    return (
      <View style={styles.errorContainer}>
        <Ionicons name="alert-circle-outline" size={64} color="#EF4444" />
        <Text style={styles.errorText}>Tutorial not found</Text>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <ScrollView style={styles.detailScrollView}>
      <View style={styles.videoContainer}>
        {videoStatus.isPlaying ? (
          <>
            <Video
              source={{ uri: tutorial.videoUrl }}
              rate={1.0}
              volume={1.0}
              isMuted={false}
              resizeMode={ResizeMode.CONTAIN}
              shouldPlay={true}
              isLooping={false}
              style={styles.video}
              onLoad={() => setVideoLoading(false)}
              onError={(error) => {
                console.error('Video error:', error);
                Alert.alert('Error', 'Failed to load video');
                setVideoStatus({ isPlaying: false });
                setVideoLoading(false);
              }}
            />
            {videoLoading && (
              <View style={styles.videoLoadingOverlay}>
                <ActivityIndicator size="large" color="white" />
                <Text style={styles.videoLoadingText}>Loading video...</Text>
              </View>
            )}
          </>
        ) : (
          <>
            <Image 
              source={{ uri: tutorial.thumbnail }} 
              style={styles.videoPlaceholder} 
            />
            <TouchableOpacity 
              style={styles.playButtonLarge}
              onPress={handlePlayVideo}
            >
              <Ionicons name="play" size={40} color="white" />
            </TouchableOpacity>
          </>
        )}
      </View>
      
      <View style={styles.detailContent}>
        <Text style={styles.detailTitle}>{tutorial.title}</Text>
        
        <View style={styles.tutorialInfo}>
          <View style={styles.tutorialInfoItem}>
            <Ionicons name="person" size={16} color="#6B7280" />
            <Text style={styles.tutorialInfoText}>{tutorial.instructor}</Text>
          </View>
          
          <View style={styles.tutorialInfoItem}>
            <Ionicons name="time" size={16} color="#6B7280" />
            <Text style={styles.tutorialInfoText}>{tutorial.duration}</Text>
          </View>
          
          <View style={styles.tutorialInfoItem}>
            <Ionicons name="fitness" size={16} color="#6B7280" />
            <Text style={styles.tutorialInfoText}>{tutorial.level}</Text>
          </View>
        </View>
        
        <View style={styles.categoryBadge}>
          <Text style={styles.categoryBadgeText}>{tutorial.category}</Text>
        </View>
        
        <View style={styles.detailSeparator} />
        
        <Text style={styles.detailSectionTitle}>Description</Text>
        <Text style={styles.detailDescription}>{tutorial.description}</Text>
        
        <View style={styles.detailSeparator} />
        
        <Text style={styles.detailSectionTitle}>Equipment Needed</Text>
        {tutorial.equipment.map((item, index) => (
          <View key={index} style={styles.equipmentItem}>
            <Ionicons name="checkmark-circle" size={18} color="#4C1D95" />
            <Text style={styles.equipmentText}>{item}</Text>
          </View>
        ))}
        
        <TouchableOpacity 
          style={styles.saveButton}
          onPress={handleSaveTutorial}
          disabled={savingTutorial}
        >
          {savingTutorial ? (
            <>
              <ActivityIndicator size="small" color="white" />
              <Text style={styles.saveButtonText}> Processing...</Text>
            </>
          ) : (
            <>
              <Ionicons 
                name={isSaved ? "bookmark" : "bookmark-outline"} 
                size={20} 
                color="white" 
              />
              <Text style={styles.saveButtonText}>
                {isSaved ? "Saved" : "Save Tutorial"}
              </Text>
            </>
          )}
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f7f7f7',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#4B5563',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f7f7f7',
    padding: 20,
  },
  errorText: {
    fontSize: 18,
    color: '#111827',
    marginTop: 16,
    marginBottom: 24,
  },
  backButton: {
    backgroundColor: '#4C1D95',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
  },
  backButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  detailScrollView: {
    flex: 1,
    backgroundColor: '#f7f7f7',
  },
  videoContainer: {
    position: 'relative',
    width: '100%',
    height: 220,
  },
  videoPlaceholder: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  video: {
    width: '100%',
    height: '100%',
  },
  videoLoadingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  videoLoadingText: {
    color: 'white',
    marginTop: 8,
    fontSize: 14,
  },
  playButtonLarge: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -35 }, { translateY: -35 }],
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  detailContent: {
    padding: 20,
  },
  detailTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 16,
  },
  tutorialInfo: {
    flexDirection: 'row',
    marginBottom: 16,
  },
  tutorialInfoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 16,
  },
  tutorialInfoText: {
    fontSize: 14,
    color: '#6B7280',
    marginLeft: 4,
  },
  categoryBadge: {
    alignSelf: 'flex-start',
    backgroundColor: '#8B5CF6',
    paddingVertical: 4,
    paddingHorizontal: 10,
    borderRadius: 12,
  },
  categoryBadgeText: {
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  detailSeparator: {
    height: 1,
    backgroundColor: '#E5E7EB',
    marginVertical: 20,
  },
  detailSectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 8,
  },
  detailDescription: {
    fontSize: 16,
    color: '#4B5563',
    lineHeight: 24,
  },
  equipmentItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  equipmentText: {
    fontSize: 16,
    color: '#4B5563',
    marginLeft: 8,
  },
  saveButton: {
    backgroundColor: '#4C1D95',
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  saveButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    marginLeft: 8,
  },
});

export default TutorialDetailScreen;