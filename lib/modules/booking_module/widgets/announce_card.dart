// lib/widgets/annonce_card.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/database/services/ride_service.dart';

// 👉 imports tracking & status (chemins à adapter si besoin)
import 'package:u_go/modules/trip_module/screens/tracking_screen.dart';
import 'package:u_go/modules/trip_module/services/trip_status_service.dart';

class AnnonceCard extends StatelessWidget {
  final String departure;
  final String departureAddress;
  final String arrival;
  final String arrivalAddress;
  final String date;
  final String time;
  final String price;
  final int seats;

  /// Sert à l'affichage des icônes ET pilote le grisé des actions
  final int reservedSeats;

  /// Callback d'édition (sera ignoré si actions désactivées)
  final VoidCallback onEdit;

  /// Référence Firestore de l'annonce (users/{driverId}/announces/{announceId})
  final DocumentReference annonceRef;

  const AnnonceCard({
    super.key,
    required this.departure,
    required this.departureAddress,
    required this.arrival,
    required this.arrivalAddress,
    required this.date,
    required this.time,
    required this.price,
    required this.seats,
    this.reservedSeats = 0,
    required this.onEdit,
    required this.annonceRef,
  });

  // ========= Helpers =========

  /// driverId déduit de la structure users/{driverId}/announces/{announceId}
  String? _driverIdFromRef() => annonceRef.parent.parent?.id;

  Future<List<String>> _loadPassengerIds() async {
    // Adapte le nom de sous-collection si besoin
    final qs = await annonceRef.collection('passengers').get();
    final ids = <String>[];
    for (final d in qs.docs) {
      final data = d.data() as Map<String, dynamic>? ?? {};
      final uid = (data['userId'] as String?) ?? d.id;
      if (uid.isNotEmpty) ids.add(uid);
    }
    return ids;
  }

