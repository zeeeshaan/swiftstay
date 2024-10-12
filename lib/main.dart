import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swiftstay/User/BottomNavBar.dart';
import 'package:swiftstay/splashscreen.dart';

import 'Service_Provider/BottomNavBar2.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  FirebaseFirestore.instance.enableNetwork().catchError((error) {
    print('Error enabling Firestore network: $error');
  });
  FirebaseFirestore.instance.settings = const Settings(
    host: 'localhost:8080', // If using a local emulator
    sslEnabled: false, // If using a local emulator
  );
  runApp(const MyApp());
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      home: FutureBuilder<Widget>(
        future: _checkUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            return snapshot.data ?? const Splashscreen();
          }
        },
      ),
    );
  }


}
Future<Widget> _checkUserType() async {
  final User? firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    return const Splashscreen();
  }

  final currentUserId = firebaseUser.uid;

  final adminDoc = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUserId)
      .get();
  if (adminDoc.exists) {
    return const BottomNavBar();
  }

  final teacherDoc = await FirebaseFirestore.instance
      .collection('Service_Providers')
      .doc(currentUserId)
      .get();
  if (teacherDoc.exists) {
    return const Bottomnavbar2();
  }


  return const Splashscreen(); // Fallback in case the user is not found in any collection
}



class MyHomePage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, dynamic>> pumps = [
    {'name': 'PSO Pump', 'coordinates': const GeoPoint(33.1514, 73.7516)},
    {'name': 'Shell Petrol Pump', 'coordinates': const GeoPoint(33.1484, 73.7518)},
    {'name': 'Total Parco Pump', 'coordinates': const GeoPoint(33.1536, 73.7498)},
    {'name': 'Attock Petrol Pump', 'coordinates': const GeoPoint(33.1505, 73.7542)},
    {'name': 'Hascol Petrol Pump', 'coordinates': const GeoPoint(33.1520, 73.7525)},
    {'name': 'Byco Petrol Pump', 'coordinates': const GeoPoint(33.1478, 73.7502)},
    {'name': 'GO Pump', 'coordinates': const GeoPoint(33.1551, 73.7547)},
    {'name': 'Admore Gas Station', 'coordinates': const GeoPoint(33.1496, 73.7533)},
    {'name': 'Fuel Max Petrol Pump', 'coordinates': const GeoPoint(33.1527, 73.7509)},
    {'name': 'Zoom Petroleum', 'coordinates': const GeoPoint(33.1500, 73.7520)},
  ];

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petrol Pumps'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            for (var pump in pumps) {
              await _firestoreService.addPump(
                pump['name'],
                pump['coordinates'].latitude,
                pump['coordinates'].longitude,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Pumps added to Firestore'),
            ));
          },
          child: const Text('Save Pumps to Firestore'),
        ),
      ),
    );
  }
}


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPump(String name, double latitude, double longitude) async {
    try {
      await _db.collection('Pumps').add({
        'name': name,
        'coordinates': GeoPoint(latitude, longitude),
      });
    } catch (e) {
      print(e);
    }
  }
}
