/**
 * Tests for the Role-Based Access Control System in FitSAGA app
 * Tests permission checks for different user roles (Admin, Instructor, Client)
 */

// Define user roles
const ROLES = {
  ADMIN: 'admin',
  INSTRUCTOR: 'instructor',
  CLIENT: 'client'
};

// Mock user data with different roles
const userData = {
  'admin-1': {
    id: 'admin-1',
    name: 'Admin User',
    email: 'admin@example.com',
    role: ROLES.ADMIN
  },
  'instructor-1': {
    id: 'instructor-1',
    name: 'Jane Smith',
    email: 'jane@example.com',
    role: ROLES.INSTRUCTOR,
    specialties: ['yoga', 'strength'],
    bio: 'Certified personal trainer with 5 years experience'
  },
  'client-1': {
    id: 'client-1',
    name: 'John Doe',
    email: 'john@example.com',
    role: ROLES.CLIENT,
    membershipType: 'premium',
    credits: {
      gymCredits: 10,
      intervalCredits: 5
    }
  }
};

// Define permissions with actions and roles that can perform them
const PERMISSIONS = {
  // User management
  VIEW_ALL_USERS: { roles: [ROLES.ADMIN] },
  EDIT_USER: { roles: [ROLES.ADMIN] },
  DELETE_USER: { roles: [ROLES.ADMIN] },
  ASSIGN_CREDITS: { roles: [ROLES.ADMIN] },
  
  // Session management
  CREATE_SESSION: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR] },
  EDIT_SESSION: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR] },
  DELETE_SESSION: { roles: [ROLES.ADMIN] },
  VIEW_ALL_SESSIONS: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR, ROLES.CLIENT] },
  BOOK_SESSION: { roles: [ROLES.CLIENT] },
  CANCEL_BOOKING: { roles: [ROLES.CLIENT, ROLES.ADMIN] },
  
  // Tutorial management
  CREATE_TUTORIAL: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR] },
  EDIT_TUTORIAL: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR] },
  DELETE_TUTORIAL: { roles: [ROLES.ADMIN] },
  VIEW_TUTORIALS: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR, ROLES.CLIENT] },
  
  // Instructor-specific permissions
  MANAGE_OWN_SESSIONS: { roles: [ROLES.INSTRUCTOR] },
  VIEW_SESSION_ATTENDEES: { roles: [ROLES.ADMIN, ROLES.INSTRUCTOR] },
  
  // Analytics
  VIEW_STUDIO_ANALYTICS: { roles: [ROLES.ADMIN] },
  VIEW_PERSONAL_ANALYTICS: { roles: [ROLES.CLIENT, ROLES.INSTRUCTOR] }
};

// Mock session data
const sessionData = [
  {
    id: 'session-1',
    title: 'Morning Yoga',
    instructorId: 'instructor-1'
  },
  {
    id: 'session-2',
    title: 'HIIT Workout',
    instructorId: 'instructor-2'
  }
];

// RBAC system utilities
const rbacUtils = {
  // Check if user has permission
  hasPermission: (userId, permissionName) => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    const permission = PERMISSIONS[permissionName];
    if (!permission) {
      throw new Error(`Permission "${permissionName}" not defined`);
    }
    
    return permission.roles.includes(user.role);
  },
  
  // Check if instructor owns a session
  instructorOwnsSession: (userId, sessionId) => {
    const user = userData[userId];
    if (!user || user.role !== ROLES.INSTRUCTOR) {
      return false;
    }
    
    const session = sessionData.find(s => s.id === sessionId);
    if (!session) {
      return false;
    }
    
    return session.instructorId === userId;
  },
  
  // Check if instructor can edit a specific session
  canEditSession: (userId, sessionId) => {
    const user = userData[userId];
    if (!user) {
      return false;
    }
    
    // Admins can edit any session
    if (user.role === ROLES.ADMIN) {
      return true;
    }
    
    // Instructors can only edit their own sessions
    if (user.role === ROLES.INSTRUCTOR) {
      return rbacUtils.instructorOwnsSession(userId, sessionId);
    }
    
    // Clients cannot edit sessions
    return false;
  },
  
  // Get user role
  getUserRole: (userId) => {
    const user = userData[userId];
    if (!user) {
      throw new Error('User not found');
    }
    
    return user.role;
  },
  
  // Check if user is an admin
  isAdmin: (userId) => {
    return rbacUtils.getUserRole(userId) === ROLES.ADMIN;
  },
  
  // Check if user is an instructor
  isInstructor: (userId) => {
    return rbacUtils.getUserRole(userId) === ROLES.INSTRUCTOR;
  },
  
  // Check if user is a client
  isClient: (userId) => {
    return rbacUtils.getUserRole(userId) === ROLES.CLIENT;
  }
};

