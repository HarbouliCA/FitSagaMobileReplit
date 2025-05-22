import React, { createContext, useState, useEffect, useContext } from 'react';
import { 
  FitSagaUser, 
  login as authLogin, 
  register as authRegister,
  logout as authLogout,
  getCurrentUserFromStorage,
  UserRole
} from '../services/auth';

// Auth context type
interface AuthContextType {
  user: FitSagaUser | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error: string | null }>;
  register: (email: string, password: string, displayName: string) => Promise<{ success: boolean; error: string | null }>;
  logout: () => Promise<{ success: boolean; error: string | null }>;
  isLoggedIn: boolean;
  isAdmin: boolean;
  isInstructor: boolean;
}

// Create the context
const AuthContext = createContext<AuthContextType>({
  user: null,
  isLoading: true,
  login: async () => ({ success: false, error: 'Not implemented' }),
  register: async () => ({ success: false, error: 'Not implemented' }),
  logout: async () => ({ success: false, error: 'Not implemented' }),
  isLoggedIn: false,
  isAdmin: false,
  isInstructor: false,
});

// Auth provider component
export const AuthProvider: React.FC<{children: React.ReactNode}> = ({ children }) => {
  const [user, setUser] = useState<FitSagaUser | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  // Load user from storage on component mount
  useEffect(() => {
    const loadUser = async () => {
      try {
        const storedUser = await getCurrentUserFromStorage();
        setUser(storedUser);
      } catch (error) {
        console.error('Error loading user:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadUser();
  }, []);

  // Login function
  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const result = await authLogin(email, password);
      
      if (result.error) {
        return { success: false, error: result.error };
      }
      
      setUser(result.user);
      return { success: true, error: null };
    } catch (error: any) {
      return { success: false, error: error.message || 'Login failed' };
    } finally {
      setIsLoading(false);
    }
  };

  // Register function
  const register = async (email: string, password: string, displayName: string) => {
    setIsLoading(true);
    try {
      const result = await authRegister(email, password, displayName);
      
      if (result.error) {
        return { success: false, error: result.error };
      }
      
      setUser(result.user);
      return { success: true, error: null };
    } catch (error: any) {
      return { success: false, error: error.message || 'Registration failed' };
    } finally {
      setIsLoading(false);
    }
  };

  // Logout function
  const logout = async () => {
    setIsLoading(true);
    try {
      const result = await authLogout();
      
      if (!result.success) {
        return { success: false, error: result.error };
      }
      
      setUser(null);
      return { success: true, error: null };
    } catch (error: any) {
      return { success: false, error: error.message || 'Logout failed' };
    } finally {
      setIsLoading(false);
    }
  };

  // Check if user is logged in
  const isLoggedIn = !!user;
  
  // Check if user is admin
  const isAdmin = !!user && user.role === UserRole.ADMIN;
  
  // Check if user is instructor (instructors and admins can both create sessions)
  const isInstructor = !!user && (user.role === UserRole.INSTRUCTOR || user.role === UserRole.ADMIN);

  // Context value
  const value = {
    user,
    isLoading,
    login,
    register,
    logout,
    isLoggedIn,
    isAdmin,
    isInstructor,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

// Custom hook to use the auth context
export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  
  return context;
};

export default AuthContext;