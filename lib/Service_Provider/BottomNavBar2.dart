import 'package:flutter/material.dart';
import 'package:swiftstay/Service_Provider/Dashboard.dart';
import 'package:swiftstay/Service_Provider/services.dart';

import 'Provider_profile.dart';
import 'mybooking.dart';




class Bottomnavbar2 extends StatefulWidget {
  const Bottomnavbar2({super.key});

  @override
  State<Bottomnavbar2> createState() => _Bottomnavbar2State();
}

class _Bottomnavbar2State extends State<Bottomnavbar2> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Dashboard(),
    Services(),
    Mybooking(),
    ProviderProfile(),







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
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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
