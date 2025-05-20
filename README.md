# FitSAGA - Gym Management App

FitSAGA is a comprehensive cross-platform mobile application designed for gym management with role-based access control, advanced session booking, tutorial system, and credit-based payment.

## Features

### User Management
- Role-based access control with three user types: Admin, Instructor, and Client
- User registration and authentication with email/password
- User profile management
- Credit system for booking sessions

### Session Management
- Calendar view with day/week/month views
- Session booking system for clients
- Session creation and management for instructors
- Recurring session scheduling with various patterns
- Conflict detection to prevent double-booking
- Session capacity management

### Tutorial System
- Categorized workout and nutrition tutorials
- Video and text-based content
- Progress tracking
- Difficulty levels
- Rating and feedback system
- Personalized recommendations based on user activity

### Admin Features
- Comprehensive dashboard with business insights
- User management and role assignment
- Credit package management
- Revenue tracking and reporting
- Content moderation

## Technical Architecture

### Frontend
- Flutter framework for cross-platform development (iOS & Android)
- Provider pattern for state management
- Clean architecture with separation of concerns
- Responsive UI with reusable components

### Backend
- Firebase Authentication for user management
- Cloud Firestore for database
- Firebase Storage for media content
- Firebase Cloud Messaging for notifications

### Data Models
- User model with role-based permissions
- Session model with recurring support
- Credit system with transaction history
- Tutorial model with progress tracking

## Screens & Flow

### Authentication Flow
- Login
- Registration
- Password reset
- Profile setup

### Client Flow
- Session booking from calendar
- Tutorial browsing and viewing
- Credit purchase
- Session history

### Instructor Flow
- Session creation and management
- Recurring session configuration
- Participant management
- Tutorial creation

### Admin Flow
- Dashboard with key metrics
- User management
- Financial reporting
- Content management

## Development Status

Current development focus:
- Calendar and session booking system
- Recurring session management
- Role-based permissions
- Firebase integration
- Tutorial system

## Next Steps
- Complete schedule management implementation
- Integrate payment processing
- Add notification system
- Implement offline support
- Add analytics tracking

## Getting Started

1. Clone the repository
2. Set up Firebase project and add the configuration files
3. Install dependencies with `flutter pub get`
4. Run the app with `flutter run`

## Requirements

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Firebase project with Authentication, Firestore, and Storage enabled
- Android Studio / Xcode for native platform development