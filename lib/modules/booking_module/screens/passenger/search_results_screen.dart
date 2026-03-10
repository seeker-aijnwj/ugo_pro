// lib/screens/passenger/search_result_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/trip_module/widgets/trip_card.dart';
import 'package:u_go/modules/booking_module/widgets/search_filter_bar.dart';
import 'package:u_go/modules/booking_module/widgets/filter_criteria.dart';
import 'package:u_go/modules/booking_module/screens/passenger/reservation_success_screen.dart';

enum SortMode { none, priceAsc, ratingDesc, timeAsc }

class SearchResultScreen extends StatefulWidget {
  final String depart;
  final String destination;
  final String? date; // optionnelle
  final VoidCallback onBack;

  const SearchResultScreen({
    super.key,
    required this.depart,
    required this.destination,
    this.date,
    required this.onBack,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  FilterCriteria _criteria = FilterCriteria.empty;
  SortMode _sort = SortMode.none;

  // Formate "Mardi 28 juin 2025"
  String formatFrenchDateLabel({DateTime? dt, String? dateText}) {
    DateTime? dateObj;
    if (dt != null) {
      dateObj = dt;
    } else if (dateText != null && dateText.isNotEmpty) {
      dateObj = DateTime.tryParse(dateText);
    }
    if (dateObj == null) return "Date inconnue";
    final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final s = formatter.format(dateObj);
    return s[0].toUpperCase() + s.substring(1);
  }

  void _openSortSheet() {
    showModalBottomSheet<SortMode>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                "Trier par",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.price_change),
              title: const Text("Prix croissant"),
              onTap: () => Navigator.of(context).pop(SortMode.priceAsc),
            ),
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text("Meilleure note"),
              onTap: () => Navigator.of(context).pop(SortMode.ratingDesc),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text("Heure de départ"),
              onTap: () => Navigator.of(context).pop(SortMode.timeAsc),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    ).then((val) {
      if (val != null) setState(() => _sort = val);
    });
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> base = FirebaseFirestore.instance
        .collectionGroup('announces')
        .where('depart', isEqualTo: widget.depart)
        .where('destination', isEqualTo: widget.destination);

