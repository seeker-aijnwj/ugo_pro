// Cette page montre le détail d'une annonce / d'un trajet.
// Côté conducteur, elle permet de démarrer la course (si statut "scheduled").

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/trip_status_service.dart';
import 'tracking_screen.dart';

/// Écran DÉTAIL d'une annonce / d'un trajet.
/// - Montre les infos clés (minimales ici) + l'état du trip en live
/// - Côté conducteur: bouton CTA "Démarrer la course" si status == scheduled
/// - Au démarrage: set status=running puis ouvre TrackingScreen (publie la position)
class AnnounceDetailScreen extends StatefulWidget {
  final String tripId;
  /// uid du conducteur affecté à ce trip (doit être connu au moment d'afficher le détail)
  final String driverUserId;

  const AnnounceDetailScreen({
    super.key,
    required this.tripId,
    required this.driverUserId,
  });

  @override
  State<AnnounceDetailScreen> createState() => _AnnounceDetailScreenState();
}

class _AnnounceDetailScreenState extends State<AnnounceDetailScreen> {
  final _tripStatus = TripStatusService();

  late final String _currentUid;
  bool get _isDriver => _currentUid == widget.driverUserId;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _startTrip() async {
    try {
      // 1) Mettre le trip en "running"
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).set(
        {'status': 'running'},
        SetOptions(merge: true),
      );

      // 2) Ouvrir la carte côté conducteur (publication de sa position)
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(
            tripId: widget.tripId,
            isDriver: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de démarrer la course: $e')),
      );
    }
  }

  Widget _buildHeader(String status) {
    Color chipColor;
    String label;
    switch (status.toLowerCase()) {
      case 'running':
        chipColor = Colors.blue.shade100;
        label = 'En cours';
        break;
      case 'completed':
        chipColor = Colors.green.shade100;
        label = 'Terminée';
        break;
      default:
        chipColor = Colors.orange.shade100;
        label = 'Planifiée';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          child: const Icon(Icons.directions_car),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Trajet #${widget.tripId}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // (Ici tu peux afficher les infos de l’annonce: points de départ/arrivée, passagers, etc.)
        Text(
          'Détails du trajet (exemple):\n- Conducteur: ${widget.driverUserId}\n- Participants: visibles ici…',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const Spacer(),

        // Bouton CTA "Démarrer la course" — conducteur uniquement, si scheduled
        if (_isDriver && status.toLowerCase() == 'scheduled')
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startTrip,
                icon: const Icon(Icons.play_arrow),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Démarrer la course'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

        // Si déjà en cours (running) côté conducteur, propose un raccourci "Ouvrir la carte"
        if (_isDriver && status.toLowerCase() == 'running')
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackingScreen(
                        tripId: widget.tripId,
                        isDriver: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Ouvrir la carte (course en cours)'),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _tripStatus.watchStatus(widget.tripId),
      builder: (context, snap) {
        final status = (snap.data ?? 'scheduled'); // défaut si non renseigné
        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail du trajet'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(status),
                const SizedBox(height: 16),
                Expanded(child: _buildBody(status)),
              ],
            ),
          ),
        );
      },
    );
  }
}
