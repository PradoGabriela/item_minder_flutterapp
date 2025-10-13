# Firebase Authentication & Google Sign-In Setup Guide

This guide provides step-by-step instructions to complete the Firebase Authentication and Google Sign-In integration for your Item Minder Flutter app.

## ✅ What's Already Done

- ✅ Firebase Auth and Google Sign-In dependencies added
- ✅ AuthService with complete authentication logic
- ✅ AuthWidget for reusable authentication UI
- ✅ AuthGroupManager for user-based group management
- ✅ Firebase security rules for authenticated access
- ✅ Example integration screen

## 🔧 Required Configuration Steps

### 1. Firebase Console Setup

#### Enable Authentication
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your `item-minder` project
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. **Enable** Google Sign-In
6. Set **Project support email** (required)
7. Click **Save**

#### Get OAuth Client Configuration
1. Go to **Project Settings** → **General**
2. Scroll to **Your apps** section
3. For each platform (Android/iOS), note the configuration files needed

### 2. Android Configuration

#### Update google-services.json
1. Download the latest `google-services.json` from Firebase Console
2. Replace the existing file in `android/app/google-services.json`
3. Ensure it includes the OAuth client configuration

#### Add SHA Fingerprints (Required for Google Sign-In)
1. Get your debug SHA-1 fingerprint using Gradle (requires compatible JDK):
   ```powershell
   # Set JAVA_HOME to a compatible JDK version (JDK 8, 11, or 17-20)
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-20"
   cd android
   .\gradlew.bat signingReport
   ```
2. Alternative method for Windows (works with any JDK):
   ```powershell
   keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
3. Copy the SHA-1 fingerprint from the output
4. In Firebase Console → **Project Settings** → **Your apps** → Android app
5. Add the SHA-1 fingerprint and click **Save**

#### Update android/app/build.gradle
Ensure these dependencies are present:
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
    // ... other dependencies
}
```

### 3. iOS Configuration

#### Update GoogleService-Info.plist
1. Download the latest `GoogleService-Info.plist` from Firebase Console
2. Replace the existing file in `ios/Runner/GoogleService-Info.plist`

