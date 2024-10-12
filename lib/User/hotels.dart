import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  _HotelsScreenState createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _cityController = TextEditingController();
  String _selectedCity = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUserCity();
  }

  Future<void> _getCurrentUserCity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('Users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _selectedCity = userDoc['city'] ?? '';
          _cityController.text = _selectedCity;
        });
      }
    }
  }

  Future<void> _showBookingDialog(BuildContext context, DocumentSnapshot hotel, String contact) async {
    final TextEditingController personsController = TextEditingController();
    final TextEditingController roomsController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must fill in the fields and press the button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book ${hotel['name']}'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: personsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Persons',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: Icon(Icons.person, color: Colors.green),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roomsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Rooms',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: Icon(Icons.hotel, color: Colors.green),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.green),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          startDate = picked;
                          startDateController.text = picked.toString().split(' ')[0];
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.green),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          endDate = picked;
                          endDateController.text = picked.toString().split(' ')[0];
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Book'),
              onPressed: () async {
                if (personsController.text.isEmpty || roomsController.text.isEmpty || startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all the fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await _firestore.collection('Bookings').add({
                      'bookerId': user.uid,
                      'serviceProviderId': hotel['userId'],
                      'hotelId': hotel.id,
                      'persons': personsController.text,
                      'rooms': roomsController.text,
                      'startDate': startDate,
                      'endDate': endDate,
                      'contact': contact,
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking Confirmed'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter City',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                suffixIcon: Icon(Icons.search, color: Colors.green),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                  print('Selected City: $_selectedCity'); // Debugging
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Hotels')
                  .where('city', isEqualTo: _selectedCity.isNotEmpty ? _selectedCity : 'defaultCity') // Adjust default value
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hotels found.'));
                }
                final hotels = snapshot.data!.docs;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    childAspectRatio: 0.7, // Adjusted aspect ratio
                  ),
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('Service_Providers')
                          .doc(hotel['userId'])
                          .get(),
                      builder: (context, serviceProviderSnapshot) {
                        if (serviceProviderSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!serviceProviderSnapshot.hasData || !serviceProviderSnapshot.data!.exists) {
                          return const Center(child: Text('Service provider not found.'));
                        }
                        final serviceProvider = serviceProviderSnapshot.data!;
                        final contact = serviceProvider['contact'];

                        return Card(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100, // Increased height
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(hotel['imageUrl'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              hotel['name'] ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.calendar_month, color: Colors.green),
                                              onPressed: () {
                                                _showBookingDialog(context, hotel, contact);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('City: ${hotel['city'] ?? 'N/A'}'),
                                      const SizedBox(height: 4),
                                      Text('Price: \$${hotel['price'] ?? 'N/A'}'),
                                      const SizedBox(height: 4),
                                      Text('Contact: $contact'),
                                      const SizedBox(height: 4),
                                      Text('Address: ${hotel['address'] ?? 'N/A'}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
