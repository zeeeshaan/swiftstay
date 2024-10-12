import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();


  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _usernameController.text = userDoc['username'];
            _contactController.text = userDoc['contact'];

          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load user data: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .update({
            'username': _usernameController.text,
            'contact': _contactController.text,

          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User details updated successfully')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to update user data: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
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
          if (label == 'Contact' && value.length != 11) {
            return 'Contact must be 11 digits';
          }
          if (label == 'Email' && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_usernameController, 'User Name', Icons.person),
                _buildTextField(_contactController, 'Contact', Icons.phone),

                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _isLoading ? null : _updateUserData,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
