import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { 
  collection, 
  getDocs, 
  doc, 
  getDoc, 
  query, 
  where, 
  orderBy 
} from 'firebase/firestore';
import { ref, getDownloadURL } from 'firebase/storage';
import { db, storage } from '../../services/firebase';

// Types for tutorial data
export interface Exercise {
  id: string;
  name: string;
  description: string;
  videoUrl?: string;
  thumbnailUrl?: string;
  duration: number;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  equipment?: string[];
  muscleGroups?: string[];
  instructions: string[];
  sets: number;
  reps?: string;
  restBetweenSets?: number;
}

export interface TutorialDay {
  id: string;
  dayNumber: number;
  title: string;
  description: string;
  exercises: Exercise[];
}

export interface Tutorial {
  id: string;
  title: string;
  category: 'exercise' | 'nutrition';
  description: string;
  thumbnailUrl?: string;
  author: string;
  authorId: string;
  duration: number;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  isPublished: boolean;
  createdAt: Date;
  updatedAt: Date;
  days: TutorialDay[];
  goals?: string[];
  equipmentRequired?: string[];
  targetAudience?: string;
}

// Tutorial progress tracking
export interface TutorialProgress {
  tutorialId: string;
  completed: boolean;
  completedDays: {
    [dayId: string]: boolean;
  };
  completedExercises: {
    [exerciseId: string]: boolean;
  };
  lastAccessedDay: string;
  startedAt: Date;
  completedAt?: Date;
}

// State interface
interface TutorialsState {
  tutorials: Tutorial[];
  currentTutorial: Tutorial | null;
  userProgress: { [tutorialId: string]: TutorialProgress };
  loading: boolean;
  error: string | null;
  filter: {
    category: string | null;
    difficulty: string | null;
    searchQuery: string;
  };
}

// Initial state
const initialState: TutorialsState = {
  tutorials: [],
  currentTutorial: null,
  userProgress: {},
  loading: false,
  error: null,
  filter: {
    category: null,
    difficulty: null,
    searchQuery: '',
  },
};

// Async thunks
export const fetchTutorials = createAsyncThunk(
  'tutorials/fetchTutorials',
  async (_, { rejectWithValue }) => {
    try {
      const tutorialsRef = collection(db, 'tutorials');
      const tutorialsQuery = query(
        tutorialsRef,
        where('isPublished', '==', true),
        orderBy('createdAt', 'desc')
      );
      
      const snapshot = await getDocs(tutorialsQuery);
      
      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          title: data.title,
          category: data.category,
          description: data.description,
          thumbnailUrl: data.thumbnailUrl,
          author: data.author,
          authorId: data.authorId,
          duration: data.duration,
          difficulty: data.difficulty,
          isPublished: data.isPublished,
          createdAt: data.createdAt?.toDate(),
          updatedAt: data.updatedAt?.toDate(),
          days: (data.days || []).map((day: any) => ({
            id: day.id,
            dayNumber: day.dayNumber,
            title: day.title,
            description: day.description,
            exercises: (day.exercises || []).map((exercise: any) => ({
              id: exercise.id,
              name: exercise.name,
              description: exercise.description,
              videoUrl: exercise.videoUrl,
              thumbnailUrl: exercise.thumbnailUrl,
              duration: exercise.duration,
              difficulty: exercise.difficulty,
              equipment: exercise.equipment,
              muscleGroups: exercise.muscleGroups,
              instructions: exercise.instructions,
              sets: exercise.sets,
              reps: exercise.reps,
              restBetweenSets: exercise.restBetweenSets,
            })),
          })),
          goals: data.goals,
          equipmentRequired: data.equipmentRequired,
          targetAudience: data.targetAudience,
        } as Tutorial;
      });
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch tutorials');
    }
  }
);

export const fetchTutorialById = createAsyncThunk(
  'tutorials/fetchTutorialById',
  async (tutorialId: string, { rejectWithValue }) => {
    try {
      const tutorialDoc = await getDoc(doc(db, 'tutorials', tutorialId));
      
      if (!tutorialDoc.exists()) {
        return rejectWithValue('Tutorial not found');
      }
      
      const data = tutorialDoc.data();
      
      // Process days and exercises
      const days = (data.days || []).map((day: any) => ({
        id: day.id,
        dayNumber: day.dayNumber,
        title: day.title,
        description: day.description,
        exercises: (day.exercises || []).map((exercise: any) => ({
          id: exercise.id,
          name: exercise.name,
          description: exercise.description,
          videoUrl: exercise.videoUrl,
          thumbnailUrl: exercise.thumbnailUrl,
          duration: exercise.duration,
          difficulty: exercise.difficulty,
          equipment: exercise.equipment,
          muscleGroups: exercise.muscleGroups,
          instructions: exercise.instructions,
          sets: exercise.sets,
          reps: exercise.reps,
          restBetweenSets: exercise.restBetweenSets,
        })),
      }));
      
      return {
        id: tutorialDoc.id,
        title: data.title,
        category: data.category,
        description: data.description,
        thumbnailUrl: data.thumbnailUrl,
        author: data.author,
        authorId: data.authorId,
        duration: data.duration,
        difficulty: data.difficulty,
        isPublished: data.isPublished,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate(),
        days,
        goals: data.goals,
        equipmentRequired: data.equipmentRequired,
        targetAudience: data.targetAudience,
      } as Tutorial;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch tutorial');
    }
  }
);

