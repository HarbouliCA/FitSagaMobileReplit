/**
 * Mock implementations for Firebase services
 * Used in testing to avoid actual Firebase calls
 */

// Mock Firebase Auth
export const mockFirebaseAuth = {
  // Mock current user
  currentUser: {
    uid: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
  },
  
  // Mock auth state change listener
  onAuthStateChanged: jest.fn((callback) => {
    // Immediately call with the mock user
    callback(mockFirebaseAuth.currentUser);
    // Return unsubscribe function
    return jest.fn();
  }),
  
  // Mock sign in
  signInWithEmailAndPassword: jest.fn((email, password) => {
    if (email === 'test@example.com' && password === 'password123') {
      return Promise.resolve({
        user: mockFirebaseAuth.currentUser,
      });
    } else {
      return Promise.reject(new Error('Invalid email or password'));
    }
  }),
  
  // Mock create user
  createUserWithEmailAndPassword: jest.fn((email, password) => {
    if (email && password) {
      return Promise.resolve({
        user: {
          ...mockFirebaseAuth.currentUser,
          email,
        },
      });
    } else {
      return Promise.reject(new Error('Invalid email or password format'));
    }
  }),
  
  // Mock sign out
  signOut: jest.fn(() => Promise.resolve()),
  
  // Mock password reset
  sendPasswordResetEmail: jest.fn((email) => {
    if (email) {
      return Promise.resolve();
    } else {
      return Promise.reject(new Error('Email is required'));
    }
  }),
};

// Mock Firestore document snapshot
class MockDocumentSnapshot {
  constructor(id, data) {
    this.id = id;
    this._data = data;
  }
  
  data() {
    return this._data;
  }
  
  exists() {
    return !!this._data;
  }
}

// Mock Firestore query snapshot
class MockQuerySnapshot {
  constructor(docs) {
    this.docs = docs.map(doc => new MockDocumentSnapshot(doc.id, doc));
    this.empty = docs.length === 0;
    this.size = docs.length;
  }
  
  forEach(callback) {
    this.docs.forEach(callback);
  }
}

// Mock Firestore document reference
class MockDocumentReference {
  constructor(id, data) {
    this.id = id;
    this._data = data || null;
  }
  
  get() {
    return Promise.resolve(new MockDocumentSnapshot(this.id, this._data));
  }
  
  set(data) {
    this._data = { ...this._data, ...data };
    return Promise.resolve();
  }
  
  update(data) {
    this._data = { ...this._data, ...data };
    return Promise.resolve();
  }
  
  delete() {
    this._data = null;
    return Promise.resolve();
  }
  
  onSnapshot(callback) {
    // Immediately call with current data
    callback(new MockDocumentSnapshot(this.id, this._data));
    // Return unsubscribe function
    return jest.fn();
  }
}

// Mock Firestore collection reference
class MockCollectionReference {
  constructor(id, docs = {}) {
    this.id = id;
    this._docs = docs;
    this._queryConstraints = [];
  }
  
  doc(id) {
    if (id) {
      return new MockDocumentReference(id, this._docs[id]);
    } else {
      // Generate a random ID for new documents
      const newId = `auto-id-${Math.random().toString(36).substr(2, 9)}`;
      return new MockDocumentReference(newId);
    }
  }
  
  add(data) {
    const newId = `auto-id-${Math.random().toString(36).substr(2, 9)}`;
    this._docs[newId] = data;
    return Promise.resolve(new MockDocumentReference(newId, data));
  }
  
