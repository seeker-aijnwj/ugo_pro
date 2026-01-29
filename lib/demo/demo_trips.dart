import 'package:flutter/material.dart';
import '../data/models/trip_ad.dart';
import '../data/services/mock_data_service.dart';

class DemoTrips extends StatelessWidget {
  const DemoTrips({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Remplacer par FirebaseFirestore.instance.collection('trip_ads').snapshots()
    return FutureBuilder<List<TripAd>>(
      future: MockDataService.getTrips(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final trips = snapshot.data!;

        return Card(
          elevation: 2,
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: trips.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColor(trip.statut).withValues(alpha: .1),
                  child: Icon(Icons.directions_bus, color: _getColor(trip.statut)),
                ),
                title: Row(
                  children: [
                    Text(trip.route.fullRoute, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text("${trip.prix} F. CFA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                subtitle: Text("Chauffeur: ${trip.driverName} • ${trip.statut.toUpperCase()}"),
                trailing: trip.statut == 'programmé'
                    ? OutlinedButton(
                        onPressed: () {
                          // TODO: Logique d'annulation Firebase
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Trajet annulé (Démo)")));
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Annuler"),
                      )
                    : const Icon(Icons.check_circle_outline, color: Colors.grey),
              );
            },
          ),
        );
      },
    );
  }

  Color _getColor(String status) {
    switch (status) {
      case 'programmé': return Colors.blue;
      case 'en_cours': return Colors.green;
      case 'annulé': return Colors.red;
      default: return Colors.grey;
    }
  }
}