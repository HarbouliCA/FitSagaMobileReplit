#!/bin/bash

# Set Firebase environment variables
export VITE_FIREBASE_API_KEY=$VITE_FIREBASE_API_KEY
export VITE_FIREBASE_APP_ID=$VITE_FIREBASE_APP_ID
export VITE_FIREBASE_PROJECT_ID=$VITE_FIREBASE_PROJECT_ID

# Start Expo server with host option to make it accessible via LAN
cd download/fitsaga-app
npx expo start