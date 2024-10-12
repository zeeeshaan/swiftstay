import 'package:flutter/material.dart';
// For a rotating text effect
// For date formatting
import 'package:lottie/lottie.dart';
import 'package:swiftstay/Loginas.dart';




class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: -0.785398, end: 0.785398).animate(_controller);

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Selectin()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Swift\nStay',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10,),

              SizedBox(
                height: 200,
                  child: Lottie.asset("assets/userlogo.json")
              ),
            ],
          ),
        ),
      ),
    );
  }
}
