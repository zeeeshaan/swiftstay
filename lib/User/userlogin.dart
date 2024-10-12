import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import 'BottomNavBar.dart';
import 'Usersignup.dart';



class Userlogin extends StatefulWidget {
  const Userlogin({super.key});

  @override
  State<Userlogin> createState() => _UserloginState();
}

class _UserloginState extends State<Userlogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                SizedBox(
                  height: 200,
                  width: 200,
                  // color: Colors.grey[200],
                  child: Lottie.asset("assets/login.json"),
                ),
                const Center(
                  child: Text(
                    "Swift Stay",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email),
                _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Usersignup()),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
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
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User logged in successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to login user: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
