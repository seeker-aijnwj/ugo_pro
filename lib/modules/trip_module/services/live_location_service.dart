import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Modèle de position live
class LivePoint {
  final double lat;
  final double lng;
  final double? heading; // en degrés
  final double? speed;   // m/s
  final DateTime ts;

  LivePoint({
    required this.lat,
    required this.lng,
    required this.ts,
    this.heading,
    this.speed,
  });

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'heading': heading,
        'speed': speed,
        'ts': Timestamp.fromDate(ts),
      };

  static LivePoint? fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>?;
    if (d == null) return null;
    final ts = (d['ts'] as Timestamp?)?.toDate() ?? DateTime.now();
    return LivePoint(
      lat: (d['lat'] as num).toDouble(),
      lng: (d['lng'] as num).toDouble(),
      heading: (d['heading'] as num?)?.toDouble(),
      speed: (d['speed'] as num?)?.toDouble(),
      ts: ts,
    );
  }
}

/// Service d’upload et d’écoute live
///
/// Schéma Firestore proposé:
/// live_locations/{tripId}/actors/{userId}
///   { lat, lng, heading, speed, ts }
///
/// - tripId : identifiant de trajet (ou "global" si tu veux par user)
/// - userId : driver ou passenger (FirebaseAuth.uid)
class LiveLocationService {
  final FirebaseFirestore _db;

  LiveLocationService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference _doc(String tripId, String userId) {
    return _db.collection('live_locations')
      .doc(tripId)
      .collection('actors')
      .doc(userId);
  }

  /// Publier une position (driver/pax)
  Future<void> publish({
    required String tripId,
    required String userId,
    required Position position,
  }) async {
    final data = LivePoint(
      lat: position.latitude,
      lng: position.longitude,
      heading: position.heading == 0 ? null : position.heading,
      speed: position.speed == 0 ? null : position.speed,
      ts: DateTime.now(),
    ).toMap();

    await _doc(tripId, userId).set(data, SetOptions(merge: true));
  }

  /// Écouter la position live d’un acteur (ex: driver) pour afficher côté passager.
  Stream<LivePoint?> watchActor({
    required String tripId,
    required String userId,
  }) {
    return _doc(tripId, userId).snapshots().map((snap) => LivePoint.fromDoc(snap));
  }

  /// Option: écouter tous les acteurs d’un trip (driver + passagers) si tu veux.
  Stream<List<LivePoint>> watchAllActors({required String tripId}) {
    return _db.collection('live_locations')
        .doc(tripId)
        .collection('actors')
        .snapshots()
        .map((qs) => qs.docs
            .map((d) => LivePoint.fromDoc(d))
            .where((e) => e != null)
            .cast<LivePoint>()
            .toList());
  }
}
