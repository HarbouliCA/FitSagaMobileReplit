import AsyncStorage from '@react-native-async-storage/async-storage';
import { FitSagaUser, updateCredits } from './auth';

// Session types
export interface Session {
  id: number;
  title: string;
  date: string;
  time: string;
  duration: string;
  instructor: string;
  description: string;
  capacity: string;
  currentBookings: number;
  creditCost: number;
  location: string;
  category: string;
  isIntervalSession?: boolean;
  image: string;
}

// Booking interface
export interface Booking {
  id: string;
  userId: string;
  sessionId: number;
  date: string; // ISO date string
  status: 'confirmed' | 'cancelled' | 'completed';
  creditsCost: number;
  isIntervalSession: boolean;
}

// Get sessions (mock data for demonstration)
export const getSessions = async (): Promise<Session[]> => {
  try {
    // In a real app, this would make a call to a backend API
    const mockSessions: Session[] = [
      {
        id: 1,
        title: 'HIIT Training',
        date: 'May 25, 2025',
        time: '15:00',
        duration: '60 min',
        instructor: 'Sarah Miller',
        description: 'This high-intensity session is designed to improve cardiovascular fitness and burn calories. Suitable for all fitness levels with modifications available.',
        capacity: '12 participants',
        currentBookings: 5,
        creditCost: 3,
        location: 'Main Studio',
        category: 'Fitness',
        isIntervalSession: true,
        image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
      },
      {
        id: 2,
        title: 'Yoga Flow',
        date: 'May 26, 2025',
        time: '09:00',
        duration: '45 min',
        instructor: 'David Chen',
        description: 'A gentle flow yoga class focusing on breathing, flexibility, and mindfulness. Perfect for beginners and experienced practitioners alike.',
        capacity: '15 participants',
        currentBookings: 8,
        creditCost: 2,
        location: 'Yoga Studio',
        category: 'Wellness',
        image: 'https://images.unsplash.com/photo-1599447802135-7ece80fd376a?q=80&w=2070'
      },
      {
        id: 3,
        title: 'Strength Training',
        date: 'May 26, 2025',
        time: '17:30',
        duration: '50 min',
        instructor: 'James Wilson',
        description: 'Build muscle and improve your overall strength with this comprehensive session using free weights and resistance machines.',
        capacity: '10 participants',
        currentBookings: 3,
        creditCost: 3,
        location: 'Weight Room',
        category: 'Strength',
        image: 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=2069'
      },
      {
        id: 4,
        title: 'Spin Class',
        date: 'May 27, 2025',
        time: '18:00',
        duration: '45 min',
        instructor: 'Emma Rodriguez',
        description: 'A high-energy indoor cycling class set to motivating music. Improve endurance and burn calories in this fun, group setting.',
        capacity: '20 participants',
        currentBookings: 12,
        creditCost: 2,
        location: 'Cycling Studio',
        category: 'Cardio',
        isIntervalSession: true,
        image: 'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?q=80&w=2031'
      },
      {
        id: 5,
        title: 'Personal Training',
        date: 'May 28, 2025',
        time: '10:00',
        duration: '60 min',
        instructor: 'Alex Johnson',
        description: 'One-on-one session tailored to your specific fitness goals with our expert trainer. Includes assessment, goal-setting, and personalized workout.',
        capacity: '1 participant',
        currentBookings: 0,
        creditCost: 5,
        location: 'Training Area',
        category: 'Personal',
        image: 'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?q=80&w=2069'
      }
    ];
    
    return mockSessions;
  } catch (error) {
    console.error('Error getting sessions:', error);
    return [];
  }
};

// Get session by ID
export const getSessionById = async (sessionId: number): Promise<Session | null> => {
  try {
    const sessions = await getSessions();
    return sessions.find(session => session.id === sessionId) || null;
  } catch (error) {
    console.error('Error getting session by ID:', error);
    return null;
  }
};

