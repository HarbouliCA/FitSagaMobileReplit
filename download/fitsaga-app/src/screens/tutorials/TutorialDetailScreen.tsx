import React, { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Text, Card, Title, Badge, Chip, Divider, Button, ActivityIndicator } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { useSelector, useDispatch } from 'react-redux';

import { RootState } from '../../redux/store';
import { 
  fetchTutorialById, 
  setLastAccessedDay,
  TutorialDay 
} from '../../redux/features/tutorialsSlice';
import { theme, spacing } from '../../theme';

// Define types for route params
type TutorialDetailRouteParams = {
  TutorialDetail: {
    tutorialId: string;
  };
};

type TutorialDetailScreenRouteProp = RouteProp<TutorialDetailRouteParams, 'TutorialDetail'>;

const TutorialDetailScreen: React.FC = () => {
  const [selectedDay, setSelectedDay] = useState<TutorialDay | null>(null);
  
  const route = useRoute<TutorialDetailScreenRouteProp>();
  const navigation = useNavigation();
  const dispatch = useDispatch();
  
  const { tutorialId } = route.params;
  const { user } = useSelector((state: RootState) => state.auth);
  const { currentTutorial, loading, error, userProgress } = useSelector((state: RootState) => state.tutorials);
  
  // Calculate tutorial progress percentage
  const calculateProgress = () => {
    if (!currentTutorial || !user) return 0;
    
    const progress = userProgress[tutorialId];
    if (!progress) return 0;
    
    let completedExercisesCount = 0;
    let totalExercisesCount = 0;
    
    currentTutorial.days.forEach(day => {
      day.exercises.forEach(exercise => {
        totalExercisesCount++;
        if (progress.completedExercises[exercise.id]) {
          completedExercisesCount++;
        }
      });
    });
    
    return totalExercisesCount > 0 ? (completedExercisesCount / totalExercisesCount) * 100 : 0;
  };

  // Format duration to display in minutes
  const formatDuration = (minutes: number) => {
    if (minutes < 60) {
      return `${minutes} min`;
    } else {
      const hours = Math.floor(minutes / 60);
      const mins = minutes % 60;
      return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`;
    }
  };

  // Get color based on difficulty
  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'beginner':
        return theme.colors.success;
      case 'intermediate':
        return theme.colors.warning;
      case 'advanced':
        return theme.colors.error;
      default:
        return theme.colors.primary;
    }
  };

  // Handle day selection
  const handleDaySelect = (day: TutorialDay) => {
    setSelectedDay(day);
    
    if (user) {
      dispatch(setLastAccessedDay({
        tutorialId,
        dayId: day.id,
      }));
    }
    
    // Navigate to day detail screen
    navigation.navigate('TutorialDayDetail', {
      tutorialId,
      dayId: day.id,
    });
  };

  // Calculate progress for a specific day
  const calculateDayProgress = (dayId: string) => {
    if (!currentTutorial || !user) return 0;
    
    const progress = userProgress[tutorialId];
    if (!progress) return 0;
    
    const day = currentTutorial.days.find(d => d.id === dayId);
    if (!day) return 0;
    
    let completedExercisesCount = 0;
    
    day.exercises.forEach(exercise => {
      if (progress.completedExercises[exercise.id]) {
        completedExercisesCount++;
      }
    });
    
    return day.exercises.length > 0 ? (completedExercisesCount / day.exercises.length) * 100 : 0;
  };

  // Check if a day is completed
  const isDayCompleted = (dayId: string) => {
    if (!user) return false;
    
    const progress = userProgress[tutorialId];
    if (!progress) return false;
    
    return progress.completedDays[dayId] || false;
  };

  // Fetch tutorial data on mount
  useEffect(() => {
    dispatch(fetchTutorialById(tutorialId));
  }, [tutorialId]);

  // Set initial selected day
  useEffect(() => {
    if (currentTutorial && currentTutorial.days.length > 0) {
      // If there's progress, select the last accessed day
      if (user && userProgress[tutorialId]) {
        const lastDayId = userProgress[tutorialId].lastAccessedDay;
        const lastDay = currentTutorial.days.find(d => d.id === lastDayId);
        
        if (lastDay) {
          setSelectedDay(lastDay);
        } else {
          setSelectedDay(currentTutorial.days[0]);
        }
      } else {
        // Otherwise select the first day
        setSelectedDay(currentTutorial.days[0]);
      }
    }
  }, [currentTutorial, userProgress, tutorialId, user]);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={theme.colors.primary} />
        <Text style={styles.loadingText}>Loading tutorial...</Text>
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

  if (!currentTutorial) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>Tutorial not found</Text>
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
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Card style={styles.headerCard}>
        <Card.Cover 
          source={{ uri: currentTutorial.thumbnailUrl }}
          style={styles.coverImage}
        />
        <Card.Content>
          <Title style={styles.title}>{currentTutorial.title}</Title>
          
          <View style={styles.badgeContainer}>
            <Chip
              style={[styles.categoryChip, { backgroundColor: theme.colors.primary }]}
              textStyle={styles.chipText}
            >
              {currentTutorial.category.charAt(0).toUpperCase() + currentTutorial.category.slice(1)}
            </Chip>
            
            <Chip
              style={[
                styles.difficultyChip, 
                { backgroundColor: getDifficultyColor(currentTutorial.difficulty) }
              ]}
              textStyle={styles.chipText}
            >
              {currentTutorial.difficulty.charAt(0).toUpperCase() + currentTutorial.difficulty.slice(1)}
            </Chip>
            
            <View style={styles.durationContainer}>
              <MaterialCommunityIcons 
                name="clock-outline" 
                size={16} 
                color={theme.colors.placeholder}
              />
              <Text style={styles.durationText}>
                {formatDuration(currentTutorial.duration)}
              </Text>
            </View>
          </View>
          
          {user && userProgress[tutorialId] && (
            <View style={styles.progressContainer}>
              <Text style={styles.progressLabel}>
                {Math.round(calculateProgress())}% Complete
              </Text>
              <View style={styles.progressBarContainer}>
                <View 
                  style={[
                    styles.progressBar, 
                    { width: `${calculateProgress()}%` }
                  ]} 
                />
              </View>
            </View>
          )}
          
          <Text style={styles.description}>{currentTutorial.description}</Text>
          
          {currentTutorial.goals && currentTutorial.goals.length > 0 && (
            <View style={styles.sectionContainer}>
              <Text style={styles.sectionTitle}>Goals</Text>
              {currentTutorial.goals.map((goal, index) => (
                <View key={index} style={styles.goalItem}>
                  <MaterialCommunityIcons 
                    name="check-circle-outline" 
                    size={18} 
                    color={theme.colors.primary}
                    style={styles.goalIcon}
                  />
                  <Text style={styles.goalText}>{goal}</Text>
                </View>
              ))}
            </View>
          )}
          
          {currentTutorial.equipmentRequired && currentTutorial.equipmentRequired.length > 0 && (
            <View style={styles.sectionContainer}>
              <Text style={styles.sectionTitle}>Equipment Required</Text>
              <View style={styles.equipmentContainer}>
                {currentTutorial.equipmentRequired.map((equipment, index) => (
                  <Chip key={index} style={styles.equipmentChip}>
                    {equipment}
                  </Chip>
                ))}
              </View>
            </View>
          )}
        </Card.Content>
      </Card>
      
      <View style={styles.daysContainer}>
        <Text style={styles.daysTitle}>Workout Schedule</Text>
        
        {currentTutorial.days.map((day, index) => (
          <TouchableOpacity 
            key={day.id} 
            onPress={() => handleDaySelect(day)}
            style={[
              styles.dayCard,
              selectedDay?.id === day.id && styles.selectedDayCard,
            ]}
          >
            <View style={styles.dayHeader}>
              <View style={styles.dayNumberContainer}>
                <Text style={styles.dayNumber}>{day.dayNumber}</Text>
              </View>
              <View style={styles.dayTitleContainer}>
                <Text style={styles.dayTitle}>{day.title}</Text>
                <Text style={styles.exerciseCount}>
                  {day.exercises.length} exercise{day.exercises.length !== 1 ? 's' : ''}
                </Text>
              </View>
              {isDayCompleted(day.id) ? (
                <Badge style={styles.completedBadge}>Completed</Badge>
              ) : (
                calculateDayProgress(day.id) > 0 && (
                  <Badge style={styles.progressBadge}>
                    {Math.round(calculateDayProgress(day.id))}%
                  </Badge>
                )
              )}
            </View>
          </TouchableOpacity>
        ))}
      </View>
      
      <Button
        mode="contained"
        onPress={() => selectedDay && handleDaySelect(selectedDay)}
        style={styles.startButton}
      >
        {userProgress[tutorialId] ? 'Continue Workout' : 'Start Workout'}
      </Button>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  contentContainer: {
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
  headerCard: {
    marginBottom: spacing.m,
    backgroundColor: theme.colors.surface,
    overflow: 'hidden',
    borderRadius: 12,
  },
  coverImage: {
    height: 200,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginVertical: spacing.s,
  },
  badgeContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'center',
    marginBottom: spacing.m,
  },
  categoryChip: {
    marginRight: spacing.s,
    marginBottom: spacing.xs,
  },
  difficultyChip: {
    marginRight: spacing.s,
    marginBottom: spacing.xs,
  },
  chipText: {
    color: 'white',
  },
  durationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  durationText: {
    fontSize: 12,
    marginLeft: 4,
    color: theme.colors.placeholder,
  },
  progressContainer: {
    marginBottom: spacing.m,
  },
  progressLabel: {
    fontSize: 12,
    marginBottom: spacing.xs,
    color: theme.colors.placeholder,
  },
  progressBarContainer: {
    height: 6,
    width: '100%',
    backgroundColor: '#EEEEEE',
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    backgroundColor: theme.colors.primary,
    borderRadius: 3,
  },
  description: {
    marginBottom: spacing.m,
    lineHeight: 22,
  },
  sectionContainer: {
    marginBottom: spacing.m,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: spacing.s,
  },
  goalItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.xs,
  },
  goalIcon: {
    marginRight: spacing.xs,
    marginTop: 2,
  },
  goalText: {
    flex: 1,
    lineHeight: 20,
  },
  equipmentContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  equipmentChip: {
    marginRight: spacing.xs,
    marginBottom: spacing.xs,
  },
  daysContainer: {
    marginBottom: spacing.m,
  },
  daysTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: spacing.m,
  },
  dayCard: {
    backgroundColor: theme.colors.surface,
    borderRadius: 8,
    padding: spacing.m,
    marginBottom: spacing.s,
    borderLeftWidth: 3,
    borderLeftColor: '#EEEEEE',
    elevation: 1,
  },
  selectedDayCard: {
    borderLeftColor: theme.colors.primary,
    backgroundColor: '#F5F9FF',
  },
  dayHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  dayNumberContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: theme.colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.m,
  },
  dayNumber: {
    color: 'white',
    fontWeight: 'bold',
  },
  dayTitleContainer: {
    flex: 1,
  },
  dayTitle: {
    fontSize: 16,
    fontWeight: '500',
  },
  exerciseCount: {
    fontSize: 12,
    color: theme.colors.placeholder,
  },
  completedBadge: {
    backgroundColor: theme.colors.success,
    color: 'white',
  },
  progressBadge: {
    backgroundColor: theme.colors.warning,
    color: 'white',
  },
  startButton: {
    marginTop: spacing.m,
    paddingVertical: spacing.xs,
  },
});

export default TutorialDetailScreen;