  /// Crée un trip minimal si `tripId` manquant, le relie à l'annonce et retourne le tripId.
  Future<String> _ensureTripExists({
    required String? currentTripId,
    required String driverUserId,
  }) async {
    if (currentTripId != null && currentTripId.trim().isNotEmpty) {
      return currentTripId;
    }

    final passengers = await _loadPassengerIds();
    final trips = FirebaseFirestore.instance.collection('trips');
    final doc = trips.doc(); // id auto
    final now = Timestamp.now();

    num? parsedPrice;
    try {
      parsedPrice = num.tryParse(price.replaceAll(' ', ''));
    } catch (_) {
      parsedPrice = null;
    }

    await doc.set({
      'status': TripStatusService.scheduled,
      'driverUserId': driverUserId,
      'passengerIds': passengers,
      'title': '$departure → $arrival',
      'from': departure,
      'to': arrival,
      'startTime': null,
      'endTime': null,
      'price': parsedPrice,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // Lier l'annonce au trip nouvellement créé
    await annonceRef.set({'tripId': doc.id}, SetOptions(merge: true));
    return doc.id;
  }

  Future<void> _startCourse(BuildContext context, String tripId) async {
    final svc = TripStatusService();
    try {
      // Transition atomique scheduled -> running
      final ok = await svc.updateStatusIfCurrent(
        tripId: tripId,
        from: TripStatusService.scheduled,
        to: TripStatusService.running,
      );

      if (!context.mounted) return;
      // Ouvrir la carte côté conducteur quoi qu'il arrive (si déjà running on n'est pas bloqué)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreen(tripId: tripId, isDriver: true),
        ),
      );

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La course est déjà en cours.")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de démarrer la course: $e")),
      );
    }
  }

  Future<void> _onPressStart(BuildContext context, String? tripIdField) async {
    final driverId = _driverIdFromRef();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (driverId == null || driverId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("driverId introuvable.")));
      return;
    }
    if (currentUid != driverId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seul le conducteur peut démarrer la course."),
        ),
      );
      return;
    }

    try {
      final ensuredTripId = await _ensureTripExists(
        currentTripId: tripIdField,
        driverUserId: driverId,
      );
      if (!context.mounted) return;
      await _startCourse(context, ensuredTripId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
  }

  Future<void> _openMapAsDriver(BuildContext context, String tripId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingScreen(tripId: tripId, isDriver: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔎 Stream temps réel (bonus sécurité/confirmation)
    final hasReservationsStream = annonceRef
        .collection('passengers') // adapte si autre nom
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: secondLightColor,
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

            // === ⭐️ BULLES D'ARRÊTS (stops) depuis Firestore ===
            const SizedBox(height: 8),
            _StopsBubbles(annonceRef: annonceRef),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TxtComponents(txt: "Date : $date", txtSize: 13),
                TxtComponents(txt: "Heure : $time", txtSize: 13),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TxtComponents(
                  txt: "$price FCFA",
                  txtSize: 14,
                  fw: FontWeight.bold,
                ),

                // 👉 Affichage des places (icônes ≤ 4, sinon 1 icône + "x/y")
                _SeatDisplay(
                  seats: seats,
                  reservedSeats: reservedSeats,
                  color: secondColor,
                ),
              ],
            ),

            // ===== Ligne d'actions (supprimer / modifier) =====
            StreamBuilder<bool>(
              stream: hasReservationsStream,
              initialData: false,
              builder: (context, snap) {
                final bool hasReservationsByIcons = reservedSeats > 0;
                final bool hasStreamError = snap.hasError;
                final bool hasReservationsFromStream = snap.data ?? false;
                final bool hasReservations =
                    hasReservationsByIcons ||
                    hasStreamError ||
                    hasReservationsFromStream;

                final bool deleteEnabled = !hasReservations;
                final bool editEnabled = !hasReservations;

                final Color deleteColor = deleteEnabled
                    ? Colors.red
                    : Colors.grey;
                final Color? editColor = editEnabled ? null : Colors.grey;

                final String defaultReasonIcons =
                    "Action indisponible : au moins une réservation existe.";
                final String defaultReasonError =
                    "Action indisponible : lecture des réservations impossible (permissions/réseau).";

                final String disableReason = hasReservationsByIcons
                    ? defaultReasonIcons
                    : hasStreamError
                    ? defaultReasonError
                    : hasReservationsFromStream
                    ? defaultReasonIcons
                    : "Action indisponible.";

                final String deleteReason =
                    "Pour supprimer, veuillez contacter l'équipe support !";
                final String editReason =
                    "Désolé, il y a des réservations en cours.";

                Widget tapAware({
                  required bool enabled,
                  required String tooltipEnabled,
                  required String tooltipDisabled,
                  required Widget child,
                }) {
                  if (enabled) {
                    return Tooltip(message: tooltipEnabled, child: child);
                  }
                  return Tooltip(
                    message: tooltipDisabled,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final msg = tooltipDisabled.isNotEmpty
                            ? tooltipDisabled
                            : disableReason;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(msg)));
                      },
                      child: child,
                    ),
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tapAware(
                      enabled: deleteEnabled,
                      tooltipEnabled: "Supprimer l'annonce",
                      tooltipDisabled: deleteReason,
                      child: TextButton.icon(
                        onPressed: deleteEnabled
                            ? () => _confirmAndDelete(context)
                            : null,
                        icon: Icon(Icons.delete, size: 16, color: deleteColor),
                        label: Text(
                          "Supprimer",
                          style: TextStyle(color: deleteColor),
                        ),
                      ),
                    ),
                    tapAware(
                      enabled: editEnabled,
                      tooltipEnabled: "Modifier l'annonce",
                      tooltipDisabled: editReason,
                      child: TextButton.icon(
                        onPressed: editEnabled ? onEdit : null,
                        icon: Icon(Icons.edit, size: 16, color: editColor),
                        label: Text(
                          "Modifier",
                          style: TextStyle(color: editColor),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // ===== CTA CONTEXTUEL (conducteur) =====
            const SizedBox(height: 8),
            _DriverCta(
              annonceRef: annonceRef,
              departure: departure,
              arrival: arrival,
              onStart: _onPressStart,
              onOpenMap: _openMapAsDriver,
              onMarkCompleted: _confirmMarkCompleted,
              isMeDriver:
                  FirebaseAuth.instance.currentUser?.uid == _driverIdFromRef(),
            ),
          ],
        ),
      ),
    );
  }

  // ==== Dialogs avec références stables (évite lookups dangereux) ====

  void _confirmMarkCompleted(BuildContext context) {
    // Références stables AVANT d’ouvrir le dialog
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isBusy = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Marquer comme effectuée ?"),
            content: Text("Confirmer la fin du trajet $departure → $arrival ?"),
            actions: [
              TextButton(
                onPressed: isBusy ? null : () => nav.pop(),
                child: const Text("Annuler"),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                onPressed: isBusy
                    ? null
                    : () async {
                        try {
                          setState(() => isBusy = true);

                          final maybeDriverId = annonceRef.parent.parent?.id;
                          final driverId =
                              maybeDriverId ??
                              (throw Exception("driverId introuvable"));

                          await RideService.markCourseCompleted(
                            annonceRef: annonceRef,
                            driverId: driverId,
                            passengersSubcollectionName: 'passengers',
                          ).timeout(const Duration(seconds: 15));

                          if (ctx.mounted) {
                            nav.pop(); // fermer le dialog
                            messenger?.showSnackBar(
                              const SnackBar(
                                content: Text("Trajet marqué comme effectué."),
                              ),
                            );
                          }
                        } on TimeoutException {
                          if (ctx.mounted) {
                            setState(() => isBusy = false);
                            messenger?.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Temps dépassé. Vérifiez votre connexion.",
                                ),
                              ),
                            );
                          }
                        } on FirebaseException catch (e) {
                          if (!ctx.mounted) return;
                          setState(() => isBusy = false);

                          debugPrint("🔥 FirebaseException: code=${e.code}");
                          debugPrint("🔥 Message complet: ${e.message}");

                          messenger?.showSnackBar(
                            SnackBar(
                              content: Text(
                                "Erreur Firestore (${e.code}) — voir console pour le détail.",
                              ),
                            ),
                          );
                        } catch (e) {
                          if (ctx.mounted) {
                            setState(() => isBusy = false);
                            messenger?.showSnackBar(
                              SnackBar(content: Text("Erreur: $e")),
                            );
                          }
                        }
                      },
                icon: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(isBusy ? "Validation..." : "Valider"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmAndDelete(BuildContext context) {
    // Références stables
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) {
        bool isDeleting = false;

        Future<void> doDelete(StateSetter setState) async {
          try {
            setState(() => isDeleting = true);

            // ✅ SÉCURITÉ: re-check qu'il n'y a AUCUNE réservation
            final hasAnyReservation = await annonceRef
                .collection('passengers')
                .limit(1)
                .get()
                .then((s) => s.docs.isNotEmpty);

            if (hasAnyReservation) {
              setState(() => isDeleting = false);
              if (ctx.mounted) {
                messenger?.showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Pour supprimer veuillez contacter l'équipe support.",
                    ),
                  ),
                );
              }
              return;
            }

            await annonceRef.delete();

            if (ctx.mounted) {
              nav.pop(); // fermer le dialog
              messenger?.showSnackBar(
                const SnackBar(content: Text("Annonce supprimée avec succès")),
              );
            }
          } on FirebaseException catch (e) {
            if (ctx.mounted) {
              setState(() => isDeleting = false);
              messenger?.showSnackBar(
                SnackBar(
                  content: Text("Échec : ${e.message ?? 'erreur inconnue'}"),
                ),
              );
            }
          } catch (_) {
            if (ctx.mounted) {
              setState(() => isDeleting = false);
              messenger?.showSnackBar(
                const SnackBar(content: Text("Une erreur est survenue.")),
              );
            }
          }
        }

        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("Confirmation"),
            content: Text(
              "Voulez-vous vraiment supprimer l'annonce $departure → $arrival ?",
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => nav.pop(),
                child: const Text("Annuler"),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isDeleting ? null : () => doDelete(setState),
                icon: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete),
                label: Text(isDeleting ? "Suppression..." : "Supprimer"),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// =====================
