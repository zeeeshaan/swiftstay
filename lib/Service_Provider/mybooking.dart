import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Mybooking extends StatefulWidget {
  const Mybooking({super.key});

  @override
  State<Mybooking> createState() => _MybookingState();
}

class _MybookingState extends State<Mybooking> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedCategory = 'Hotels'; // Default to Hotels

  Stream<List<Map<String, dynamic>>> _getBookingsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection(_selectedCategory == 'Hotels' ? 'Bookings' : 'CarBookings')
        .where('serviceProviderId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> bookingsWithDetails = [];
      for (var booking in snapshot.docs) {
        var bookingData = booking.data();
        if (_selectedCategory == 'Hotels') {
          var hotelDoc = await _firestore.collection('Hotels').doc(bookingData['hotelId']).get();
          bookingData['hotelName'] = hotelDoc.exists ? hotelDoc['name'] : 'Unknown';
          bookingData['city'] = hotelDoc.exists ? hotelDoc['city'] : 'Unknown';
        }
        bookingsWithDetails.add({...bookingData, 'id': booking.id});
      }
      return bookingsWithDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'Hotels';
                  });
                },
                child: const Text('Hotels'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = 'Cars';
                  });
                },
                child: const Text('Cars'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getBookingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No bookings found.'));
                }
                final bookings = snapshot.data!;
                final dateFormat = DateFormat('dd-MM-yyyy');

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final startDate = (booking['startDate'] as Timestamp?)?.toDate();
                    final endDate = (booking['endDate'] as Timestamp?)?.toDate();

                    return Card(
                      child: ListTile(
                        title: Text(_selectedCategory == 'Hotels'
                            ? 'Hotel Name: ${booking['hotelName']},\nCity: ${booking['city']}'
                            : 'Car Name: ${booking['carname']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Persons: ${booking['persons'] ?? 'N/A'}'),
                            if (_selectedCategory == 'Hotels')
                              Text('Rooms: ${booking['rooms'] ?? 'N/A'}')
                            else
                              Text('Days: ${booking['days'] ?? 'N/A'}'),
                            Text('Start Date: ${startDate != null ? dateFormat.format(startDate) : 'N/A'}'),
                            Text('End Date: ${endDate != null ? dateFormat.format(endDate) : 'N/A'}'),
                            Text('Contact: ${booking['contact'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _firestore
                                .collection(_selectedCategory == 'Hotels' ? 'Bookings' : 'CarBookings')
                                .doc(booking['id'])
                                .delete();
                          },
                        ),
                      ),
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