// Run RBAC Tests
console.log("Running FitSAGA Role-Based Access Control Tests:");

// Test admin permissions
console.log("\nTest: Admin Permissions");
const adminId = 'admin-1';

console.log("Admin can view all users:", 
  rbacUtils.hasPermission(adminId, 'VIEW_ALL_USERS') ? "PASS" : "FAIL");
console.log("Admin can assign credits:", 
  rbacUtils.hasPermission(adminId, 'ASSIGN_CREDITS') ? "PASS" : "FAIL");
console.log("Admin can create sessions:", 
  rbacUtils.hasPermission(adminId, 'CREATE_SESSION') ? "PASS" : "FAIL");
console.log("Admin can delete tutorials:", 
  rbacUtils.hasPermission(adminId, 'DELETE_TUTORIAL') ? "PASS" : "FAIL");
console.log("Admin can view studio analytics:", 
  rbacUtils.hasPermission(adminId, 'VIEW_STUDIO_ANALYTICS') ? "PASS" : "FAIL");
console.log("Admin can edit any session:", 
  rbacUtils.canEditSession(adminId, 'session-1') ? "PASS" : "FAIL");

// Test instructor permissions
console.log("\nTest: Instructor Permissions");
const instructorId = 'instructor-1';

console.log("Instructor can create sessions:", 
  rbacUtils.hasPermission(instructorId, 'CREATE_SESSION') ? "PASS" : "FAIL");
console.log("Instructor cannot view all users:", 
  !rbacUtils.hasPermission(instructorId, 'VIEW_ALL_USERS') ? "PASS" : "FAIL");
console.log("Instructor can view session attendees:", 
  rbacUtils.hasPermission(instructorId, 'VIEW_SESSION_ATTENDEES') ? "PASS" : "FAIL");
console.log("Instructor can edit their own session:", 
  rbacUtils.canEditSession(instructorId, 'session-1') ? "PASS" : "FAIL");
console.log("Instructor cannot edit another instructor's session:", 
  !rbacUtils.canEditSession(instructorId, 'session-2') ? "PASS" : "FAIL");
console.log("Instructor cannot delete tutorials:", 
  !rbacUtils.hasPermission(instructorId, 'DELETE_TUTORIAL') ? "PASS" : "FAIL");

// Test client permissions
console.log("\nTest: Client Permissions");
const clientId = 'client-1';

console.log("Client can book sessions:", 
  rbacUtils.hasPermission(clientId, 'BOOK_SESSION') ? "PASS" : "FAIL");
console.log("Client can view tutorials:", 
  rbacUtils.hasPermission(clientId, 'VIEW_TUTORIALS') ? "PASS" : "FAIL");
console.log("Client cannot create tutorials:", 
  !rbacUtils.hasPermission(clientId, 'CREATE_TUTORIAL') ? "PASS" : "FAIL");
console.log("Client cannot create sessions:", 
  !rbacUtils.hasPermission(clientId, 'CREATE_SESSION') ? "PASS" : "FAIL");
console.log("Client cannot edit sessions:", 
  !rbacUtils.canEditSession(clientId, 'session-1') ? "PASS" : "FAIL");
console.log("Client can view personal analytics:", 
  rbacUtils.hasPermission(clientId, 'VIEW_PERSONAL_ANALYTICS') ? "PASS" : "FAIL");
console.log("Client cannot view studio analytics:", 
  !rbacUtils.hasPermission(clientId, 'VIEW_STUDIO_ANALYTICS') ? "PASS" : "FAIL");

// Test role detection
console.log("\nTest: Role Detection");
console.log("Detect admin role:", rbacUtils.isAdmin(adminId) ? "PASS" : "FAIL");
console.log("Detect instructor role:", rbacUtils.isInstructor(instructorId) ? "PASS" : "FAIL");
console.log("Detect client role:", rbacUtils.isClient(clientId) ? "PASS" : "FAIL");

console.log("\nAll RBAC tests completed!");