/// CTA conducteur selon statut du TRIP
/// =====================
class _DriverCta extends StatelessWidget {
  final DocumentReference annonceRef;
  final String departure;
  final String arrival;
  final Future<void> Function(BuildContext, String?) onStart;
  final Future<void> Function(BuildContext, String) onOpenMap;
  final void Function(BuildContext) onMarkCompleted;
  final bool? isMeDriver;

  const _DriverCta({
    required this.annonceRef,
    required this.departure,
    required this.arrival,
    required this.onStart,
    required this.onOpenMap,
    required this.onMarkCompleted,
    required this.isMeDriver,
  });

  @override
  Widget build(BuildContext context) {
    if (isMeDriver != true) {
      return const SizedBox.shrink();
    }

    // On écoute l'annonce pour récupérer tripId (et donc le statut du trip)
    return StreamBuilder<DocumentSnapshot>(
      stream: annonceRef.snapshots(),
      builder: (context, snap) {
        final data = (snap.data?.data() as Map<String, dynamic>?) ?? {};
        final String? tripId = (data['tripId'] as String?);

        if (tripId == null || tripId.isEmpty) {
          // Pas de trip → proposer "Commencer la course" (créera le trip)
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => onStart(context, null),
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text("Commencer la course"),
              ),
            ],
          );
        }

