// lib/app/core/services/history_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// ---- MODELE ----
class Reservation {
  final String
  id; // id du doc dans users/{uid}/reservations/{id} (ou via collectionGroup)
  final String announceId;
  final String driverId;
  final String passengerId;
  final String status; // awaiting_rating | rated
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? ratePromptAt; // optionnel selon ton schéma
  final Map<String, dynamic>? meta; // champs libres (trajet, prix, etc.)

  // (facultatif) infos d'affichage si tu veux brancher direct la carte
  final String? depart;
  final String? departureAddress;
  final String? destination;
  final String? arrivalAddress;
  final String? timeText;
  final num? price;

  Reservation({
    required this.id,
    required this.announceId,
    required this.driverId,
    required this.passengerId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.ratePromptAt,
    this.meta,
    this.depart,
    this.departureAddress,
    this.destination,
    this.arrivalAddress,
    this.timeText,
    this.price,
  });

  factory Reservation.fromFirestoreDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Reservation(
      id: doc.id,
      announceId: data['announceId'] ?? '',
      driverId: data['driverId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      status: data['status'] ?? '',
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
      ratePromptAt: _toDate(data['ratePromptAt']),
      meta: data['meta'] != null
          ? Map<String, dynamic>.from(data['meta'])
          : null,

      // champs d’affichage que tu as en base (vu dans ta capture)
      depart: data['depart'],
      departureAddress: data['departureAddress'],
      destination: data['destination'],
      arrivalAddress: data['arrivalAddress'],
      timeText: data['timeText'],
      price: data['price'],
    );
  }

  static DateTime? _toDate(dynamic ts) {
    if (ts == null) return null;
    if (ts is Timestamp) return ts.toDate();
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
    return null;
  }

  /// meilleure date pour trier l’historique
  DateTime get historyDate =>
      ratePromptAt ??
      updatedAt ??
      createdAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

/// Buckets déjà séparés par statut pour l’Historique
class HistoryBuckets {
  final List<Reservation> awaitingRating;
  final List<Reservation> rated;

  const HistoryBuckets({required this.awaitingRating, required this.rated});

  bool get isEmpty => awaitingRating.isEmpty && rated.isEmpty;
}

/// ---- SERVICE ----
/// TA STRUCTURE :
/// - users/{uid}/reservations/{reservationId}
///   champs: announceId, driverId, passengerId, status ("awaiting_rating"/"rated"), createdAt, (updatedAt?), (ratePromptAt?), etc.
///
/// Pour le PASSAGER: on lit directement `users/{uid}/reservations`
/// Pour le CHAUFFEUR: on lit `collectionGroup('reservations')` filtré par driverId
class HistoryService {
  HistoryService._();

  static final _db = FirebaseFirestore.instance;
  static const List<String> _historyStatuses = ['awaiting_rating', 'rated'];

  /// ---- PASSAGER ----
  /// Historique pour un passager: on lit SA sous-collection users/{uid}/reservations
  static Stream<List<Reservation>> historyForPassengerUid(String uid) {
    final q = _db
        .collection('users')
        .doc(uid)
        .collection('reservations')
        .where('status', whereIn: _historyStatuses)
        // on ordonne sur createdAt pour l’index (tri final côté client sur historyDate)
        .orderBy('createdAt', descending: true);
    return q.snapshots().map(
      (snap) =>
          snap.docs.map(Reservation.fromFirestoreDoc).toList(growable: false),
    );
  }

  static Stream<HistoryBuckets> bucketsForPassengerUid(String uid) {
    return historyForPassengerUid(uid).map((list) {
      // tri robuste côté client
      list.sort((a, b) => b.historyDate.compareTo(a.historyDate));
      final awaiting = <Reservation>[];
      final rated = <Reservation>[];
      for (final r in list) {
        if (r.status == 'awaiting_rating') {
          awaiting.add(r);
        } else if (r.status == 'rated') {
          rated.add(r);
        }
      }
      return HistoryBuckets(awaitingRating: awaiting, rated: rated);
    });
  }

  /// ---- CHAUFFEUR ----
  /// On veut toutes les réservations (chez tous les users) où driverId == uid
  /// → collectionGroup('reservations')
  static Stream<List<Reservation>> historyForDriver(String driverId) {
    final q = _db
        .collectionGroup('reservations')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: _historyStatuses)
        .orderBy('createdAt', descending: true);
    return q.snapshots().map(
      (snap) =>
          snap.docs.map(Reservation.fromFirestoreDoc).toList(growable: false),
    );
  }

  static Stream<HistoryBuckets> bucketsForDriver(String driverId) {
    return historyForDriver(driverId).map((list) {
      list.sort((a, b) => b.historyDate.compareTo(a.historyDate));
      final awaiting = <Reservation>[];
      final rated = <Reservation>[];
      for (final r in list) {
        if (r.status == 'awaiting_rating') {
          awaiting.add(r);
        } else if (r.status == 'rated') {
          rated.add(r);
        }
      }
      return HistoryBuckets(awaitingRating: awaiting, rated: rated);
    });
  }
}
