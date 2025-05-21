import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { 
  doc, 
  getDoc, 
  updateDoc, 
  collection, 
  addDoc, 
  query, 
  where, 
  orderBy, 
  getDocs,
  Timestamp 
} from 'firebase/firestore';
import { db } from '../../services/firebase';

// Define types for our credit data
interface Credits {
  total: number;
  intervalCredits: number;
  lastRefilled?: Date;
}

interface CreditTransaction {
  id: string;
  userId: string;
  amount: number;
  type: 'deduction' | 'addition' | 'refill' | 'expiration';
  reason: string;
  timestamp: Date;
  previousTotal: number;
  newTotal: number;
  previousIntervalCredits?: number;
  newIntervalCredits?: number;
  adjustedBy?: string;
}

interface CreditsState {
  credits: Credits;
  transactions: CreditTransaction[];
  loading: boolean;
  error: string | null;
}

// Initial state
const initialState: CreditsState = {
  credits: {
    total: 0,
    intervalCredits: 0,
  },
  transactions: [],
  loading: false,
  error: null,
};

// Async thunks
export const fetchUserCredits = createAsyncThunk(
  'credits/fetchUserCredits',
  async (userId: string, { rejectWithValue }) => {
    try {
      const userDoc = await getDoc(doc(db, 'users', userId));
      
      if (!userDoc.exists()) {
        return rejectWithValue('User not found');
      }
      
      const userData = userDoc.data();
      
      return {
        total: userData.credits || 0,
        intervalCredits: userData.intervalCredits || 0,
        lastRefilled: userData.lastRefilled ? userData.lastRefilled.toDate() : undefined,
      } as Credits;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch credits');
    }
  }
);

export const fetchCreditTransactions = createAsyncThunk(
  'credits/fetchCreditTransactions',
  async (userId: string, { rejectWithValue }) => {
    try {
      const transactionsRef = collection(db, 'creditTransactions');
      const transactionsQuery = query(
        transactionsRef,
        where('userId', '==', userId),
        orderBy('timestamp', 'desc')
      );
      
      const snapshot = await getDocs(transactionsQuery);
      
      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          userId: data.userId,
          amount: data.amount,
          type: data.type,
          reason: data.reason,
          timestamp: data.timestamp.toDate(),
          previousTotal: data.previousTotal,
          newTotal: data.newTotal,
          previousIntervalCredits: data.previousIntervalCredits,
          newIntervalCredits: data.newIntervalCredits,
          adjustedBy: data.adjustedBy,
        } as CreditTransaction;
      });
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to fetch credit transactions');
    }
  }
);

export const adjustCredits = createAsyncThunk(
  'credits/adjustCredits',
  async ({ 
    userId, 
    amount, 
    reason, 
    type,
    adjustedBy
  }: { 
    userId: string; 
    amount: number; 
    reason: string; 
    type: 'deduction' | 'addition' | 'refill' | 'expiration';
    adjustedBy?: string;
  }, { rejectWithValue }) => {
    try {
      // Get the current user data
      const userDoc = await getDoc(doc(db, 'users', userId));
      
      if (!userDoc.exists()) {
        return rejectWithValue('User not found');
      }
      
      const userData = userDoc.data();
      const currentTotal = userData.credits || 0;
      const currentIntervalCredits = userData.intervalCredits || 0;
      
      // Calculate new values
      let newTotal = currentTotal;
      let newIntervalCredits = currentIntervalCredits;
      
      if (type === 'deduction') {
        // For deductions, try to use interval credits first
        if (amount <= currentIntervalCredits) {
          newIntervalCredits -= amount;
        } else {
          const remainingAfterInterval = amount - currentIntervalCredits;
          newIntervalCredits = 0;
          newTotal = Math.max(0, currentTotal - remainingAfterInterval);
        }
      } else if (type === 'addition' || type === 'refill') {
        newTotal = currentTotal + amount;
      }
      
      // Update the user document
      await updateDoc(doc(db, 'users', userId), {
        credits: newTotal,
        intervalCredits: newIntervalCredits,
        lastUpdated: Timestamp.now(),
      });
      
      // Record the transaction
      const transactionData = {
        userId,
        amount,
        type,
        reason,
        timestamp: Timestamp.now(),
        previousTotal: currentTotal,
        newTotal,
        previousIntervalCredits: currentIntervalCredits,
        newIntervalCredits,
        adjustedBy,
      };
      
      await addDoc(collection(db, 'creditTransactions'), transactionData);
      
      // Return the updated credit state
      return {
        credits: {
          total: newTotal,
          intervalCredits: newIntervalCredits,
          lastRefilled: type === 'refill' ? new Date() : userData.lastRefilled?.toDate(),
        },
        transaction: {
          ...transactionData,
          id: 'temp-id', // This will be replaced by the actual ID when we fetch transactions
          timestamp: new Date(),
        },
      };
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to adjust credits');
    }
  }
);

// Create the slice
const creditsSlice = createSlice({
  name: 'credits',
  initialState,
  reducers: {
    clearCreditError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // fetchUserCredits actions
      .addCase(fetchUserCredits.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchUserCredits.fulfilled, (state, action) => {
        state.loading = false;
        state.credits = action.payload;
      })
      .addCase(fetchUserCredits.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      
      // fetchCreditTransactions actions
      .addCase(fetchCreditTransactions.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchCreditTransactions.fulfilled, (state, action) => {
        state.loading = false;
        state.transactions = action.payload;
      })
      .addCase(fetchCreditTransactions.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      
      // adjustCredits actions
      .addCase(adjustCredits.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(adjustCredits.fulfilled, (state, action) => {
        state.loading = false;
        state.credits = action.payload.credits;
        // Update transactions list if we have a new transaction
        if (action.payload.transaction) {
          state.transactions = [action.payload.transaction, ...state.transactions];
        }
      })
      .addCase(adjustCredits.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { clearCreditError } = creditsSlice.actions;
export default creditsSlice.reducer;