import 'dart:async';
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';

class DriverTransitionScreen extends StatefulWidget {
  const DriverTransitionScreen({super.key});

  @override
  State<DriverTransitionScreen> createState() => _DriverTransitionScreenState();
}

class _DriverTransitionScreenState extends State<DriverTransitionScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.drive_eta, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Vous êtes maintenant conducteur",
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
