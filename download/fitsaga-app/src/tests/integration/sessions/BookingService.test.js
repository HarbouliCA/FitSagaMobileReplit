/**
 * Integration tests for the Session Booking Service
 * Tests the booking flow including credit deduction
 */
import { 
  bookSession, 
  cancelBooking,
  fetchUserBookings,
  fetchSessionDetails
} from '../../../services/sessionService';
import { getUserCredits } from '../../../services/creditService';
import { mockFirebase } from '../../mocks/firebaseMock';

// Mock the Firebase module
jest.mock('@react-native-firebase/app', () => mockFirebase);
jest.mock('@react-native-firebase/firestore', () => mockFirebase.firestore);

describe('Booking Service', () => {
  // Mock user ID and session ID for tests
  const userId = 'test-user-id';
  const sessionId = 'session-2'; // HIIT Workout session from mock data
  
  // Track initial credits for verification
  let initialGymCredits = 0;
  let initialIntervalCredits = 0;
  
  // Setup: capture initial credit state
  beforeAll(async () => {
    const credits = await getUserCredits(userId);
    initialGymCredits = credits.gymCredits;
    initialIntervalCredits = credits.intervalCredits;
  });
  
  describe('Session Booking', () => {
    test('books a session successfully', async () => {
      // Fetch session details first
      const session = await fetchSessionDetails(sessionId);
      
      // Book the session
      const result = await bookSession(userId, sessionId);
      
      // Verify booking result
      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.bookingId).toBeDefined();
      expect(result.updatedCredits).toBeDefined();
      
      // Verify credit deduction
      const { gymCredits, intervalCredits } = result.updatedCredits;
      
      // Credit deduction logic should prioritize interval credits first
      if (initialIntervalCredits >= session.creditCost) {
        expect(intervalCredits).toBe(initialIntervalCredits - session.creditCost);
        expect(gymCredits).toBe(initialGymCredits);
      } else {
        // If interval credits insufficient, should use gym credits
        const remainingCost = session.creditCost - initialIntervalCredits;
        expect(intervalCredits).toBe(0);
        expect(gymCredits).toBe(initialGymCredits - remainingCost);
      }
      
      // Verify booking is in user's bookings
      const userBookings = await fetchUserBookings(userId);
      const foundBooking = userBookings.find(booking => booking.sessionId === sessionId);
      expect(foundBooking).toBeDefined();
      expect(foundBooking.id).toBe(result.bookingId);
    });
    
    test('fails to book session with insufficient credits', async () => {
      // Set up a mock session with very high credit cost
      const expensiveSessionId = 'session-3'; // not in our mock data
      
      // Add session to mock DB for testing
      mockFirebase.firestore()._collections.sessions['session-3'] = {
        title: 'Premium Training',
        activityType: 'personal',
        instructorId: 'instructor-id',
        instructorName: 'Jane Instructor',
        startTime: new Date('2025-05-23T10:00:00'),
        endTime: new Date('2025-05-23T11:00:00'),
        capacity: 1,
        enrolledCount: 0,
        creditCost: 100, // Very high cost
        location: 'VIP Room',
      };
      
      // Attempt to book expensive session
      try {
        await bookSession(userId, expensiveSessionId);
        fail('Should have thrown insufficient credits error');
      } catch (error) {
        expect(error.message).toContain('Insufficient credits');
      }
      
      // Verify credits remained unchanged
      const currentCredits = await getUserCredits(userId);
      expect(currentCredits.gymCredits).toBe(initialGymCredits);
      expect(currentCredits.intervalCredits).toBe(initialIntervalCredits);
    });
    
    test('fails to book full session', async () => {
      // Set up a mock full session
      const fullSessionId = 'session-4'; // not in our mock data
      
      // Add session to mock DB for testing
      mockFirebase.firestore()._collections.sessions['session-4'] = {
        title: 'Full Session',
        activityType: 'yoga',
        instructorId: 'instructor-id',
        instructorName: 'Jane Instructor',
        startTime: new Date('2025-05-24T10:00:00'),
        endTime: new Date('2025-05-24T11:00:00'),
        capacity: 10,
        enrolledCount: 10, // At capacity
        creditCost: 2,
        location: 'Studio B',
      };
      
      // Attempt to book full session
      try {
        await bookSession(userId, fullSessionId);
        fail('Should have thrown session full error');
      } catch (error) {
        expect(error.message).toContain('Session is full');
      }
      
      // Verify credits remained unchanged
      const currentCredits = await getUserCredits(userId);
      expect(currentCredits.gymCredits).toBe(initialGymCredits);
      expect(currentCredits.intervalCredits).toBe(initialIntervalCredits);
    });
  });
  
  describe('Booking Cancellation', () => {
    // We'll create a booking and then cancel it
    let bookingId;
    let sessionCreditCost;
    
    // Setup: create a booking to cancel
    beforeAll(async () => {
      // Use session-1 from mock data
      const tempSessionId = 'session-1';
      const session = await fetchSessionDetails(tempSessionId);
      sessionCreditCost = session.creditCost;
      
      // Store initial credits for later comparison
      const credits = await getUserCredits(userId);
      initialGymCredits = credits.gymCredits;
      initialIntervalCredits = credits.intervalCredits;
      
      // Book the session
      const result = await bookSession(userId, tempSessionId);
      bookingId = result.bookingId;
      
      // Verify booking was created
      expect(bookingId).toBeDefined();
    });
    
    test('cancels booking and refunds credits', async () => {
      // Verify credits were deducted after booking
      const creditsAfterBooking = await getUserCredits(userId);
      
      // Cancel the booking
      const result = await cancelBooking(userId, bookingId);
      
      // Verify cancellation result
      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.updatedCredits).toBeDefined();
      
      // Verify credit refund
      const { gymCredits, intervalCredits } = result.updatedCredits;
      expect(gymCredits + intervalCredits).toBe(
        creditsAfterBooking.gymCredits + creditsAfterBooking.intervalCredits + sessionCreditCost
      );
      
      // Verify booking is removed from user's bookings
      const userBookings = await fetchUserBookings(userId);
      const foundBooking = userBookings.find(booking => booking.id === bookingId);
      expect(foundBooking).toBeUndefined();
    });
    
    test('fails to cancel non-existent booking', async () => {
      const nonExistentBookingId = 'non-existent-booking';
      
      try {
        await cancelBooking(userId, nonExistentBookingId);
        fail('Should have thrown booking not found error');
      } catch (error) {
        expect(error.message).toContain('Booking not found');
      }
    });
    
    test('adds cancellation fee for late cancellation', async () => {
      // Create a new booking
      const tempSessionId = 'session-2';
      const session = await fetchSessionDetails(tempSessionId);
      
      // Get current credits
      const beforeBookingCredits = await getUserCredits(userId);
      
      // Book the session
      const bookResult = await bookSession(userId, tempSessionId);
      const lateBookingId = bookResult.bookingId;
      
      // Modify booking timestamp to be within cancellation window (mocking late cancellation)
      const bookingRef = mockFirebase.firestore().collection('bookings').doc(lateBookingId);
      const booking = (await bookingRef.get()).data();
      
      // Set booking date to be older (24+ hours ago)
      booking.bookingDate = new Date(Date.now() - 25 * 60 * 60 * 1000);
      await bookingRef.set(booking);
      
      // Set session start time to be very soon (within cancellation window)
      session.startTime = new Date(Date.now() + 60 * 60 * 1000); // 1 hour from now
      await mockFirebase.firestore().collection('sessions').doc(tempSessionId).set(session);
      
      // Cancel the booking (should incur cancellation fee)
      const result = await cancelBooking(userId, lateBookingId, true);
      
      // Verify cancellation result
      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.cancellationFee).toBeGreaterThan(0);
      
      // Verify partial refund (credit cost minus cancellation fee)
      const afterCancelCredits = await getUserCredits(userId);
      const totalCreditsAfterCancel = afterCancelCredits.gymCredits + afterCancelCredits.intervalCredits;
      const totalCreditsBeforeBooking = beforeBookingCredits.gymCredits + beforeBookingCredits.intervalCredits;
      
      // Should get back less than full credit cost
      expect(totalCreditsAfterCancel).toBeLessThan(totalCreditsBeforeBooking);
      // But should get back more than 0 (partial refund)
      expect(totalCreditsAfterCancel).toBeGreaterThan(
        totalCreditsBeforeBooking - session.creditCost
      );
    });
  });
  
  describe('User Bookings', () => {
    test('returns all user bookings', async () => {
      const bookings = await fetchUserBookings(userId);
      
      expect(bookings).toBeDefined();
      expect(Array.isArray(bookings)).toBe(true);
      
      // Check booking structure
      if (bookings.length > 0) {
        const booking = bookings[0];
        expect(booking.id).toBeDefined();
        expect(booking.userId).toBe(userId);
        expect(booking.sessionId).toBeDefined();
        expect(booking.sessionTitle).toBeDefined();
        expect(booking.startTime).toBeDefined();
        expect(booking.endTime).toBeDefined();
        expect(booking.bookingDate).toBeDefined();
      }
    });
    
    test('filters bookings by status', async () => {
      // Upcoming bookings
      const upcomingBookings = await fetchUserBookings(userId, 'upcoming');
      
      expect(upcomingBookings).toBeDefined();
      expect(Array.isArray(upcomingBookings)).toBe(true);
      
      // All upcoming bookings should have start time in the future
      const now = new Date();
      upcomingBookings.forEach(booking => {
        expect(new Date(booking.startTime).getTime()).toBeGreaterThan(now.getTime());
      });
      
      // Past bookings
      const pastBookings = await fetchUserBookings(userId, 'past');
      
      expect(pastBookings).toBeDefined();
      expect(Array.isArray(pastBookings)).toBe(true);
      
      // All past bookings should have end time in the past
      pastBookings.forEach(booking => {
        expect(new Date(booking.endTime).getTime()).toBeLessThan(now.getTime());
      });
    });
  });
});