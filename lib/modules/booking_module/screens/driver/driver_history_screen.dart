// lib/screens/passenger/driver_history_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/widgets/driver_history_card.dart';
import 'package:u_go/modules/booking_module/widgets/search_filter_bar.dart';
import 'package:u_go/modules/booking_module/widgets/filter_criteria.dart';

// Ajouts:
import 'package:u_go/modules/booking_module/models/announce_draft.dart';
import 'package:u_go/modules/booking_module/services/announce_prefill_service.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({super.key});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

enum SortMode { none, priceAsc, passengerDesc, timeAsc }

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  FilterCriteria _criteria = FilterCriteria.empty;
  SortMode _sort = SortMode.none;

  // ---- Helpers ----
  String _str(dynamic v) => v?.toString() ?? '';
  int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  String _formatFrenchDateLabel({DateTime? dt, String? dateText}) {
    DateTime? dateObj = dt;
    if (dateObj == null && (dateText != null && dateText.isNotEmpty)) {
      dateObj = DateTime.tryParse(dateText);
    }
    if (dateObj == null) return "Date inconnue";
    final formatter = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final s = formatter.format(dateObj);
    return s[0].toUpperCase() + s.substring(1);
  }

  double _parsePriceToDouble(String price) {
    if (price.isEmpty) return 0.0;
    var cleaned = price.replaceAll(RegExp(r'[^0-9,\.\-]'), '');
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    if (lastComma != -1 && lastDot != -1) {
      if (lastComma > lastDot) {
        cleaned = cleaned.replaceAll('.', '');
        cleaned = cleaned.replaceRange(lastComma, lastComma + 1, '.');
        cleaned = cleaned.replaceAll(',', '');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (lastComma != -1) {
      cleaned = cleaned.replaceAll(',', '.');
    }
    return double.tryParse(cleaned) ?? 0.0;
  }

  TimeOfDay? _parseTimeOfDayFromText(String s) {
    final parts = s.split(':');
    if (parts.length >= 2) {
      final hh = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hh, minute: mm);
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay? tod) {
    if (tod == null) return "";
    final h = tod.hour.toString().padLeft(2, '0');
    final m = tod.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  int _weekdayFromDate(DateTime? dt) => dt?.weekday ?? 0; // 1=Lundi..7

  // Map Firestore -> VM
  List<_DriverTripVM> _mapDocsToVM(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs.map((doc) {
      final d = doc.data();

      // completedAt (source principale pour date/heure)
      DateTime? completedAt;
      if (d['completedAt'] is Timestamp) {
        completedAt = (d['completedAt'] as Timestamp).toDate();
      } else if (d['dateText'] is String) {
        final dt = DateTime.tryParse(d['dateText']);
        if (dt != null &&
            d['timeText'] is String &&
            (d['timeText'] as String).contains(':')) {
          final parts = (d['timeText'] as String).split(':');
          final hh = int.tryParse(parts[0]) ?? 0;
          final mm = int.tryParse(parts[1]) ?? 0;
          completedAt = DateTime(dt.year, dt.month, dt.day, hh, mm);
        } else {
          completedAt = dt;
        }
      }

      final timeText = _str(d['timeText']);
      final tod = timeText.isNotEmpty
          ? _parseTimeOfDayFromText(timeText)
          : (completedAt != null
                ? TimeOfDay(hour: completedAt.hour, minute: completedAt.minute)
                : null);

      final priceStr = _str(d['price']);
      final priceVal = _parsePriceToDouble(priceStr);

      final passengerCount = _int(
        d['reservedSeats'] ?? d['reservedCount'] ?? 0,
      );

      // ✅ capacité réelle (seats/capacity) que l'on DOIT utiliser pour la reconduction
      final capacity = _int(d['seats'] ?? d['capacity'] ?? 0);

      return _DriverTripVM(
        depart: _str(d['depart']),
        meetingPlace: _str(d['meetingPlace']),
        departureAddress: _str(d['departureAddress']),
        destination: _str(d['destination']),
        arrivalAddress: _str(d['arrivalAddress']),
        priceStr: priceStr,
        priceVal: priceVal,
        timeText: timeText.isNotEmpty ? timeText : null,
        timeOfDay: tod,
        completedAt: completedAt,
        dateText: _str(d['dateText']),
        weekday: _weekdayFromDate(completedAt),
        passengerCount: passengerCount,
        capacity: capacity, // ✅
      );
    }).toList();
  }

  // Filtres
  List<_DriverTripVM> _applyFilters(
    List<_DriverTripVM> items,
    FilterCriteria c,
  ) {
    return items.where((t) {
      // Jour
      if (c.day != null) {
        final wd = intFromWeekday(c.day)!;
        if (t.weekday != wd) return false;
      }
      // Départ
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
      if (c.minPrice != null && t.priceVal < c.minPrice!) return false;
      if (c.maxPrice != null && t.priceVal > c.maxPrice!) return false;

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
      return true;
    }).toList();
  }

  // Tri
  List<_DriverTripVM> _applySort(List<_DriverTripVM> list, SortMode mode) {
    final copy = [...list];
    switch (mode) {
      case SortMode.priceAsc:
        copy.sort((a, b) => a.priceVal.compareTo(b.priceVal));
        break;
      case SortMode.passengerDesc:
        copy.sort((a, b) => b.passengerCount.compareTo(a.passengerCount));
        break;
      case SortMode.timeAsc:
        copy.sort((a, b) {
          final ad = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bd = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return ad.compareTo(bd);
        });
        break;
      case SortMode.none:
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
              leading: const Icon(Icons.group),
              title: const Text("Passagers (décroissant)"),
              onTap: () => Navigator.of(context).pop(SortMode.passengerDesc),
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Veuillez vous connecter")),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('announces_effectuees')
        .orderBy('completedAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Historique des annonces',
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
          SearchFilterBar(
            criteria: _criteria,
            onChanged: (c) => setState(() => _criteria = c),
            onOpenSort: _openSortSheet,
            backgroundColor: secondColor,
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text("Erreur : ${snap.error}"));
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("Aucune annonce effectuée."));
                }

                final items = _mapDocsToVM(docs);
                final filtered = _applyFilters(items, _criteria);
                final visible = _applySort(filtered, _sort);

                if (visible.isEmpty) {
                  return const Center(
                    child: Text("Aucun élément ne correspond aux filtres."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final t = visible[i];

                    final dateLabel = _formatFrenchDateLabel(
                      dt: t.completedAt,
                      dateText: t.dateText,
                    );

                    final time = t.timeText ?? _formatTimeOfDay(t.timeOfDay);
                    final departureAddrDisplay = t.meetingPlace.isNotEmpty
                        ? t.meetingPlace
                        : (t.departureAddress.isNotEmpty
                              ? t.departureAddress
                              : '');

                    return DriverHistoryCard(
                      dateLabel: dateLabel,
                      time: time,
                      departure: t.depart,
                      departureAddress: departureAddrDisplay,
                      arrival: t.destination,
                      arrivalAddress: t.arrivalAddress,
                      price: t.priceStr,
                      passengerCount: t.passengerCount,
                      onReconduire: () {
                        // 1) Construire le draft avec DATE VIDE (null) et TIME conservée
                        final draft = AnnounceDraft(
                          depart: t.depart,
                          destination: t.destination,
                          meetingPlace: departureAddrDisplay,
                          arrivalPlace: t.arrivalAddress,
                          date: null, // ← EXIGÉ : pas de date pré-remplie
                          time: t.timeOfDay, // si tu veux vider l’heure -> null
                          seats: t
                              .capacity, // ✅ CAPACITÉ (seats), pas reservedSeats
                          price: (t.priceVal).toInt(),
                        );

                        // 2) Poser le draft
                        final svc = AnnouncePrefillService();
                        svc.setDraft(draft);

                        // 3) Aller vers l’onglet "Annoncer" (index = 1)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DriverHomeScreen(initialIndex: 1),
                          ),
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
}

// ---------- ViewModel ----------
class _DriverTripVM {
  final String depart;
  final String meetingPlace;
  final String departureAddress;
  final String destination;
  final String arrivalAddress;

  final String priceStr;
  final double priceVal;

  final String? timeText;
  final TimeOfDay? timeOfDay;

  final DateTime? completedAt;
  final String dateText;
  final int weekday; // 1..7

  final int passengerCount; // réservés
  final int capacity; // ✅ capacité totale

  _DriverTripVM({
    required this.depart,
    required this.meetingPlace,
    required this.departureAddress,
    required this.destination,
    required this.arrivalAddress,
    required this.priceStr,
    required this.priceVal,
    required this.timeText,
    required this.timeOfDay,
    required this.completedAt,
    required this.dateText,
    required this.weekday,
    required this.passengerCount,
    required this.capacity,
  });
}
