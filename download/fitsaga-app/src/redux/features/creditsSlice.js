import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { db } from '../../services/firebase';

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

// Fetch user credits action
export const fetchUserCredits = createAsyncThunk(
  'credits/fetchUserCredits',
  async (userId, { rejectWithValue }) => {
    try {
      const userDoc = await db().collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw new Error('User not found');
      }
      
      const userData = userDoc.data();
      
      if (!userData.credits) {
        throw new Error('User credits data not found');
      }
      
      // Calculate total credits
      const total = (userData.credits.gymCredits || 0) + (userData.credits.intervalCredits || 0);
      
      return {
        total,
        gymCredits: userData.credits.gymCredits || 0,
        intervalCredits: userData.credits.intervalCredits || 0,
        lastRefilled: userData.credits.lastRefilled || null,
        nextRefillDate: userData.credits.nextRefillDate || null
      };
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Adjust credits action (deduction or addition)
export const adjustCredits = createAsyncThunk(
  'credits/adjustCredits',
  async ({ userId, amount, type, metadata }, { rejectWithValue, getState }) => {
    try {
      // Run transaction to ensure credit operations are atomic
      const result = await db().runTransaction(async (transaction) => {
        const userRef = db().collection('users').doc(userId);
        const userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw new Error('User not found');
        }
        
        const userData = userDoc.data();
        
        if (!userData.credits) {
          throw new Error('User credits data not found');
        }
        
        let gymCredits = userData.credits.gymCredits || 0;
        let intervalCredits = userData.credits.intervalCredits || 0;
        
        // Check if sufficient credits for deduction
        if (amount < 0) {
          const totalCredits = gymCredits + intervalCredits;
          if (totalCredits < Math.abs(amount)) {
            throw new Error('Insufficient credits');
          }
          
          // Prioritize using interval credits first
          if (intervalCredits >= Math.abs(amount)) {
            intervalCredits += amount; // amount is negative
          } else {
            // Use all interval credits and then gym credits
            const remainingAmount = amount + intervalCredits; // amount is negative
            gymCredits += remainingAmount;
            intervalCredits = 0;
          }
        } else {
          // For credit addition, add to gym credits by default unless specified
          if (metadata?.creditsType === 'intervalCredits') {
            intervalCredits += amount;
          } else {
            gymCredits += amount;
          }
        }
        
        // Update user credits
        transaction.update(userRef, {
          'credits.gymCredits': gymCredits,
          'credits.intervalCredits': intervalCredits,
          'credits.lastUpdated': new Date().toISOString()
        });
        
        // Create transaction record
        const transactionRef = db().collection('creditTransactions').doc();
        const transactionData = {
          userId,
          amount,
          type,
          ...metadata,
          timestamp: new Date().toISOString(),
        };
        
        transaction.set(transactionRef, transactionData);
        
        return {
          credits: {
            total: gymCredits + intervalCredits,
            gymCredits,
            intervalCredits,
            lastRefilled: userData.credits.lastRefilled,
            nextRefillDate: userData.credits.nextRefillDate
          },
          transaction: {
            id: transactionRef.id,
            ...transactionData
          }
        };
      });
      
      return result;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Add credits (admin function)
export const addCredits = createAsyncThunk(
  'credits/addCredits',
  async ({ userId, amount, creditsType, adminId, adminName }, { rejectWithValue }) => {
    try {
      return await adjustCredits({
        userId,
        amount, // Positive amount for addition
        type: 'admin_adjustment',
        metadata: {
          creditsType,
          adminId,
          adminName,
          note: 'Admin credit adjustment'
        }
      }).unwrap();
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Reset credits (monthly refresh)
export const resetCredits = createAsyncThunk(
  'credits/resetCredits',
  async ({ userId, newGymCredits }, { rejectWithValue }) => {
    try {
      // Run transaction to reset credits
      const result = await db().runTransaction(async (transaction) => {
        const userRef = db().collection('users').doc(userId);
        const userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw new Error('User not found');
        }
        
        const userData = userDoc.data();
        
        if (!userData.credits) {
          throw new Error('User credits data not found');
        }
        
        // Keep interval credits, reset gym credits
        const intervalCredits = userData.credits.intervalCredits || 0;
        const gymCredits = newGymCredits;
        const now = new Date();
        const nextMonth = new Date(now);
        nextMonth.setMonth(nextMonth.getMonth() + 1);
        
        // Update user credits
        transaction.update(userRef, {
          'credits.gymCredits': gymCredits,
          'credits.intervalCredits': intervalCredits,
          'credits.lastRefilled': now.toISOString(),
          'credits.nextRefillDate': nextMonth.toISOString()
        });
        
        // Create transaction record
        const transactionRef = db().collection('creditTransactions').doc();
        const transactionData = {
          userId,
          amount: newGymCredits,
          type: 'monthly_reset',
          source: 'gymCredits',
          timestamp: now.toISOString(),
        };
        
        transaction.set(transactionRef, transactionData);
        
        return {
          credits: {
            total: gymCredits + intervalCredits,
            gymCredits,
            intervalCredits,
            lastRefilled: now.toISOString(),
            nextRefillDate: nextMonth.toISOString()
          },
          transaction: {
            id: transactionRef.id,
            ...transactionData
          }
        };
      });
      
      return result;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

// Credits slice
const creditsSlice = createSlice({
  name: 'credits',
  initialState,
  reducers: {
    // Clear error
    clearError: (state) => {
      state.error = null;
    }
  },
  extraReducers: (builder) => {
    // Fetch user credits cases
    builder.addCase(fetchUserCredits.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(fetchUserCredits.fulfilled, (state, action) => {
      state.credits = action.payload;
      state.loading = false;
      state.error = null;
    });
    builder.addCase(fetchUserCredits.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
    
    // Adjust credits cases
    builder.addCase(adjustCredits.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(adjustCredits.fulfilled, (state, action) => {
      state.credits = action.payload.credits;
      state.transactions = [action.payload.transaction, ...state.transactions];
      state.loading = false;
      state.error = null;
    });
    builder.addCase(adjustCredits.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
    
    // Add credits cases
    builder.addCase(addCredits.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(addCredits.fulfilled, (state, action) => {
      state.credits = action.payload.credits;
      state.transactions = [action.payload.transaction, ...state.transactions];
      state.loading = false;
      state.error = null;
    });
    builder.addCase(addCredits.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
    
    // Reset credits cases
    builder.addCase(resetCredits.pending, (state) => {
      state.loading = true;
      state.error = null;
    });
    builder.addCase(resetCredits.fulfilled, (state, action) => {
      state.credits = action.payload.credits;
      state.transactions = [action.payload.transaction, ...state.transactions];
      state.loading = false;
      state.error = null;
    });
    builder.addCase(resetCredits.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload;
    });
  },
});

export const { clearError } = creditsSlice.actions;

export default creditsSlice.reducer;