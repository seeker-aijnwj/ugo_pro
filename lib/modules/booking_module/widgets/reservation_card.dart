// lib/widgets/reservation_card.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/modules/booking_module/services/booking_service.dart';
import 'package:u_go/app/core/utils/colors.dart';

class ReservationCard extends StatelessWidget {
  final String departure;
  final String departureAddress;
  final String arrival;
  final String arrivalAddress;
  final String date;
  final String time;
  final String price;

  /// Optionnel : si tu veux overrider le comportement d’appel
  final VoidCallback? onCall;

  /// Référence Firestore de la réservation
  final DocumentReference reservationRef;

  /// Optionnel : callback après annulation réussie
  final VoidCallback? onCanceled;

  const ReservationCard({
    super.key,
    required this.departure,
    required this.departureAddress,
    required this.arrival,
    required this.arrivalAddress,
    required this.date,
    required this.time,
    required this.price,
    required this.reservationRef,
    this.onCanceled,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    // On lit la réservation pour récupérer dynamiquement stops + infos conducteur
    return StreamBuilder<DocumentSnapshot>(
      stream: reservationRef.snapshots(),
      builder: (context, snap) {
        final hasData = snap.hasData && snap.data?.data() != null;
        final data = hasData
            ? (snap.data!.data() as Map<String, dynamic>)
            : const <String, dynamic>{};

        final stops = _readStops(data);
        final driverHints = _DriverHints.fromReservation(data);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color.fromARGB(255, 220, 233, 244),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TxtComponents(
                  txt: "$departure → $arrival",
                  txtSize: 16,
                  fw: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                TxtComponents(
                  txt: "Départ : $departureAddress",
                  txtSize: 13,
                  color: Colors.grey,
                ),
                TxtComponents(
                  txt: "Arrivée : $arrivalAddress",
                  txtSize: 13,
                  color: Colors.grey,
                ),

                // === STOPS/ARRÊTS : style identique à AnnonceCard (une seule ligne) ===
                if (stops.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Arrêts :",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: stops
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _StopChip(text: s),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TxtComponents(txt: "Date : $date", txtSize: 13),
                    TxtComponents(txt: "Heure : $time", txtSize: 13),
                  ],
                ),
                const SizedBox(height: 8),
                TxtComponents(
                  txt: "$price FCFA",
                  txtSize: 14,
                  fw: FontWeight.bold,
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmAndCancel(context),
                      icon: const Icon(
                        Icons.cancel,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        "Annuler",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        if (onCall != null) {
                          onCall!();
                          return;
                        }
                        await _callDriver(context, driverHints);
                      },
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text("Appeler le conducteur"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---- Annulation avec confirmation ----
  void _confirmAndCancel(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dlgCtx) {
        bool isBusy = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> doCancel() async {
              try {
                setState(() => isBusy = true);

                await BookingService.cancelReservation(
                  reservationRef: reservationRef,
                );

                if (context.mounted) {
                  Navigator.of(dlgCtx).pop();
                  _smallSnack(context, "Réservation annulée.");
                }
                onCanceled?.call();
              } on FirebaseException catch (e) {
                if (context.mounted) {
                  setState(() => isBusy = false);
                  _smallSnack(
                    context,
                    "Échec : ${e.message ?? 'erreur inconnue'}",
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() => isBusy = false);
                  _smallSnack(context, e.toString());
                }
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("Annuler la réservation ?"),
              content: Text(
                "Voulez-vous vraiment annuler la réservation $departure → $arrival ?",
              ),
              actions: [
                TextButton(
                  onPressed: isBusy ? null : () => Navigator.of(dlgCtx).pop(),
                  child: const Text("Non"),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isBusy ? null : doCancel,
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cancel),
                  label: Text(isBusy ? "Annulation..." : "Oui, annuler"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---- Lecture des stops (tolérant sur la clé) ----
  List<String> _readStops(Map<String, dynamic> m) {
    final raw = m['stops'] ?? m['escales'] ?? m['legs'];
    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  // ---- Appel du conducteur ----
  Future<void> _callDriver(BuildContext context, _DriverHints hints) async {
    try {
      // 1) Numéro directement sur la réservation ?
      if (hints.inlinePhone != null && hints.inlinePhone!.trim().isNotEmpty) {
        await _launchPhone(context, hints.inlinePhone!.trim());
        return;
      }

      // 2) Sinon, on tente de charger le doc utilisateur du conducteur
      final driverId = hints.driverId;
      if (driverId == null || driverId.trim().isEmpty) {
        _smallSnack(
          context,
          "Impossible de trouver l'identifiant du conducteur.",
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(driverId)
          .get();
      if (!userDoc.exists || userDoc.data() == null) {
        _smallSnack(context, "Conducteur introuvable.");
        return;
      }
      final u = userDoc.data()!;
      final phone = (u['numero']).toString().trim();

      if (phone.isEmpty) {
        _smallSnack(context, "Aucun numéro enregistré pour le conducteur.");
        return;
      }

      await _launchPhone(context, phone);
    } on FirebaseException catch (e) {
      _smallSnack(context, "Firebase : ${e.message ?? e.code}");
    } catch (e) {
      _smallSnack(context, "Erreur : $e");
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      _smallSnack(context, "Impossible d’ouvrir le composeur téléphonique.");
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ---- SnackBar compacte “bulle” ----
  void _smallSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Chip identique à AnnonceCard
class _StopChip extends StatelessWidget {
  final String text;
  const _StopChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: secondColor.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stop_circle_outlined, size: 16, color: secondColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Indices tolérants pour retrouver soit un numéro inline,
/// soit un id conducteur à résoudre dans `users/{id}`
class _DriverHints {
  final String? inlinePhone;
  final String? driverId;

  _DriverHints({this.inlinePhone, this.driverId});

  factory _DriverHints.fromReservation(Map<String, dynamic> m) {
    // Numéro directement dans la réservation ?
    final inlinePhone = (m['driverPhone'] ?? m['conducteurPhone'] ?? m['phone'])
        ?.toString();

    // Plusieurs clés possibles pour l’id conducteur (selon tes schémas)
    final driverId =
        (m['driverId'] ??
                m['driverUserId'] ??
                m['conducteurId'] ??
                m['driver'] ??
                m['uidDriver'])
            ?.toString();

    return _DriverHints(inlinePhone: inlinePhone, driverId: driverId);
  }
}