// Book a session
export const bookSession = async (
  userId: string,
  sessionId: number
): Promise<{ success: boolean; error: string | null }> => {
  try {
    // 1. Get the session details
    const session = await getSessionById(sessionId);
    if (!session) {
      return { success: false, error: 'Session not found' };
    }

    // 2. Check if session is at capacity
    if (session.currentBookings >= parseInt(session.capacity.split(' ')[0])) {
      return { success: false, error: 'Session is fully booked' };
    }

    // 3. Get user data
    const userDataStr = await AsyncStorage.getItem(`userdata_${userId}`);
    if (!userDataStr) {
      return { success: false, error: 'User data not found' };
    }
    
    const userData: FitSagaUser = JSON.parse(userDataStr);

    // 4. Check if user has enough credits
    const isIntervalSession = !!session.isIntervalSession;
    
    if (isIntervalSession) {
      if (userData.intervalCredits < session.creditCost) {
        return { success: false, error: 'Not enough interval credits' };
      }
    } else {
      if (userData.credits < session.creditCost) {
        return { success: false, error: 'Not enough credits' };
      }
    }

    // 5. Create booking record
    const booking: Booking = {
      id: `booking_${Date.now()}`,
      userId,
      sessionId,
      date: new Date().toISOString(),
      status: 'confirmed',
      creditsCost: session.creditCost,
      isIntervalSession
    };

    // 6. Update user's credits
    if (isIntervalSession) {
      await updateCredits(
        userId, 
        userData.credits, 
        userData.intervalCredits - session.creditCost
      );
    } else {
      await updateCredits(
        userId, 
        userData.credits - session.creditCost,
        userData.intervalCredits
      );
    }

    // 7. Save booking to storage (in a real app, this would be saved to a database)
    const existingBookingsStr = await AsyncStorage.getItem(`bookings_${userId}`);
    const existingBookings: Booking[] = existingBookingsStr ? JSON.parse(existingBookingsStr) : [];
    
    const updatedBookings = [...existingBookings, booking];
    await AsyncStorage.setItem(`bookings_${userId}`, JSON.stringify(updatedBookings));

    // 8. Update session's currentBookings (in a real app, this would be updated in the database)
    // For demo purposes, we'll just update our local storage copy of the sessions
    const existingSessionsStr = await AsyncStorage.getItem('sessions');
    let existingSessions: Session[] = existingSessionsStr ? JSON.parse(existingSessionsStr) : await getSessions();
    
    existingSessions = existingSessions.map(s => 
      s.id === session.id 
        ? { ...s, currentBookings: s.currentBookings + 1 } 
        : s
    );
    
    await AsyncStorage.setItem('sessions', JSON.stringify(existingSessions));

    return { success: true, error: null };
  } catch (error: any) {
    console.error('Error booking session:', error);
    return { success: false, error: error.message || 'Failed to book session' };
  }
};

// Get user's bookings
export const getUserBookings = async (userId: string): Promise<Booking[]> => {
  try {
    const bookingsStr = await AsyncStorage.getItem(`bookings_${userId}`);
    if (!bookingsStr) {
      return [];
    }
    
    return JSON.parse(bookingsStr) as Booking[];
  } catch (error) {
    console.error('Error getting user bookings:', error);
    return [];
  }
};

// Cancel booking
export const cancelBooking = async (
  userId: string,
  bookingId: string
): Promise<{ success: boolean; error: string | null }> => {
  try {
    // 1. Get user's bookings
    const bookingsStr = await AsyncStorage.getItem(`bookings_${userId}`);
    if (!bookingsStr) {
      return { success: false, error: 'No bookings found' };
    }
    
    const bookings: Booking[] = JSON.parse(bookingsStr);
    
    // 2. Find the booking to cancel
    const bookingIndex = bookings.findIndex(b => b.id === bookingId);
    if (bookingIndex === -1) {
      return { success: false, error: 'Booking not found' };
    }
    
    const booking = bookings[bookingIndex];
    
    // 3. Check if booking is already cancelled
    if (booking.status === 'cancelled') {
      return { success: false, error: 'Booking is already cancelled' };
    }
    
    // 4. Update booking status
    bookings[bookingIndex] = { ...booking, status: 'cancelled' };
    
    // 5. Refund credits to user
    const userDataStr = await AsyncStorage.getItem(`userdata_${userId}`);
    if (!userDataStr) {
      return { success: false, error: 'User data not found' };
    }
    
    const userData: FitSagaUser = JSON.parse(userDataStr);
    
    if (booking.isIntervalSession) {
      await updateCredits(
        userId, 
        userData.credits, 
        userData.intervalCredits + booking.creditsCost
      );
    } else {
      await updateCredits(
        userId, 
        userData.credits + booking.creditsCost,
        userData.intervalCredits
      );
    }
    
    // 6. Save updated bookings
    await AsyncStorage.setItem(`bookings_${userId}`, JSON.stringify(bookings));
    
    // 7. Update session's currentBookings
    const session = await getSessionById(booking.sessionId);
    if (session) {
      const existingSessionsStr = await AsyncStorage.getItem('sessions');
      let existingSessions: Session[] = existingSessionsStr ? JSON.parse(existingSessionsStr) : await getSessions();
      
      existingSessions = existingSessions.map(s => 
        s.id === session.id 
          ? { ...s, currentBookings: Math.max(0, s.currentBookings - 1) } 
          : s
      );
      
      await AsyncStorage.setItem('sessions', JSON.stringify(existingSessions));
    }
    
    return { success: true, error: null };
  } catch (error: any) {
    console.error('Error cancelling booking:', error);
    return { success: false, error: error.message || 'Failed to cancel booking' };
  }
};