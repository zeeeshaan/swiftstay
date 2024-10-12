import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    FirebaseFirestore.instance.enableNetwork().catchError((error) {
      print('Error enabling Firestore network: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onTap: () async {
            try {
              DocumentReference docRef = await FirebaseFirestore.instance
                  .collection('yourCollection')
                  .add({
                'field1': 'value1',
                'field2': 'value2',
              });
              print('Document written with ID: ${docRef.id}');
            } catch (e) {
              print('Error writing document: $e');
            }
          },
          child: const Center(
            child: Text("testttt"),
          ),
        ),
      ),
    );
  }
}
