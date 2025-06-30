import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/base/res/styles/app_styles.dart';
import 'package:item_minder_flutterapp/base/widgets/groups_widget.dart';
import 'package:item_minder_flutterapp/screens/calendar_screen.dart';
import 'package:item_minder_flutterapp/screens/profile_screen.dart';
import 'package:item_minder_flutterapp/screens/home_screen.dart';
import 'package:item_minder_flutterapp/screens/shopping_list_screen.dart';
import 'package:item_minder_flutterapp/screens/starter_screen.dart';

class BottomNavBar extends StatefulWidget {
  final String currentGroupId;
  const BottomNavBar({super.key, required this.currentGroupId});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final List<Widget> appScreens;

  @override
  void initState() {
    super.initState();
    appScreens = [
      const StarterScreen(),
      HomeScreen(groupId: widget.currentGroupId),
      ShoppingListScreen(currentGroupID: widget.currentGroupId),
      const CalendarScreen(),
      ProfileScreen(groupId: widget.currentGroupId),
    ];
  }

  var _selectedIndex = 1;

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
