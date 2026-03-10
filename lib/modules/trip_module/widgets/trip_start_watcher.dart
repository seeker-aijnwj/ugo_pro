// lib/widgets/trip_start_watcher.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_go/modules/trip_module/screens/tracking_screen.dart';
import 'package:u_go/modules/trip_module/services/trip_status_service.dart';

class TripStartWatcher {
  TripStartWatcher._();

  /// Anti double-ouverture (par id de trip)
  static final Set<String> _openedTrips = <String>{};

  /// Écoute les TRIPS du PASSAGER qui passent à "running" et ouvre la carte.
  /// Retourne la souscription (à annuler dans dispose()).
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  startListening(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      debugPrint('[TripStartWatcher] Aucun utilisateur connecté — stop.');
      return null;
    }

    // IMPORTANT :
    // - arrayContains + equality => souvent nécessite un index composite.
    // - TripStatusService.running doit être la STRING "running".
    final query = FirebaseFirestore.instance
        .collection('trips')
        .where('passengerIds', arrayContains: uid)
        .where('status', isEqualTo: TripStatusService.running);

    final sub = query.snapshots().listen(
      (qs) {
        if (qs.docs.isEmpty) return;

        // On parcourt les docs courants. On pourrait utiliser docChanges pour n’ouvrir
        // que sur "added", mais garder docs est ok grâce à _openedTrips (idempotent).
        for (final d in qs.docs) {
          final tripId = d.id;
          if (_openedTrips.contains(tripId)) {
            continue; // déjà ouvert au moins une fois
          }

          final data = d.data();
          final raw = (data['status'] as String? ?? '').toLowerCase();
          if (raw != TripStatusService.running) continue; // sécurité

          final driverUserId = (data['driverUserId'] as String?)?.trim() ?? '';
          if (driverUserId.isEmpty) {
            debugPrint(
              '[TripStartWatcher] trip:$tripId sans driverUserId — skip.',
            );
            continue;
          }

          _openedTrips.add(tripId);

          // Diffère la navigation pour éviter "setState() or markNeedsBuild()" en plein build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            // rootNavigator=true pour garantir l’ouverture au niveau racine.
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => TrackingScreen(
                  tripId: tripId,
                  isDriver: false,
                  driverUserId: driverUserId,
                ),
              ),
            );
          });
        }
      },
      onError: (error, stack) {
        // On logue proprement TOUT (utile en debug console / cmd).
        if (error is FirebaseException) {
          debugPrint(
            '[TripStartWatcher] Firestore listen error '
            '(${error.code}): ${error.message}',
          );
          // Les messages d’index manquant contiennent souvent une URL directe pour créer l’index.
          final msg = error.message ?? '';
          final urlIndex = _extractFirstUrl(msg);
          if (urlIndex != null) {
            debugPrint('[TripStartWatcher] Crée l’index ici : $urlIndex');
          }
        } else {
          debugPrint('[TripStartWatcher] listen error: $error');
        }

        // Message doux côté UI (sans bloquer l’app)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ouverture automatique indisponible (probable index Firestore manquant).',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
    );

    return sub;
  }

  /// (Optionnel) Permet de réinitialiser l’anti double-ouverture (par ex. à la déconnexion).
  static void resetOpenedTripsCache() => _openedTrips.clear();

  /// Essaie d’extraire la première URL d’un texte (utile pour l’URL "Create index").
  static String? _extractFirstUrl(String text) {
    final reg = RegExp(r'(https?:\/\/[^\s]+)');
    final m = reg.firstMatch(text);
    return m?.group(0);
  }
}
