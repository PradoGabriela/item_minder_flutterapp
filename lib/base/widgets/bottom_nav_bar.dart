import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/groups_widget.dart';
import 'package:item_minder_flutterapp/screens/calendar_screen.dart';
import 'package:item_minder_flutterapp/screens/profile_screen.dart';
import 'package:item_minder_flutterapp/screens/home_screen.dart';
import 'package:item_minder_flutterapp/screens/shopping_list_screen.dart';
import 'package:item_minder_flutterapp/screens/starter_screen.dart';

/// **Main navigation wrapper that manages screen switching and bottom navigation.**
///
/// [BottomNavBar] serves as the **primary navigation controller** for the Item Minder
/// app, managing the complete user journey from group selection through all main
/// features. It implements a sophisticated navigation pattern where the bottom
/// navigation bar is **conditionally displayed** based on the current screen context.
///
/// **Navigation Architecture:**
/// * **Index 0**: [StarterScreen] (group selection) - **No navigation bar shown**
/// * **Index 1**: [HomeScreen] (inventory management) - Navigation bar visible
/// * **Index 2**: [ShoppingListScreen] (shopping list) - Navigation bar visible
/// * **Index 3**: [CalendarScreen] (calendar view) - Navigation bar visible
/// * **Index 4**: [ProfileScreen] (user profile) - Navigation bar visible
///
/// **Key Features:**
/// * **Group-aware navigation**: Passes group context to relevant screens
/// * **Conditional UI**: Hides navigation on group selection screen
/// * **Consistent styling**: Uses [AppStyles] for brand-consistent appearance
/// * **Icon-based navigation**: Clear visual indicators for each section
///
/// **Important Usage Notes:**
/// * Must receive a valid `currentGroupId` for group-specific screens
/// * Starts with index 1 (HomeScreen) by default, not 0 (StarterScreen)
/// * The navigation bar only appears when not on the StarterScreen
///
/// {@tool snippet}
/// ```dart
/// // Navigate to main app interface with group context
/// Navigator.pushReplacement(
///   context,
///   MaterialPageRoute(
///     builder: (context) => BottomNavBar(
///       currentGroupId: selectedGroup.groupID,
///     ),
///   ),
/// );
/// ```
/// {@end-tool}
class BottomNavBar extends StatefulWidget {
  /// **Group identifier** for context-aware screen navigation.
  ///
  /// This ID is passed to group-specific screens ([HomeScreen], [ShoppingListScreen],
  /// [ProfileScreen]) to ensure they display data for the correct user group.
  /// Must be a valid group ID that exists in the user's group list.
  final String currentGroupId;

  /// Creates a [BottomNavBar] with the specified group context.
  ///
  /// **Parameters:**
  /// * [currentGroupId] - The active group identifier for filtering screen content
  const BottomNavBar({super.key, required this.currentGroupId});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  /// **Screen collection** for navigation system.
  ///
  /// Contains all navigable screens in the app, initialized with proper
  /// group context where required. The list order corresponds to navigation
  /// bar index positions.
  late final List<Widget> appScreens;

  @override
  void initState() {
    super.initState();
    // Initialize screens with group context for data filtering
    appScreens = [
      const StarterScreen(),
      HomeScreen(groupId: widget.currentGroupId),
      ShoppingListScreen(currentGroupID: widget.currentGroupId),
      const CalendarScreen(),
      ProfileScreen(groupId: widget.currentGroupId),
    ];
  }

  /// **Current navigation index** - defaults to HomeScreen (index 1).
  ///
  /// Note: Starts at index 1 (HomeScreen) rather than 0 (StarterScreen)
  /// because users typically navigate here after selecting a group.
  var _selectedIndex = 1;

  /// **Navigation handler** for bottom navigation bar taps.
  ///
  /// Updates the selected index to switch between screens. Called automatically
  /// when users tap navigation bar items.
  ///
  /// **Parameters:**
  /// * [index] - The target screen index to navigate to
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[_selectedIndex],
      bottomNavigationBar: _selectedIndex == 0
          ? null
          : BottomNavigationBar(
              backgroundColor: AppStyles().getPrimaryColor(),
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    FluentSystemIcons.ic_fluent_home_filled,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FluentSystemIcons.ic_fluent_notebook_filled,
                  ),
                  label: 'Starter',
                ),
                BottomNavigationBarItem(
                  //shopping icon
                  icon: Icon(Icons.shopping_cart),
                  label: 'Shopping List',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FluentSystemIcons.ic_fluent_calendar_date_filled),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FluentSystemIcons.ic_fluent_person_filled),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
