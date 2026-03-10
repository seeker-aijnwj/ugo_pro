import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_go/app/database/services/ride_service.dart';
import 'package:u_go/app/core/utils/colors.dart'; // secondColor

/// Dialog de notation conducteur avec header "Départ → Destination" et bandeau conducteur/prix.
/// - Récupère les données d'annonce (archivée puis inline) si non fournies.
/// - Envoie la note via RideService.submitDriverRating(...).
Future<void> showRateDriverDialog(
  BuildContext context, {
  required String driverId,
  required String passengerId,
  required String announceId,
  required String reservationId,
  DocumentReference? notifRef,
  // Si fournis, on affiche tel quel, sinon on va chercher
  String? departure,
  String? departureDetail,
  String? arrival,
  String? arrivalDetail,
  String? price, // ex "1000 XOF"
}) async {
  int selected = 0;
  bool sending = false;

  String stringify(dynamic value) => value?.toString() ?? '';

  Future<Map<String, String>> fetchTrip() async {
    String depart = (departure ?? '').trim();
    String departDetail = (departureDetail ?? '').trim();
    String arrivee = (arrival ?? '').trim();
    String arriveeDetail = (arrivalDetail ?? '').trim();
    String prix = (price ?? '').trim();

    if (depart.isNotEmpty && arrivee.isNotEmpty && prix.isNotEmpty) {
      return {
        'departure': depart,
        'departureDetail': departDetail,
        'arrival': arrivee,
        'arrivalDetail': arriveeDetail,
        'price': prix,
      };
    }

    Future<Map<String, String>?> findAnnouce(DocumentReference ref) async {
      final snap = await ref.get();
      if (!snap.exists) return null;
      final d = snap.data() as Map<String, dynamic>? ?? {};

      final departureText = [
        stringify(d['depart']),
        stringify(d['from']),
        stringify(d['startAddress']),
        stringify(d['departureAddress']),
      ].firstWhere((e) => e.trim().isNotEmpty, orElse: () => '—');

      final depSubName = [
        stringify(d['meetingPlace']),
        stringify(d['departureMeetingPoint']),
      ].firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');

      final arrivalText = [
        stringify(d['destination']),
        stringify(d['to']),
        stringify(d['endAddress']),
        stringify(d['arrivalAddress']),
      ].firstWhere((e) => e.trim().isNotEmpty, orElse: () => '—');

      final priceText = [
        stringify(d['price']),
        stringify(d['amount']),
      ].firstWhere((e) => e.trim().isNotEmpty, orElse: () => '—');

      return {
        'departure': depart.isNotEmpty ? depart : departureText,
        'departureDetail': departDetail.isNotEmpty ? departDetail : depSubName,
        'arrival': arrivee.isNotEmpty ? arrivee : arrivalText,
        'arrivalDetail': arriveeDetail.isNotEmpty ? arriveeDetail : '',
        'price': prix.isNotEmpty ? prix : priceText,
      };
    }

    final archivedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .collection('announces_effectuees')
        .doc(announceId);
    final inlineRef = FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .collection('announces')
        .doc(announceId);

    return await findAnnouce(archivedRef) ??
        await findAnnouce(inlineRef) ??
        {'departure': '—', 'departureDetail': '', 'arrival': '—', 'arrivalDetail': '', 'price': '—'};
  }

  Future<String>fetchDriverDisplay() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .get();
    if (!doc.exists) return '—';
    final d = doc.data() ?? {};
    final prenom = stringify(d['prenom']).trim();
    final nom = stringify(d['nom']).trim();
    final customId = stringify(d['customId']).trim();
    final full = [prenom, nom].where((e) => e.isNotEmpty).join(' ').trim();
    return full.isNotEmpty ? full : (customId.isNotEmpty ? customId : '—');
  }

  // On regroupe les 2 chargements dans un seul Future (évite 2 FutureBuilders imbriqués).
  Future<({Map<String, String> trip, String driverDisplay})> loadResults() async {
    final results = await Future.wait([fetchTrip(), fetchDriverDisplay()]);
    return (
      trip: results[0] as Map<String, String>,
      driverDisplay: results[1] as String,
    );
  }

  void bubble(BuildContext ctx, String text) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withOpacity(0.4),
        content: Text(text, style: const TextStyle(color: Colors.black)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  return showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) =>
        FutureBuilder<({Map<String, String> trip, String driverDisplay})>(
          future: loadResults(),
          builder: (ctx, snap) {
            final loading = snap.connectionState == ConnectionState.waiting;
            final trip =
                snap.data?.trip ?? {
                  'departure': '—',
                  'departureDetail': '',
                  'arrival': '—',
                  'arrivalDetail': '',
                  'price': '—',
                };

            final driverDisplay = snap.data?.driverDisplay ?? '—';

            final dep = trip['departure']!;
            final depSub = trip['departureDetail']!;
            final arr = trip['arrival']!;
            final arrSub = trip['arrivalDetail']!;
            final prx = trip['price']!;

            return StatefulBuilder(
              builder: (ctx, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),

                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dep,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            arr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            depSub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            arrSub,
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2DEF5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              loading ? 'Chargement...' : driverDisplay,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            prx,
                            style: const TextStyle(
                              fontFamily: 'Regular',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Notez le conducteur",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < selected;
                        return IconButton(
                          iconSize: 32,
                          splashRadius: 24,
                          onPressed: (sending || loading)
                              ? null
                              : () => setState(() => selected = i + 1),
                          icon: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: filled ? secondColor : Colors.grey,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selected == 0
                          ? "Choisissez une note"
                          : "Note : $selected / 5",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                actions: [
                  TextButton(
                    onPressed: sending ? null : () => Navigator.of(ctx).pop(),
                    child: const Text("Plus tard"),
                  ),
                  FilledButton(
                    onPressed: (selected == 0 || sending || loading)
                        ? null
                        : () async {
                            try {
                              setState(() => sending = true);
                              // ⚠️ Agrégation/arrondi/plafond (4.5 max) se fait côté service/db.
                              await RideService.submitDriverRating(
                                driverId: driverId,
                                passengerId: passengerId,
                                announceId: announceId,
                                reservationId: reservationId,
                                rating: selected,
                                notifRef: notifRef,
                              );
                              if (context.mounted) {
                                Navigator.of(ctx).pop(
                                  selected,
                                ); // on retourne la note au cas où
                                bubble(context, "Merci pour votre note !");
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() => sending = false);
                                bubble(context, "Erreur: $e");
                              }
                            }
                          },
                    child: (sending || loading)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Envoyer"),
                  ),
                ],
              ),
            );
          },
        ),
  );
}