#### Add URL Scheme (Required for Google Sign-In)
1. Open `ios/Runner/Info.plist`
2. Add the following URL scheme (replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>
```

### 4. Web Configuration (Optional)

#### Update web/index.html
Add the Google Sign-In meta tag:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

### 5. Deploy Firebase Security Rules

#### Update Firebase Realtime Database Rules
1. Go to Firebase Console → **Realtime Database** → **Rules**
2. Replace the existing rules with the content from `firebase-rules-secure.json`:

```json
{
  "rules": {
    "groups": {
      "$groupId": {
        ".read": "auth != null && (data.child('members').hasChild(auth.uid) || data.child('createdBy').val() == auth.uid)",
        ".write": "auth != null && (data.child('members').hasChild(auth.uid) || data.child('createdBy').val() == auth.uid || (!data.exists() && newData.child('createdBy').val() == auth.uid))",
        // ... rest of the validation rules from firebase-rules-secure.json
      }
    },
    "$other": {
      ".read": false,
      ".write": false
    }
  }
}
```

3. Click **Publish** to deploy the rules

## 🧪 Testing the Integration

### 1. Test Authentication Flow
1. Run the app: `flutter run`
2. Navigate to the AuthExampleScreen (add it to your navigation)
3. Test Google Sign-In process
4. Verify user information appears correctly
5. Test sign-out functionality

### 2. Test Group Management
1. While signed in, create a test group
2. Note the group ID from console logs
3. Sign out and sign in with a different Google account
4. Try to join the group using the group ID
5. Verify group access and permissions work correctly

### 3. Test Security Rules
1. Try accessing Firebase Realtime Database without authentication (should fail)
2. Try accessing another user's group data (should fail)
3. Verify only group members can read/write group data

## 🔗 Integration with Existing App

### 1. Update Starter Screen
Modify `lib/screens/starter_screen.dart` to include authentication check:

```dart
// Add at the top of StarterScreen
final AuthService _authService = AuthService();

// In build method, add authentication check:
@override
Widget build(BuildContext context) {
  return StreamBuilder<User?>(
    stream: _authService.authStateChanges,
    builder: (context, snapshot) {
      final user = snapshot.data;
      
      if (user != null) {
        // User is signed in, show normal app flow
        return YourNormalStarterScreenContent();
      } else {
        // User not signed in, show auth widget
        return AuthWidget(
          onAuthStateChanged: (User? user) {
            if (user != null) {
              // Navigate to main app or refresh state
              setState(() {});
            }
          },
        );
      }
    },
  );
}
```

### 2. Update Group Manager Usage
Replace device-based group operations with user-based ones:

```dart
// OLD: Device-based group creation
await GroupManager().createGroup(groupName, deviceId, iconUrl, categories, userName);

// NEW: User-based group creation
await AuthGroupManager().createGroupAsUser(
  groupName: groupName,
  groupIconUrl: iconUrl,
  categoriesNames: categories,
);
```

### 3. Add Authentication Status to App Bar
Use the compact AuthWidget in your app bars:

```dart
AppBar(
  title: Text('Item Minder'),
  actions: [
    Container(
      width: 200,
      child: AuthWidget(
        compact: true,
        onAuthStateChanged: (user) {
          // Handle auth state changes
        },
      ),
    ),
  ],
)
```

## 🛡️ Security Best Practices

### 1. Validate User Input
- Always validate group IDs and user input
- Use the provided security rules for server-side validation
- Implement proper error handling for authentication failures

### 2. Handle Offline State
- The app continues to work offline with Hive storage
- Authentication state persists across app restarts
- Sync happens automatically when connection is restored

### 3. User Privacy
- Only collect necessary user information
- Follow Google's OAuth policies
- Provide clear privacy information to users

## 🚀 Production Deployment

### 1. Release SHA Fingerprints
For production builds, add release SHA fingerprints to Firebase:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

### 2. Update OAuth Settings
- Configure authorized domains in Firebase Console
- Update redirect URIs for production domains
- Review and update security rules for production data

### 3. Enable Additional Security
- Consider enabling App Check for additional security
- Set up monitoring and alerts for authentication events
- Implement rate limiting for sensitive operations

## 📱 Usage Examples

### Basic Authentication Check
```dart
final authService = AuthService();
if (authService.isSignedIn) {
  // User is signed in
  final userId = authService.userUid;
  final userName = authService.userDisplayName;
}
```

### Create User Group
```dart
final authGroupManager = AuthGroupManager();
final success = await authGroupManager.createGroupAsUser(
  groupName: "My Inventory",
  categoriesNames: ["Kitchen", "Bathroom"],
);
```

### Get User's Groups
```dart
final userGroups = authGroupManager.getUserGroups();
for (final group in userGroups) {
  print('Group: ${group.groupName}, Role: ${authGroupManager.getUserGroupRole(group.groupID)}');
}
```

## 🐛 Troubleshooting

### Common Issues

1. **"Developer Error" on Android**
   - Verify SHA-1 fingerprint is added to Firebase
   - Check package name matches Firebase configuration

2. **"Sign in failed" on iOS**
   - Verify REVERSED_CLIENT_ID is correctly added to Info.plist
   - Check bundle identifier matches Firebase configuration

3. **Firebase rules denying access**
   - Verify rules are deployed correctly
   - Check user authentication state
   - Ensure user UID matches group membership

### Debug Tips
- Check debug console for authentication flow logs (prefixed with 🔐, ✅, ❌)
- Use Firebase Console Authentication logs for detailed error information
- Test with multiple Google accounts to verify group isolation

## 📚 Additional Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)

---

This setup provides a complete, production-ready authentication system that integrates seamlessly with your existing Item Minder architecture while adding secure user-based access control.
