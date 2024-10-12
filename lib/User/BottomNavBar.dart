import 'package:flutter/material.dart';
import 'package:swiftstay/User/profile.dart';
import 'booking.dart';
import 'cars.dart';

import 'home.dart';
import 'hotels.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HotelsScreen(),
    RentACarScreen(),
    ProfileScreen(),
    BookingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Hotels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Cars',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.blue,
        unselectedLabelStyle: const TextStyle(color: Colors.green),
        selectedLabelStyle: const TextStyle(color: Colors.blue),
        onTap: _onItemTapped,
      ),
    );
  }
}
