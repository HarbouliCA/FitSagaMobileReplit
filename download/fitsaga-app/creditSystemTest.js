/**
 * Tests for the Credit System in FitSAGA app
 * Tests credit allocation, deduction, and refill functionality
 */

// Define credit types and operations
const CREDIT_TYPES = {
  GYM: 'gym',
  INTERVAL: 'interval'
};

const CREDIT_OPERATIONS = {
  ADD: 'add',
  DEDUCT: 'deduct',
  REFILL: 'refill'
};

// Mock user data with credits
let userData = {
  'client-1': {
    id: 'client-1',
    name: 'John Doe',
    email: 'john@example.com',
    membershipType: 'premium',
    credits: {
      gymCredits: 10,
      intervalCredits: 5,
      lastRefilled: new Date('2025-05-01'),
      nextRefillDate: new Date('2025-06-01')
    }
  },
  'client-2': {
    id: 'client-2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    membershipType: 'standard',
    credits: {
      gymCredits: 5,
      intervalCredits: 2,
      lastRefilled: new Date('2025-05-05'),
      nextRefillDate: new Date('2025-06-05')
    }
  }
};

// Mock membership plans with refill amounts
const membershipPlans = {
  'standard': {
    monthlyGymCredits: 5,
    monthlyIntervalCredits: 2,
    price: 29.99
  },
  'premium': {
    monthlyGymCredits: 10,
    monthlyIntervalCredits: 5,
    price: 49.99
  },
  'unlimited': {
    monthlyGymCredits: 30,
    monthlyIntervalCredits: 15,
    price: 99.99
  }
};

// Credit transaction history
let creditTransactions = [
  {
    userId: 'client-1',
    creditType: CREDIT_TYPES.GYM,
    amount: 10,
    operation: CREDIT_OPERATIONS.REFILL,
    timestamp: new Date('2025-05-01'),
    reason: 'Monthly refill',
    adminId: null
  },
  {
    userId: 'client-1',
    creditType: CREDIT_TYPES.INTERVAL,
    amount: 5,
    operation: CREDIT_OPERATIONS.REFILL,
    timestamp: new Date('2025-05-01'),
    reason: 'Monthly refill',
    adminId: null
  },
  {
    userId: 'client-2',
    creditType: CREDIT_TYPES.GYM,
    amount: 5,
    operation: CREDIT_OPERATIONS.REFILL,
    timestamp: new Date('2025-05-05'),
    reason: 'Monthly refill',
    adminId: null
  },
  {
    userId: 'client-2',
    creditType: CREDIT_TYPES.INTERVAL,
    amount: 2,
    operation: CREDIT_OPERATIONS.REFILL,
    timestamp: new Date('2025-05-05'),
    reason: 'Monthly refill',
    adminId: null
  }
];