  get() {
    let filteredDocs = Object.entries(this._docs).map(([id, data]) => ({
      id,
      ...data,
    }));
    
    // Apply query constraints (very basic implementation)
    this._queryConstraints.forEach(constraint => {
      if (constraint.type === 'where') {
        const { field, operator, value } = constraint;
        filteredDocs = filteredDocs.filter(doc => {
          if (operator === '==') return doc[field] === value;
          if (operator === '>') return doc[field] > value;
          if (operator === '>=') return doc[field] >= value;
          if (operator === '<') return doc[field] < value;
          if (operator === '<=') return doc[field] <= value;
          if (operator === '!=') return doc[field] !== value;
          return true;
        });
      } else if (constraint.type === 'orderBy') {
        const { field, direction } = constraint;
        filteredDocs.sort((a, b) => {
          if (direction === 'desc') {
            return b[field] > a[field] ? 1 : -1;
          } else {
            return a[field] > b[field] ? 1 : -1;
          }
        });
      } else if (constraint.type === 'limit') {
        filteredDocs = filteredDocs.slice(0, constraint.limit);
      }
    });
    
    return Promise.resolve(new MockQuerySnapshot(filteredDocs));
  }
  
  where(field, operator, value) {
    const newRef = new MockCollectionReference(this.id, this._docs);
    newRef._queryConstraints = [
      ...this._queryConstraints,
      { type: 'where', field, operator, value },
    ];
    return newRef;
  }
  
  orderBy(field, direction = 'asc') {
    const newRef = new MockCollectionReference(this.id, this._docs);
    newRef._queryConstraints = [
      ...this._queryConstraints,
      { type: 'orderBy', field, direction },
    ];
    return newRef;
  }
  
  limit(limit) {
    const newRef = new MockCollectionReference(this.id, this._docs);
    newRef._queryConstraints = [
      ...this._queryConstraints,
      { type: 'limit', limit },
    ];
    return newRef;
  }
  
  onSnapshot(callback) {
    // Immediately call with current data
    this.get().then(snapshot => callback(snapshot));
    // Return unsubscribe function
    return jest.fn();
  }
}

// Mock Firestore
export const mockFirestore = {
  // Mock collections with initial data
  _collections: {
    users: {
      'test-user-id': {
        name: 'Test User',
        email: 'test@example.com',
        role: 'client',
        credits: {
          gymCredits: 10,
          intervalCredits: 5,
        },
      },
      'instructor-id': {
        name: 'Jane Instructor',
        email: 'instructor@example.com',
        role: 'instructor',
      },
      'admin-id': {
        name: 'Admin User',
        email: 'admin@example.com',
        role: 'admin',
      },
    },
    
    sessions: {
      'session-1': {
        title: 'Morning Yoga',
        activityType: 'yoga',
        instructorId: 'instructor-id',
        instructorName: 'Jane Instructor',
        startTime: new Date('2025-05-22T09:00:00'),
        endTime: new Date('2025-05-22T10:00:00'),
        capacity: 20,
        enrolledCount: 12,
        creditCost: 2,
        location: 'Studio A',
      },
      'session-2': {
        title: 'HIIT Workout',
        activityType: 'hiit',
        instructorId: 'instructor-id',
        instructorName: 'Jane Instructor',
        startTime: new Date('2025-05-22T18:00:00'),
        endTime: new Date('2025-05-22T19:00:00'),
        capacity: 15,
        enrolledCount: 10,
        creditCost: 3,
        location: 'Gym Floor',
      },
    },
    
    bookings: {
      'booking-1': {
        userId: 'test-user-id',
        userName: 'Test User',
        sessionId: 'session-1',
        sessionTitle: 'Morning Yoga',
        startTime: new Date('2025-05-22T09:00:00'),
        endTime: new Date('2025-05-22T10:00:00'),
        creditsCost: 2,
        bookingDate: new Date('2025-05-21T12:00:00'),
      },
    },
    
    tutorials: {
      'tutorial-1': {
        title: 'Beginner Yoga Series',
        description: 'Learn the fundamentals of yoga',
        category: 'yoga',
        difficulty: 'beginner',
        thumbnailUrl: 'https://example.com/thumbnails/yoga.jpg',
        instructor: 'Jane Instructor',
        totalDays: 7,
      },
    },
    
    videoMetadata: {
      'video-1': {
        title: 'Downward Dog Pose',
        description: 'Learn proper form for downward dog',
        tutorialId: 'tutorial-1',
        dayNumber: 1,
        exerciseNumber: 1,
        duration: 180, // seconds
        thumbnailUrl: 'https://example.com/thumbnails/downward-dog.jpg',
        videoUrl: 'https://storage.example.com/videos/downward-dog.mp4',
      },
    },
  },
  
  // Collection method
  collection(collectionName) {
    return new MockCollectionReference(
      collectionName,
      this._collections[collectionName] || {}
    );
  },
  
  // Batch write operations
  batch() {
    const operations = [];
    
    return {
      set: (docRef, data) => {
        operations.push({ type: 'set', ref: docRef, data });
        return this;
      },
      update: (docRef, data) => {
        operations.push({ type: 'update', ref: docRef, data });
        return this;
      },
      delete: (docRef) => {
        operations.push({ type: 'delete', ref: docRef });
        return this;
      },
      commit: () => {
        // Execute all queued operations
        return Promise.all(
          operations.map((op) => {
            if (op.type === 'set') return op.ref.set(op.data);
            if (op.type === 'update') return op.ref.update(op.data);
            if (op.type === 'delete') return op.ref.delete();
            return Promise.resolve();
          })
        );
      },
    };
  },
  
  // Transaction operations
  runTransaction: async (transactionFn) => {
    // Simple transaction object with read/write methods
    const transaction = {
      get: (docRef) => docRef.get(),
      set: (docRef, data) => {
        docRef._data = data;
        return transaction;
      },
      update: (docRef, data) => {
        docRef._data = { ...docRef._data, ...data };
        return transaction;
      },
      delete: (docRef) => {
        docRef._data = null;
        return transaction;
      },
    };
    
    return transactionFn(transaction);
  },
};

