// Cette page affiche la carte de suivi en temps réel pendant un trajet.
// - Côté conducteur, elle publie sa position et affiche un bouton "Marquer comme

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/app/database/services/trip_status_service.dart';
import '../widgets/tracking_map.dart';

/// Écran TRACKING (carte + actions de fin)
/// - isDriver=true: publie sa position (dans TrackingMap)
/// - Affiche le bouton "Marquer comme terminé" côté conducteur quand status=running
/// - Se ferme automatiquement si status=completed
class TrackingScreen extends StatefulWidget {
  final String tripId;
  final bool isDriver;

  /// Requis côté passager pour suivre le conducteur (null côté conducteur)
  final String? driverUserId;

  const TrackingScreen({
    super.key,
    required this.tripId,
    required this.isDriver,
    this.driverUserId,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _tripStatus = TripStatusService();
  StreamSubscription<String?>? _statusSub;

  String _currentStatus = 'running';

  @override
  void initState() {
    super.initState();
    _statusSub = _tripStatus.watchStatus(widget.tripId).listen((status) {
      if (!mounted) return;
      final s = (status ?? 'scheduled');
      setState(() => _currentStatus = s);

      if (s.toLowerCase() == 'completed') {
        Navigator.of(context).maybePop(); // fermeture auto de la carte
      }
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _markCompleted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terminer la course ?'),
        content: const Text(
          'Cette action marquera le trajet comme effectué,'
          ' déclenchera les micro-frais et fermera la carte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      // ✅ Utiliser le service pour status + micro-frais (idempotence incluse)
      await _tripStatus.completeTripAndCharge(widget.tripId);

      if (!mounted) return;
      _bubble(context, 'Course payée/confirmée ✅');
      // La fermeture sera gérée par le watcher (status=completed → maybePop()).
    } catch (e) {
      if (!mounted) return;
      final msg = '$e';
      if (msg == 'TRIP_NOT_FOUND') {
        _bubble(context, 'Trajet introuvable.');
      } else {
        _bubble(context, 'Impossible de terminer : $msg');
      }
    }
  }

  void _bubble(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withOpacity(0.4),
        content: Text(text, style: const TextStyle(color: Colors.black)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final publishSelf = widget.isDriver && currentUid != null;

    final canShowCompleteButton =
        widget.isDriver && _currentStatus.toLowerCase() == 'running';

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi en temps réel')),
      body: Column(
        children: [
          // Carte
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TrackingMap(
                tripId: widget.tripId,
                publishSelf: publishSelf,
                showSelf: true,
                driverUserId: widget.isDriver ? null : widget.driverUserId,
              ),
            ),
          ),

          // Barre d'état + bouton terminer (conducteur uniquement)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Petit bandeau d’état
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _currentStatus.toLowerCase() == 'running'
                          ? Colors.blue.shade50
                          : (_currentStatus.toLowerCase() == 'completed'
                                ? Colors.green.shade50
                                : Colors.orange.shade50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Statut: ${_currentStatus.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (canShowCompleteButton)
                    ElevatedButton.icon(
                      onPressed: _markCompleted,
                      icon: const Icon(Icons.flag),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Marquer comme terminé'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
