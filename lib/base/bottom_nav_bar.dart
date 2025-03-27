import 'package:flutter/material.dart';
import 'package:item_minder_flutterapp/screens/home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    HomeScreen(),
    const Text('Shopping List'),
    const Text('Calendar'),
    const Text('Profile'),
  ];

  var _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Minder'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: appScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber.shade800,
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_sharp),
            label: 'Shopping List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