    final query = (widget.date != null && widget.date!.isNotEmpty)
        ? base.where('dateText', isEqualTo: widget.date)
        : base;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.depart} → ${widget.destination}',
          style: const TextStyle(
            fontFamily: 'Agbalumo',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ Barre de filtres (jour + filtres + tri)
          SearchFilterBar(
            criteria: _criteria,
            onChanged: (c) => setState(() => _criteria = c),
            onOpenSort: _openSortSheet,
          ),

          // Résultats
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text("Erreur : ${snap.error}"));
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucun trajet trouvé."));
                }

                final items = _mapDocsToTrips(snap.data!.docs);
                final visible = _applyFilters(items, _criteria);
                final sorted = _applySort(visible, _sort);

                if (sorted.isEmpty) {
                  return const Center(
                    child: Text("Aucun trajet ne correspond aux filtres."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  itemBuilder: (context, i) {
                    final t = sorted[i];

                    // 🔎 Récupère la note & le nombre de clients du chauffeur
                    return FutureBuilder<_DriverStats>(
                      future: _fetchDriverStats(t.driverId),
                      builder: (context, dsnap) {
                        final stats = dsnap.data;
                        final driverRating = stats?.rating ?? t.rating;
                        final clientCount = stats?.clientCount ?? t.ratingCount;

                        return TripCard(
                          driverId: t.driverId,
                          dateLabel: formatFrenchDateLabel(
                            dt: t.departureAt,
                            dateText: t.dateText,
                          ),
                          departure: t.depart,
                          departureAddress: t.meetingPlace,
                          arrival: t.destination,
                          arrivalAddress: t.arrivalAddress,
                          time: t.timeText ?? _formatTimeOfDay(t.timeOfDay),
                          price: t.price.toStringAsFixed(0),
                          rating: driverRating,
                          ratingCount:
                              clientCount, // affiché ailleurs si besoin
                          seats: t.seats,
                          reservedSeats: t.reservedSeats,
                          stops: t.stops,
                          onReserve: () async {
                            try {
                              // 👉 Demande pickup/dropoff avant création
                              final choice = await _selectStopsForTrip(
                                context,
                                t,
                              );
                              if (choice == null) return;

                              await _reserveTripAndCreateRecord(
                                t.originalDoc,
                                pickup: choice.$1,
                                dropoff: choice.$2,
                              );

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ReservationSuccessScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Modèle interne pour faciliter filtre/tri ----------
  String _formatTimeOfDay(TimeOfDay? tod) {
    if (tod == null) return "";
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  int _weekdayFromDate(DateTime? dt) {
    if (dt == null) return 0;
    // DateTime.weekday : 1 = Lundi ... 7 = Dimanche
    return dt.weekday;
  }

  TimeOfDay? _timeOfDayFromDate(DateTime? dt) {
    if (dt == null) return null;
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  List<_TripVM> _mapDocsToTrips(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) {
      final d = doc.data();

      // Date/heure du trajet
      DateTime? departureAt;
      if (d['departureAt'] is Timestamp) {
        departureAt = (d['departureAt'] as Timestamp).toDate();
      } else if (d['dateText'] is String) {
        // tente de parser "YYYY-MM-DD" + éventuellement "timeText" "HH:mm"
        final dt = DateTime.tryParse(d['dateText']);
        if (dt != null &&
            d['timeText'] is String &&
            (d['timeText'] as String).contains(':')) {
          final parts = (d['timeText'] as String).split(':');
          final hh = int.tryParse(parts[0]) ?? 0;
          final mm = int.tryParse(parts[1]) ?? 0;
          departureAt = DateTime(dt.year, dt.month, dt.day, hh, mm);
        } else {
          departureAt = dt;
        }
      }

      // Heure de départ indépendante si nécessaire
      final tod = _timeOfDayFromDate(departureAt);

      final price = (d['price'] is num) ? (d['price'] as num).toDouble() : 0.0;

      // ⚠️ On garde ces deux champs comme fallback, mais on priorisera le profil chauffeur
      final rating = (d['rating'] is num)
          ? (d['rating'] as num).toDouble()
          : 0.0;
      final ratingCount = (d['ratingCount'] is num)
          ? (d['ratingCount'] as num).toInt()
          : 0;

      final seats = (d['seats'] is num) ? (d['seats'] as num).toInt() : 0;
      final reserved = (d['reservedSeats'] is num)
          ? (d['reservedSeats'] as num).toInt()
          : 0;

      // Stops (facultatif) : string[] ou [{name: "..."}]
      final List<String> stops = (() {
        final raw = d['stops'];
        if (raw is List) {
          return raw
              .map((e) {
                if (e is String) return e;
                if (e is Map && e['name'] is String) return e['name'] as String;
                return null;
              })
              .whereType<String>()
              .toList();
        }
        return <String>[];
      })();

      return _TripVM(
        originalDoc: doc,
        driverId: (d['userId'] ?? '') as String,
        depart: (d['depart'] ?? '') as String,
        meetingPlace: (d['meetingPlace'] ?? '') as String,
        destination: (d['destination'] ?? '') as String,
        // ✅ IMPORTANT : l'annonce stocke *arrivalPlace*
        arrivalAddress: (d['arrivalPlace'] ?? '') as String,
        dateText: (d['dateText'] ?? '') as String,
        timeText: (d['timeText'] ?? '') as String?,
        departureAt: departureAt,
        timeOfDay: tod,
        weekday: _weekdayFromDate(departureAt), // 1..7
        price: price,
        rating: rating,
        ratingCount: ratingCount,
        seats: seats,
        reservedSeats: reserved,
        stops: stops,
      );
    }).toList();
  }

  List<_TripVM> _applyFilters(List<_TripVM> data, FilterCriteria c) {
    return data.where((t) {
      // Jour
      if (c.day != null) {
        final wd = intFromWeekday(c.day)!; // 1..7
        if (t.weekday != wd) return false;
      }
      // Départ (recherche partielle)
      if (c.departureQuery != null && c.departureQuery!.isNotEmpty) {
        if (!t.depart.toLowerCase().contains(c.departureQuery!.toLowerCase())) {
          return false;
        }
      }
      // Arrivée
      if (c.arrivalQuery != null && c.arrivalQuery!.isNotEmpty) {
        if (!t.destination.toLowerCase().contains(
          c.arrivalQuery!.toLowerCase(),
        )) {
          return false;
        }
      }
      // Prix
      if (c.minPrice != null && t.price < c.minPrice!) return false;
      if (c.maxPrice != null && t.price > c.maxPrice!) return false;

      // Plage horaire
      if (c.startTime != null || c.endTime != null) {
        final tripMinutes =
            (t.timeOfDay?.hour ?? 0) * 60 + (t.timeOfDay?.minute ?? 0);
        final startMinutes = c.startTime == null
            ? 0
            : c.startTime!.hour * 60 + c.startTime!.minute;
        final endMinutes = c.endTime == null
            ? 24 * 60 - 1
            : c.endTime!.hour * 60 + c.endTime!.minute;
        if (tripMinutes < startMinutes || tripMinutes > endMinutes) {
          return false;
        }
      }

      // Places disponibles
      if (c.onlyAvailableSeats && t.reservedSeats >= t.seats) return false;

      return true;
    }).toList();
  }

  List<_TripVM> _applySort(List<_TripVM> list, SortMode mode) {
    final copy = [...list];
    switch (mode) {
      case SortMode.priceAsc:
        copy.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortMode.ratingDesc:
        copy.sort((a, b) {
          // Note d'abord, puis nombre d’avis (si égalité)
          final r = b.rating.compareTo(a.rating);
          if (r != 0) return r;
          return b.ratingCount.compareTo(a.ratingCount);
        });
        break;
      case SortMode.timeAsc:
        copy.sort((a, b) {
          final at = a.departureAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bt = b.departureAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return at.compareTo(bt);
        });
        break;
      case SortMode.none:
        break;
    }
    return copy;
  }

  /// Récupère les stats chauffeur (note et nb de clients)
  Future<_DriverStats> _fetchDriverStats(String driverId) async {
    if (driverId.isEmpty) {
      return const _DriverStats(rating: 0.0, clientCount: 0);
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .get();
    final data = doc.data() ?? {};

    // On prend en priorité la note chauffeur + nb clients
    final rating = (data['rating'] is num)
        ? (data['rating'] as num).toDouble()
        : 0.0;
    // Nombre total de clients servis (réservations complétées uniques)
    final clientCount = (data['clientCount'] is num)
        ? (data['clientCount'] as num).toInt()
        : 0;

    return _DriverStats(rating: rating, clientCount: clientCount);
  }

  /// Feuille de sélection des arrêts / dépose.
  /// Retourne (pickup, dropoff) ou null si annulé.
  Future<(StopOption, StopOption)?> _selectStopsForTrip(
    BuildContext context,
    _TripVM t,
  ) async {
    // Construit la liste des points dans l'ordre du trajet
    final List<StopOption> options = [
      StopOption(
        index: 0,
        label: t.meetingPlace.isNotEmpty ? t.meetingPlace : t.depart,
      ),
      ...List.generate(
        t.stops.length,
        (i) => StopOption(index: i + 1, label: t.stops[i]),
      ),
      StopOption(
        index: t.stops.length + 1,
        label: t.arrivalAddress.isNotEmpty ? t.arrivalAddress : t.destination,
      ),
    ];

    StopOption? selectedPickup = options.first;
    StopOption? selectedDrop = options.last;

    return await showModalBottomSheet<(StopOption, StopOption)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            top: 8,
          ),
          child: StatefulBuilder(
            builder: (context, setSheet) {
              String? error;
              if (selectedPickup != null &&
                  selectedDrop != null &&
                  selectedDrop!.index <= selectedPickup!.index) {
                error =
                    "Le point de dépose doit être après le point d’embarquement.";
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Choisir embarquement & dépose",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Sélectionne où monter et où descendre."),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<StopOption>(
                    value: selectedPickup,
                    decoration: const InputDecoration(
                      labelText: "Embarquement",
                      border: OutlineInputBorder(),
                    ),
                    items: options
                        .map(
                          (o) =>
                              DropdownMenuItem(value: o, child: Text(o.label)),
                        )
                        .toList(),
                    onChanged: (v) => setSheet(() => selectedPickup = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<StopOption>(
                    value: selectedDrop,
                    decoration: const InputDecoration(
                      labelText: "Dépose",
                      border: OutlineInputBorder(),
                    ),
                    items: options
                        .map(
                          (o) =>
                              DropdownMenuItem(value: o, child: Text(o.label)),
                        )
                        .toList(),
                    onChanged: (v) => setSheet(() => selectedDrop = v),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          (selectedPickup == null ||
                              selectedDrop == null ||
                              selectedDrop!.index <= selectedPickup!.index)
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pop((selectedPickup!, selectedDrop!));
                            },
                      child: const Text("Valider et réserver"),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Réservation complète (avec stops pickup/dropoff)
  Future<void> _reserveTripAndCreateRecord(
    QueryDocumentSnapshot<Map<String, dynamic>> announceDoc, {
    required StopOption pickup,
    required StopOption dropoff,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Veuillez vous connecter pour réserver.");
    }

    final db = FirebaseFirestore.instance;
    final announceRef = announceDoc.reference;
    final reservationsCol = db
        .collection('users')
        .doc(user.uid)
        .collection('reservations');

    await db.runTransaction((tx) async {
      // 1) Relire l’annonce
      final snap = await tx.get(announceRef);
      if (!snap.exists) throw Exception("Trajet introuvable.");

      final data = snap.data()!;

      // Normalise la liste de stops (string[] ou [{name: "..."}])
      final List<String> stopsList = (() {
        final raw = data['stops'];
        if (raw is List) {
          return raw
              .map((e) {
                if (e is String) return e;
                if (e is Map && e['name'] is String) return e['name'] as String;
                return null;
              })
              .whereType<String>()
              .toList();
        }
        return <String>[];
      })();

      final seats = (data['seats'] ?? 0) as int;
      final reserved = (data['reservedSeats'] ?? 0) as int;
      if (reserved >= seats) {
        throw Exception("Plus de places disponibles.");
      }

      // 2) Créer la réservation (snapshot pour affichage passager)
      final reservationRef = reservationsCol.doc();
      tx.set(reservationRef, {
        'announceId': announceRef.id,
        'driverId': data['userId'],
        'passengerId': user.uid,
        'status': 'en_cours',
        'createdAt': FieldValue.serverTimestamp(),

        'depart': data['depart'] ?? '',
        'departureAddress':
            data['meetingPlace'] ?? data['departureAddress'] ?? '',
        'destination': data['destination'] ?? '',
        // ✅ CORRIGÉ : on remplit depuis *arrivalPlace*
        'arrivalAddress': data['arrivalPlace'] ?? '',
        'dateText': data['dateText'] ?? '',
        'timeText': data['timeText'] ?? '',
        'price': data['price'] ?? 0,

        // ✅ Stops de l’annonce copiés dans la réservation
        'stops': stopsList,

        // ✅ Choix du passager
        'pickupStop': pickup.label,
        'pickupIndex': pickup.index,
        'dropoffStop': dropoff.label,
        'dropoffIndex': dropoff.index,
      });

      // 3) Incrémenter le nombre de réservations sur l’annonce
      tx.update(announceRef, {'reservedSeats': reserved + 1});

      // 3bis) Notif conducteur (facultatifement enrichie)
      if ((data['userId'] ?? '').toString().isNotEmpty) {
        final notifRef = db
            .collection('users')
            .doc(data['userId'])
            .collection('notifications')
            .doc(reservationRef.id);

        final title = "Nouvelle réservation";
        final body =
            "${data['depart'] ?? ''} → ${data['destination'] ?? ''}"
            "${(data['dateText'] ?? '').toString().isNotEmpty ? ' • ${data['dateText']}' : ''}"
            "${(data['timeText'] ?? '').toString().isNotEmpty ? ' • ${data['timeText']}' : ''}"
            " • Embarquement: ${pickup.label}"
            " • Dépose: ${dropoff.label}";

        tx.set(notifRef, {
          'type': 'reservation_created',
          'title': title,
          'body': body,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'announceId': announceRef.id,
          'reservationId': reservationRef.id,
          'actorId': user.uid,
          'roleTarget': 'driver',
          'silent': false,
        }, SetOptions(merge: true));
      }

      // 4) Mapping announce_reservations
      final announceNumber = (data['announceNumber'] ?? '') as String?;
      final driverId = (data['userId'] ?? '') as String?;

      final mapDocRef = db
          .collection('announce_reservations')
          .doc(announceRef.id);
      tx.set(mapDocRef, {
        'announceId': announceRef.id,
        if (announceNumber != null) 'announceNumber': announceNumber,
        if (driverId != null) 'driverId': driverId,
        'seats': seats,
        'reservedCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5) Sous-collection passengers (on peut aussi y recopier les stops)
      final passengerRef = mapDocRef.collection('passengers').doc(user.uid);
      tx.set(passengerRef, {
        'passengerId': user.uid,
        'reservationId': reservationRef.id,
        'pickupStop': pickup.label,
        'pickupIndex': pickup.index,
        'dropoffStop': dropoff.label,
        'dropoffIndex': dropoff.index,
        'stops':
            stopsList, // ✅ recopie ici aussi (pratique pour vue conducteur)
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}

// ----------- ViewModels & petits POJOs -----------

class _TripVM {
  final QueryDocumentSnapshot<Map<String, dynamic>> originalDoc;

  final String driverId;
  final String depart;
  final String meetingPlace;
  final String destination;
  final String arrivalAddress;

  final String dateText;
  final String? timeText;
  final DateTime? departureAt;
  final TimeOfDay? timeOfDay;
  final int weekday; // 1..7

  final double price;
  final double rating; // fallback si pas de stats chauffeur
  final int ratingCount; // fallback si pas de clientCount
  final int seats;
  final int reservedSeats;

  final List<String> stops; // stops intermédiaires (optionnels)

  _TripVM({
    required this.originalDoc,
    required this.driverId,
    required this.depart,
    required this.meetingPlace,
    required this.destination,
    required this.arrivalAddress,
    required this.dateText,
    required this.timeText,
    required this.departureAt,
    required this.timeOfDay,
    required this.weekday,
    required this.price,
    required this.rating,
    required this.ratingCount,
    required this.seats,
    required this.reservedSeats,
    required this.stops,
  });
}

class _DriverStats {
  final double rating;
  final int clientCount;
  const _DriverStats({required this.rating, required this.clientCount});
}

class StopOption {
  final int
  index; // ordre dans l'itinéraire (0=point de départ, dernier=arrivée)
  final String label;
  StopOption({required this.index, required this.label});

  @override
  String toString() => '$index:$label';
}
