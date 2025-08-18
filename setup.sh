#!/bin/bash

# Item Minder Flutter App Setup Script
# This script helps automate the initial setup process

echo "🚀 Setting up Item Minder Flutter App..."
echo "========================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "⚠️  Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

echo "✅ Firebase CLI found: $(firebase --version)"

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get

# Check if Firebase configuration exists
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "⚠️  Firebase configuration not found."
    echo "📋 Please follow these steps:"
    echo "1. Create a Firebase project at https://console.firebase.google.com/"
    echo "2. Enable Realtime Database"
    echo "3. Run: firebase login"
    echo "4. Run: flutterfire configure"
    echo "5. Copy the generated firebase_options.dart to lib/"
    echo ""
    echo "Or copy firebase_options.dart.example to firebase_options.dart and edit with your values."
else
    echo "✅ Firebase configuration found"
fi

# Check if google-services.json exists
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Android Firebase configuration (google-services.json) not found."
    echo "📋 Download from Firebase console and place in android/app/"
else
    echo "✅ Android Firebase configuration found"
fi

# Generate Hive models
echo "🔧 Generating Hive models..."
flutter packages pub run build_runner build

# Check for iOS configuration (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
        echo "⚠️  iOS Firebase configuration (GoogleService-Info.plist) not found."
        echo "📋 Download from Firebase console and place in ios/Runner/"
    else
        echo "✅ iOS Firebase configuration found"
    fi
fi

echo ""
echo "🎉 Setup completed!"
echo "📱 You can now run: flutter run"
echo ""
echo "📚 For detailed setup instructions, see README.md"
echo "🐛 If you encounter issues, check the Troubleshooting section in README.md"
