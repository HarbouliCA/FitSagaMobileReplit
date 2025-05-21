import { DefaultTheme } from 'react-native-paper';

/**
 * App theme configuration
 * This defines colors, fonts, and other visual elements used throughout the app
 */
export const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#4A58C0',      // Main brand color
    accent: '#FF6B6B',       // Secondary accent color
    background: '#F5F7FA',   // Background color
    surface: '#FFFFFF',      // Surface color for cards
    text: '#333333',         // Main text color
    error: '#D32F2F',        // Error color
    success: '#4CAF50',      // Success color
    warning: '#FFC107',      // Warning color
    info: '#2196F3',         // Info color
    disabled: '#BDBDBD',     // Disabled state color
    placeholder: '#9E9E9E',  // Placeholder text color
  },
  roundness: 8,              // Border radius for components
  fonts: {
    ...DefaultTheme.fonts,
  },
};

// Typography scale
export const typography = {
  h1: {
    fontSize: 28,
    fontWeight: 'bold',
  },
  h2: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  h3: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  subtitle1: {
    fontSize: 18,
    fontWeight: '500',
  },
  subtitle2: {
    fontSize: 16,
    fontWeight: '500',
  },
  body1: {
    fontSize: 16,
    fontWeight: 'normal',
  },
  body2: {
    fontSize: 14,
    fontWeight: 'normal',
  },
  button: {
    fontSize: 16,
    fontWeight: '500',
  },
  caption: {
    fontSize: 12,
    fontWeight: 'normal',
  },
};

// Spacing scale (in pixels)
export const spacing = {
  xs: 4,
  s: 8,
  m: 16,
  l: 24,
  xl: 32,
  xxl: 48,
};