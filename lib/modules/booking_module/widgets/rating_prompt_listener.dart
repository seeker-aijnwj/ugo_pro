import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/modules/booking_module/widgets/rate_driver_dialog.dart';

/// Place simplement ce widget quelque part dans l'arbre (ex. en haut d'un écran).
/// Il n'affiche rien mais ouvre la bulle de notation quand il détecte une notif.
class RatingPromptListener extends StatefulWidget {
  const RatingPromptListener({super.key});

  @override
  State<RatingPromptListener> createState() => _RatingPromptListenerState();
}

class _RatingPromptListenerState extends State<RatingPromptListener> {
  final _shown = <String>{}; // IDs des notifs déjà affichées (éviter doublons)
  StreamSubscription<QuerySnapshot>? _sub;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _sub = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('type', isEqualTo: 'rate_driver')
          .where('read', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(_onSnapshot);
    }
  }

  void _onSnapshot(QuerySnapshot snap) {
    if (!mounted) return;

    for (final doc in snap.docs) {
      if (_shown.contains(doc.id)) continue;
      _shown.add(doc.id);

      final data = doc.data() as Map<String, dynamic>;
      final driverId = (data['driverId'] ?? '').toString();
      final announceId = (data['announceId'] ?? '').toString();
      final reservationId = (data['reservationId'] ?? '').toString();

      if (driverId.isEmpty || announceId.isEmpty || reservationId.isEmpty) {
        continue;
      }

      // Ouvre la bulle APRÈS ce frame pour éviter setState pendant build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final passengerId = FirebaseAuth.instance.currentUser!.uid;

        showRateDriverDialog(
          context,
          driverId: driverId,
          passengerId: passengerId,
          announceId: announceId,
          reservationId: reservationId,
          notifRef:
              doc.reference, // permettra au service de marquer read/consumed
        );
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
