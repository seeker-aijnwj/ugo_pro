import 'dart:async';
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/passenger/home_screen.dart';

class PassengerTransitionScreen extends StatefulWidget {
  const PassengerTransitionScreen({super.key});

  @override
  State<PassengerTransitionScreen> createState() =>
      _PassengerTransitionScreenState();
}

class _PassengerTransitionScreenState extends State<PassengerTransitionScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Vous êtes maintenant passager",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: "Bold",
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
