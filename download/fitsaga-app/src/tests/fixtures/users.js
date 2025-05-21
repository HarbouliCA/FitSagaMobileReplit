/**
 * Test fixtures for user data
 */

export const mockUsers = {
  admin: {
    id: 'admin-user-1',
    email: 'admin@fitsaga.com',
    name: 'Admin User',
    role: 'admin',
    createdAt: '2025-01-01T00:00:00.000Z',
    lastLogin: '2025-05-20T10:30:00.000Z',
    photoURL: 'https://example.com/profiles/admin.jpg',
    isActive: true
  },
  
  instructor: {
    id: 'instructor-user-1',
    email: 'instructor@fitsaga.com',
    name: 'Jane Smith',
    role: 'instructor',
    createdAt: '2025-01-15T00:00:00.000Z',
    lastLogin: '2025-05-20T09:15:00.000Z',
    photoURL: 'https://example.com/profiles/instructor.jpg',
    bio: 'Certified personal trainer with 10 years of experience',
    specialties: ['Yoga', 'HIIT', 'Strength Training'],
    isActive: true
  },
  
  client: {
    id: 'client-user-1',
    email: 'client@example.com',
    name: 'John Doe',
    role: 'client',
    createdAt: '2025-02-01T00:00:00.000Z',
    lastLogin: '2025-05-20T16:45:00.000Z',
    photoURL: 'https://example.com/profiles/client.jpg',
    memberSince: '2025-02-01T00:00:00.000Z',
    credits: {
      gymCredits: 10,
      intervalCredits: 5,
      lastRefilled: '2025-05-01T00:00:00.000Z',
      nextRefillDate: '2025-06-01T00:00:00.000Z'
    },
    isActive: true
  },
  
  inactiveClient: {
    id: 'inactive-client-1',
    email: 'inactive@example.com',
    name: 'Inactive User',
    role: 'client',
    createdAt: '2025-01-05T00:00:00.000Z',
    lastLogin: '2025-03-15T11:20:00.000Z',
    photoURL: 'https://example.com/profiles/inactive.jpg',
    memberSince: '2025-01-05T00:00:00.000Z',
    credits: {
      gymCredits: 0,
      intervalCredits: 0,
      lastRefilled: '2025-03-01T00:00:00.000Z',
      nextRefillDate: null
    },
    isActive: false
  }
};

export const mockUserCredentials = {
  admin: {
    email: 'admin@fitsaga.com',
    password: 'Password123!'
  },
  
  instructor: {
    email: 'instructor@fitsaga.com',
    password: 'Password123!'
  },
  
  client: {
    email: 'client@example.com',
    password: 'Password123!'
  }
};