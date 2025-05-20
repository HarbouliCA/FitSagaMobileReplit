# FitSAGA Gym Management App Test Plan

## Application Overview
FitSAGA is a comprehensive gym management mobile application designed to streamline tutorial experiences, session bookings, and user engagement through advanced mobile technologies. The app provides role-based access with three distinct user roles: Admin, Instructor, and Client.

## Features Implemented

### Authentication System
- Login screen with role-based authentication
- Test credentials for Admin, Instructor, and Client roles
- Profile management with editable fields

### Session Management
- Calendar view for browsing available sessions
- List view for all sessions
- Session detail view with booking functionality
- Booking confirmation with credit deduction

### Credit System
- Credit display on profile screen
- Credit history tracking
- Different credit types (Gym credits and Interval credits)

### Tutorial System
- Categorized tutorial browsing
- Tutorial detail view with video player
- Role-based tutorial creation (Admin/Instructor only)

### Admin Features
- Dashboard with stats overview
- User management section
- Session creation and management

### Instructor Features
- Dashboard with today's sessions
- Student management
- Tutorial creation and management

### Client Features
- Session booking
- Tutorial viewing
- Credit management

## Test Cases by Role

### Admin Role Tests
1. **Login as Admin**
   - Use credentials: admin@test.com / admin123
   - Verify admin dashboard appears

2. **Navigate to User Management**
   - Verify user list is displayed
   - Test "Add User" button functionality

3. **Session Management**
   - Navigate to session calendar
   - Verify ability to view all sessions
   - Test session creation flow

4. **Tutorial Management**
   - Navigate to tutorials section
   - Verify ability to add/edit tutorials
   - Test tutorial content display

### Instructor Role Tests
1. **Login as Instructor**
   - Use credentials: instructor@test.com / instructor123
   - Verify instructor dashboard appears

2. **Today's Sessions**
   - Verify today's sessions are displayed correctly
   - Test session detail navigation

3. **Student Management**
   - Verify student list is displayed
   - Test student detail view

4. **Tutorial Creation**
   - Test "Create New Tutorial" button
   - Verify tutorial appears in the list

### Client Role Tests
1. **Login as Client**
   - Use credentials: client@test.com / client123
   - Verify client landing page appears

2. **Session Booking**
   - Navigate to calendar view
   - Select a session and view details
   - Complete booking process
   - Verify credit deduction
   - Test cancellation policy

3. **Tutorial Viewing**
   - Navigate to tutorials section
   - Select and play a tutorial
   - Test video controls

4. **Profile and Credits**
   - Navigate to profile section
   - Verify credit balance display
   - Check credit history

## Edge Cases

1. **No Internet Connection**
   - Test app behavior when offline
   - Verify appropriate error messages

2. **Empty States**
   - Test calendar view with no sessions
   - Test tutorial section with no tutorials
   - Test credit history with no transactions

3. **Validation**
   - Test form validation on login
   - Test booking with insufficient credits
   - Test session booking when session is full

4. **Navigation**
   - Test back navigation from all screens
   - Test deep linking to specific screens
   - Verify bottom navigation works correctly

## Development/Testing Instructions

### Running the App
1. The app is configured to run in a Flutter environment
2. Use standard Flutter commands to run/test:
   ```
   flutter run
   ```

### Test Login Credentials
- Admin: admin@test.com / admin123
- Instructor: instructor@test.com / instructor123
- Client: client@test.com / client123

### Known Limitations
- Firebase integration is currently disabled for local testing
- Some advanced features are simulated with mock data
- Backend services like payment processing are not implemented

## Screenshots
Screenshots will be attached separately to illustrate key app flows and screens.