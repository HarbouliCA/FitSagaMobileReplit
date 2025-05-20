# FitSAGA Local Testing Instructions

This document provides instructions for setting up and testing the FitSAGA gym management application on your local development environment.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (version 3.0.0 or later)
- Dart SDK (version 2.17.0 or later)
- Android Studio or Visual Studio Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- Git

## Getting Started

1. Clone this repository to your local machine:
```
git clone https://github.com/your-username/fitsaga.git
```

2. Navigate to the project directory:
```
cd fitsaga
```

3. Install dependencies:
```
flutter pub get
```

## Firebase Configuration

The app uses Firebase for authentication and data storage. To test with Firebase:

1. Create a new Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and add the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Enable Authentication with Email/Password in the Firebase console
5. Create Firestore collections for users, sessions, and tutorials

## Mock Mode

For testing without Firebase:
- The app includes a mock mode that simulates backend functionality
- Firebase initialization is wrapped in try-catch to allow the app to run without proper Firebase setup
- Sample data is provided for sessions, tutorials, and bookings

## Running the App

Launch the app using your preferred IDE or run:
```
flutter run
```

## Testing Different User Roles

You can test different user roles (client, instructor, admin) by modifying the `role` field in the `AuthProvider` class or by creating different user accounts with different roles.

## Testing Features

### Authentication
- Test registration with a new email
- Test login with existing credentials
- Test password reset functionality

### Client Features
- Browse available sessions in the calendar view
- Book sessions and manage bookings
- View and interact with tutorials
- Update profile information

### Instructor Features
- Manage sessions (view participants, mark attendance)
- Create and modify your sessions

### Admin Features
- Manage users (view, edit roles)
- Manage all sessions and bookings
- Access analytics and reports

## Troubleshooting

### Common Issues:
1. **Firebase Connection Issues**
   - Verify your Firebase configuration files are correctly placed
   - Ensure you have the correct dependencies in pubspec.yaml

2. **Flutter Version Issues**
   - Run `flutter doctor` to diagnose any Flutter installation issues
   - Update Flutter with `flutter upgrade` if needed

3. **Dependency Issues**
   - Run `flutter clean` followed by `flutter pub get`

## Additional Information

- The app uses Provider for state management
- Navigation is centralized through the AppRouter and NavigationService
- The UI is built using Material Design components with custom theming
- All data models are defined in the models directory with proper Firebase integration

For more information, please refer to the code documentation in each file.