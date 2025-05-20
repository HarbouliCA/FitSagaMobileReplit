# FitSAGA Gym Management Application

## Overview

FitSAGA is a comprehensive gym management mobile application designed to streamline tutorial experiences, session bookings, and user engagement through advanced mobile technologies. The application connects to Firebase for authentication and data storage, implementing a role-based access control system with three primary user roles: Admin, Instructor, and Client.

## Key Features

### Role-Based Access Control
- **Admin**: Full system management, user administration, analytics
- **Instructor**: Session management, tutorial creation, client tracking
- **Client**: Session booking, tutorial access, profile management

### Credit-Based Session Booking
- Two credit types: Gym Credits and Interval Credits
- Credits can be purchased or awarded through memberships
- Each session requires a specific number of credits to book

### Tutorial System
- Comprehensive fitness tutorials with video integration
- Multi-day structured content with exercises
- Progress tracking and difficulty levels
- Categories by workout type and difficulty
- Video content stored on Azure Blob Storage with secure access

### Session Management
- Calendar view of available sessions
- Booking and cancellation functionality
- Session filtering by type and instructor
- Attendance tracking

### User Profiles
- Customizable user profiles
- Credit balance and transaction history
- Workout history and progress tracking
- Membership management

## Technology Stack

- **Framework**: Flutter for cross-platform mobile development
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Media Storage**: Azure Blob Storage for tutorial videos
- **State Management**: Provider pattern
- **Navigation**: Centralized routing system
- **UI/UX**: Material Design with custom theming

## Project Structure

```
lib/
├── main.dart                  # Application entry point
├── models/                    # Data models
│   ├── user_model.dart        # User profile model
│   ├── session_model.dart     # Session and booking models
│   └── tutorial_model.dart    # Tutorial system models
├── providers/                 # State management
│   ├── auth_provider.dart     # Authentication logic
│   └── ...
├── screens/                   # UI screens
│   ├── auth/                  # Authentication screens
│   ├── home/                  # Dashboard and main navigation
│   ├── profile/               # User profile management
│   ├── sessions/              # Session booking and calendar
│   └── tutorials/             # Tutorial browsing and viewing
├── widgets/                   # Reusable UI components
│   └── common/                # Shared widgets
├── navigation/                # Routing system
│   ├── app_router.dart        # Route definitions
│   └── navigation_service.dart # Navigation utilities
├── theme/                     # UI styling
│   └── app_theme.dart         # Theme configuration
└── services/                  # API communication and backend services
```

## Installation and Setup

Refer to the `README_FOR_LOCAL_TESTING.md` file for detailed setup instructions, including:
- Setting up your development environment
- Firebase configuration
- Running the application locally
- Testing features with different user roles

## Firebase Integration

The application uses Firebase for:
- **Authentication**: Email/password auth with role-based access
- **Firestore**: Database for users, sessions, tutorials, and bookings
- **Storage**: File storage for images (profile pictures, session images)

## Credit System Implementation

The credit system allows:
- Purchasing of two credit types (gym and interval)
- Credit consumption when booking sessions
- Credit rewards through membership plans
- Credit history and transaction tracking

## Tutorial System Implementation

Tutorials include:
- Multi-day structured content
- Individual exercises with detailed instructions
- Video integration for demonstration
- Progress tracking
- Difficulty levels and categorization

## Session Booking Flow

1. User browses available sessions in calendar view
2. User selects a session and views details
3. User confirms booking using available credits
4. System deducts credits and reserves a spot
5. User can manage or cancel bookings

## Development Guidelines

- Use proper code documentation
- Follow Flutter best practices for state management
- Ensure proper error handling
- Implement responsive designs for various screen sizes
- Test across different device types
- Use Firebase security rules for data protection

## License

This project is proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

## Contact

For further information, please contact the development team at [dev-team@fitsaga.com](mailto:dev-team@fitsaga.com).