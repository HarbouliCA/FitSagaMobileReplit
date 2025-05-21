import { configureStore } from '@reduxjs/toolkit';
import authReducer from './features/authSlice';
import creditsReducer from './features/creditsSlice';
import tutorialsReducer from './features/tutorialsSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    credits: creditsReducer,
    tutorials: tutorialsReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false, // Needed for Firebase objects
    }),
});

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;