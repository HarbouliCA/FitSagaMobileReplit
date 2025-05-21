// Credit system utility functions for FitSAGA app
const creditUtils = {
  // Calculate remaining credits
  calculateRemainingCredits: (total, used) => Math.max(0, total - used),
  
  // Check if user has enough credits for a session
  hasEnoughCredits: (userCredits, sessionCost) => userCredits >= sessionCost,
  
  // Determine which credit type to use (interval credits first)
  determineCreditsToUse: (gymCredits, intervalCredits, cost) => {
    if (intervalCredits >= cost) {
      return { intervalCreditsUsed: cost, gymCreditsUsed: 0 };
    } else if (intervalCredits + gymCredits >= cost) {
      return { 
        intervalCreditsUsed: intervalCredits, 
        gymCreditsUsed: cost - intervalCredits 
      };
    }
    return null; // Not enough credits
  }
};

// Basic unit tests for credit system
console.log("Running FitSAGA Credit System Tests:");

// Test calculateRemainingCredits
console.log("\nTest: calculateRemainingCredits");
console.log("10 total, 3 used = 7 remaining:", 
  creditUtils.calculateRemainingCredits(10, 3) === 7 ? "PASS" : "FAIL");
console.log("5 total, 5 used = 0 remaining:", 
  creditUtils.calculateRemainingCredits(5, 5) === 0 ? "PASS" : "FAIL");
console.log("2 total, 5 used = 0 remaining (no negative):", 
  creditUtils.calculateRemainingCredits(2, 5) === 0 ? "PASS" : "FAIL");

// Test hasEnoughCredits
console.log("\nTest: hasEnoughCredits");
console.log("5 credits, 2 cost = can book:", 
  creditUtils.hasEnoughCredits(5, 2) === true ? "PASS" : "FAIL");
console.log("5 credits, 5 cost = can book:", 
  creditUtils.hasEnoughCredits(5, 5) === true ? "PASS" : "FAIL");
console.log("5 credits, 6 cost = cannot book:", 
  creditUtils.hasEnoughCredits(5, 6) === false ? "PASS" : "FAIL");

// Test determineCreditsToUse
console.log("\nTest: determineCreditsToUse");

// Case 1: Enough interval credits
const result1 = creditUtils.determineCreditsToUse(10, 5, 3);
console.log("10 gym, 5 interval, 3 cost = use interval credits only:", 
  result1.intervalCreditsUsed === 3 && result1.gymCreditsUsed === 0 ? "PASS" : "FAIL");

// Case 2: Some interval credits, need to use gym credits too
const result2 = creditUtils.determineCreditsToUse(10, 2, 5);
console.log("10 gym, 2 interval, 5 cost = use all interval + some gym:", 
  result2.intervalCreditsUsed === 2 && result2.gymCreditsUsed === 3 ? "PASS" : "FAIL");

// Case 3: Not enough credits total
const result3 = creditUtils.determineCreditsToUse(3, 1, 5);
console.log("3 gym, 1 interval, 5 cost = not enough credits:", 
  result3 === null ? "PASS" : "FAIL");

console.log("\nAll tests completed!");