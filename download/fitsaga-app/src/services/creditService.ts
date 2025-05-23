// Credit service for handling credit transactions and operations

import { FitSagaUser } from './authService';
import { Session } from './sessionService';

export interface Transaction {
  id: string;
  userId: string;
  date: string;
  description: string;
  amount: number;
  type: 'addition' | 'deduction';
  category: 'session' | 'interval' | 'admin' | 'monthly';
  relatedSessionId?: number;
  status: 'pending' | 'completed' | 'failed' | 'cancelled';
}

interface CreditResponse {
  success: boolean;
  error?: string;
  newCreditBalance?: number;
  newIntervalCreditBalance?: number;
  transaction?: Transaction;
}

// Helper function to create a transaction ID
const generateTransactionId = (): string => {
  return 'txn_' + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
};

// Helper function to get current date in ISO format
const getCurrentDate = (): string => {
  return new Date().toISOString();
};

/**
 * Process a session booking by deducting credits
 */
export const processSessionBooking = async (
  user: FitSagaUser,
  session: Session
): Promise<CreditResponse> => {
  try {
    // Check which type of credits to use
    const isIntervalSession = session.isIntervalSession === true;
    const creditsToDeduct = session.creditCost;
    
    // Check if user has enough credits
    if (isIntervalSession) {
      if (user.intervalCredits < creditsToDeduct) {
        return {
          success: false,
          error: 'Not enough interval credits'
        };
      }
    } else {
      if (user.credits < creditsToDeduct) {
        return {
          success: false,
          error: 'Not enough credits'
        };
      }
    }
    
    // Create the transaction
    const transaction: Transaction = {
      id: generateTransactionId(),
      userId: user.uid,
      date: getCurrentDate(),
      description: `${session.title} - ${session.isIntervalSession ? 'Interval' : 'Regular'} Session`,
      amount: -creditsToDeduct,
      type: 'deduction',
      category: isIntervalSession ? 'interval' : 'session',
      relatedSessionId: session.id,
      status: 'completed'
    };
    
    // Update user's credit balance
    let newCredits = user.credits;
    let newIntervalCredits = user.intervalCredits;
    
    if (isIntervalSession) {
      newIntervalCredits -= creditsToDeduct;
    } else {
      newCredits -= creditsToDeduct;
    }
    
    // In a real app, this would update Firebase
    // For now, we'll just return the new balances
    
    return {
      success: true,
      newCreditBalance: newCredits,
      newIntervalCreditBalance: newIntervalCredits,
      transaction
    };
  } catch (error) {
    console.error('Error processing session booking:', error);
    return {
      success: false,
      error: 'Failed to process transaction'
    };
  }
};

/**
 * Process a session cancellation by refunding credits
 */
export const processSessionCancellation = async (
  user: FitSagaUser,
  session: Session
): Promise<CreditResponse> => {
  try {
    // Check which type of credits to refund
    const isIntervalSession = session.isIntervalSession === true;
    const creditsToRefund = session.creditCost;
    
    // Create the transaction
    const transaction: Transaction = {
      id: generateTransactionId(),
      userId: user.uid,
      date: getCurrentDate(),
      description: `Cancellation Refund: ${session.title}`,
      amount: creditsToRefund,
      type: 'addition',
      category: isIntervalSession ? 'interval' : 'session',
      relatedSessionId: session.id,
      status: 'completed'
    };
    
    // Update user's credit balance
    let newCredits = user.credits;
    let newIntervalCredits = user.intervalCredits;
    
    if (isIntervalSession) {
      newIntervalCredits += creditsToRefund;
    } else {
      newCredits += creditsToRefund;
    }
    
    // In a real app, this would update Firebase
    // For now, we'll just return the new balances
    
    return {
      success: true,
      newCreditBalance: newCredits,
      newIntervalCreditBalance: newIntervalCredits,
      transaction
    };
  } catch (error) {
    console.error('Error processing session cancellation:', error);
    return {
      success: false,
      error: 'Failed to process refund'
    };
  }
};

/**
 * Add credits to user account (can be used by admin)
 */
