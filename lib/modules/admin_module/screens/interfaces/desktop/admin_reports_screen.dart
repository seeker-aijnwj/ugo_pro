// Fichier: lib/screens/admin/admin_reports_screen.dart
import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline, size: 80, color: Colors.green[800]),
          ),
          const SizedBox(height: 20),
          const Text(
            "Tout est calme !",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Aucun signalement en attente pour le moment.\nProfitez-en pour prendre un café ☕",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Fonction pour forcer le rafraîchissement
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Actualiser"),
          )
        ],
      ),
    );
  }
}