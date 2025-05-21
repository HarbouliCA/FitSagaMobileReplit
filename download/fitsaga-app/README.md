# FitSAGA Mobile App

FitSAGA is a comprehensive gym management mobile application built with React Native and Expo, designed to streamline tutorial experiences, session bookings, and user engagement through a credit-based system.

## Features

- **Role-Based Access Control**: Admin, Instructor, and Client roles with appropriate permissions
- **Credit System**: Book sessions using credits with support for standard and interval credits
- **Session Booking**: Browse, filter, and book gym sessions
- **Tutorial System**: Access video-based fitness tutorials with progress tracking
- **Cross-Platform**: Works on iOS, Android, and Web platforms

## Getting Started

### Prerequisites

- Node.js (v14 or later)
- npm or yarn
- Expo CLI (`npm install -g expo-cli`)
- iOS Simulator (Mac only) / Android Emulator / Physical device

### Installation

1. Clone the repository
```
git clone <repository-url>
cd fitsaga-app
```

2. Install dependencies
```
npm install
# or
yarn install
```

3. Start the development server
```
npx expo start
# or
yarn expo start
```

4. Run on a device or simulator
   - Press `i` for iOS Simulator (Mac only)
   - Press `a` for Android Emulator
   - Scan the QR code with the Expo Go app on your physical device

## Firebase Configuration

The app is configured to use Firebase for authentication, data storage, and media content. The Firebase configuration files are included in the repository:

- `google-services.json` for Android
- `GoogleService-Info.plist` for iOS

If you need to connect to a different Firebase project, replace these files with your own configuration.

## Platform-Specific Setup

### iOS

1. Make sure you have Xcode installed (Mac only)
2. If you need to build a standalone app:
```
expo prebuild --platform ios
cd ios
pod install
cd ..
npx expo run:ios
```

### Android

1. Make sure you have Android Studio and Android SDK installed
2. If you need to build a standalone app:
```
expo prebuild --platform android
npx expo run:android
```

## Building for Production

### Expo EAS Build

1. Install EAS CLI:
```
npm install -g eas-cli
```

2. Log in to your Expo account:
```
eas login
```

3. Configure the build:
```
eas build:configure
```

4. Build for the desired platform:
```
# For iOS
eas build --platform ios

# For Android
eas build --platform android
```

## Project Structure

- `/src/assets`: Static assets like images and icons
- `/src/components`: Reusable UI components
- `/src/navigation`: Navigation configuration
- `/src/redux`: Redux state management
- `/src/screens`: App screens organized by feature
- `/src/services`: Firebase and API services
- `/src/theme`: Styling and theming configuration

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- React Native
- Expo
- Firebase
- React Navigation
- Redux Toolkit
- React Native Paper