// Simplified Jest setup file for testing
global.console = {
  ...console,
  // Make tests less noisy
  error: jest.fn(),
  warn: jest.fn(),
  log: jest.fn(),
};

// Basic fetch mock
global.fetch = jest.fn(() =>
  Promise.resolve({
    json: () => Promise.resolve({}),
    text: () => Promise.resolve(''),
    ok: true,
    status: 200,
  })
);

// Setup timezone for consistent date testing
process.env.TZ = 'UTC';