        // Si on a un tripId → écouter son statut
        final tripDoc = FirebaseFirestore.instance
            .collection('trips')
            .doc(tripId);
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: tripDoc.snapshots(),
          builder: (context, s2) {
            final status =
                ((s2.data?.data()?['status'] as String?) ?? 'scheduled')
                    .toLowerCase();

            if (status == TripStatusService.scheduled) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => onStart(context, tripId),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text("Commencer la course"),
                  ),
                ],
              );
            }

            if (status == TripStatusService.running) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onOpenMap(context, tripId),
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text("Ouvrir la carte (en cours)"),
                  ),
                ],
              );
            }

            if (status == TripStatusService.completed) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => onMarkCompleted(context),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Marquer comme effectuée"),
                  ),
                ],
              );
            }

            // canceled ou autre → pas de CTA
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

/// =====================
/// BULLES D'ARRÊTS (une seule ligne) — (TES ÉLÉMENTS ORIGINAUX)
/// =====================
class _StopsBubbles extends StatelessWidget {
  final DocumentReference annonceRef;
  const _StopsBubbles({required this.annonceRef});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: annonceRef.snapshots(),
      builder: (context, snap) {
        if (snap.hasError || !snap.hasData) {
          return const SizedBox.shrink();
        }
        final data = snap.data!.data() as Map<String, dynamic>?;
        final raw = (data?['stops'] ?? []) as List<dynamic>;
        final stops = raw
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (stops.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        );
      },
    );
  }
}

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

/// ================================================
/// Affichage des places — (TES ÉLÉMENTS ORIGINAUX)
/// ================================================
class _SeatDisplay extends StatelessWidget {
  final int seats;
  final int reservedSeats;
  final Color color;

  const _SeatDisplay({
    required this.seats,
    required this.reservedSeats,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final int total = seats.clamp(0, 9999);
    final int reserved = reservedSeats.clamp(0, total);
    final double ratio = total == 0 ? 0 : reserved / total;

    if (total <= 4) {
      // Affichage classique: une icône par place
      return Wrap(
        spacing: 6,
        children: List.generate(total, (index) {
          final isReserved = index < reserved;
          return Icon(
            isReserved ? Icons.person : Icons.person_outline,
            size: 20,
            color: color,
          );
        }),
      );
    }

    // Affichage condensé: "reserved/total" + 1 icône avec remplissage partiel
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$reserved/$total",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        _PartialFillIcon(
          size: 22,
          outlineColor: Colors.grey,
          fillColor: color,
          ratio: ratio,
        ),
      ],
    );
  }
}

/// Icône "person" remplie de bas en haut selon [ratio] (0.0 → 1.0)
class _PartialFillIcon extends StatelessWidget {
  final double size;
  final Color outlineColor;
  final Color fillColor;
  final double ratio;

  const _PartialFillIcon({
    required this.size,
    required this.outlineColor,
    required this.fillColor,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = ratio.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.person_outline, size: size, color: outlineColor),
          // Remplissage partiel depuis le bas
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: SizedBox(
                width: size,
                height: size * clamped,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.person, size: size, color: fillColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
