# FitSAGA App Deployment Guide

This guide provides step-by-step instructions for building and deploying the FitSAGA mobile app for both iOS and Android platforms.

## Prerequisites

- Expo account (https://expo.dev/signup)
- Apple Developer account (for iOS deployment)
- Google Play Developer account (for Android deployment)
- Node.js and npm/yarn installed
- Expo CLI installed (`npm install -g expo-cli`)
- EAS CLI installed (`npm install -g eas-cli`)

## Setting Up EAS Build

Expo Application Services (EAS) is the recommended way to build and deploy React Native apps created with Expo.

### 1. Log in to your Expo account

```bash
eas login
```

### 2. Configure the project

```bash
eas build:configure
```

This will create an `eas.json` file in your project that contains your build configuration.

## iOS Deployment

### 1. Set up App Store Connect

1. Register a new app in App Store Connect (https://appstoreconnect.apple.com/)
2. Create an App ID in the Apple Developer portal
3. Generate and download required certificates and provisioning profiles

### 2. Configure iOS-specific settings

Update the following files:

- `app.json`: Verify iOS-specific configurations
- `GoogleService-Info.plist`: Ensure this file contains the correct Firebase configuration

### 3. Build for iOS

```bash
eas build --platform ios
```

You can specify the build profile:

```bash
eas build --platform ios --profile production
```

### 4. Submit to App Store

Once the build is complete, you can submit it directly to the App Store:

```bash
eas submit --platform ios
```

Or download the build and submit it manually through Xcode or Transporter.

## Android Deployment

### 1. Set up Google Play Console

1. Create a new application in the Google Play Console
2. Fill in the required information (store listing, content rating, etc.)
3. Create a release track (internal testing, closed testing, open testing, or production)

### 2. Configure Android-specific settings

Update the following files:

- `app.json`: Verify Android-specific configurations
- `google-services.json`: Ensure this file contains the correct Firebase configuration

### 3. Build for Android

```bash
eas build --platform android
```

You can specify the build profile:

```bash
eas build --platform android --profile production
```

### 4. Submit to Google Play

Once the build is complete, you can submit it directly to Google Play:

```bash
eas submit --platform android
```

Or download the build (.aab file) and upload it manually through the Google Play Console.

## Building for Multiple Platforms

You can build for both platforms in one command:

```bash
eas build --platform all
```

## Build Profiles

EAS allows you to define different build profiles in the `eas.json` file:

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {}
  }
}
```

- **development**: For development and testing (includes development client)
- **preview**: For internal testing
- **production**: For App Store/Google Play submission

## Managing Environment Variables

### 1. Using EAS Secret

```bash
eas secret:create --name API_KEY --value "your-api-key"
```

### 2. In your `eas.json` file:

```json
{
  "build": {
    "production": {
      "env": {
        "FIREBASE_API_KEY": "your-firebase-api-key"
      }
    }
  }
}
```

## Troubleshooting Common Issues

### iOS Build Failures

1. **Certificate/Provisioning Profile Issues**
   - Ensure your Apple Developer account has the correct certificates
   - Try: `eas credentials --platform ios`

2. **Missing GoogleService-Info.plist**
   - Make sure the file is in the correct location
   - Verify the Bundle ID matches your App Store Connect app

### Android Build Failures

1. **Keystore Issues**
   - Let EAS manage your keystore or provide your own
   - If providing your own, ensure it's correctly configured in `eas.json`

2. **Package Name Mismatch**
   - Ensure package name in `app.json` matches Google Play Console
   - Make sure `google-services.json` has the correct package name

3. **Gradle Build Failures**
   - Check logs for specific errors
   - Update `build.gradle` if necessary (may require pre-build)

## Updates and OTA (Over-the-Air) Updates

EAS Update allows you to push updates to your app without going through app stores:

1. Configure updates in `app.json`:

```json
{
  "expo": {
    "updates": {
      "enabled": true,
      "fallbackToCacheTimeout": 0
    }
  }
}
```

2. Create and push an update:

```bash
eas update --branch production --message "Fixed login bug"
```

## Conclusion

By following this guide, you should be able to successfully build and deploy the FitSAGA app to both iOS and Android platforms. Remember that the app store review process can take several days, so plan your release schedule accordingly.

For more information, refer to the Expo documentation:
- [EAS Build](https://docs.expo.dev/build/introduction/)
- [EAS Submit](https://docs.expo.dev/submit/introduction/)
- [EAS Update](https://docs.expo.dev/eas-update/introduction/)