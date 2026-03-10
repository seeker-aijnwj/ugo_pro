import 'package:flutter/material.dart';
import 'package:u_go/modules/booking_module/screens/onboarding/views/welcome_sceen.dart';
//import 'package:u_go/screens/auth/login_screen.dart';

Future<Null> time(BuildContext context) {
  return Future.delayed(const Duration(seconds: 5), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  });
}
