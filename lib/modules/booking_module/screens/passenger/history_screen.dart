// lib/screens/passenger/history_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/widgets/history_card.dart';

// 👉 nouveaux imports (barre de filtre et critères partagés)
import 'package:u_go/modules/booking_module/widgets/search_filter_bar.dart';
import 'package:u_go/modules/booking_module/widgets/filter_criteria.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

// mêmes modes de tri que sur l’écran de résultats
enum SortMode { none, priceAsc, ratingDesc, timeAsc }

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<void> _intlReady;

  // 👉 état de filtre/tri (comme sur SearchResultScreen)
  FilterCriteria _criteria = FilterCriteria.empty;
  SortMode _sort = SortMode.none;

  @override
  void initState() {
    super.initState();
    // IMPORTANT : initialiser la locale 'fr_FR' une seule fois
    _intlReady = initializeDateFormatting('fr_FR');
  }

  // ---- Helpers de parsing sûrs ----
  String _str(dynamic v) => v?.toString() ?? '';
  int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  double _double(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return 0.0;
  }

  Map<String, dynamic> _map(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    return const {};
  }

  DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  String _formatFrenchDateLabel(DateTime? dt) {
    if (dt == null) return "Date inconnue";
    final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final s = formatter.format(dt);
    return s[0].toUpperCase() + s.substring(1);
  }

  /// Meilleure date pour trier l’historique
  DateTime _bestHistoryDate(Map<String, dynamic> d) {
    final meta = _map(d['meta']);
    return _ts(d['ratePromptAt']) ?? // vue dans ta capture
        _ts(d['updatedAt']) ??
        _ts(d['createdAt']) ??
        _ts(d['date']) ??
        _ts(meta['date']) ??
        _ts(d['dateText']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// Normalise un doc Firestore vers les champs attendus par HistoryCard.
  /// On utilise aussi l'uid courant pour déterminer qui est le "customer" à afficher.
  Map<String, dynamic> _normalizeDoc(
    Map<String, dynamic> d,
    String currentUid,
  ) {
    final meta = _map(d['meta']);

    final timeText = _str(d['timeText']).isNotEmpty
        ? _str(d['timeText'])
        : _str(meta['timeText']);

    final depart = [
      _str(d['depart']),
      _str(d['from']),
      _str(meta['depart']),
      _str(meta['from']),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    final meetingPlace = [
      _str(d['meetingPlace']),
      _str(meta['meetingPlace']),
      _str(d['departureMeetingPoint']),
      _str(meta['departureMeetingPoint']),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    final departureAddress = [
      _str(d['departureAddress']),
      _str(meta['departureAddress']),
      _str(d['startAddress']),
      _str(meta['startAddress']),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    final destination = [
      _str(d['destination']),
      _str(d['to']),
      _str(meta['destination']),
      _str(meta['to']),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    final arrivalAddress = [
      _str(d['arrivalAddress']),
      _str(meta['arrivalAddress']),
      _str(d['endAddress']),
      _str(meta['endAddress']),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    // price peut être string ou num -> on le laisse en string (pour display),
    // on parséra un double pour filtrer/ trier via _parsePriceToDouble
    final price = [
      _str(d['price']),
      _str(meta['price']),
      _str(d['amount']),
      _str(meta['amount']),
    ].firstWhere((e) => e.isNotEmpty, orElse: () => '');

    // Déterminer qui afficher comme "customer":
    // - si je suis le passager: afficher le driverId
    // - si je suis le chauffeur: afficher le passengerId
    final passengerId = _str(d['passengerId']);
    final driverId = _str(d['driverId']);
    final customerId = (passengerId == currentUid) ? driverId : passengerId;

    final rating = _double(d['rating'] ?? meta['rating'] ?? 0);
    final ratingCount = _int(d['ratingCount'] ?? meta['ratingCount'] ?? 0);

    final historyDate = _bestHistoryDate(d);

    return {
      'timeText': timeText,
      'depart': depart,
      'meetingPlace': meetingPlace,
      'departureAddress': departureAddress,
      'destination': destination,
      'arrivalAddress': arrivalAddress,
      'price': price,
      'customerId': customerId,
      'rating': rating,
      'ratingCount': ratingCount,
      'historyDate': historyDate,
    };
  }

  // ---- Helpers filtres/tri (comme SearchResultScreen) ----

  double _parsePriceToDouble(String price) {
    if (price.isEmpty) return 0.0;

    // Garde chiffres, virgules, points et signe -
    var cleaned = price.replaceAll(RegExp(r'[^0-9,\.\-]'), '');

    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');

    if (lastComma != -1 && lastDot != -1) {
      // Les deux présents : on garde le dernier comme séparateur décimal
      if (lastComma > lastDot) {
        // Virgule = décimal → supprimer les points (milliers), remplacer la dernière virgule par un point
        cleaned = cleaned.replaceAll('.', '');
        // remplace seulement la dernière virgule par un point
        cleaned = cleaned.replaceRange(lastComma, lastComma + 1, '.');
        cleaned = cleaned.replaceAll(',', '');
      } else {
        // Point = décimal → supprimer les virgules (milliers)
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (lastComma != -1) {
      // Uniquement virgule → décimal
      cleaned = cleaned.replaceAll(',', '.');
    } else {
      // Uniquement point ou ni l’un ni l’autre → rien à faire
    }

    return double.tryParse(cleaned) ?? 0.0;
  }

  int _weekdayFromDate(DateTime? dt) => dt?.weekday ?? 0; // 1=Lundi..7

  TimeOfDay? _parseTimeOfDayFromText(String s) {
    // attend "HH:mm"
    final parts = s.split(':');
    if (parts.length >= 2) {
      final hh = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hh, minute: mm);
    }
    return null;
  }

  TimeOfDay _extractTripTime(Map<String, dynamic> norm) {
    // priorité timeText, sinon heure de historyDate
    final t = _str(norm['timeText']);
    final tod = t.isNotEmpty ? _parseTimeOfDayFromText(t) : null;
    if (tod != null) return tod;

    final dt = norm['historyDate'] as DateTime?;
    if (dt != null) return TimeOfDay(hour: dt.hour, minute: dt.minute);

    return const TimeOfDay(hour: 0, minute: 0);
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> items,
    FilterCriteria c,
  ) {
    return items.where((d) {
      final historyDate = d['historyDate'] as DateTime?;
      final weekday = _weekdayFromDate(historyDate);

      // Jour
      if (c.day != null) {
        final wd = intFromWeekday(c.day)!; // 1..7
        if (weekday != wd) return false;
      }

      // Départ
      if (c.departureQuery != null && c.departureQuery!.isNotEmpty) {
        final s = _str(d['depart']).toLowerCase();
        if (!s.contains(c.departureQuery!.toLowerCase())) return false;
      }

      // Arrivée
      if (c.arrivalQuery != null && c.arrivalQuery!.isNotEmpty) {
        final s = _str(d['destination']).toLowerCase();
        if (!s.contains(c.arrivalQuery!.toLowerCase())) return false;
      }

      // Prix
      final priceStr = _str(d['price']);
      final priceVal = _parsePriceToDouble(priceStr);
      if (c.minPrice != null && priceVal < c.minPrice!) return false;
      if (c.maxPrice != null && priceVal > c.maxPrice!) return false;

      // Plage horaire
      if (c.startTime != null || c.endTime != null) {
        final tod = _extractTripTime(d);
        final tripMinutes = tod.hour * 60 + tod.minute;
        final startMinutes = c.startTime == null
            ? 0
            : c.startTime!.hour * 60 + c.startTime!.minute;
        final endMinutes = c.endTime == null
            ? (24 * 60 - 1)
            : c.endTime!.hour * 60 + c.endTime!.minute;
        if (tripMinutes < startMinutes || tripMinutes > endMinutes) {
          return false;
        }
      }

      // onlyAvailableSeats ne s’applique pas à l’historique -> ignoré
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _applySort(
    List<Map<String, dynamic>> list,
    SortMode mode,
  ) {
    final copy = [...list];
    switch (mode) {
      case SortMode.priceAsc:
        copy.sort((a, b) {
          final pa = _parsePriceToDouble(_str(a['price']));
          final pb = _parsePriceToDouble(_str(b['price']));
          return pa.compareTo(pb);
        });
        break;
      case SortMode.ratingDesc:
        copy.sort((a, b) {
          final ra = _double(a['rating']);
          final rb = _double(b['rating']);
          final r = rb.compareTo(ra);
          if (r != 0) return r;
          // départager par nb d’avis
          final ca = _int(a['ratingCount']);
          final cb = _int(b['ratingCount']);
          return cb.compareTo(ca);
        });
        break;
      case SortMode.timeAsc:
        copy.sort((a, b) {
          final ad =
              (a['historyDate'] as DateTime?) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bd =
              (b['historyDate'] as DateTime?) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return ad.compareTo(bd);
        });
        break;
      case SortMode.none:
        // on conserve l’ordre par défaut (déjà trié desc par date en base)
        break;
    }
    return copy;
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
              title: const Text("Heure (date historique)"),
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Veuillez vous connecter")),
      );
    }

    final passengerReservationsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('reservations')
        .where('passengerId', isEqualTo: uid) // <-- blindage
        .where('status', whereIn: const ['awaiting_rating', 'rated'])
        .orderBy('createdAt', descending: true)
        .snapshots();

    return FutureBuilder<void>(
      future: _intlReady,
      builder: (context, intlSnap) {
        if (intlSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Historique des trajets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Column(
            children: [
              // 👉 Barre de filtre opérationnelle (jour + feuille filtres + tri)
              SearchFilterBar(
                criteria: _criteria,
                onChanged: (c) => setState(() => _criteria = c),
                onOpenSort: _openSortSheet,
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: passengerReservationsStream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(
                        child: Text("Erreur (passager) : ${snap.error}"),
                      );
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text("Aucun trajet dans l’historique."),
                      );
                    }

                    // 1) normaliser
                    final normalized = docs
                        .map((e) => _normalizeDoc(e.data(), uid))
                        .toList(growable: false);

                    // 2) trier desc par date (comportement existant)
                    normalized.sort((a, b) {
                      final ad =
                          (a['historyDate'] as DateTime?) ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final bd =
                          (b['historyDate'] as DateTime?) ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return bd.compareTo(ad); // desc
                    });

                    // 3) appliquer filtres + tri
                    final filtered = _applyFilters(normalized, _criteria);
                    final visible = _applySort(filtered, _sort);

                    if (visible.isEmpty) {
                      return const Center(
                        child: Text("Aucun trajet ne correspond aux filtres."),
                      );
                    }

                    // 4) UI
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: visible.length,
                      itemBuilder: (context, i) {
                        final d = visible[i];

                        final dateLabel = _formatFrenchDateLabel(
                          d['historyDate'] as DateTime?,
                        );

                        final timeText = _str(d['timeText']);
                        final depart = _str(d['depart']);
                        final meetingPlace = _str(d['meetingPlace']);
                        final departureAddress = _str(d['departureAddress']);
                        final destination = _str(d['destination']);
                        final arrivalAddress = _str(d['arrivalAddress']);
                        final price = _str(d['price']);
                        final customerId = _str(d['customerId']);
                        final rating = _double(d['rating']);
                        final ratingCount = _int(d['ratingCount']);

                        final departureAddrDisplay = meetingPlace.isNotEmpty
                            ? meetingPlace
                            : (departureAddress.isNotEmpty
                                  ? departureAddress
                                  : '');

                        return FutureBuilder<
                          DocumentSnapshot<Map<String, dynamic>>
                        >(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(customerId)
                              .get(),
                          builder: (context, snap) {
                            String displayCustomer = "Utilisateur inconnu";

                            if (snap.hasData && snap.data!.exists) {
                              final u = snap.data!.data() ?? {};

                              // Champs possibles pour le nom
                              final name = (u['name'] ?? '').toString().trim();
                              final prenom = (u['prenom'] ?? '')
                                  .toString()
                                  .trim();
                              final nom = (u['nom'] ?? '').toString().trim();
                              final full = [
                                prenom,
                                nom,
                              ].where((s) => s.isNotEmpty).join(' ').trim();

                              // Repli : afficher le customId si aucun nom
                              final customId = (u['customId'] ?? '')
                                  .toString()
                                  .trim();

                              if (name.isNotEmpty) {
                                displayCustomer = name;
                              } else if (full.isNotEmpty) {
                                displayCustomer = full;
                              } else if (customId.isNotEmpty) {
                                displayCustomer = customId;
                              } else {
                                displayCustomer = "Nom non défini";
                              }
                            }

                            return HistoryCard(
                              dateLabel: dateLabel,
                              time: timeText,
                              departure: depart,
                              departureAddress: departureAddrDisplay,
                              arrival: destination,
                              arrivalAddress: arrivalAddress,
                              price: price,
                              customerId: displayCustomer,
                              rating: rating,
                              ratingCount: ratingCount,
                              onTap: () {
                                // Navigator.push(...);
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
      },
    );
  }
}