// Credit system utilities
const creditUtils = {
  // Get user's current credit balance
  getUserCredits: (userId) => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    return {
      gymCredits: user.credits.gymCredits,
      intervalCredits: user.credits.intervalCredits,
      lastRefilled: user.credits.lastRefilled,
      nextRefillDate: user.credits.nextRefillDate
    };
  },
  
  // Add credits to user account (admin operation)
  addCredits: (userId, creditType, amount, adminId, reason = 'Manual addition') => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    if (amount <= 0) {
      throw new Error('Credit amount must be positive');
    }
    
    // Update user credits
    if (creditType === CREDIT_TYPES.GYM) {
      user.credits.gymCredits += amount;
    } else if (creditType === CREDIT_TYPES.INTERVAL) {
      user.credits.intervalCredits += amount;
    } else {
      throw new Error('Invalid credit type');
    }
    
    // Record transaction
    const transaction = {
      userId,
      creditType,
      amount,
      operation: CREDIT_OPERATIONS.ADD,
      timestamp: new Date(),
      reason,
      adminId
    };
    
    creditTransactions.push(transaction);
    
    return {
      success: true,
      updatedCredits: creditUtils.getUserCredits(userId),
      transaction
    };
  },
  
  // Deduct credits from user account (used when booking sessions)
  deductCredits: (userId, creditType, amount, reason = 'Session booking') => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    if (amount <= 0) {
      throw new Error('Credit amount must be positive');
    }
    
    // Check if user has enough credits
    let hasEnoughCredits = false;
    
    if (creditType === CREDIT_TYPES.GYM) {
      hasEnoughCredits = user.credits.gymCredits >= amount;
    } else if (creditType === CREDIT_TYPES.INTERVAL) {
      hasEnoughCredits = user.credits.intervalCredits >= amount;
    } else {
      throw new Error('Invalid credit type');
    }
    
    if (!hasEnoughCredits) {
      throw new Error(`Insufficient ${creditType} credits`);
    }
    
    // Deduct credits
    if (creditType === CREDIT_TYPES.GYM) {
      user.credits.gymCredits -= amount;
    } else if (creditType === CREDIT_TYPES.INTERVAL) {
      user.credits.intervalCredits -= amount;
    }
    
    // Record transaction
    const transaction = {
      userId,
      creditType,
      amount,
      operation: CREDIT_OPERATIONS.DEDUCT,
      timestamp: new Date(),
      reason,
      adminId: null
    };
    
    creditTransactions.push(transaction);
    
    return {
      success: true,
      updatedCredits: creditUtils.getUserCredits(userId),
      transaction
    };
  },
  
  // Refill credits based on membership plan
  refillCredits: (userId) => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    const plan = membershipPlans[user.membershipType];
    if (!plan) {
      throw new Error('Invalid membership plan');
    }
    
    // Add credits based on membership plan
    user.credits.gymCredits += plan.monthlyGymCredits;
    user.credits.intervalCredits += plan.monthlyIntervalCredits;
    
    // Update refill dates
    const now = new Date();
    user.credits.lastRefilled = now;
    
    // Set next refill date to one month from now
    const nextRefill = new Date(now);
    nextRefill.setMonth(nextRefill.getMonth() + 1);
    user.credits.nextRefillDate = nextRefill;
    
    // Record transactions
    const gymTransaction = {
      userId,
      creditType: CREDIT_TYPES.GYM,
      amount: plan.monthlyGymCredits,
      operation: CREDIT_OPERATIONS.REFILL,
      timestamp: now,
      reason: 'Monthly refill',
      adminId: null
    };
    
    const intervalTransaction = {
      userId,
      creditType: CREDIT_TYPES.INTERVAL,
      amount: plan.monthlyIntervalCredits,
      operation: CREDIT_OPERATIONS.REFILL,
      timestamp: now,
      reason: 'Monthly refill',
      adminId: null
    };
    
    creditTransactions.push(gymTransaction, intervalTransaction);
    
    return {
      success: true,
      updatedCredits: creditUtils.getUserCredits(userId),
      transactions: [gymTransaction, intervalTransaction]
    };
  },
  
  // Get user's credit transaction history
  getUserTransactions: (userId, options = {}) => {
    const { creditType, operation, limit = 10 } = options;
    
    // Filter transactions by user ID
    let filteredTransactions = creditTransactions.filter(
      transaction => transaction.userId === userId
    );
    
    // Additional filtering
    if (creditType) {
      filteredTransactions = filteredTransactions.filter(
        transaction => transaction.creditType === creditType
      );
    }
    
    if (operation) {
      filteredTransactions = filteredTransactions.filter(
        transaction => transaction.operation === operation
      );
    }
    
    // Sort by timestamp (newest first)
    filteredTransactions.sort((a, b) => b.timestamp - a.timestamp);
    
    // Apply limit
    return filteredTransactions.slice(0, limit);
  },
  
  // Check if user needs to use gym vs interval credits
  getCreditTypeForActivity: (activityType) => {
    // Group activities requiring interval credits
    const intervalActivities = ['yoga', 'hiit', 'pilates', 'cycling', 'zumba', 'boxing'];
    
    // Gym credits for general gym access and other activities
    return intervalActivities.includes(activityType) ? 
      CREDIT_TYPES.INTERVAL : CREDIT_TYPES.GYM;
  },
  
  // Calculate credit cost based on activity and duration
  calculateCreditCost: (activityType, durationMinutes) => {
    const creditType = creditUtils.getCreditTypeForActivity(activityType);
    
    let cost = 1; // Base cost
    
    // Adjust cost based on duration
    if (durationMinutes > 60) {
      cost = Math.ceil(durationMinutes / 60);
    }
    
    // Premium activities may cost more
    const premiumActivities = ['yoga', 'pilates', 'personal-training'];
    if (premiumActivities.includes(activityType)) {
      cost += 1;
    }
    
    return {
      creditType,
      cost
    };
  }
};