export const fetchUserTutorialProgress = createAsyncThunk(
  'tutorials/fetchUserTutorialProgress',
  async (userId: string, { rejectWithValue }) => {
    try {
      const progressRef = collection(db, 'users', userId, 'tutorialProgress');
      const snapshot = await getDocs(progressRef);
      
      const progress: { [tutorialId: string]: TutorialProgress } = {};
      
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        progress[doc.id] = {
          tutorialId: doc.id,
          completed: data.completed || false,
          completedDays: data.completedDays || {},
          completedExercises: data.completedExercises || {},
          lastAccessedDay: data.lastAccessedDay || '',
          startedAt: data.startedAt?.toDate() || new Date(),
          completedAt: data.completedAt?.toDate(),
        };
      });
      
      return progress;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch progress');
    }
  }
);

export const getVideoUrl = createAsyncThunk(
  'tutorials/getVideoUrl',
  async (videoPath: string, { rejectWithValue }) => {
    try {
      if (!videoPath) {
        return rejectWithValue('Invalid video path');
      }
      
      const storageRef = ref(storage, videoPath);
      const url = await getDownloadURL(storageRef);
      
      return { path: videoPath, url };
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch video URL');
    }
  }
);

// Create the slice
const tutorialsSlice = createSlice({
  name: 'tutorials',
  initialState,
  reducers: {
    setFilter: (state, action) => {
      state.filter = {
        ...state.filter,
        ...action.payload,
      };
    },
    clearFilter: (state) => {
      state.filter = {
        category: null,
        difficulty: null,
        searchQuery: '',
      };
    },
    markExerciseCompleted: (state, action) => {
      const { tutorialId, dayId, exerciseId } = action.payload;
      
      if (!state.userProgress[tutorialId]) {
        state.userProgress[tutorialId] = {
          tutorialId,
          completed: false,
          completedDays: {},
          completedExercises: {},
          lastAccessedDay: dayId,
          startedAt: new Date(),
        };
      }
      
      state.userProgress[tutorialId].completedExercises[exerciseId] = true;
      
      // Check if all exercises in the day are completed
      if (state.currentTutorial) {
        const day = state.currentTutorial.days.find(d => d.id === dayId);
        
        if (day) {
          const allExercisesCompleted = day.exercises.every(
            exercise => state.userProgress[tutorialId].completedExercises[exercise.id]
          );
          
          if (allExercisesCompleted) {
            state.userProgress[tutorialId].completedDays[dayId] = true;
            
            // Check if all days are completed
            const allDaysCompleted = state.currentTutorial.days.every(
              d => state.userProgress[tutorialId].completedDays[d.id]
            );
            
            if (allDaysCompleted) {
              state.userProgress[tutorialId].completed = true;
              state.userProgress[tutorialId].completedAt = new Date();
            }
          }
        }
      }
    },
    setLastAccessedDay: (state, action) => {
      const { tutorialId, dayId } = action.payload;
      
      if (!state.userProgress[tutorialId]) {
        state.userProgress[tutorialId] = {
          tutorialId,
          completed: false,
          completedDays: {},
          completedExercises: {},
          lastAccessedDay: dayId,
          startedAt: new Date(),
        };
      } else {
        state.userProgress[tutorialId].lastAccessedDay = dayId;
      }
    },
  },
  extraReducers: (builder) => {
    builder
      // fetchTutorials
      .addCase(fetchTutorials.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchTutorials.fulfilled, (state, action) => {
        state.loading = false;
        state.tutorials = action.payload;
      })
      .addCase(fetchTutorials.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      
      // fetchTutorialById
      .addCase(fetchTutorialById.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchTutorialById.fulfilled, (state, action) => {
        state.loading = false;
        state.currentTutorial = action.payload;
      })
      .addCase(fetchTutorialById.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      
      // fetchUserTutorialProgress
      .addCase(fetchUserTutorialProgress.fulfilled, (state, action) => {
        state.userProgress = action.payload;
      })
      
      // getVideoUrl
      .addCase(getVideoUrl.fulfilled, (state, action) => {
        // If we have the current tutorial loaded, update the video URL
        if (state.currentTutorial) {
          for (const day of state.currentTutorial.days) {
            for (const exercise of day.exercises) {
              if (exercise.videoUrl === action.payload.path) {
                exercise.videoUrl = action.payload.url;
              }
            }
          }
        }
      });
  },
});

export const { 
  setFilter, 
  clearFilter, 
  markExerciseCompleted,
  setLastAccessedDay,
} = tutorialsSlice.actions;

export default tutorialsSlice.reducer;