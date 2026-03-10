// lib/screens/driver/driver_announce_detail_screen.dart

// Cette page affiche les détails d'une annonce effectuée par le conducteur.
// Elle permet aussi de "refaire une annonce similaire" en préremplissant le formulaire

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/core/utils/ugo_responsive.dart';
import 'package:u_go/modules/booking_module/models/announce_draft.dart';
import 'package:u_go/modules/booking_module/services/announce_prefill_service.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/modules/trip_module/screens/tracking_screen.dart';

class DriverAnnounceDetailScreen extends StatelessWidget {
  final String announceId;

  /// ✅ Même signature que DriverHistoryCard
  final VoidCallback? onReconduire;

  const DriverAnnounceDetailScreen({
    super.key,
    required this.announceId,
    this.onReconduire,
  });

  Future<void> onStartTrip(BuildContext context, String tripId) async {
    // 1) Marquer le trip comme en cours
    await FirebaseFirestore.instance.collection('trips').doc(tripId).set({
      'status': 'running',
    }, SetOptions(merge: true));

    // 2) Ouvrir la carte (publie la position)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(tripId: tripId, isDriver: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de l’annonce')),
        body: const Center(child: Text("Utilisateur non connecté.")),
      );
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('announces_effectuees')
        .doc(announceId);

