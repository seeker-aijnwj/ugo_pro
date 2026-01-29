import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';
import 'package:ugo_pro/data/models/trip_ad.dart';

// Écran de détail pour Mobile uniquement (Push navigation)
class MobileDetailScreen extends StatelessWidget {
  final TripAd trip;
  const MobileDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE7DE), // Fond Chat
      appBar: AppBar(
        backgroundColor: UGOAdminTheme.bubbleSelf,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.directions_bus, size: 16)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.route.fullRoute, style: const TextStyle(fontSize: 16, color: Colors.white)),
                const Text("En ligne", style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: Center(child: Text("Ici le contenu détaillé (même widget que Desktop)")), 
      // Vous pouvez réutiliser _buildMessageBubble ici
    );
  }
}