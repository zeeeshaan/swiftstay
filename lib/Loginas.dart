
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:swiftstay/Service_Provider/servicerlogin.dart';
import 'package:swiftstay/User/userlogin.dart';

class Selectin extends StatefulWidget {
  const Selectin({super.key});

  @override
  State<Selectin> createState() => _SelectinState();
}

class _SelectinState extends State<Selectin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50,),
              const Text("Continue as", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
              const SizedBox(height: 50,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>   const Servicerlogin()),
                  );
                },
                child: Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: const Center(
                            child: Text(
                              "Services",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                            child: Lottie.asset("assets/serviceprovider.json")
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  const Userlogin()));

                },
                child: Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: const Center(
                            child: Text(
                              "User",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Container(
                            child: Lottie.asset("assets/userlogo.json")
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50,),

            ],
          ),
        ),
      ),
    );
  }
}