export const addCredits = async (
  user: FitSagaUser,
  amount: number,
  isIntervalCredits: boolean = false,
  description: string = 'Admin credit adjustment'
): Promise<CreditResponse> => {
  try {
    if (amount <= 0) {
      return {
        success: false,
        error: 'Credit amount must be positive'
      };
    }
    
    // Create the transaction
    const transaction: Transaction = {
      id: generateTransactionId(),
      userId: user.uid,
      date: getCurrentDate(),
      description,
      amount,
      type: 'addition',
      category: 'admin',
      status: 'completed'
    };
    
    // Update user's credit balance
    let newCredits = user.credits;
    let newIntervalCredits = user.intervalCredits;
    
    if (isIntervalCredits) {
      newIntervalCredits += amount;
    } else {
      newCredits += amount;
    }
    
    // In a real app, this would update Firebase
    // For now, we'll just return the new balances
    
    return {
      success: true,
      newCreditBalance: newCredits,
      newIntervalCreditBalance: newIntervalCredits,
      transaction
    };
  } catch (error) {
    console.error('Error adding credits:', error);
    return {
      success: false,
      error: 'Failed to add credits'
    };
  }
};

/**
 * Process monthly credit refill
 */
export const processMonthlyCredits = async (
  user: FitSagaUser,
  regularCredits: number = 20,
  intervalCredits: number = 5
): Promise<CreditResponse> => {
  try {
    // Create transactions for both types of credits
    const regularTransaction: Transaction = {
      id: generateTransactionId(),
      userId: user.uid,
      date: getCurrentDate(),
      description: 'Monthly Regular Credits',
      amount: regularCredits,
      type: 'addition',
      category: 'monthly',
      status: 'completed'
    };
    
    const intervalTransaction: Transaction = {
      id: generateTransactionId(),
      userId: user.uid,
      date: getCurrentDate(),
      description: 'Monthly Interval Credits',
      amount: intervalCredits,
      type: 'addition',
      category: 'monthly',
      status: 'completed'
    };
    
    // Update user's credit balances
    const newCredits = user.credits + regularCredits;
    const newIntervalCredits = user.intervalCredits + intervalCredits;
    
    // In a real app, this would update Firebase and store both transactions
    // For now, we'll just return the new balances and one transaction
    
    return {
      success: true,
      newCreditBalance: newCredits,
      newIntervalCreditBalance: newIntervalCredits,
      transaction: regularTransaction // Just returning one for simplicity
    };
  } catch (error) {
    console.error('Error processing monthly credits:', error);
    return {
      success: false,
      error: 'Failed to process monthly credits'
    };
  }
};

/**
 * Get user's transaction history
 */
export const getUserTransactions = async (userId: string): Promise<Transaction[]> => {
  // Mock transaction data
  // In a real app, this would fetch from Firebase
  const transactions: Transaction[] = [
    {
      id: 'txn_1',
      userId,
      date: new Date(2025, 4, 20).toISOString(),
      description: 'HIIT Training Session',
      amount: -3,
      type: 'deduction',
      category: 'session',
      relatedSessionId: 1,
      status: 'completed'
    },
    {
      id: 'txn_2',
      userId,
      date: new Date(2025, 4, 18).toISOString(),
      description: 'Personal Training Session',
      amount: -5,
      type: 'deduction',
      category: 'session',
      relatedSessionId: 2,
      status: 'completed'
    },
    {
      id: 'txn_3',
      userId,
      date: new Date(2025, 4, 15).toISOString(),
      description: 'Monthly Credit Refill',
      amount: 20,
      type: 'addition',
      category: 'monthly',
      status: 'completed'
    },
    {
      id: 'txn_4',
      userId,
      date: new Date(2025, 4, 15).toISOString(),
      description: 'Monthly Interval Credit Refill',
      amount: 5,
      type: 'addition',
      category: 'monthly',
      status: 'completed'
    },
    {
      id: 'txn_5',
      userId,
      date: new Date(2025, 4, 10).toISOString(),
      description: 'Group Fitness Class',
      amount: -2,
      type: 'deduction',
      category: 'session',
      relatedSessionId: 3,
      status: 'completed'
    },
    {
      id: 'txn_6',
      userId,
      date: new Date(2025, 4, 5).toISOString(),
      description: 'Admin Credit Adjustment',
      amount: 5,
      type: 'addition',
      category: 'admin',
      status: 'completed'
    }
  ];
  
  return transactions;
};