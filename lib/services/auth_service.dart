import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// **Firebase Authentication service with Google Sign-In integration.**
///
/// [AuthService] provides a complete authentication layer for the Item Minder app,
/// handling Google Sign-In, sign-out, and Firebase Auth state management.
/// It follows the same singleton pattern as other managers in the app.
///
/// **Core Responsibilities:**
/// * **Google Sign-In**: Handle OAuth flow and credential exchange
/// * **Firebase Auth**: Manage user authentication state
/// * **User State**: Track signed-in user information
/// * **Error Handling**: Provide comprehensive error management
/// * **Auto Sign-In**: Handle persistent authentication sessions
///
/// **Integration Points:**
/// * Works seamlessly with existing Firebase Realtime Database
/// * Provides user UID for security rules implementation
/// * Maintains compatibility with existing manager pattern
///
/// **Usage:**
/// ```dart
/// final authService = AuthService();
///
/// // Sign in with Google
/// final user = await authService.signInWithGoogle();
///
/// // Check current user
/// final currentUser = authService.currentUser;
///
/// // Sign out
/// await authService.signOut();
/// ```
class AuthService {
  // Singleton pattern implementation
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth and Google Sign-In instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Current authenticated user from Firebase Auth.
  /// Returns null if no user is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes.
  /// Useful for reactive UI updates based on auth state.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// User ID for Firebase security rules.
  /// Returns null if no user is authenticated.
  String? get userUid => currentUser?.uid;

  /// User display name for UI purposes.
  /// Falls back to email if display name is not available.
  String? get userDisplayName =>
      currentUser?.displayName ?? currentUser?.email?.split('@')[0];

  /// User email address.
  String? get userEmail => currentUser?.email;