// Run Credit System Tests
console.log("Running FitSAGA Credit System Tests:");

// Test credit balance retrieval
console.log("\nTest: Credit Balance");
const userId = 'client-1';
const userCredits = creditUtils.getUserCredits(userId);

console.log("Get user credits:", 
  userCredits.gymCredits === 10 && userCredits.intervalCredits === 5 ? "PASS" : "FAIL");

// Test credit deduction
console.log("\nTest: Credit Deduction");
const deductResult = creditUtils.deductCredits(userId, CREDIT_TYPES.GYM, 2, 'Open gym access');

console.log("Deduct gym credits:", deductResult.success === true ? "PASS" : "FAIL");
console.log("Verify gym credits reduced:", 
  deductResult.updatedCredits.gymCredits === 8 ? "PASS" : "FAIL");
console.log("Verify interval credits unchanged:", 
  deductResult.updatedCredits.intervalCredits === 5 ? "PASS" : "FAIL");

// Test credit addition (admin operation)
console.log("\nTest: Credit Addition");
const addResult = creditUtils.addCredits(userId, CREDIT_TYPES.INTERVAL, 3, 'admin-1', 'Bonus credits');

console.log("Add interval credits:", addResult.success === true ? "PASS" : "FAIL");
console.log("Verify interval credits increased:", 
  addResult.updatedCredits.intervalCredits === 8 ? "PASS" : "FAIL");
console.log("Verify gym credits unchanged:", 
  addResult.updatedCredits.gymCredits === 8 ? "PASS" : "FAIL");

// Test insufficient credits
console.log("\nTest: Insufficient Credits");
try {
  creditUtils.deductCredits(userId, CREDIT_TYPES.GYM, 50, 'Personal training');
  console.log("Insufficient credits check: FAIL - should have thrown an error");
} catch (error) {
  console.log("Insufficient credits check:", 
    error.message === 'Insufficient gym credits' ? "PASS" : "FAIL");
}

// Test credit transaction history
console.log("\nTest: Transaction History");
const transactions = creditUtils.getUserTransactions(userId, { limit: 10 });

// At this point we should have at least 4 transactions:
// 1. Initial refill (gym credits)
// 2. Initial refill (interval credits)
// 3. Deduction of gym credits
// 4. Addition of interval credits
console.log("Get transaction history:", transactions.length >= 4 ? "PASS" : "FAIL");

// Since we're adding transactions in chronological order with newer timestamps,
// the first transaction should be newer than the second one when sorted
const isCorrectOrder = transactions.length >= 2 ? 
  (new Date(transactions[0].timestamp).getTime() >= new Date(transactions[1].timestamp).getTime()) : true;
  
console.log("Transaction ordering (newest first):", isCorrectOrder ? "PASS" : "FAIL");

// Test membership refill
console.log("\nTest: Membership Refill");
const refillResult = creditUtils.refillCredits(userId);

console.log("Monthly credit refill:", refillResult.success === true ? "PASS" : "FAIL");
console.log("Verify gym credits refilled:", 
  refillResult.updatedCredits.gymCredits === 18 ? "PASS" : "FAIL"); // 8 + 10 (premium plan)
console.log("Verify interval credits refilled:", 
  refillResult.updatedCredits.intervalCredits === 13 ? "PASS" : "FAIL"); // 8 + 5 (premium plan)
console.log("Verify next refill date updated:", 
  refillResult.updatedCredits.nextRefillDate > refillResult.updatedCredits.lastRefilled ? "PASS" : "FAIL");

// Test credit cost calculation
console.log("\nTest: Credit Cost Calculation");
const yogaCost = creditUtils.calculateCreditCost('yoga', 60);
console.log("Yoga credit type:", yogaCost.creditType === CREDIT_TYPES.INTERVAL ? "PASS" : "FAIL");
console.log("Yoga credit cost:", yogaCost.cost === 2 ? "PASS" : "FAIL"); // Base 1 + 1 for premium

const gymCost = creditUtils.calculateCreditCost('open-gym', 120);
console.log("Gym credit type:", gymCost.creditType === CREDIT_TYPES.GYM ? "PASS" : "FAIL");
console.log("Gym credit cost (2 hours):", gymCost.cost === 2 ? "PASS" : "FAIL");

console.log("\nAll credit system tests completed!");