import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Image,
  SafeAreaView,
  FlatList,
  TextInput
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';

const TutorialsScreen = () => {
  const navigation = useNavigation();
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  // Mock data for categories
  const categories = [
    { id: 'all', name: 'All' },
    { id: 'strength', name: 'Strength' },
    { id: 'cardio', name: 'Cardio' },
    { id: 'flexibility', name: 'Flexibility' },
    { id: 'hiit', name: 'HIIT' },
    { id: 'yoga', name: 'Yoga' },
  ];

  // Mock data for tutorial videos
  const tutorials = [
    {
      id: 1,
      title: 'Full Body Workout',
      category: 'strength',
      duration: '25 min',
      level: 'Beginner',
      instructor: 'Alex Johnson',
      thumbnail: 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?q=80&w=2069',
      progress: 0.75,
    },
    {
      id: 2,
      title: 'HIIT Cardio Burn',
      category: 'hiit',
      duration: '30 min',
      level: 'Intermediate',
      instructor: 'Sarah Miller',
      thumbnail: 'https://images.unsplash.com/photo-1549576490-b0b4831ef60a?q=80&w=2070',
      progress: 0.4,
    },
    {
      id: 3,
      title: 'Stretching Routine',
      category: 'flexibility',
      duration: '15 min',
      level: 'All Levels',
      instructor: 'Michael Torres',
      thumbnail: 'https://images.unsplash.com/photo-1570691079236-4bca6c45d440?q=80&w=2070',
      progress: 1.0,
    },
    {
      id: 4,
      title: 'Cardio Kickboxing',
      category: 'cardio',
      duration: '45 min',
      level: 'Advanced',
      instructor: 'Jessica Wong',
      thumbnail: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=2020',
      progress: 0.2,
    },
    {
      id: 5,
      title: 'Yoga Flow',
      category: 'yoga',
      duration: '20 min',
      level: 'Beginner',
      instructor: 'Emma Phillips',
      thumbnail: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=2022',
      progress: 0,
    },
    {
      id: 6,
      title: 'Strength Training',
      category: 'strength',
      duration: '35 min',
      level: 'Intermediate',
      instructor: 'David Kim',
      thumbnail: 'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?q=80&w=2069',
      progress: 0.6,
    },
  ];

  // Filter tutorials based on selected category and search query
  const filteredTutorials = tutorials.filter(tutorial => {
    const matchesCategory = selectedCategory === 'all' || tutorial.category === selectedCategory;
    const matchesSearch = tutorial.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          tutorial.instructor.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const handleTutorialPress = (tutorialId) => {
    // Navigate to tutorial detail screen
    navigation.navigate('TutorialDetail', { tutorialId });
  };

  const renderProgressBar = (progress) => {
    return (
      <View style={styles.progressBarContainer}>
        <View style={[styles.progressBar, { width: `${progress * 100}%` }]} />
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Workout Tutorials</Text>
        <TouchableOpacity>
          <Ionicons name="options-outline" size={24} color="#111827" />
        </TouchableOpacity>
      </View>

      <View style={styles.searchContainer}>
        <Ionicons name="search" size={20} color="#9CA3AF" style={styles.searchIcon} />
        <TextInput
          style={styles.searchInput}
          placeholder="Search tutorials or instructors"
          placeholderTextColor="#9CA3AF"
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
        {searchQuery !== '' && (
          <TouchableOpacity onPress={() => setSearchQuery('')}>
            <Ionicons name="close-circle" size={20} color="#9CA3AF" />
          </TouchableOpacity>
        )}
      </View>

      <View style={styles.categoriesContainer}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {categories.map(category => (
            <TouchableOpacity
              key={category.id}
              style={[
                styles.categoryButton,
                selectedCategory === category.id && styles.selectedCategoryButton
              ]}
              onPress={() => setSelectedCategory(category.id)}
            >
              <Text
                style={[
                  styles.categoryText,
                  selectedCategory === category.id && styles.selectedCategoryText
                ]}
              >
                {category.name}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <FlatList
        data={filteredTutorials}
        keyExtractor={item => item.id.toString()}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.tutorialList}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.tutorialCard}
            onPress={() => handleTutorialPress(item.id)}
          >
            <View style={styles.thumbnailContainer}>
              <Image
                source={{ uri: item.thumbnail }}
                style={styles.thumbnail}
              />
              <View style={styles.playButton}>
                <Ionicons name="play" size={20} color="white" />
              </View>
              <View style={styles.durationContainer}>
                <Text style={styles.durationText}>{item.duration}</Text>
              </View>
            </View>
            <View style={styles.tutorialInfo}>
              <Text style={styles.tutorialTitle}>{item.title}</Text>
              <Text style={styles.instructorName}>by {item.instructor}</Text>
              <View style={styles.tutorialMeta}>
                <View style={styles.levelContainer}>
                  <Text style={styles.levelText}>{item.level}</Text>
                </View>
                {item.progress > 0 && (
                  <View style={styles.progressContainer}>
                    {renderProgressBar(item.progress)}
                    <Text style={styles.progressText}>
                      {item.progress === 1 ? 'Completed' : `${Math.round(item.progress * 100)}%`}
                    </Text>
                  </View>
                )}
              </View>
            </View>
          </TouchableOpacity>
        )}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7f7f7',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#111827',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
    borderRadius: 12,
    margin: 16,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginTop: 0,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#111827',
  },
  categoriesContainer: {
    paddingVertical: 8,
    paddingHorizontal: 16,
  },
  categoryButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: 'white',
    marginRight: 10,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  selectedCategoryButton: {
    backgroundColor: '#4C1D95',
    borderColor: '#4C1D95',
  },
  categoryText: {
    fontSize: 14,
    color: '#6B7280',
  },
  selectedCategoryText: {
    color: 'white',
    fontWeight: '500',
  },
  tutorialList: {
    padding: 16,
    paddingTop: 8,
  },
  tutorialCard: {
    backgroundColor: 'white',
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  thumbnailContainer: {
    position: 'relative',
    height: 180,
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  playButton: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -20 }, { translateY: -20 }],
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  durationContainer: {
    position: 'absolute',
    bottom: 10,
    right: 10,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    borderRadius: 4,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  durationText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '500',
  },
  tutorialInfo: {
    padding: 16,
  },
  tutorialTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
    marginBottom: 4,
  },
  instructorName: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 8,
  },
  tutorialMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  levelContainer: {
    backgroundColor: '#EDE9FE',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 4,
  },
  levelText: {
    fontSize: 12,
    color: '#4C1D95',
    fontWeight: '500',
  },
  progressContainer: {
    flex: 1,
    marginLeft: 12,
  },
  progressBarContainer: {
    height: 4,
    backgroundColor: '#E5E7EB',
    borderRadius: 2,
    overflow: 'hidden',
    marginBottom: 4,
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#4C1D95',
  },
  progressText: {
    fontSize: 12,
    color: '#6B7280',
    textAlign: 'right',
  },
});

export default TutorialsScreen;