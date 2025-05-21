import React, { useEffect, useState } from 'react';
import { View, StyleSheet, FlatList, RefreshControl, TouchableOpacity } from 'react-native';
import { Text, Searchbar, Chip, ActivityIndicator, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useSelector, useDispatch } from 'react-redux';

import { RootState } from '../../redux/store';
import { 
  fetchTutorials, 
  fetchUserTutorialProgress,
  setFilter, 
  clearFilter 
} from '../../redux/features/tutorialsSlice';
import TutorialCard from '../../components/tutorials/TutorialCard';
import { theme, spacing } from '../../theme';

const TutorialsScreen: React.FC = () => {
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  
  const navigation = useNavigation();
  const dispatch = useDispatch();
  
  const { user } = useSelector((state: RootState) => state.auth);
  const { 
    tutorials, 
    loading, 
    error,
    userProgress,
    filter 
  } = useSelector((state: RootState) => state.tutorials);

  // Get filtered tutorials
  const getFilteredTutorials = () => {
    let result = [...tutorials];
    
    // Apply category filter
    if (filter.category) {
      result = result.filter(tutorial => tutorial.category === filter.category);
    }
    
    // Apply difficulty filter
    if (filter.difficulty) {
      result = result.filter(tutorial => tutorial.difficulty === filter.difficulty);
    }
    
    // Apply search query
    if (searchQuery.trim() !== '') {
      const query = searchQuery.toLowerCase().trim();
      result = result.filter(tutorial => 
        tutorial.title.toLowerCase().includes(query) ||
        tutorial.description.toLowerCase().includes(query) ||
        tutorial.author.toLowerCase().includes(query)
      );
    }
    
    return result;
  };

  // Calculate progress for a tutorial
  const calculateProgress = (tutorialId: string) => {
    const progress = userProgress[tutorialId];
    
    if (!progress) return 0;
    
    if (progress.completed) return 1;
    
    const tutorial = tutorials.find(t => t.id === tutorialId);
    if (!tutorial) return 0;
    
    let completedExercisesCount = 0;
    let totalExercisesCount = 0;
    
    tutorial.days.forEach(day => {
      day.exercises.forEach(exercise => {
        totalExercisesCount++;
        if (progress.completedExercises[exercise.id]) {
          completedExercisesCount++;
        }
      });
    });
    
    return totalExercisesCount > 0 ? completedExercisesCount / totalExercisesCount : 0;
  };

  // Load tutorials and user progress
  const loadData = async () => {
    setRefreshing(true);
    
    await dispatch(fetchTutorials());
    
    if (user) {
      await dispatch(fetchUserTutorialProgress(user.uid));
    }
    
    setRefreshing(false);
  };

  // Handle category filter
  const handleCategoryFilter = (category: string | null) => {
    dispatch(setFilter({ category }));
  };

  // Handle difficulty filter
  const handleDifficultyFilter = (difficulty: string | null) => {
    dispatch(setFilter({ difficulty }));
  };

  // Handle search
  const handleSearch = (query: string) => {
    setSearchQuery(query);
  };

  // Handle clear filters
  const handleClearFilters = () => {
    dispatch(clearFilter());
    setSearchQuery('');
  };

  // Navigate to tutorial details
  const handleTutorialPress = (tutorialId: string) => {
    navigation.navigate('TutorialDetail', { tutorialId });
  };

  // Initial data load
  useEffect(() => {
    loadData();
  }, [user]);

  // Render category filters
  const renderCategoryFilters = () => {
    const categories = [
      { key: 'exercise', label: 'Exercise' },
      { key: 'nutrition', label: 'Nutrition' },
    ];
    
    return (
      <View style={styles.filterRow}>
        <Text style={styles.filterLabel}>Category:</Text>
        <View style={styles.chipContainer}>
          {categories.map(category => (
            <Chip
              key={category.key}
              selected={filter.category === category.key}
              onPress={() => handleCategoryFilter(
                filter.category === category.key ? null : category.key
              )}
              style={[
                styles.filterChip,
                filter.category === category.key && styles.selectedChip,
              ]}
              textStyle={filter.category === category.key ? styles.selectedChipText : undefined}
            >
              {category.label}
            </Chip>
          ))}
        </View>
      </View>
    );
  };

  // Render difficulty filters
  const renderDifficultyFilters = () => {
    const difficulties = [
      { key: 'beginner', label: 'Beginner' },
      { key: 'intermediate', label: 'Intermediate' },
      { key: 'advanced', label: 'Advanced' },
    ];
    
    return (
      <View style={styles.filterRow}>
        <Text style={styles.filterLabel}>Difficulty:</Text>
        <View style={styles.chipContainer}>
          {difficulties.map(difficulty => (
            <Chip
              key={difficulty.key}
              selected={filter.difficulty === difficulty.key}
              onPress={() => handleDifficultyFilter(
                filter.difficulty === difficulty.key ? null : difficulty.key
              )}
              style={[
                styles.filterChip,
                filter.difficulty === difficulty.key && styles.selectedChip,
              ]}
              textStyle={filter.difficulty === difficulty.key ? styles.selectedChipText : undefined}
            >
              {difficulty.label}
            </Chip>
          ))}
        </View>
      </View>
    );
  };

  // Render empty state
  const renderEmptyState = () => {
    if (loading && !refreshing) {
      return (
        <View style={styles.emptyContainer}>
          <ActivityIndicator size="large" color={theme.colors.primary} />
          <Text style={styles.emptyText}>Loading tutorials...</Text>
        </View>
      );
    }
    
    if (error) {
      return (
        <View style={styles.emptyContainer}>
          <Text style={styles.errorText}>Error: {error}</Text>
          <Button 
            mode="contained"
            onPress={loadData}
            style={styles.retryButton}
          >
            Retry
          </Button>
        </View>
      );
    }
    
    if (getFilteredTutorials().length === 0) {
      return (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>No tutorials found</Text>
          {(filter.category || filter.difficulty || searchQuery) && (
            <>
              <Text style={styles.emptySubtext}>
                Try adjusting your filters
              </Text>
              <Button
                mode="contained"
                onPress={handleClearFilters}
                style={styles.clearButton}
              >
                Clear Filters
              </Button>
            </>
          )}
        </View>
      );
    }
    
    return null;
  };

  // Render tutorial item
  const renderTutorialItem = ({ item }) => (
    <TutorialCard
      id={item.id}
      title={item.title}
      category={item.category}
      description={item.description}
      thumbnailUrl={item.thumbnailUrl}
      author={item.author}
      duration={item.duration}
      difficulty={item.difficulty}
      progress={calculateProgress(item.id)}
      onPress={() => handleTutorialPress(item.id)}
    />
  );

  return (
    <View style={styles.container}>
      <View style={styles.searchContainer}>
        <Searchbar
          placeholder="Search tutorials..."
          onChangeText={handleSearch}
          value={searchQuery}
          style={styles.searchbar}
          iconColor={theme.colors.primary}
        />
      </View>
      
      <View style={styles.filtersContainer}>
        {renderCategoryFilters()}
        {renderDifficultyFilters()}
        
        {(filter.category || filter.difficulty || searchQuery) && (
          <TouchableOpacity onPress={handleClearFilters}>
            <Text style={styles.clearFiltersText}>Clear All Filters</Text>
          </TouchableOpacity>
        )}
      </View>
      
      <FlatList
        data={getFilteredTutorials()}
        keyExtractor={(item) => item.id}
        renderItem={renderTutorialItem}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={renderEmptyState}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={loadData} />
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  searchContainer: {
    padding: spacing.m,
    backgroundColor: theme.colors.primary,
  },
  searchbar: {
    elevation: 0,
    backgroundColor: 'white',
  },
  filtersContainer: {
    padding: spacing.m,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: '#EEEEEE',
  },
  filterRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.s,
  },
  filterLabel: {
    width: 80,
    fontSize: 14,
    color: theme.colors.placeholder,
  },
  chipContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    flex: 1,
  },
  filterChip: {
    marginRight: spacing.s,
    marginBottom: spacing.xs,
  },
  selectedChip: {
    backgroundColor: theme.colors.primary,
  },
  selectedChipText: {
    color: 'white',
  },
  clearFiltersText: {
    color: theme.colors.primary,
    textAlign: 'right',
    marginTop: spacing.s,
    fontWeight: '500',
  },
  listContent: {
    padding: spacing.m,
    paddingBottom: spacing.xl,
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.xl,
    marginTop: spacing.xl,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: 'bold',
    marginVertical: spacing.s,
  },
  emptySubtext: {
    textAlign: 'center',
    color: theme.colors.placeholder,
    marginBottom: spacing.m,
  },
  errorText: {
    color: theme.colors.error,
    textAlign: 'center',
    marginBottom: spacing.m,
  },
  retryButton: {
    marginTop: spacing.m,
  },
  clearButton: {
    marginTop: spacing.m,
  },
});

export default TutorialsScreen;