    return UGoScaffold(
      appBar: AppBar(title: const Text('Détails de l’annonce')),
      maxWidth: 560,
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text("Erreur de chargement."));
          }
          final data = snap.data?.data();
          if (data == null) {
            return const Center(child: Text("Annonce introuvable."));
          }

          final from = (data['depart'] ?? '').toString();
          final to = (data['destination'] ?? '').toString();
          final meetingPlace = (data['meetingPlace'] ?? '').toString();
          // final arrivalAddress = (data['arrivalAddress'] ?? '').toString();
          final priceStr = (data['price'] ?? '').toString();
          final status = (data['status'] ?? '').toString();
          final announceNumber = (data['announceNumber'] ?? '').toString();

          final reservedSeats = _toInt(data['reservedSeats']); // affichage
          final seats = _toInt(data['seats']); // ✅ capacité

          final String departDateTime = _formatDeparture(
            data['departureAt'],
            data['dateText'],
            data['timeText'],
          );

          final String? completed = status.toLowerCase() == 'completed'
              ? _fmtDateTime(data['completedAt'])
              : null;

          final List<String> stops = _asStringList(data['stops']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _tile(title: "Trajet", value: _arrow(from, to)),

              _tile(title: "Départ", value: departDateTime),

              if (meetingPlace.isNotEmpty)
                _tile(title: "Lieu de rendez-vous", value: meetingPlace),

              _tile(title: "Réservations", value: "$reservedSeats / $seats"),

              if (priceStr.isNotEmpty)
                _tile(title: "Prix (par passager)", value: "$priceStr F"),

              if (stops.isNotEmpty) _stopsSection(stops),

              if (announceNumber.isNotEmpty)
                _tile(title: "Numéro d'annonce", value: announceNumber),

              if (completed != null)
                _tile(title: "Terminé le", value: completed),

              const SizedBox(height: 16),

              // Démarrer la course
              // ElevatedButton.icon(
              // onPressed: onStartTrip(context, ),
              // icon: const Icon(Icons.flag),
              // label: const Padding(
              // padding: EdgeInsets.symmetric(vertical: 14),
              // child: Text('Démarrer la course'),
              // ),
              // style: ElevatedButton.styleFrom(
              // backgroundColor: Colors.red,
              // foregroundColor: Colors.white,
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              // ),
              // ),
              const SizedBox(height: 16),

              // 🔁 Refaire une annonce similaire
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: secondColor),
                onPressed: () async {
                  if (onReconduire != null) {
                    onReconduire!.call();
                  } else {
                    await _refaireSimilaireViaDraft(context, data);
                  }
                },
                icon: const Icon(Icons.replay),
                label: const Text("Refaire une annonce similaire"),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- Reconduction: même logique que DriverHistoryCard ----------
  Future<void> _refaireSimilaireViaDraft(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      final from = (data['depart'] ?? '').toString();
      final to = (data['destination'] ?? '').toString();
      final meetingPlace = (data['meetingPlace'] ?? '').toString();
      final arrivalAddress = (data['arrivalAddress'] ?? '').toString();
      final priceStr = (data['price'] ?? '').toString();

      // ⏰ time = on préfère timeText ("HH:mm"), sinon l'heure de departureAt
      final time = _extractTimeOfDay(
        timeText: data['timeText'],
        departureAt: data['departureAt'],
      );

      // ✅ Utiliser la CAPACITÉ d'origine
      final seats = _toInt(data['seats']);

      final draft = AnnounceDraft(
        depart: from,
        destination: to,
        meetingPlace: meetingPlace,
        arrivalPlace: arrivalAddress,
        date: null, // pas de date préremplie
        time: time, // garde l’heure si dispo (ou mets null pour vider)
        seats: seats, // ✅ capacité (seats)
        price: _priceToInt(priceStr),
      );

      final svc = AnnouncePrefillService();
      svc.setDraft(draft);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverHomeScreen(initialIndex: 1),
        ),
      );
    } catch (e) {
      _toast(context, "Échec de la reconduction. Réessaie.");
    }
  }

  // ---------- Helpers ----------
  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static int _priceToInt(String s) {
    if (s.isEmpty) return 0;
    final cleaned = s.replaceAll(RegExp(r'[^\d\-]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v.where((e) => e != null).map((e) => e.toString()).toList();
    }
    if (v is String && v.trim().isNotEmpty) {
      return [v.trim()];
    }
    return const [];
  }

  static TimeOfDay? _extractTimeOfDay({dynamic timeText, dynamic departureAt}) {
    final tStr = timeText?.toString() ?? "";
    if (tStr.contains(':')) {
      final parts = tStr.split(':');
      final hh = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hh, minute: mm);
    }
    final dt = _toDateTime(departureAt);
    if (dt != null) {
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    }
    return null;
  }

  static DateTime? _toDateTime(dynamic v) {
    try {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final ms = int.tryParse(v);
        if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
        final iso = DateTime.tryParse(v);
        if (iso != null) return iso;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _arrow(String a, String b) {
    if (a.isEmpty && b.isEmpty) return "—";
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    return "$a → $b";
  }

  String _formatDeparture(
    dynamic departureAt,
    dynamic dateText,
    dynamic timeText,
  ) {
    final ts = _fmtDateTime(departureAt);
    if (ts != null) return ts;

    final d = dateText?.toString() ?? "";
    final t = timeText?.toString() ?? "";
    if (d.isEmpty && t.isEmpty) return "—";

    String ddmmyyyy = "—";
    try {
      final parts = d.split('-'); // 2025-08-23
      if (parts.length == 3) {
        ddmmyyyy = "${parts[2]}/${parts[1]}/${parts[0]}";
      } else {
        ddmmyyyy = d;
      }
    } catch (_) {
      ddmmyyyy = d.isEmpty ? "—" : d;
    }

    return t.isEmpty ? ddmmyyyy : "$ddmmyyyy $t";
  }

  String? _fmtDateTime(dynamic tsOr) {
    try {
      DateTime? dt;
      if (tsOr == null) return null;
      if (tsOr is Timestamp) {
        dt = tsOr.toDate();
      } else if (tsOr is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(tsOr);
      } else if (tsOr is String) {
        final ms = int.tryParse(tsOr);
        if (ms != null) dt = DateTime.fromMillisecondsSinceEpoch(ms);
      }
      if (dt == null) return null;
      String two(int n) => n.toString().padLeft(2, '0');
      return "${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}";
    } catch (_) {
      return null;
    }
  }

  Widget _tile({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: secondColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopsSection(List<String> stops) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: secondColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stops intermédiaires",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stops.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(s, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
