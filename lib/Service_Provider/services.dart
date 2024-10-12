import 'package:flutter/material.dart';
import 'package:swiftstay/Service_Provider/ServiceManagment.dart';

import 'MyServices.dart';


class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  bool isMyServicesSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          const SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceButton('My Services', Icons.list, isMyServicesSelected, () {
                setState(() {
                  isMyServicesSelected = true;
                });
              }),
              _buildServiceButton('Add Service', Icons.add, !isMyServicesSelected, () {
                setState(() {
                  isMyServicesSelected = false;
                });
              }),
            ],
          ),
          Expanded(
            child: isMyServicesSelected ? const Myservices() : const AddService(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(String text, IconData icon, bool isSelected, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.blue, backgroundColor: isSelected ? Colors.blue : Colors.white,
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.blue),
      label: Text(
        text,
        style: TextStyle(color: isSelected ? Colors.white : Colors.blue),
      ),
    );
  }
}
