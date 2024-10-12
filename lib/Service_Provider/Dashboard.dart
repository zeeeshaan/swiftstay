import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiftstay/splashscreen.dart'; // Make sure to import the SplashScreen widget

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int hotelCount = 0;
  int rentCarCount = 0;
  int bookingsCount = 0;

  String username = "";
  String businessName = "";
  String contact = "";
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchCounts();
  }

  Future<void> _loadUserData() async {

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Service_Providers')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'];
             contact= userDoc['contact'];
            businessName= userDoc['businessName'] ?? '';

          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load user data: $e')));
    }
  }

  Future<void> _fetchCounts() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetching Hotels count
    final hotelsSnapshot = await FirebaseFirestore.instance
        .collection('Hotels')
        .where('userId', isEqualTo: userId)
        .get();
    setState(() {
      hotelCount = hotelsSnapshot.size;
    });

    // Fetching Rent_Car count
    final rentCarSnapshot = await FirebaseFirestore.instance
        .collection('Rent_Car')
        .where('userId', isEqualTo: userId)
        .get();
    setState(() {
      rentCarCount = rentCarSnapshot.size;
    });

    // Fetching Bookings count where serviceProviderId is equal to the current user ID
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('serviceProviderId', isEqualTo: userId)
        .get();
    setState(() {
      bookingsCount = bookingsSnapshot.size;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Splashscreen()),
    );
  }

  Widget _buildDashboardItem(String title, IconData icon, int count) {
    return GestureDetector(
      onTap: () {
        if (title == "Logout") {
          _logout();
        }
      },
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
         const SizedBox(height: 10),
            (title!="Logout")?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.green,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ):  Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Center(child: Text('Dashboard', style: TextStyle(color: Colors.black))),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.green,
                            ),
                            child: const Center(
                              child: Icon(Icons.person,size: 30, color: Colors.white,),
                            ),
                          ),
                          const SizedBox(width: 8,),
                          Column(
                            children: [
                              Text(username, style:  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                              Text(businessName, style:  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                            ],
                          ),

                        ],
                      ),

                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardItem("Bookings", Icons.book, bookingsCount),
                _buildDashboardItem("Hotels", Icons.hotel, hotelCount),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardItem("Vehicles", Icons.directions_car, rentCarCount),
                _buildDashboardItem("Logout", Icons.logout, 0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
