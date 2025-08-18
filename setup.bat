@echo off
REM Item Minder Flutter App Setup Script for Windows
REM This script helps automate the initial setup process

echo 🚀 Setting up Item Minder Flutter App...
echo ========================================

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter found
flutter --version | findstr "Flutter"

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Firebase CLI not found. Installing...
    npm install -g firebase-tools
)

echo ✅ Firebase CLI found
firebase --version

REM Install Flutter dependencies
echo 📦 Installing Flutter dependencies...
flutter pub get

REM Check if Firebase configuration exists
if not exist "lib\firebase_options.dart" (
    echo ⚠️  Firebase configuration not found.
    echo 📋 Please follow these steps:
    echo 1. Create a Firebase project at https://console.firebase.google.com/
    echo 2. Enable Realtime Database
    echo 3. Run: firebase login
    echo 4. Run: flutterfire configure
    echo 5. Copy the generated firebase_options.dart to lib/
    echo.
    echo Or copy firebase_options.dart.example to firebase_options.dart and edit with your values.
) else (
    echo ✅ Firebase configuration found
)

REM Check if google-services.json exists
if not exist "android\app\google-services.json" (
    echo ⚠️  Android Firebase configuration (google-services.json) not found.
    echo 📋 Download from Firebase console and place in android/app/
) else (
    echo ✅ Android Firebase configuration found
)

REM Generate Hive models
echo 🔧 Generating Hive models...
flutter packages pub run build_runner build

echo.
echo 🎉 Setup completed!
echo 📱 You can now run: flutter run
echo.
echo 📚 For detailed setup instructions, see README.md
echo 🐛 If you encounter issues, check the Troubleshooting section in README.md
pause
