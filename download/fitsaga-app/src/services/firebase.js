// Firebase service implementation
// This is a minimal implementation for testing

// Auth service
export const auth = () => ({
  currentUser: {
    uid: 'test-user-id',
    email: 'test@example.com',
  },
  onAuthStateChanged: (callback) => {
    callback({
      uid: 'test-user-id',
      email: 'test@example.com',
    });
    return () => {};
  },
  signInWithEmailAndPassword: (email, password) => {
    if (email === 'test@example.com' && password === 'password123') {
      return Promise.resolve({
        user: {
          uid: 'test-user-id',
          email: 'test@example.com',
        },
      });
    }
    return Promise.reject(new Error('Invalid email or password'));
  },
  createUserWithEmailAndPassword: (email, password) => {
    return Promise.resolve({
      user: {
        uid: 'new-user-id',
        email,
      },
    });
  },
  signOut: () => Promise.resolve(),
  sendPasswordResetEmail: (email) => Promise.resolve(),
});

// Firestore service
export const db = () => ({
  collection: (collectionName) => ({
    doc: (id) => ({
      get: () => {
        if (id === 'test-user-id') {
          return Promise.resolve({
            id: 'test-user-id',
            exists: true,
            data: () => ({
              name: 'Test User',
              email: 'test@example.com',
              role: 'client',
              credits: {
                gymCredits: 10,
                intervalCredits: 5,
                lastRefilled: '2025-05-01T00:00:00.000Z',
                nextRefillDate: '2025-06-01T00:00:00.000Z',
              },
            }),
          });
        }
        if (id === 'new-user-id') {
          return Promise.resolve({
            id: 'new-user-id',
            exists: true,
            data: () => ({
              name: 'New User',
              email: 'newuser@example.com',
              role: 'client',
              credits: {
                gymCredits: 10,
                intervalCredits: 0,
                lastRefilled: '2025-05-21T00:00:00.000Z',
                nextRefillDate: '2025-06-21T00:00:00.000Z',
              },
            }),
          });
        }
        return Promise.resolve({
          exists: false,
          data: () => null,
        });
      },
      set: () => Promise.resolve(),
      update: () => Promise.resolve(),
    }),
    where: () => ({
      get: () => Promise.resolve({
        docs: [],
        empty: true,
      }),
    }),
  }),
  runTransaction: (callback) => {
    const transaction = {
      get: async (docRef) => {
        return await docRef.get();
      },
      update: () => {},
      set: () => {},
    };
    return callback(transaction);
  },
});

// Storage service
export const storage = () => ({
  ref: (path) => ({
    getDownloadURL: () => Promise.resolve(`https://example.com/${path}`),
    put: () => Promise.resolve(),
  }),
});