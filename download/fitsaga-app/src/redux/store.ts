import { configureStore } from '@reduxjs/toolkit';
import authReducer from './features/authSlice';
import creditsReducer from './features/creditsSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    credits: creditsReducer,
    // We'll add more reducers as we implement features
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false, // Needed for Firebase objects
    }),
});

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;