import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swiftstay/User/buggetrecomendation.dart';
import 'package:swiftstay/User/placesdiscription.dart';
import 'package:weather/weather.dart';

import '../splashscreen.dart';
import 'Suggestions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController _cityController = TextEditingController();
  final WeatherFactory _weatherFactory = WeatherFactory("52f9c4b90d7dfea12bef7e6cc399e355"); // Replace with your free API key

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Splashscreen()),
    );
  }

  Future<void> _showWeatherDialog(String city) async {
    try {
      Weather weather = await _weatherFactory.currentWeatherByCityName(city);
      final temperature = weather.temperature?.celsius?.toStringAsFixed(1);
      final description = weather.weatherDescription;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Weather in $city'),
          content: Text('Temperature: $temperature°C\nDescription: $description'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('City not found or failed to fetch weather data');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToNewPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Description()),
    );
  }
  final MapController _mapController = MapController();
  String _currentLocation = '';
  LatLng? userLocation;
  List<Marker> markers = [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((_) {
      _getCurrentLocation();
    });
    _searchProducts();
    //_getCurrentUser();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = 'Location permissions are permanently denied.';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = '${position.latitude},${position.longitude}';
      userLocation = LatLng(position.latitude, position.longitude);
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: userLocation!,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    });
  }

  Future<void> _searchProducts() async {
    List<Marker> newMarkers = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pumps')
        .get();

    for (var doc in snapshot.docs) {
      String coordinates = doc['coordinates'];
      List<String> parts = coordinates.split(',');
      if (parts.length == 2) {
        double latitude = double.parse(parts[0]);
        double longitude = double.parse(parts[1]);
        newMarkers.add(
          Marker(
            width: 80,
            height: 80,
            point: LatLng(latitude, longitude),
            child: GestureDetector(
              onTap: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context)=> BuyersProductDetails(productId: doc["id"])));
              },
              child: const Icon(
                Icons.gas_meter,
                color: Colors.green,
                size: 40,
              ),
            ),
          ),
        );
      }
    }

    setState(() {
      markers = newMarkers;
      if (userLocation != null) {
        markers.add(
          Marker(
            width: 80,
            height: 80,
            point: userLocation!,
            child: const Icon(
              Icons.person_pin_circle,
              color: Colors.blue,
            ),
          ),
        );
      }
    });
  }

  Future<void> _retryLocation() async {
    await _getCurrentLocation();
  }

  void _showMap() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 1.0,
            height: MediaQuery.of(context).size.height * 0.80,
            child: userLocation == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_currentLocation),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryLocation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLocation!,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showMap,
        backgroundColor: Colors.white,
        child: const Icon(Icons.location_on, color: Colors.blue,),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
             const Text('Dashboard', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 20,),
            GestureDetector(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetRecommendation()),
              );

              },child: const Icon(Icons.monetization_on_sharp, color:  Colors.white,))
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            //height: 100,
            color: Colors.deepPurple,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Swift Stay",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter city name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.green),
                            onPressed: () {
                              final city = _cityController.text;
                              if (city.isNotEmpty) {
                                _showWeatherDialog(city);
                              } else {
                                _showErrorDialog('Please enter a city name');
                              }
                            },
                          ),
                        ),
                        onSubmitted: (city) {
                          if (city.isNotEmpty) {
                            _showWeatherDialog(city);
                          } else {
                            _showErrorDialog('Please enter a city name');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            // color: Colors.green,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCard('assets/arengkel.jpg', 'Areng kel'),

                  _buildCard('assets/toubat.jpg', 'Naran'),
                  _buildCard('assets/naran.jpg', 'Toubat'),
                  _buildCard('assets/sharda.jpg', 'Sharda'),
                ],
              ),
            ),
          ),

          const Text("Suggestions"),
          const SizedBox(height: 2,),
          const Expanded(child: Suggestions()),
        ],
      ),
    );
  }

  Widget _buildCard(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: _navigateToNewPage,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
