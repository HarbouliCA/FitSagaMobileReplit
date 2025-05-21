/**
 * Unit tests for authentication Redux slice
 */
import authReducer, { 
  loginUser, 
  logoutUser, 
  registerUser,
  resetPassword
} from '../../../redux/features/authSlice';

describe('Auth Slice', () => {
  // Define initial state for tests
  const initialState = {
    isAuthenticated: false,
    user: null,
    userData: null,
    loading: false,
    error: null,
  };

  // Basic tests for handling initial state
  test('should return the initial state', () => {
    expect(authReducer(undefined, { type: undefined })).toEqual(initialState);
  });

  // Login action tests
  describe('Login actions', () => {
    test('should handle loginUser.pending', () => {
      const action = { type: loginUser.pending.type };
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle loginUser.fulfilled', () => {
      const mockUser = { uid: 'user123', email: 'test@example.com' };
      const mockUserData = { 
        id: 'user123',
        name: 'Test User', 
        role: 'client',
        email: 'test@example.com'
      };
      
      const action = { 
        type: loginUser.fulfilled.type, 
        payload: { user: mockUser, userData: mockUserData } 
      };
      
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(mockUser);
      expect(state.userData).toEqual(mockUserData);
      expect(state.error).toBe(null);
    });

    test('should handle loginUser.rejected', () => {
      const mockError = 'Invalid email or password';
      
      const action = { 
        type: loginUser.rejected.type, 
        payload: mockError 
      };
      
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBe(null);
      expect(state.error).toBe(mockError);
    });
  });

  // Registration action tests
  describe('Registration actions', () => {
    test('should handle registerUser.pending', () => {
      const action = { type: registerUser.pending.type };
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle registerUser.fulfilled', () => {
      const mockUser = { uid: 'newuser123', email: 'newuser@example.com' };
      const mockUserData = { 
        id: 'newuser123',
        name: 'New User', 
        role: 'client',
        email: 'newuser@example.com'
      };
      
      const action = { 
        type: registerUser.fulfilled.type, 
        payload: { user: mockUser, userData: mockUserData } 
      };
      
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(mockUser);
      expect(state.userData).toEqual(mockUserData);
      expect(state.error).toBe(null);
    });

    test('should handle registerUser.rejected', () => {
      const mockError = 'Email already in use';
      
      const action = { 
        type: registerUser.rejected.type, 
        payload: mockError 
      };
      
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBe(null);
      expect(state.error).toBe(mockError);
    });
  });

  // Logout action tests
  describe('Logout actions', () => {
    // Set up an authenticated state for logout tests
    const authenticatedState = {
      isAuthenticated: true,
      user: { uid: 'user123', email: 'test@example.com' },
      userData: { 
        id: 'user123', 
        name: 'Test User', 
        role: 'client',
        email: 'test@example.com'
      },
      loading: false,
      error: null,
    };

    test('should handle logoutUser.pending', () => {
      const action = { type: logoutUser.pending.type };
      const state = authReducer(authenticatedState, action);
      
      expect(state.loading).toBe(true);
    });

    test('should handle logoutUser.fulfilled', () => {
      const action = { type: logoutUser.fulfilled.type };
      const state = authReducer(authenticatedState, action);
      
      expect(state.loading).toBe(false);
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBe(null);
      expect(state.userData).toBe(null);
      expect(state.error).toBe(null);
    });

    test('should handle logoutUser.rejected', () => {
      const mockError = 'Failed to sign out';
      
      const action = { 
        type: logoutUser.rejected.type, 
        payload: mockError 
      };
      
      const state = authReducer(authenticatedState, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(mockError);
      // Even on error, the user should remain logged in
      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(authenticatedState.user);
    });
  });

  // Password reset action tests
  describe('Password reset actions', () => {
    test('should handle resetPassword.pending', () => {
      const action = { type: resetPassword.pending.type };
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle resetPassword.fulfilled', () => {
      const action = { 
        type: resetPassword.fulfilled.type,
        payload: 'Password reset email sent'
      };
      
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(null);
    });

    test('should handle resetPassword.rejected', () => {
      const mockError = 'Email not found';
      
      const action = { 
        type: resetPassword.rejected.type, 
        payload: mockError 
      };
      
      const state = authReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(mockError);
    });
  });
});