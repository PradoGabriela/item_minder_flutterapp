import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:item_minder_flutterapp/base/widgets/auth_widget.dart';
import 'package:item_minder_flutterapp/services/auth_service.dart';
import 'package:item_minder_flutterapp/services/auth_group_manager.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';

/// **Example screen demonstrating Firebase Authentication integration.**
///
/// This screen shows how to use the [AuthWidget] and [AuthService] components
/// to create an authentication-aware interface that adapts to user sign-in state.
///
/// **Features Demonstrated:**
/// * Reactive authentication state management
/// * User-specific group display
/// * Authentication-aware navigation
/// * Integration with existing app architecture
///
/// **Usage:** Use this as a reference for implementing authentication
/// in your existing screens or as a standalone authentication screen.
class AuthExampleScreen extends StatefulWidget {
  const AuthExampleScreen({super.key});

  @override
  State<AuthExampleScreen> createState() => _AuthExampleScreenState();
}

class _AuthExampleScreenState extends State<AuthExampleScreen> {
  final AuthService _authService = AuthService();
  final AuthGroupManager _authGroupManager = AuthGroupManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Auth Integration',
          style: AppStyles().appBarTextStyle,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: _authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingView();
            }

            final user = snapshot.data;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Authentication Widget Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authentication Status',
                            style: AppStyles().catTitleStyle,
                          ),
                          SizedBox(height: 16),
                          AuthWidget(
                            onAuthStateChanged: (User? user) {
                              _handleAuthStateChange(user);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // User Groups Section (only shown when authenticated)
                  if (user != null) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Groups',
                              style: AppStyles().catTitleStyle,
                            ),
                            SizedBox(height: 16),
                            _buildUserGroupsList(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // User Information Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User Information',
                              style: AppStyles().catTitleStyle,
                            ),
                            SizedBox(height: 16),
                            _buildUserInfoSection(user),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Group Management Actions
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Management',
                              style: AppStyles().catTitleStyle,
                            ),
                            SizedBox(height: 16),
                            _buildGroupManagementActions(),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Welcome message for non-authenticated users
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.security,
                              size: 48,
                              color: AppStyles().getPrimaryColor(),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Secure Authentication',
                              style: AppStyles().catTitleStyle,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Sign in to access your personalized inventory groups and sync your data securely across devices.',
                              style: AppStyles().bodyStyle.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Security Information
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppStyles().getPrimaryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppStyles().getPrimaryColor().withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppStyles().getPrimaryColor(),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Security Features',
                              style: AppStyles().formTextStyle,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Firebase Authentication with Google Sign-In\n'
                          '• Secure group-based access control\n'
                          '• Real-time data synchronization\n'
                          '• User-specific inventory management\n'
                          '• Offline-first architecture with cloud sync',
                          style: AppStyles().bodyStyle.copyWith(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppStyles().getPrimaryColor()),
          ),
          SizedBox(height: 16),
          Text(
            'Loading authentication state...',
            style: AppStyles().bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildUserGroupsList() {
    final userGroups = _authGroupManager.getUserGroups();

    if (userGroups.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.group_add,
              size: 32,
              color: Colors.grey[500],
            ),
            SizedBox(height: 8),
            Text(
              'No groups yet',
              style: AppStyles().formTextStyle.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            SizedBox(height: 4),
            Text(
              'Create or join a group to start managing inventory',
              style: AppStyles().bodyStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: userGroups.map((group) {
        final isOwner = _authGroupManager.isUserGroupOwner(group);
        final role = _authGroupManager.getUserGroupRole(group.groupID);

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppStyles().getPrimaryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group,
                  color: AppStyles().getPrimaryColor(),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: AppStyles().formFieldStyle,
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isOwner ? Icons.star : Icons.person,
                          size: 12,
                          color: isOwner ? Colors.amber : Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${role.toUpperCase()} • ${group.members.length} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserInfoSection(User user) {
    return Column(
      children: [
        _buildInfoRow('User ID', user.uid),
        _buildInfoRow('Email', user.email ?? 'Not provided'),
        _buildInfoRow('Display Name', user.displayName ?? 'Not set'),
        _buildInfoRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
        if (user.metadata.creationTime != null)
          _buildInfoRow(
              'Account Created', _formatDate(user.metadata.creationTime!)),
        if (user.metadata.lastSignInTime != null)
          _buildInfoRow(
              'Last Sign In', _formatDate(user.metadata.lastSignInTime!)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppStyles().formTextStyle,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles().bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupManagementActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _createTestGroup,
            icon: Icon(Icons.add),
            label: Text('Create Test Group'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles().getPrimaryColor(),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showJoinGroupDialog,
            icon: Icon(Icons.group_add),
            label: Text('Join Group'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStyles().getPrimaryColor(),
              side: BorderSide(color: AppStyles().getPrimaryColor()),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAuthStateChange(User? user) {
    setState(() {
      // Trigger rebuild to update group display and user info
    });

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${user.displayName ?? 'User'}!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed out successfully'),
          backgroundColor: Colors.grey[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _createTestGroup() async {
    try {
      final success = await _authGroupManager.createGroupAsUser(
        groupName: 'Test Group ${DateTime.now().millisecondsSinceEpoch}',
        groupIconUrl: 'assets/icons/home.png',
        categoriesNames: ['Kitchen', 'Bathroom', 'Living Room'],
      );

      if (success) {
        setState(() {
          // Refresh groups display
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test group created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create group: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showJoinGroupDialog() {
    final TextEditingController groupIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the group ID to join:'),
            SizedBox(height: 16),
            TextField(
              controller: groupIdController,
              decoration: InputDecoration(
                labelText: 'Group ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _joinGroup(groupIdController.text.trim());
            },
            child: Text('Join'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinGroup(String groupId) async {
    if (groupId.isEmpty) return;

    try {
      final success = await _authGroupManager.joinGroupAsUser(groupId, context);

      if (success) {
        setState(() {
          // Refresh groups display
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join group: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
