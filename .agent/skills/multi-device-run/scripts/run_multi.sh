#!/bin/bash

# Multi-device run script for Flutter
# iOS Simulator: iPhone 17 Pro
# Android Emulator: emulator-5554

IOS_DEVICE="0D590785-B970-43D0-BE1F-368862470165"
ANDROID_DEVICE="emulator-5554"

echo "🚀 Starting Flutter app on multiple devices..."

# Run on iOS in background
echo "📱 Launching on iOS Simulator (iPhone 17 Pro)..."
flutter run -d $IOS_DEVICE &

# Run on Android in background
echo "🤖 Launching on Android Emulator (emulator-5554)..."
flutter run -d $ANDROID_DEVICE &

# Wait for all background processes
wait
echo "✅ Both devices launched."
