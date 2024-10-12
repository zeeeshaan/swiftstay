import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Myservices extends StatefulWidget {
  const Myservices({super.key});

  @override
  State<Myservices> createState() => _MyservicesState();
}

class _MyservicesState extends State<Myservices> {
  String _selectedService = 'Hotels'; // Default selected service
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          _buildServiceCategoryRadioButtons(),
          Expanded(
            child: _buildServiceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategoryRadioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRadioButton('Hotels'),
        _buildRadioButton('Rent_Car'),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedService,
          onChanged: (String? newValue) {
            setState(() {
              _selectedService = newValue!;
            });
          },
        ),
        Text(value),
      ],
    );
  }

  Widget _buildServiceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(_selectedService)
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching services'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No services found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final service = snapshot.data!.docs[index];
            return _buildServiceItem(service);
          },
        );
      },
    );
  }

  Widget _buildServiceItem(DocumentSnapshot service) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 50,
          backgroundImage: service['imageUrl'] != null
              ? NetworkImage(service['imageUrl'])
              : const AssetImage('assets/placeholder.jpg') as ImageProvider,
        ),
        title: Text(service['name']),
        subtitle: Text(service['address']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Navigate to the edit screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditServiceScreen(service: service),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _deleteService(service.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      await FirebaseFirestore.instance.collection(_selectedService).doc(serviceId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete service: $e')),
      );
    }
  }
}

class EditServiceScreen extends StatefulWidget {
  final DocumentSnapshot service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service['name']);
    _addressController = TextEditingController(text: widget.service['address']);
    _priceController = TextEditingController(text: widget.service['price']);
  }

  Future<void> _updateService() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection(widget.service.reference.parent.id)
            .doc(widget.service.id)
            .update({
          'name': _nameController.text,
          'address': _addressController.text,
          'price': _priceController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update service: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name', Icons.business),
              _buildTextField(_addressController, 'Address', Icons.location_on),
              _buildTextField(_priceController, 'Price', Icons.attach_money),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50), // Increase button width
                ),
                child: const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
