// Session service for handling gym sessions and bookings

import { FitSagaUser } from './authService';
import { processSessionBooking, processSessionCancellation } from './creditService';

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

export interface Booking {
  id: string;
  userId: string;
  sessionId: number;
  date: string; // ISO date string
  status: 'confirmed' | 'cancelled' | 'completed';
  creditsCost: number;
  isIntervalSession: boolean;
}

interface BookingResponse {
  success: boolean;
  error?: string;
  booking?: Booking;
}

// Mock session data
const sessions: Session[] = [
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
    isIntervalSession: false,
    image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070'
  },
  {
    id: 2,
    title: 'Interval Power Session',
    date: 'May 26, 2025',
    time: '18:30',
    duration: '45 min',
    instructor: 'Mike Johnson',
    description: 'A group training session featuring short bursts of intense activity separated by periods of rest. Great for building endurance and strength.',
    capacity: '8 participants',
    currentBookings: 3,
    creditCost: 4,
    location: 'Training Room 2',
    category: 'Strength',
    isIntervalSession: true,
    image: 'https://images.unsplash.com/photo-1533681904393-9ab6eee7e408?q=80&w=2070'
  },
  {
    id: 3,
    title: 'Personal Training',
    date: 'May 27, 2025',
    time: '10:00',
    duration: '45 min',
    instructor: 'Alex Williams',
    description: 'One-on-one training session tailored to your fitness goals and needs. Includes personalized workout plan and nutrition advice.',
    capacity: '1 participant',
    currentBookings: 0,
    creditCost: 5,
    location: 'Personal Training Area',
    category: 'Personal',
    isIntervalSession: false,
    image: 'https://images.unsplash.com/photo-1571388208497-71bedc66e932?q=80&w=2072'
  },
  {
    id: 4,
    title: 'Yoga Flow',
    date: 'May 28, 2025',
    time: '09:00',
    duration: '60 min',
    instructor: 'Emma Chen',
    description: 'A mindful practice focusing on breath, flexibility, and strength. Suitable for all levels from beginner to advanced.',
    capacity: '15 participants',
    currentBookings: 8,
    creditCost: 2,
    location: 'Yoga Studio',
    category: 'Mind & Body',
    isIntervalSession: false,
    image: 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?q=80&w=2070'
  }
];

// Mock bookings data
let bookings: Booking[] = [];

// Helper function to generate booking ID
const generateBookingId = (): string => {
  return 'booking_' + Math.random().toString(36).substring(2, 15);
};

/**
 * Get all available sessions
 */
export const getSessions = async (): Promise<Session[]> => {
  // Simulating API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  return sessions;
};

/**
 * Get session by ID
 */
export const getSessionById = async (sessionId: number): Promise<Session | null> => {
  // Simulating API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  const session = sessions.find(s => s.id === sessionId);
  return session || null;
};

/**
 * Book a session and process credit transaction
 */
export const bookSession = async (
  userId: string,
  sessionId: number
): Promise<BookingResponse> => {
  try {
    // Get session details
    const session = await getSessionById(sessionId);
    if (!session) {
      return { success: false, error: 'Session not found' };
    }
    
    // Check session capacity
    if (session.currentBookings >= parseInt(session.capacity.split(' ')[0])) {
      return { success: false, error: 'Session is fully booked' };
    }
    
    // Get user data
    const userDataStr = localStorage.getItem(`user_${userId}`);
    if (!userDataStr) {
      return { success: false, error: 'User not found' };
    }
    
    const userData: FitSagaUser = JSON.parse(userDataStr);
    
    // Process payment (deduct credits)
    const paymentResult = await processSessionBooking(userData, session);
    
    if (!paymentResult.success) {
      return { success: false, error: paymentResult.error || 'Failed to process payment' };
    }
    
    // Create booking record
    const booking: Booking = {
      id: generateBookingId(),
      userId,
      sessionId,
      date: new Date().toISOString(),
      status: 'confirmed',
      creditsCost: session.creditCost,
      isIntervalSession: session.isIntervalSession || false
    };
    
    // Update session bookings count
    const sessionIndex = sessions.findIndex(s => s.id === sessionId);
    if (sessionIndex !== -1) {
      sessions[sessionIndex].currentBookings += 1;
    }
    
    // Add booking to the list
    bookings.push(booking);
    
    // Update user's credits in storage
    if (paymentResult.newCreditBalance !== undefined && paymentResult.newIntervalCreditBalance !== undefined) {
      userData.credits = paymentResult.newCreditBalance;
      userData.intervalCredits = paymentResult.newIntervalCreditBalance;
      localStorage.setItem(`user_${userId}`, JSON.stringify(userData));
    }
    
    return { success: true, booking };
  } catch (error) {
    console.error('Error booking session:', error);
    return { success: false, error: 'An unexpected error occurred' };
  }
};

/**
 * Get user's bookings
 */
export const getUserBookings = async (userId: string): Promise<Booking[]> => {
  // Simulating API call delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  return bookings.filter(b => b.userId === userId);
};

/**
 * Cancel a booking and process credit refund
 */
export const cancelBooking = async (
  userId: string,
  bookingId: string
): Promise<{ success: boolean, error?: string }> => {
  try {
    // Find the booking
    const bookingIndex = bookings.findIndex(b => b.id === bookingId && b.userId === userId);
    
    if (bookingIndex === -1) {
      return { success: false, error: 'Booking not found' };
    }
    
    const booking = bookings[bookingIndex];
    
    // Check if booking is already cancelled
    if (booking.status === 'cancelled') {
      return { success: false, error: 'Booking is already cancelled' };
    }
    
    // Get session details
    const session = await getSessionById(booking.sessionId);
    if (!session) {
      return { success: false, error: 'Session not found' };
    }
    
    // Get user data
    const userDataStr = localStorage.getItem(`user_${userId}`);
    if (!userDataStr) {
      return { success: false, error: 'User not found' };
    }
    
    const userData: FitSagaUser = JSON.parse(userDataStr);
    
    // Process refund (add credits back)
    const refundResult = await processSessionCancellation(userData, session);
    
    if (!refundResult.success) {
      return { success: false, error: refundResult.error || 'Failed to process refund' };
    }
    
    // Update booking status
    bookings[bookingIndex].status = 'cancelled';
    
    // Update session bookings count
    const sessionIndex = sessions.findIndex(s => s.id === booking.sessionId);
    if (sessionIndex !== -1) {
      sessions[sessionIndex].currentBookings -= 1;
    }
    
    // Update user's credits in storage
    if (refundResult.newCreditBalance !== undefined && refundResult.newIntervalCreditBalance !== undefined) {
      userData.credits = refundResult.newCreditBalance;
      userData.intervalCredits = refundResult.newIntervalCreditBalance;
      localStorage.setItem(`user_${userId}`, JSON.stringify(userData));
    }
    
    return { success: true };
  } catch (error) {
    console.error('Error cancelling booking:', error);
    return { success: false, error: 'An unexpected error occurred' };
  }
};