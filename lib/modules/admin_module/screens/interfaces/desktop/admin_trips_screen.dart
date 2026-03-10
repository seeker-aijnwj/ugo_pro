import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pour les dates et devises
import '../../../widgets/responsive_layout.dart';

class AdminTripsScreen extends StatelessWidget {
  const AdminTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // On récupère les trajets, du plus récent au plus ancien
      stream: FirebaseFirestore.instance
          .collection('trips')
          .orderBy('startTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucun trajet publié pour le moment."));
        }

        final trips = snapshot.data!.docs;

        return ResponsiveLayout(
          // --- MOBILE : Liste de cartes ---
          mobileBody: ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final data = trips[index].data() as Map<String, dynamic>;
              return _buildMobileTripCard(data, trips[index].id, context);
            },
          ),

          // --- DESKTOP : Grand Tableau Détaillé ---
          desktopBody: Card(
            elevation: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Date Départ')),
                    DataColumn(label: Text('Itinéraire')),
                    DataColumn(label: Text('Conducteur')),
                    DataColumn(label: Text('Prix/Place')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: trips.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildDesktopTripRow(data, doc.id, context);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS DESKTOP ---
  
  DataRow _buildDesktopTripRow(Map<String, dynamic> data, String tripId, BuildContext context) {
    // Formatage sécurisé de la date
    final Timestamp? ts = data['startTime'];
    final String dateStr = ts != null 
        ? DateFormat('dd/MM HH:mm').format(ts.toDate()) 
        : 'N/A';

    final String status = data['status'] ?? 'scheduled';
    final bool isCancelled = status == 'cancelled';

    return DataRow(
      // Griser la ligne si annulée
      color: WidgetStateProperty.resolveWith((states) => isCancelled ? Colors.grey[50] : null),
      cells: [
        DataCell(Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data['departureAddress'] ?? '?'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.arrow_right_alt, size: 16)),
            Text(data['arrivalAddress'] ?? '?'),
          ],
        )),
        DataCell(Text(data['driverName'] ?? 'Inconnu')),
        DataCell(Text("${data['price']} F. CFA")),
        DataCell(_buildStatusBadge(status)),
        DataCell(
          isCancelled 
          ? const Text("Terminé", style: TextStyle(color: Colors.grey))
          : IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              tooltip: "Annuler ce trajet",
              onPressed: () => _showCancelDialog(context, tripId),
            ),
        ),
      ],
    );
  }

  // --- WIDGETS MOBILE ---

  Widget _buildMobileTripCard(Map<String, dynamic> data, String tripId, BuildContext context) {
    final Timestamp? ts = data['startTime'];
    final String dateStr = ts != null ? DateFormat('dd MMM à HH:mm').format(ts.toDate()) : 'N/A';
    final String status = data['status'] ?? 'scheduled';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderOnForeground: true,
      // Bordure rouge si annulé
      shape: status == 'cancelled' 
          ? RoundedRectangleBorder(side: const BorderSide(color: Colors.red, width: 1), borderRadius: BorderRadius.circular(12))
          : null,
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                "${data['departureAddress']} ➔ ${data['arrivalAddress']}", 
                style: const TextStyle(fontWeight: FontWeight.bold)
              )
            ),
            Text(
              "${data['price']} F. CFA", 
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text("Conducteur: ${data['driverName']} • $dateStr"),
            const SizedBox(height: 5),
            _buildStatusBadge(status),
          ],
        ),
        trailing: status == 'scheduled' 
            ? IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showCancelDialog(context, tripId))
            : const Icon(Icons.check, color: Colors.grey),
      ),
    );
  }

  // --- HELPERS (Badges & Dialogues) ---

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'scheduled': color = Colors.green; text = "Programmé"; break;
      case 'cancelled': color = Colors.red; text = "Annulé"; break;
      case 'finished': color = Colors.grey; text = "Terminé"; break;
      default: color = Colors.blue; text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  void _showCancelDialog(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Annuler le trajet ?"),
        content: const Text("Les passagers seront notifiés et remboursés (simulation). Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Non")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Action Firestore réelle
              await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
                'status': 'cancelled'
              });
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Oui, Annuler"),
          )
        ],
      ),
    );
  }
}