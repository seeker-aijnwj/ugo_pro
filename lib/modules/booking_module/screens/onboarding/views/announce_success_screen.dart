import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';

class AnnounceSuccessScreen extends StatelessWidget {
  const AnnounceSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Annonce effectuée avec succès",
                  style: TextStyle(
                    fontFamily: 'Bold',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 32),
                ButtonComponent(
                  txtButton: "Retourner",
                  colorButton: secondColor,
                  colorText: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DriverHomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
