import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedService;
  File? _selectedImage;
  String _selectedCity = 'Mirpur'; // Default city
  bool _isLoading = false; // Loading state

  final List<String> _cities = [
    'Mirpur', // Add default city to the list
    'Karachi',
    'Lahore',
    'Islamabad',
    'Quetta',
    'Peshawar',
    // Add more cities as needed
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('services/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(image);
      return await imageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_selectedService == null) {
      _showSnackbar('Please select a service category');
      return;
    }
    if (_selectedImage == null) {
      _showSnackbar('Please select an image');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImage(_selectedImage!);
        }

        final collection = _selectedService == 'Hotels' ? 'Hotels' : 'Rent_Car';
        final userId = FirebaseAuth.instance.currentUser?.uid;

        await FirebaseFirestore.instance.collection(collection).add({
          'name': _nameController.text,
          'address': _addressController.text,
          'city': _selectedCity,
          'price': _priceController.text,
          'imageUrl': imageUrl,
          'userId': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service added successfully to $collection')),
        );

        // Clear form fields after successful submission
        _nameController.clear();
        _addressController.clear();
        _priceController.clear();
        setState(() {
          _selectedImage = null;
          _selectedService = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add service: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildServiceCategoryRadioButtons(),
              const SizedBox(height: 20),
              _selectedImage == null
                  ? GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Text("Please Select Image")),
                ),
              )
                  : Image.file(
                _selectedImage!,
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              if (_selectedService != null) ..._buildFormFields(),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50), // Increase button width
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildTextField(_nameController, _selectedService == 'Hotels' ? 'Hotel Name' : 'Car Name', Icons.business),
      _buildTextField(_addressController, 'Address', Icons.location_on),
      _buildCityDropdown(),
      _buildTextField(
        _priceController,
        _selectedService == 'Hotels' ? 'Price per Room' : 'Price per Day',
        Icons.attach_money,
      ),
    ];
  }

  Widget _buildServiceCategoryRadioButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRadioButton('Rent a Car'),
        _buildRadioButton('Hotels'),
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
              _selectedService = newValue;
            });
          },
        ),
        Text(value),
      ],
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

  Widget _buildCityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_city, color: Colors.green),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        items: _cities.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCity = newValue!;
          });
        },
      ),
    );
  }
}
