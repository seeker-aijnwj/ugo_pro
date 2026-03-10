import 'package:flutter/material.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart'; // si tu utilises mainColor

class ReservationSuccessScreen extends StatelessWidget {
  const ReservationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TxtComponents(
                txt: "Réservation validée avec succès",
                fw: FontWeight.bold,
                txtAlign: TextAlign.center,
                txtSize: 20,
                family: "Agbalumo",
              ),
              const SizedBox(height: 32),
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 32),
              ButtonComponent(
                txtButton: "Retourner",
                colorButton: mainColor,
                colorText: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', // Assure-toi que cette route est bien définie
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
