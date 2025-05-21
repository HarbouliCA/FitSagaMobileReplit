/**
 * FitSAGA Test Runner Script
 * 
 * This script runs all the test files for the FitSAGA application
 * and reports the results.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

// Test files to run
const testFiles = [
  'rbacTest.js',
  'creditSystemTest.js',
  'sessionBookingTest.js',
  'tutorialSystemTest.js',
  'firebaseAuthTest.js',
  'basicTest.js'
];

// Results storage
const testResults = {
  passed: [],
  failed: [],
  skipped: []
};

// Print header
console.log(`\n${colors.bright}${colors.cyan}==============================================`);
console.log(`       FitSAGA Test Runner (${new Date().toLocaleDateString()})`);
console.log(`==============================================${colors.reset}\n`);

// Run each test file
testFiles.forEach((testFile) => {
  const testPath = path.join(process.cwd(), testFile);
  
  // Check if file exists
  if (!fs.existsSync(testPath)) {
    console.log(`${colors.yellow}⚠ Skipping ${testFile} - file not found${colors.reset}`);
    testResults.skipped.push(testFile);
    return;
  }
  
  console.log(`${colors.bright}Running: ${testFile}${colors.reset}`);
  
  try {
    // Execute the test file
    const output = execSync(`node ${testPath}`, { encoding: 'utf8' });
    
    // Simple pass/fail detection based on absence of "FAIL" in output
    // This is a basic implementation - a more sophisticated version could parse
    // the detailed results and provide statistics
    if (output.includes('FAIL')) {
      console.log(`${colors.red}✗ Test contains failures${colors.reset}`);
      console.log(`${colors.red}${output}${colors.reset}`);
      testResults.failed.push(testFile);
    } else {
      console.log(`${colors.green}✓ All tests passed${colors.reset}`);
      testResults.passed.push(testFile);
    }
  } catch (error) {
    console.error(`${colors.red}✗ Error running ${testFile}:${colors.reset}`);
    console.error(`${colors.red}${error.message}${colors.reset}`);
    testResults.failed.push(testFile);
  }
  
  console.log(`${colors.bright}----------------------------------------${colors.reset}\n`);
});

// Print summary
console.log(`${colors.bright}${colors.cyan}=== Test Summary ===${colors.reset}`);
console.log(`${colors.green}✓ Passed: ${testResults.passed.length} tests${colors.reset}`);
testResults.passed.forEach(test => console.log(`  - ${test}`));

if (testResults.failed.length > 0) {
  console.log(`${colors.red}✗ Failed: ${testResults.failed.length} tests${colors.reset}`);
  testResults.failed.forEach(test => console.log(`  - ${test}`));
}

if (testResults.skipped.length > 0) {
  console.log(`${colors.yellow}⚠ Skipped: ${testResults.skipped.length} tests${colors.reset}`);
  testResults.skipped.forEach(test => console.log(`  - ${test}`));
}

console.log(`\n${colors.bright}${colors.cyan}=== End of Test Run ===${colors.reset}\n`);