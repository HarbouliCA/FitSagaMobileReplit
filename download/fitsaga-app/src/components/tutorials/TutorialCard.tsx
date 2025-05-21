import React from 'react';
import { StyleSheet, View, TouchableOpacity } from 'react-native';
import { Card, Text, Chip, ProgressBar } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import { theme, spacing } from '../../theme';

// Props for the component
interface TutorialCardProps {
  id: string;
  title: string;
  category: 'exercise' | 'nutrition';
  description: string;
  thumbnailUrl?: string;
  author: string;
  duration: number;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  progress?: number; // 0 to 1
  onPress: () => void;
}

const TutorialCard: React.FC<TutorialCardProps> = ({
  id,
  title,
  category,
  description,
  thumbnailUrl,
  author,
  duration,
  difficulty,
  progress = 0,
  onPress,
}) => {
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
  const getDifficultyColor = () => {
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

  // Get icon based on category
  const getCategoryIcon = () => {
    switch (category) {
      case 'exercise':
        return 'dumbbell';
      case 'nutrition':
        return 'food-apple';
      default:
        return 'video';
    }
  };

  return (
    <TouchableOpacity onPress={onPress}>
      <Card style={styles.card}>
        <Card.Cover 
          source={{ uri: thumbnailUrl }}
          style={styles.coverImage}
          resizeMode="cover"
        />
        <Card.Content style={styles.content}>
          <View style={styles.header}>
            <Chip
              style={[styles.categoryChip, { backgroundColor: theme.colors.primary }]}
              textStyle={styles.chipText}
              icon={() => (
                <MaterialCommunityIcons
                  name={getCategoryIcon()}
                  size={16}
                  color="white"
                />
              )}
            >
              {category.charAt(0).toUpperCase() + category.slice(1)}
            </Chip>
            <Chip
              style={[styles.difficultyChip, { backgroundColor: getDifficultyColor() }]}
              textStyle={styles.chipText}
            >
              {difficulty.charAt(0).toUpperCase() + difficulty.slice(1)}
            </Chip>
          </View>
          
          <Text style={styles.title} numberOfLines={2} ellipsizeMode="tail">
            {title}
          </Text>
          
          <Text style={styles.description} numberOfLines={2} ellipsizeMode="tail">
            {description}
          </Text>
          
          <View style={styles.footer}>
            <View style={styles.authorContainer}>
              <MaterialCommunityIcons name="account" size={16} color={theme.colors.placeholder} />
              <Text style={styles.authorText}>{author}</Text>
            </View>
            
            <View style={styles.durationContainer}>
              <MaterialCommunityIcons name="clock-outline" size={16} color={theme.colors.placeholder} />
              <Text style={styles.durationText}>{formatDuration(duration)}</Text>
            </View>
          </View>
          
          {progress > 0 && (
            <View style={styles.progressContainer}>
              <ProgressBar
                progress={progress}
                color={theme.colors.primary}
                style={styles.progressBar}
              />
              <Text style={styles.progressText}>{Math.round(progress * 100)}% Complete</Text>
            </View>
          )}
        </Card.Content>
      </Card>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    marginBottom: spacing.m,
    borderRadius: 12,
    elevation: 3,
    backgroundColor: theme.colors.surface,
  },
  coverImage: {
    height: 150,
    borderTopLeftRadius: 12,
    borderTopRightRadius: 12,
  },
  content: {
    paddingTop: spacing.s,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: spacing.s,
  },
  categoryChip: {
    height: 28,
  },
  difficultyChip: {
    height: 28,
  },
  chipText: {
    color: 'white',
    fontSize: 12,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: spacing.xs,
  },
  description: {
    fontSize: 14,
    color: theme.colors.placeholder,
    marginBottom: spacing.s,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: spacing.s,
  },
  authorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  authorText: {
    fontSize: 12,
    marginLeft: 4,
    color: theme.colors.placeholder,
  },
  durationContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  durationText: {
    fontSize: 12,
    marginLeft: 4,
    color: theme.colors.placeholder,
  },
  progressContainer: {
    marginTop: spacing.s,
  },
  progressBar: {
    height: 4,
    borderRadius: 2,
  },
  progressText: {
    fontSize: 10,
    color: theme.colors.placeholder,
    marginTop: 2,
    textAlign: 'right',
  },
});

export default TutorialCard;