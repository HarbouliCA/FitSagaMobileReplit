/**
 * Unit tests for credits Redux slice
 */
import creditsReducer, { 
  fetchUserCredits, 
  adjustCredits,
  resetCredits,
  addCredits
} from '../../../redux/features/creditsSlice';

describe('Credits Slice', () => {
  // Define initial state for tests
  const initialState = {
    credits: {
      total: 0,
      gymCredits: 0,
      intervalCredits: 0,
      lastRefilled: null,
      nextRefillDate: null
    },
    transactions: [],
    loading: false,
    error: null,
  };

  // Test initial state handling
  test('should return the initial state', () => {
    expect(creditsReducer(undefined, { type: undefined })).toEqual(initialState);
  });

  // Fetch user credits tests
  describe('Fetch user credits', () => {
    test('should handle fetchUserCredits.pending', () => {
      const action = { type: fetchUserCredits.pending.type };
      const state = creditsReducer(initialState, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle fetchUserCredits.fulfilled', () => {
      const mockCredits = {
        total: 15,
        gymCredits: 10,
        intervalCredits: 5,
        lastRefilled: '2025-05-01T00:00:00.000Z',
        nextRefillDate: '2025-06-01T00:00:00.000Z'
      };
      
      const action = { 
        type: fetchUserCredits.fulfilled.type, 
        payload: mockCredits
      };
      
      const state = creditsReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.credits).toEqual(mockCredits);
      expect(state.error).toBe(null);
    });

    test('should handle fetchUserCredits.rejected', () => {
      const mockError = 'Failed to fetch user credits';
      
      const action = { 
        type: fetchUserCredits.rejected.type, 
        payload: mockError 
      };
      
      const state = creditsReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(mockError);
    });
  });

  // Adjust credits tests
  describe('Adjust credits', () => {
    // Start with a state that has existing credits
    const stateWithCredits = {
      ...initialState,
      credits: {
        total: 15,
        gymCredits: 10,
        intervalCredits: 5,
        lastRefilled: '2025-05-01T00:00:00.000Z',
        nextRefillDate: '2025-06-01T00:00:00.000Z'
      }
    };

    test('should handle adjustCredits.pending', () => {
      const action = { type: adjustCredits.pending.type };
      const state = creditsReducer(stateWithCredits, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle adjustCredits.fulfilled for session booking', () => {
      const mockPayload = {
        credits: {
          total: 13,
          gymCredits: 8,
          intervalCredits: 5,
          lastRefilled: '2025-05-01T00:00:00.000Z',
          nextRefillDate: '2025-06-01T00:00:00.000Z'
        },
        transaction: {
          id: 'tx123',
          amount: -2,
          type: 'session_booking',
          source: 'gymCredits',
          sessionId: 'session1',
          sessionName: 'Yoga Class',
          timestamp: '2025-05-21T15:30:00.000Z',
        }
      };
      
      const action = { 
        type: adjustCredits.fulfilled.type, 
        payload: mockPayload
      };
      
      const state = creditsReducer(stateWithCredits, action);
      
      expect(state.loading).toBe(false);
      expect(state.credits).toEqual(mockPayload.credits);
      expect(state.transactions).toEqual([mockPayload.transaction]);
      expect(state.error).toBe(null);
    });

    test('should handle adjustCredits.fulfilled for session cancellation', () => {
      // State with an existing transaction
      const stateWithTransaction = {
        ...stateWithCredits,
        transactions: [
          {
            id: 'tx123',
            amount: -2,
            type: 'session_booking',
            source: 'gymCredits',
            sessionId: 'session1',
            sessionName: 'Yoga Class',
            timestamp: '2025-05-21T15:30:00.000Z',
          }
        ]
      };
      
      const mockPayload = {
        credits: {
          total: 15,
          gymCredits: 10,
          intervalCredits: 5,
          lastRefilled: '2025-05-01T00:00:00.000Z',
          nextRefillDate: '2025-06-01T00:00:00.000Z'
        },
        transaction: {
          id: 'tx124',
          amount: 2,
          type: 'session_cancellation',
          source: 'gymCredits',
          sessionId: 'session1',
          sessionName: 'Yoga Class',
          timestamp: '2025-05-21T16:00:00.000Z',
        }
      };
      
      const action = { 
        type: adjustCredits.fulfilled.type, 
        payload: mockPayload
      };
      
      const state = creditsReducer(stateWithTransaction, action);
      
      expect(state.loading).toBe(false);
      expect(state.credits).toEqual(mockPayload.credits);
      expect(state.transactions.length).toBe(2);
      expect(state.transactions[1]).toEqual(mockPayload.transaction);
    });

    test('should handle adjustCredits.rejected', () => {
      const mockError = 'Insufficient credits';
      
      const action = { 
        type: adjustCredits.rejected.type, 
        payload: mockError 
      };
      
      const state = creditsReducer(stateWithCredits, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(mockError);
      // Credits should remain unchanged
      expect(state.credits).toEqual(stateWithCredits.credits);
    });
  });

  // Add credits tests
  describe('Add credits', () => {
    test('should handle addCredits.pending', () => {
      const action = { type: addCredits.pending.type };
      const state = creditsReducer(initialState, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle addCredits.fulfilled', () => {
      const mockPayload = {
        credits: {
          total: 10,
          gymCredits: 10,
          intervalCredits: 0,
          lastRefilled: '2025-05-21T00:00:00.000Z',
          nextRefillDate: '2025-06-01T00:00:00.000Z'
        },
        transaction: {
          id: 'tx125',
          amount: 10,
          type: 'admin_adjustment',
          source: 'gymCredits',
          adminId: 'admin1',
          adminName: 'Admin User',
          timestamp: '2025-05-21T17:00:00.000Z',
        }
      };
      
      const action = { 
        type: addCredits.fulfilled.type, 
        payload: mockPayload
      };
      
      const state = creditsReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.credits).toEqual(mockPayload.credits);
      expect(state.transactions).toEqual([mockPayload.transaction]);
      expect(state.error).toBe(null);
    });

    test('should handle addCredits.rejected', () => {
      const mockError = 'Failed to add credits';
      
      const action = { 
        type: addCredits.rejected.type, 
        payload: mockError 
      };
      
      const state = creditsReducer(initialState, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(mockError);
    });
  });

  // Reset credits tests
  describe('Reset credits', () => {
    // State with existing credits and transactions
    const stateWithHistory = {
      credits: {
        total: 5,
        gymCredits: 3,
        intervalCredits: 2,
        lastRefilled: '2025-04-01T00:00:00.000Z',
        nextRefillDate: '2025-05-01T00:00:00.000Z'
      },
      transactions: [
        {
          id: 'tx123',
          amount: -2,
          type: 'session_booking',
          source: 'gymCredits',
          sessionId: 'session1',
          timestamp: '2025-04-15T15:30:00.000Z',
        }
      ],
      loading: false,
      error: null,
    };

    test('should handle resetCredits.pending', () => {
      const action = { type: resetCredits.pending.type };
      const state = creditsReducer(stateWithHistory, action);
      
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });

    test('should handle resetCredits.fulfilled for monthly reset', () => {
      const mockPayload = {
        credits: {
          total: 12,
          gymCredits: 10,
          intervalCredits: 2, // Interval credits carried over
          lastRefilled: '2025-05-01T00:00:00.000Z',
          nextRefillDate: '2025-06-01T00:00:00.000Z'
        },
        transaction: {
          id: 'tx126',
          amount: 10,
          type: 'monthly_reset',
          source: 'gymCredits',
          timestamp: '2025-05-01T00:00:00.000Z',
        }
      };
      
      const action = { 
        type: resetCredits.fulfilled.type, 
        payload: mockPayload
      };
      
      const state = creditsReducer(stateWithHistory, action);
      
      expect(state.loading).toBe(false);
      expect(state.credits).toEqual(mockPayload.credits);
      expect(state.transactions.length).toBe(2);
      expect(state.transactions[1]).toEqual(mockPayload.transaction);
      expect(state.error).toBe(null);
    });

    test('should handle resetCredits.rejected', () => {
      const mockError = 'Failed to reset credits';
      
      const action = { 
        type: resetCredits.rejected.type, 
        payload: mockError 
      };
      
      const state = creditsReducer(stateWithHistory, action);
      
      expect(state.loading).toBe(false);
      expect(state.error).toBe(mockError);
      // Credits should remain unchanged
      expect(state.credits).toEqual(stateWithHistory.credits);
    });
  });
});