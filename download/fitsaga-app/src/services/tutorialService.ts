// Tutorial service for handling tutorial data and operations

export interface Tutorial {
  id: number;
  title: string;
  instructor: string;
  duration: string;
  level: string;
  description: string;
  category: string;
  videoUrl: string;
  thumbnail: string;
  equipment: string[];
  isLiked?: boolean;
  isSaved?: boolean;
}

interface TutorialResponse {
  success: boolean;
  error?: string;
}

// Mock data for tutorials - will be replaced with Firebase data later
const tutorials: Tutorial[] = [
  {
    id: 1,
    title: 'Full Body HIIT Workout',
    instructor: 'Alex Johnson',
    duration: '25 min',
    level: 'Intermediate',
    description: 'This high-intensity interval training workout targets all major muscle groups. Perfect for building strength and cardiovascular endurance.',
    category: 'HIIT',
    videoUrl: 'http://d23dyxeqlo5psv.cloudfront.net/big_buck_bunny.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?q=80&w=2069',
    equipment: ['Dumbbells', 'Exercise mat'],
    isLiked: false,
    isSaved: false
  },
  {
    id: 2,
    title: 'Strength Training Basics',
    instructor: 'Sarah Miller',
    duration: '35 min',
    level: 'Beginner',
    description: 'Learn the fundamentals of strength training with this beginner-friendly tutorial. Focus on form and technique for effective results.',
    category: 'Strength',
    videoUrl: 'http://d23dyxeqlo5psv.cloudfront.net/big_buck_bunny.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=2070',
    equipment: ['Dumbbells', 'Resistance bands', 'Exercise mat'],
    isLiked: false,
    isSaved: false
  },
  {
    id: 3,
    title: 'Advanced Yoga Flow',
    instructor: 'Michael Chen',
    duration: '45 min',
    level: 'Advanced',
    description: 'Take your yoga practice to the next level with this challenging flow that builds strength, flexibility, and mindfulness.',
    category: 'Yoga',
    videoUrl: 'http://d23dyxeqlo5psv.cloudfront.net/big_buck_bunny.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=2070',
    equipment: ['Yoga mat', 'Yoga blocks'],
    isLiked: false,
    isSaved: false
  },
  {
    id: 4,
    title: 'Cardio Kickboxing',
    instructor: 'James Wilson',
    duration: '30 min',
    level: 'Intermediate',
    description: 'Burn calories and improve coordination with this high-energy kickboxing workout that combines martial arts moves with cardio.',
    category: 'Cardio',
    videoUrl: 'http://d23dyxeqlo5psv.cloudfront.net/big_buck_bunny.mp4',
    thumbnail: 'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?q=80&w=2069',
    equipment: ['Exercise mat', 'Water bottle'],
    isLiked: false,
    isSaved: false
  }
];

/**
 * Get all available tutorials
 */
export const getTutorials = async (): Promise<Tutorial[]> => {
  // Simulating API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  return tutorials;
};

/**
 * Get tutorial by ID
 */
export const getTutorialById = async (tutorialId: number): Promise<Tutorial | null> => {
  // Simulating API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  const tutorial = tutorials.find(t => t.id === tutorialId);
  return tutorial || null;
};

/**
 * Get tutorials by category
 */
export const getTutorialsByCategory = async (category: string): Promise<Tutorial[]> => {
  // Simulating API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  return tutorials.filter(t => t.category.toLowerCase() === category.toLowerCase());
};

/**
 * Save tutorial to user's saved list
 */
export const saveTutorial = async (userId: string, tutorialId: number): Promise<TutorialResponse> => {
  // Find the tutorial to save
  const tutorial = tutorials.find(t => t.id === tutorialId);
  
  if (!tutorial) {
    return { success: false, error: 'Tutorial not found' };
  }
  
  // In a real app, this would update Firebase
  tutorial.isSaved = true;
  
  return { success: true };
};

/**
 * Remove tutorial from user's saved list
 */
export const unsaveTutorial = async (userId: string, tutorialId: number): Promise<TutorialResponse> => {
  // Find the tutorial to unsave
  const tutorial = tutorials.find(t => t.id === tutorialId);
  
  if (!tutorial) {
    return { success: false, error: 'Tutorial not found' };
  }
  
  // In a real app, this would update Firebase
  tutorial.isSaved = false;
  
  return { success: true };
};

/**
 * Like a tutorial
 */
export const likeTutorial = async (userId: string, tutorialId: number): Promise<TutorialResponse> => {
  // Find the tutorial to like
  const tutorial = tutorials.find(t => t.id === tutorialId);
  
  if (!tutorial) {
    return { success: false, error: 'Tutorial not found' };
  }
  
  // In a real app, this would update Firebase
  tutorial.isLiked = true;
  
  return { success: true };
};

/**
 * Unlike a tutorial
 */
export const unlikeTutorial = async (userId: string, tutorialId: number): Promise<TutorialResponse> => {
  // Find the tutorial to unlike
  const tutorial = tutorials.find(t => t.id === tutorialId);
  
  if (!tutorial) {
    return { success: false, error: 'Tutorial not found' };
  }
  
  // In a real app, this would update Firebase
  tutorial.isLiked = false;
  
  return { success: true };
};