  /// User profile photo URL.
  String? get userPhotoUrl => currentUser?.photoURL;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// **Sign in with Google using OAuth flow.**
  ///
  /// Handles the complete Google Sign-In process including:
  /// 1. Google OAuth authentication
  /// 2. Firebase credential creation
  /// 3. Firebase Auth sign-in
  /// 4. Error handling and logging
  ///
  /// **Returns:**
  /// * [User?] - The signed-in Firebase user, or null if sign-in failed
  ///
  /// **Throws:**
  /// * [FirebaseAuthException] - Firebase-specific authentication errors
  /// * [Exception] - General authentication errors
  ///
  /// **Common Error Scenarios:**
  /// * User cancels sign-in process
  /// * Network connectivity issues
  /// * Firebase project configuration problems
  /// * Google Sign-In configuration issues
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Google Sign-In process...');

      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        return null;
      }

      debugPrint('✅ Google Sign-In successful: ${googleUser.email}');

      // Step 2: Obtain Google Auth credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('❌ Failed to obtain Google Auth tokens');
        throw Exception('Failed to obtain Google authentication tokens');
      }

      // Step 3: Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with Google credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        debugPrint(
            '🎉 Firebase Auth successful: ${user.email} (UID: ${user.uid})');
        debugPrint('   Display Name: ${user.displayName}');
        debugPrint('   Photo URL: ${user.photoURL}');
      } else {
        debugPrint('❌ Firebase Auth failed: User is null');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');

      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception(
              'An account already exists with a different sign-in method.');
        case 'invalid-credential':
          throw Exception('Invalid authentication credentials.');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled for this project.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'user-not-found':
          throw Exception('No user found with these credentials.');
        case 'wrong-password':
          throw Exception('Invalid password.');
        case 'invalid-verification-code':
          throw Exception('Invalid verification code.');
        case 'invalid-verification-id':
          throw Exception('Invalid verification ID.');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected sign-in error: $e');
      throw Exception('Sign-in failed: $e');
    }
  }

  /// **Sign out from both Firebase Auth and Google Sign-In.**
  ///
  /// Performs a complete sign-out process that:
  /// 1. Signs out from Firebase Auth
  /// 2. Signs out from Google Sign-In
  /// 3. Clears all authentication state
  /// 4. Handles any errors gracefully
  ///
  /// **Important:** This method ensures complete logout from both services
  /// to prevent authentication state inconsistencies.
  ///
  /// **Throws:**
  /// * [Exception] - If sign-out fails for any reason
  Future<void> signOut() async {
    try {
      debugPrint('🔓 Starting sign-out process...');

      // Sign out from Firebase Auth
      await _firebaseAuth.signOut();
      debugPrint('✅ Firebase Auth sign-out successful');

      // Sign out from Google Sign-In
      await _googleSignIn.signOut();
      debugPrint('✅ Google Sign-In sign-out successful');

      debugPrint('🎉 Complete sign-out successful');
    } catch (e) {
      debugPrint('❌ Sign-out error: $e');
      throw Exception('Sign-out failed: $e');
    }
  }

  /// **Silent sign-in attempt using existing Google credentials.**
  ///
  /// Attempts to sign in without showing the Google Sign-In UI by using
  /// previously cached credentials. This is useful for:
  /// * App startup automatic sign-in
  /// * Restoring user sessions
  /// * Background authentication refresh
  ///
  /// **Returns:**
  /// * [User?] - The signed-in Firebase user, or null if silent sign-in failed
  ///
  /// **Note:** This method will not show any UI and will fail silently
  /// if no cached credentials are available.
  Future<User?> signInSilently() async {
    try {
      debugPrint('🔄 Attempting silent sign-in...');

      // Try to sign in silently with Google
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();

      if (googleUser == null) {
        debugPrint('ℹ️ No cached Google credentials found');
        return null;
      }

      debugPrint('✅ Silent Google Sign-In successful: ${googleUser.email}');

      // Get authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('❌ Failed to obtain Google Auth tokens silently');
        return null;
      }

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        debugPrint('🎉 Silent Firebase Auth successful: ${user.email}');
      }

      return user;
    } catch (e) {
      debugPrint('ℹ️ Silent sign-in failed: $e');
      return null;
    }
  }

  /// **Delete the current user account.**
  ///
  /// Permanently deletes the user's Firebase Auth account. This action:
  /// * Cannot be undone
  /// * Requires recent authentication
  /// * May fail if the user signed in too long ago
  ///
  /// **Important:** Consider implementing re-authentication before calling
  /// this method for security purposes.
  ///
  /// **Throws:**
  /// * [FirebaseAuthException] - If deletion fails
  /// * [Exception] - If no user is currently signed in
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      debugPrint('🗑️ Deleting user account: ${user.email}');

      await user.delete();

      // Also sign out from Google to clear all state
      await _googleSignIn.signOut();

      debugPrint('✅ User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Account deletion error: ${e.code} - ${e.message}');

      if (e.code == 'requires-recent-login') {
        throw Exception('Please sign in again before deleting your account.');
      }

      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected account deletion error: $e');
      throw Exception('Account deletion failed: $e');
    }
  }

  /// **Reload the current user's profile information.**
  ///
  /// Refreshes the user's profile data from Firebase Auth.
  /// Useful after profile updates or when you need the latest user information.
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
      debugPrint('✅ User profile reloaded');
    } catch (e) {
      debugPrint('❌ Failed to reload user: $e');
    }
  }

  /// **Get user information for debugging purposes.**
  ///
  /// Returns a formatted string containing current user information.
  /// Useful for logging and debugging authentication state.
  String getUserInfo() {
    if (!isSignedIn) {
      return 'No user signed in';
    }

    return '''
👤 User Information:
   UID: ${userUid}
   Email: ${userEmail}
   Display Name: ${userDisplayName}
   Photo URL: ${userPhotoUrl}
   Email Verified: ${currentUser?.emailVerified}
   Creation Time: ${currentUser?.metadata.creationTime}
   Last Sign-In: ${currentUser?.metadata.lastSignInTime}
''';
  }
}
