import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Text, Card, Divider, Button, Checkbox, ActivityIndicator } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { useSelector, useDispatch } from 'react-redux';

import { RootState } from '../../redux/store';
import { 
  fetchTutorialById, 
  markExerciseCompleted,
  getVideoUrl,
  TutorialDay,
  Exercise
} from '../../redux/features/tutorialsSlice';
import VideoPlayer from '../../components/tutorials/VideoPlayer';
import { theme, spacing } from '../../theme';

// Define types for route params
type TutorialDayDetailRouteParams = {
  TutorialDayDetail: {
    tutorialId: string;
    dayId: string;
  };
};

type TutorialDayDetailScreenRouteProp = RouteProp<TutorialDayDetailRouteParams, 'TutorialDayDetail'>;

const TutorialDayDetailScreen: React.FC = () => {
  const [currentDay, setCurrentDay] = useState<TutorialDay | null>(null);
  const [currentExercise, setCurrentExercise] = useState<Exercise | null>(null);
  const [exerciseExpanded, setExerciseExpanded] = useState<{ [key: string]: boolean }>({});
  
  const route = useRoute<TutorialDayDetailScreenRouteProp>();
  const navigation = useNavigation();
  const dispatch = useDispatch();
  
  const { tutorialId, dayId } = route.params;
  const { user } = useSelector((state: RootState) => state.auth);
  const { currentTutorial, loading, error, userProgress } = useSelector((state: RootState) => state.tutorials);

  // Load video URL for an exercise
  const loadVideoUrl = (exercise: Exercise) => {
    if (exercise.videoUrl && !exercise.videoUrl.startsWith('http')) {
      dispatch(getVideoUrl(exercise.videoUrl));
    }
  };

  // Handle exercise completion
  const handleExerciseComplete = (exerciseId: string) => {
    if (!user) return;
    
    dispatch(markExerciseCompleted({
      tutorialId,
      dayId,
      exerciseId,
    }));
  };

  // Check if an exercise is completed
  const isExerciseCompleted = (exerciseId: string) => {
    if (!user) return false;
    
    const progress = userProgress[tutorialId];
    if (!progress) return false;
    
    return progress.completedExercises[exerciseId] || false;
  };

  // Toggle exercise expanded state
  const toggleExerciseExpanded = (exerciseId: string) => {
    setExerciseExpanded(prev => ({
      ...prev,
      [exerciseId]: !prev[exerciseId],
    }));
    
    // Load video URL if expanded
    if (!exerciseExpanded[exerciseId] && currentDay) {
      const exercise = currentDay.exercises.find(e => e.id === exerciseId);
      if (exercise) {
        loadVideoUrl(exercise);
      }
    }
  };

  // Format sets and reps
  const formatSetsReps = (exercise: Exercise) => {
    const sets = exercise.sets || 0;
    const reps = exercise.reps || '';
    
    return `${sets} set${sets !== 1 ? 's' : ''} × ${reps}`;
  };

  // Format rest time
  const formatRestTime = (seconds: number | undefined) => {
    if (!seconds) return 'No rest';
    
    if (seconds < 60) {
      return `${seconds} sec`;
    } else {
      const minutes = Math.floor(seconds / 60);
      const secs = seconds % 60;
      return secs > 0 ? `${minutes}:${secs.toString().padStart(2, '0')} min` : `${minutes} min`;
    }
  };

  // Navigate to the next day
  const goToNextDay = () => {
    if (!currentTutorial) return;
    
    const currentIndex = currentTutorial.days.findIndex(d => d.id === dayId);
    if (currentIndex < currentTutorial.days.length - 1) {
      const nextDay = currentTutorial.days[currentIndex + 1];
      navigation.replace('TutorialDayDetail', {
        tutorialId,
        dayId: nextDay.id,
      });
    } else {
      // If this is the last day, go back to tutorial detail
      navigation.navigate('TutorialDetail', { tutorialId });
    }
  };

  // Navigate to the previous day
  const goToPreviousDay = () => {
    if (!currentTutorial) return;
    
    const currentIndex = currentTutorial.days.findIndex(d => d.id === dayId);
    if (currentIndex > 0) {
      const prevDay = currentTutorial.days[currentIndex - 1];
      navigation.replace('TutorialDayDetail', {
        tutorialId,
        dayId: prevDay.id,
      });
    }
  };

  // Initial data load
  useEffect(() => {
    if (!currentTutorial) {
      dispatch(fetchTutorialById(tutorialId));
    }
  }, [tutorialId, currentTutorial]);

  // Set current day and expand first exercise when tutorial is loaded
  useEffect(() => {
    if (currentTutorial) {
      const day = currentTutorial.days.find(d => d.id === dayId);
      if (day) {
        setCurrentDay(day);
        
        // Expand first exercise by default
        if (day.exercises.length > 0) {
          setExerciseExpanded({ [day.exercises[0].id]: true });
          setCurrentExercise(day.exercises[0]);
          loadVideoUrl(day.exercises[0]);
        }
      }
    }
  }, [currentTutorial, dayId]);

  if (loading && !currentDay) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={styles.loadingText}>Loading tutorial day...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Error: {error}</Text>
        <Button 
          mode="contained"
          onPress={() => dispatch(fetchTutorialById(tutorialId))}
          style={styles.errorButton}
        >
          Retry
        </Button>
      </View>
    );
  }

  if (!currentDay) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Day not found</Text>
        <Button 
          mode="contained"
          onPress={() => navigation.goBack()}
          style={styles.errorButton}
        >
          Go Back
        </Button>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.headerContainer}>
          <Text style={styles.dayNumber}>Day {currentDay.dayNumber}</Text>
          <Text style={styles.dayTitle}>{currentDay.title}</Text>
          
          {currentDay.description && (
            <Text style={styles.dayDescription}>{currentDay.description}</Text>
          )}
        </View>
        
        <Divider style={styles.divider} />
        
        <Text style={styles.exercisesTitle}>
          Exercises ({currentDay.exercises.length})
        </Text>
        
        {currentDay.exercises.map((exercise, index) => (
          <Card key={exercise.id} style={styles.exerciseCard}>
            <TouchableOpacity
              onPress={() => toggleExerciseExpanded(exercise.id)}
              style={styles.exerciseHeader}
            >
              <View style={styles.exerciseNumberContainer}>
                <Text style={styles.exerciseNumber}>{index + 1}</Text>
              </View>
              
              <View style={styles.exerciseTitleContainer}>
                <Text style={styles.exerciseTitle}>{exercise.name}</Text>
                <Text style={styles.exerciseDetail}>
                  {formatSetsReps(exercise)} · {formatRestTime(exercise.restBetweenSets)}
                </Text>
              </View>
              
              <MaterialCommunityIcons 
                name={exerciseExpanded[exercise.id] ? 'chevron-up' : 'chevron-down'} 
                size={24} 
                color={theme.colors.placeholder}
              />
            </TouchableOpacity>
            
            {exerciseExpanded[exercise.id] && (
              <Card.Content style={styles.exerciseContent}>
                {exercise.videoUrl && (
                  <VideoPlayer 
                    uri={exercise.videoUrl} 
                    thumbnailUri={exercise.thumbnailUrl}
                    title={exercise.name}
                    onComplete={() => handleExerciseComplete(exercise.id)}
                  />
                )}
                
                <Text style={styles.exerciseDescription}>
                  {exercise.description}
                </Text>
                
                {exercise.instructions && exercise.instructions.length > 0 && (
                  <View style={styles.instructionsContainer}>
                    <Text style={styles.instructionsTitle}>Instructions:</Text>
                    {exercise.instructions.map((instruction, i) => (
                      <View key={i} style={styles.instructionItem}>
                        <Text style={styles.instructionNumber}>{i + 1}.</Text>
                        <Text style={styles.instructionText}>{instruction}</Text>
                      </View>
                    ))}
                  </View>
                )}
                
                {exercise.equipment && exercise.equipment.length > 0 && (
                  <View style={styles.equipmentContainer}>
                    <Text style={styles.equipmentTitle}>Equipment:</Text>
                    <Text style={styles.equipmentText}>
                      {exercise.equipment.join(', ')}
                    </Text>
                  </View>
                )}
                
                {exercise.muscleGroups && exercise.muscleGroups.length > 0 && (
                  <View style={styles.muscleGroupsContainer}>
                    <Text style={styles.muscleGroupsTitle}>Target Muscles:</Text>
                    <Text style={styles.muscleGroupsText}>
                      {exercise.muscleGroups.join(', ')}
                    </Text>
                  </View>
                )}
                
                <View style={styles.checkboxContainer}>
                  <Checkbox
                    status={isExerciseCompleted(exercise.id) ? 'checked' : 'unchecked'}
                    onPress={() => handleExerciseComplete(exercise.id)}
                  />
                  <Text style={styles.checkboxLabel}>
                    Mark as Complete
                  </Text>
                </View>
              </Card.Content>
            )}
          </Card>
        ))}
        
        <View style={styles.navigationContainer}>
          <Button
            mode="outlined"
            onPress={goToPreviousDay}
            style={styles.navButton}
            disabled={currentDay.dayNumber === 1}
          >
            Previous Day
          </Button>
          
          <Button
            mode="contained"
            onPress={goToNextDay}
            style={styles.navButton}
          >
            {currentTutorial && 
             currentDay.dayNumber === currentTutorial.days.length
             ? 'Finish' : 'Next Day'}
          </Button>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  scrollContent: {
    padding: spacing.m,
    paddingBottom: spacing.xxl,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  loadingText: {
    marginTop: spacing.m,
    color: theme.colors.placeholder,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xl,
  },
  errorText: {
    color: theme.colors.error,
    marginBottom: spacing.m,
  },
  errorButton: {
    marginTop: spacing.m,
  },
  headerContainer: {
    marginBottom: spacing.m,
  },
  dayNumber: {
    fontSize: 14,
    color: theme.colors.primary,
    fontWeight: '500',
    marginBottom: spacing.xs,
  },
  dayTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: spacing.s,
  },
  dayDescription: {
    marginBottom: spacing.m,
    lineHeight: 22,
  },
  divider: {
    marginBottom: spacing.m,
  },
  exercisesTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: spacing.m,
  },
  exerciseCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
    overflow: 'hidden',
  },
  exerciseHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.m,
  },
  exerciseNumberContainer: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: theme.colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.m,
  },
  exerciseNumber: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 14,
  },
  exerciseTitleContainer: {
    flex: 1,
  },
  exerciseTitle: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 2,
  },
  exerciseDetail: {
    fontSize: 12,
    color: theme.colors.placeholder,
  },
  exerciseContent: {
    paddingTop: 0,
    paddingHorizontal: spacing.m,
    paddingBottom: spacing.m,
  },
  exerciseDescription: {
    marginBottom: spacing.m,
    lineHeight: 20,
  },
  instructionsContainer: {
    marginBottom: spacing.m,
  },
  instructionsTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: spacing.xs,
  },
  instructionItem: {
    flexDirection: 'row',
    marginBottom: spacing.xs,
  },
  instructionNumber: {
    width: 20,
    fontWeight: 'bold',
  },
  instructionText: {
    flex: 1,
    lineHeight: 20,
  },
  equipmentContainer: {
    marginBottom: spacing.m,
  },
  equipmentTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: spacing.xs,
  },
  equipmentText: {
    color: theme.colors.placeholder,
  },
  muscleGroupsContainer: {
    marginBottom: spacing.m,
  },
  muscleGroupsTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: spacing.xs,
  },
  muscleGroupsText: {
    color: theme.colors.placeholder,
  },
  checkboxContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.s,
  },
  checkboxLabel: {
    marginLeft: spacing.xs,
  },
  navigationContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.m,
  },
  navButton: {
    flex: 1,
    marginHorizontal: spacing.xs,
  },
});

export default TutorialDayDetailScreen;