# FitSAGA Local Testing Setup Guide

This guide will help you set up the FitSAGA mobile app for local testing using VS Code or Android Studio.

## Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Android emulator or physical device
- Git (for cloning the repository)

## Setup Instructions

1. **Clone the repository to your local machine**
   ```
   git clone [repository-url]
   cd fitsaga
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Set up Firebase**
   
   The app uses Firebase for authentication and database. Follow these steps:
   
   - Make sure the `google-services.json` file is placed in the `android/app/` directory
   - For iOS testing, you'll need to add the GoogleService-Info.plist file to the iOS/Runner directory

4. **Run the app**
   ```
   flutter run
   ```

## App Structure

- `lib/main.dart` - Entry point of the application
- `lib/navigation/` - Contains navigation system with role-based access
- `lib/models/` - Data models with Firestore integration
- `lib/screens/` - UI screens organized by feature
- `lib/providers/` - State management using Provider pattern
- `lib/services/` - API and Firebase integration services

## Testing Scenarios

1. **User Authentication**
   - Test login flow (uses demo mode if Firebase is not configured)
   - Test role-based access (admin, instructor, client)

2. **Session Booking**
   - Browse available sessions
   - Book a session using credits
   - Cancel a session
   - View booking history

3. **Tutorial System**
   - Browse tutorials by difficulty and category
   - Track tutorial progress
   - View tutorial details and exercises

4. **Profile Management**
   - View and edit profile information
   - Check credit balance and history
   - View membership details

## Troubleshooting

If you encounter issues:

1. Make sure Flutter is up-to-date:
   ```
   flutter upgrade
   ```

2. Check Firebase configuration:
   - Verify the package name in `google-services.json` matches your app's package name
   - Ensure Firebase project is properly set up with Authentication and Firestore

3. For build issues:
   ```
   flutter clean
   flutter pub get
   ```

## Need Help?

If you have any questions or need assistance with the setup, please contact the development team.