// Mock Firebase Storage
export const mockFirebaseStorage = {
  // Storage references
  _files: {
    'tutorials/yoga/downward-dog.mp4': {
      url: 'https://storage.example.com/videos/downward-dog.mp4',
      metadata: {
        contentType: 'video/mp4',
        size: 15000000,
        timeCreated: '2025-01-15T12:00:00Z',
      },
    },
    'thumbnails/yoga/downward-dog.jpg': {
      url: 'https://storage.example.com/thumbnails/downward-dog.jpg',
      metadata: {
        contentType: 'image/jpeg',
        size: 500000,
        timeCreated: '2025-01-15T12:00:00Z',
      },
    },
  },
  
  // Reference method
  ref(path) {
    return {
      fullPath: path,
      name: path.split('/').pop(),
      
      // Child method for nested paths
      child(childPath) {
        return mockFirebaseStorage.ref(`${path}/${childPath}`);
      },
      
      // Get download URL
      getDownloadURL() {
        const file = mockFirebaseStorage._files[path];
        if (file) {
          return Promise.resolve(file.url);
        } else {
          return Promise.reject(new Error('File not found'));
        }
      },
      
      // Get metadata
      getMetadata() {
        const file = mockFirebaseStorage._files[path];
        if (file) {
          return Promise.resolve(file.metadata);
        } else {
          return Promise.reject(new Error('File not found'));
        }
      },
      
      // Put file
      put(data, metadata) {
        mockFirebaseStorage._files[path] = {
          url: `https://storage.example.com/${path}`,
          metadata: {
            contentType: metadata?.contentType || 'application/octet-stream',
            size: data.size || 1000,
            timeCreated: new Date().toISOString(),
          },
        };
        
        return {
          on: (event, onProgress, onError, onComplete) => {
            // Simulate completion
            onComplete({
              ref: mockFirebaseStorage.ref(path),
              metadata: mockFirebaseStorage._files[path].metadata,
            });
          },
          then: (callback) => {
            return Promise.resolve({
              ref: mockFirebaseStorage.ref(path),
              metadata: mockFirebaseStorage._files[path].metadata,
            }).then(callback);
          },
        };
      },
      
      // Delete file
      delete() {
        if (mockFirebaseStorage._files[path]) {
          delete mockFirebaseStorage._files[path];
          return Promise.resolve();
        } else {
          return Promise.reject(new Error('File not found'));
        }
      },
    };
  },
};

// Mock complete Firebase module
export const mockFirebase = {
  auth: () => mockFirebaseAuth,
  firestore: () => mockFirestore,
  storage: () => mockFirebaseStorage,
};