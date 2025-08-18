# 📱 Item Minder - Flutter Inventory Management App

A comprehensive Flutter inventory management application with real-time synchronization, offline support, and collaborative group features.

## 🌟 Features

- **📦 Inventory Management**: Add, edit, and track items with categories, quantities, and auto-reorder levels
- **👥 Group Collaboration**: Create and join groups for shared inventory management
- **🔄 Real-time Sync**: Firebase integration for instant updates across devices
- **📴 Offline Support**: Hive local storage ensures functionality without internet
- **🛒 Shopping Lists**: Generate and manage shopping lists based on inventory needs
- **📅 Calendar Integration**: Track item expiration dates and reorder schedules
- **🔔 Smart Notifications**: Get alerts for low stock and expiring items
- **🏷️ Category System**: Organize items with customizable categories and templates
- **📊 Dashboard Analytics**: Visual insights into inventory status and trends

## 🏗️ Architecture

This app implements a **dual-persistence architecture**:

- **Hive** for offline-first local storage (primary data source)
- **Firebase Realtime Database** for real-time sync across devices
- **Manager pattern** for all business logic and CRUD operations

```
UI Screens → Managers → Hive Boxes ↔ Firebase Listeners
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.5.4)
- Dart SDK
- Android Studio / Xcode
- Firebase account
- Git

### 📋 Installation Steps

#### 1. Clone the Repository
```bash
git clone https://github.com/PradoGabriela/item_minder_flutterapp.git
cd item_minder_flutterapp
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Firebase Setup

⚠️ **IMPORTANT**: This repository does not include Firebase configuration files for security reasons. You must create your own Firebase project.

##### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "item-minder" (or your preferred name)
3. Enable **Realtime Database** (not Firestore)
4. Set up authentication if needed

##### 3.2 Configure Firebase for Android
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Firebase for your project
firebase init

# Generate Firebase configuration
flutterfire configure
```

##### 3.3 Download Configuration Files
After running `flutterfire configure`:
- Download `google-services.json` for Android and place it in `android/app/`
- Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`

##### 3.4 Create Firebase Options File
Create `lib/firebase_options.dart` with your Firebase configuration:

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    authDomain: 'your-project.firebaseapp.com',
    databaseURL: 'https://your-project-default-rtdb.firebaseio.com',
    storageBucket: 'your-project.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    databaseURL: 'https://your-project-default-rtdb.firebaseio.com',
    storageBucket: 'your-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    databaseURL: 'https://your-project-default-rtdb.firebaseio.com',
    storageBucket: 'your-project.firebasestorage.app',
    iosBundleId: 'com.example.itemMinderFlutterapp',
  );

  // Add other platforms as needed...
}
```

#### 4. Generate Hive Models
```bash
flutter packages pub run build_runner build
```

#### 5. Run the Application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 📁 Project Structure

```
lib/
├── base/
│   ├── hiveboxes/          # Hive data models
│   │   ├── item.dart       # Item model
│   │   ├── group.dart      # Group model
│   │   └── ...
│   ├── managers/           # Business logic layer
│   │   ├── item_manager.dart
│   │   ├── group_manager.dart
│   │   ├── firebase_*_manager.dart
│   │   └── ...
│   ├── res/               # Resources and styles
│   │   ├── styles/
│   │   └── media.dart
│   └── widgets/           # Reusable widgets
├── listeners/             # Firebase real-time listeners
├── screens/              # UI screens
├── services/             # App-level services
├── device_id.dart        # Device identification
├── firebase_options.dart # Firebase configuration
└── main.dart            # App entry point
```

## 🔧 Development Setup

### Code Generation
After modifying any Hive models (`@HiveType` or `@HiveField`):
```bash
flutter packages pub run build_runner build
```

### Clean Build
If you encounter Hive-related issues:
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build
```

### Debug Firebase Sync
Enable debug prints in Firebase listeners:
```bash
flutter run --debug
```
Look for emoji-prefixed debug messages:
- 🆕 New data added
- 🔄 Data updated
- 🗑️ Data deleted
- ❌ Errors

## 🔑 Key Components

### Manager Classes
All data operations go through manager classes:
- `ItemManager` - Items CRUD and Firebase sync
- `GroupManager` - Group management and member tracking
- `BoxManager` - Hive box lifecycle management
- `NotificationManager` - Local notifications

### Firebase Listeners
`FirebaseListeners` class handles real-time synchronization:
- Monitors group changes
- Handles member additions/removals
- Manages item synchronization
- Resolves conflicts using timestamps

### Data Models
All models extend `HiveObject` with proper annotations:
- `AppItem` (typeId: 0) - Inventory items
- `AppGroup` (typeId: 3) - User groups
- `AppNotification` (typeId: 1) - Local notifications
- `AppShopping` (typeId: 2) - Shopping list items

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Firebase Integration
1. Create a test group
2. Add items from multiple devices
3. Verify real-time synchronization
4. Test offline/online scenarios

## 📱 Platform-Specific Setup

### Android
- Minimum SDK: 21
- Target SDK: 34
- Uses debug signing by default

### iOS
- Minimum iOS: 12.0
- Bundle ID: `com.example.itemMinderFlutterapp`
- Requires iOS development certificate for device testing

## 🔒 Security Considerations

### Firebase Security Rules
Set up appropriate Firebase Realtime Database rules:

```json
{
  "rules": {
    "groups": {
      "$groupId": {
        ".read": "auth != null && data.child('members').hasChild(auth.uid)",
        ".write": "auth != null && data.child('members').hasChild(auth.uid)"
      }
    }
  }
}
```

### Local Data Protection
- Hive boxes are stored locally and encrypted
- Device ID generation for conflict resolution
- No sensitive data in local storage

## 🐛 Troubleshooting

### Common Issues

#### Firebase Connection Issues
```bash
# Check if Firebase is properly initialized
flutter run --debug
# Look for Firebase initialization logs
```

#### Hive Issues
```bash
# Clear Hive boxes and regenerate
flutter clean
rm -rf build/
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Platform-specific Build Issues
```bash
# Android
cd android && ./gradlew clean && cd ..

# iOS
cd ios && rm -rf Pods/ Podfile.lock && pod install && cd ..
```

## 📄 Dependencies

### Core Dependencies
- `flutter` - UI framework
- `firebase_core` & `firebase_database` - Firebase integration
- `hive` & `hive_flutter` - Local storage
- `connectivity_plus` - Network status monitoring

### UI Dependencies
- `font_awesome_flutter` - Icons
- `flutter_carousel_widget` - Carousel components
- `flutter_slidable` - Swipe actions

### Development Dependencies
- `hive_generator` - Code generation for Hive
- `build_runner` - Build system
- `flutter_lints` - Code analysis

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the Manager pattern for business logic
- Use proper Hive annotations for data models
- Add comprehensive debug logging
- Test both online and offline scenarios
- Update documentation for API changes

## 📞 Support

For issues and questions:
1. Check existing [Issues](https://github.com/PradoGabriela/item_minder_flutterapp/issues)
2. Create a new issue with detailed description
3. Include device info, Flutter version, and error logs

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for real-time database services
- Hive for efficient local storage
- Open source community for various packages

---

**Note**: This is a portfolio project demonstrating Flutter development skills, Firebase integration, and mobile app architecture best practices.
