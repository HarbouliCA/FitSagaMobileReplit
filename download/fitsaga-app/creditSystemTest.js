// Credit system utility functions for FitSAGA app based on correct business rules
const creditUtils = {
  // Calculate remaining credits for each type
  getRemainingCredits: (total, used) => Math.max(0, total - used),
  
  // Check if user has enough credits of the specific type
  hasEnoughCredits: (availableCredits, cost) => availableCredits >= cost,
  
  // Process gym access booking
  processGymBooking: (gymCredits, cost) => {
    if (gymCredits >= cost) {
      return { 
        success: true,
        remainingGymCredits: gymCredits - cost,
        message: "Gym access booked successfully" 
      };
    }
    return { 
      success: false, 
      remainingGymCredits: gymCredits,
      message: "Insufficient gym credits" 
    };
  },
  
  // Process group session booking
  processGroupSessionBooking: (intervalCredits, cost) => {
    if (intervalCredits >= cost) {
      return { 
        success: true,
        remainingIntervalCredits: intervalCredits - cost,
        message: "Group session booked successfully" 
      };
    }
    return { 
      success: false, 
      remainingIntervalCredits: intervalCredits,
      message: "Insufficient interval credits" 
    };
  },
  
  // Admin add credits
  adminAddCredits: (currentCredits, amountToAdd, creditType) => {
    if (creditType === 'gym') {
      return {
        gymCredits: currentCredits.gymCredits + amountToAdd,
        intervalCredits: currentCredits.intervalCredits
      };
    } else if (creditType === 'interval') {
      return {
        gymCredits: currentCredits.gymCredits,
        intervalCredits: currentCredits.intervalCredits + amountToAdd
      };
    }
    return currentCredits; // No change if invalid type
  }
};

// Basic unit tests for credit system
console.log("Running FitSAGA Credit System Tests (Updated):");

// Test hasEnoughCredits
console.log("\nTest: hasEnoughCredits");
console.log("5 credits, 2 cost = can book:", 
  creditUtils.hasEnoughCredits(5, 2) === true ? "PASS" : "FAIL");
console.log("5 credits, 5 cost = can book:", 
  creditUtils.hasEnoughCredits(5, 5) === true ? "PASS" : "FAIL");
console.log("5 credits, 6 cost = cannot book:", 
  creditUtils.hasEnoughCredits(5, 6) === false ? "PASS" : "FAIL");

// Test gym bookings
console.log("\nTest: processGymBooking");
const gymResult1 = creditUtils.processGymBooking(10, 2);
console.log("10 gym credits, 2 cost = successful booking:", 
  gymResult1.success === true && gymResult1.remainingGymCredits === 8 ? "PASS" : "FAIL");

const gymResult2 = creditUtils.processGymBooking(5, 10);
console.log("5 gym credits, 10 cost = failed booking:", 
  gymResult2.success === false && gymResult2.remainingGymCredits === 5 ? "PASS" : "FAIL");

// Test group session bookings
console.log("\nTest: processGroupSessionBooking");
const sessionResult1 = creditUtils.processGroupSessionBooking(8, 3);
console.log("8 interval credits, 3 cost = successful booking:", 
  sessionResult1.success === true && sessionResult1.remainingIntervalCredits === 5 ? "PASS" : "FAIL");

const sessionResult2 = creditUtils.processGroupSessionBooking(2, 5);
console.log("2 interval credits, 5 cost = failed booking:", 
  sessionResult2.success === false && sessionResult2.remainingIntervalCredits === 2 ? "PASS" : "FAIL");

// Test admin add credits
console.log("\nTest: adminAddCredits");
const currentCredits = { gymCredits: 5, intervalCredits: 8 };

const updatedGymCredits = creditUtils.adminAddCredits(currentCredits, 10, 'gym');
console.log("Add 10 gym credits:", 
  updatedGymCredits.gymCredits === 15 && updatedGymCredits.intervalCredits === 8 ? "PASS" : "FAIL");

const updatedIntervalCredits = creditUtils.adminAddCredits(currentCredits, 5, 'interval');
console.log("Add 5 interval credits:", 
  updatedIntervalCredits.gymCredits === 5 && updatedIntervalCredits.intervalCredits === 13 ? "PASS" : "FAIL");

const invalidTypeUpdate = creditUtils.adminAddCredits(currentCredits, 3, 'invalid');
console.log("Invalid credit type - no change:", 
  invalidTypeUpdate.gymCredits === 5 && invalidTypeUpdate.intervalCredits === 8 ? "PASS" : "FAIL");

console.log("\nAll tests completed!");