import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:item_minder_flutterapp/services/auth_service.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

/// **Reusable authentication UI widget with adaptive states.**
///
/// [AuthWidget] provides a complete authentication interface that automatically
/// adapts based on the user's current authentication state. It integrates
/// seamlessly with the app's existing design system and follows Material Design
/// principles.
///
/// **Features:**
/// * **Adaptive UI**: Shows login or user profile based on auth state
/// * **Google Sign-In**: Native Google OAuth integration
/// * **Error Handling**: User-friendly error messages and loading states
/// * **Consistent Design**: Uses app's existing [AppStyles] theming
/// * **Accessibility**: Proper semantic labels and touch targets
///
/// **States:**
/// * **Signed Out**: Shows Google Sign-In button with app branding
/// * **Loading**: Shows progress indicator during authentication
/// * **Signed In**: Shows user profile with welcome message and sign-out
/// * **Error**: Shows error message with retry option
///
/// **Usage:**
/// ```dart
/// // In any screen that needs authentication
/// AuthWidget(
///   onAuthStateChanged: (User? user) {
///     // Handle authentication state changes
///     if (user != null) {
///       // User signed in, navigate to main app
///     } else {
///       // User signed out, show onboarding
///     }
///   },
/// )
/// ```
class AuthWidget extends StatefulWidget {
  /// Callback fired when authentication state changes.
  /// Provides the current [User] or null if signed out.
  final void Function(User? user)? onAuthStateChanged;

  /// Whether to show a compact version of the widget.
  /// Useful for embedding in app bars or smaller spaces.
  final bool compact;

  /// Custom title text override.
  /// If null, uses default app-appropriate titles.
  final String? customTitle;

  /// Custom subtitle text override.
  /// If null, uses default context-appropriate subtitles.
  final String? customSubtitle;

  const AuthWidget({
    super.key,
    this.onAuthStateChanged,
    this.compact = false,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tryAutoSignIn();
  }

  /// Attempt automatic sign-in using cached credentials.
  Future<void> _tryAutoSignIn() async {
    if (_authService.isSignedIn) {
      // User is already signed in
      widget.onAuthStateChanged?.call(_authService.currentUser);
      return;
    }

    try {
      final user = await _authService.signInSilently();
      if (mounted) {
        widget.onAuthStateChanged?.call(user);
      }
    } catch (e) {
      // Silent sign-in failed, which is expected if no cached credentials
      debugPrint('Auto sign-in failed: $e');
    }
  }

  /// Handle Google Sign-In button press.
  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (mounted) {
        if (user != null) {
          widget.onAuthStateChanged?.call(user);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Welcome, ${user.displayName ?? 'User'}!'),
                ],
              ),
              backgroundColor: AppStyles().getPrimaryColor(),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });

        // Show error in snackbar as well
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text(_errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleGoogleSignIn,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle sign-out button press.
  Future<void> _handleSignOut() async {
    if (_isLoading) return;

    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signOut();

      if (mounted) {
        widget.onAuthStateChanged?.call(null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 8),
                Text('Signed out successfully'),
              ],
            ),
            backgroundColor: Colors.grey[600],
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign out failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting &&
            !_authService.isSignedIn) {
          return _buildLoadingState();
        }

        if (user != null) {
          return _buildSignedInState(user);
        } else {
          return _buildSignedOutState();
        }
      },
    );
  }

  /// Build the loading state UI.
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(widget.compact ? 16 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppStyles().getPrimaryColor()),
          ),
          if (!widget.compact) ...[
            SizedBox(height: 16),
            Text(
              'Connecting...',
              style: AppStyles().bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build the signed-out state UI with Google Sign-In button.
  Widget _buildSignedOutState() {
    return Container(
      padding: EdgeInsets.all(widget.compact ? 16 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App logo or icon
          if (!widget.compact) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppStyles().getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 40,
                color: AppStyles().getPrimaryColor(),
              ),
            ),
            SizedBox(height: 24),
          ],

          // Title
          Text(
            widget.customTitle ??
                (widget.compact ? 'Sign In' : 'Welcome to Item Minder'),
            style: widget.compact
                ? AppStyles().buttonTextStyle
                : AppStyles().titleStyle,
            textAlign: TextAlign.center,
          ),

          // Subtitle
          if (!widget.compact) ...[
            SizedBox(height: 8),
            Text(
              widget.customSubtitle ??
                  'Sign in to sync your inventory across devices',
              style: AppStyles().bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
          ] else ...[
            SizedBox(height: 16),
          ],

          // Error message
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Google Sign-In Button
          SizedBox(
            width: double.infinity,
            height: widget.compact ? 40 : 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Image.asset(
                      'assets/icons/logo.png', // Using your existing logo
                      width: 20,
                      height: 20,
                    ),
              label: Text(
                _isLoading ? 'Signing in...' : 'Continue with Google',
                style: TextStyle(
                  fontSize: widget.compact ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles().getPrimaryColor(),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Privacy note
          if (!widget.compact) ...[
            SizedBox(height: 16),
            Text(
              'By signing in, you agree to sync your data securely.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Build the signed-in state UI with user profile.
  Widget _buildSignedInState(User user) {
    return Container(
      padding: EdgeInsets.all(widget.compact ? 12 : 20),
      child:
          widget.compact ? _buildCompactProfile(user) : _buildFullProfile(user),
    );
  }

  /// Build compact user profile for app bars.
  Widget _buildCompactProfile(User user) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: AppStyles().getPrimaryColor().withOpacity(0.1),
          backgroundImage:
              user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? Text(
                  (user.displayName ?? user.email ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    color: AppStyles().getPrimaryColor(),
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        SizedBox(width: 12),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.displayName ?? 'User',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (user.email != null)
                Text(
                  user.email!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),

        // Sign out button
        IconButton(
          onPressed: _isLoading ? null : _handleSignOut,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.logout, size: 18),
          tooltip: 'Sign Out',
          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  /// Build full user profile for dedicated auth screens.
  Widget _buildFullProfile(User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // User avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: AppStyles().getPrimaryColor().withOpacity(0.1),
          backgroundImage:
              user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? Text(
                  (user.displayName ?? user.email ?? 'U')[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    color: AppStyles().getPrimaryColor(),
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        SizedBox(height: 16),

        // Welcome message
        Text(
          'Welcome back!',
          style: AppStyles().titleStyle,
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8),

        // User name
        Text(
          user.displayName ?? 'User',
          style: AppStyles().formFieldStyle.copyWith(
                color: AppStyles().getPrimaryColor(),
              ),
          textAlign: TextAlign.center,
        ),

        // User email
        if (user.email != null) ...[
          SizedBox(height: 4),
          Text(
            user.email!,
            style: AppStyles().bodyStyle.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],

        SizedBox(height: 24),

        // Sign out button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleSignOut,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.logout),
            label: Text(_isLoading ? 'Signing out...' : 'Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
