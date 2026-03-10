// lib/app/core/services/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class RatingSummary {
  /// Moyenne à afficher (incluant l’a priori de 3/5)
  final double averageDisplayed;

  /// Nombre d’avis réels (sans l’a priori)
  final int realCount;

  /// Moyenne réelle sans l’a priori (utile si besoin analytics)
  final double averageReal;

  const RatingSummary({
    required this.averageDisplayed,
    required this.realCount,
    required this.averageReal,
  });
}

class RatingService {
  static final _db = FirebaseFirestore.instance;

  /// Schéma conseillé :
  /// users/{driverId}/ratings/{ratingId}  (documents individuels)
  /// users/{driverId}/rating_summary      (doc agrégé {sum: double, count: int})
  ///
  /// Le résumé s’entretient lors de l’ajout d’une note.

  static DocumentReference<Map<String, dynamic>> _summaryRef(String driverId) {
    return _db
        .collection('users')
        .doc(driverId)
        .collection('meta')
        .doc('rating_summary');
  }

  static CollectionReference<Map<String, dynamic>> _ratingsCol(
    String driverId,
  ) {
    return _db.collection('users').doc(driverId).collection('ratings');
  }

  /// Ajoute / remplace une note pour un trajet et un rateur donnés, en étant idempotent.
  /// - [ratingId] recommandé = "${rideId}_${raterId}" pour éviter les doublons.
  /// - [value] bornée 1..5
  static Future<void> addOrUpdateRating({
    required String driverId,
    required String ratingId, // ex: "${rideId}_${raterId}"
    required double value, // 1..5
    required String rideId,
    required String raterId,
  }) async {
    final v = value.clamp(1.0, 5.0);
    final ratingDoc = _ratingsCol(driverId).doc(ratingId);
    final summaryDoc = _summaryRef(driverId);

    await _db.runTransaction((tx) async {
      final prevSnap = await tx.get(ratingDoc);
      final prevData = prevSnap.data();

      // Résumé courant (peut ne pas exister la 1ère fois)
      final summarySnap = await tx.get(summaryDoc);
      double sum = (summarySnap.data()?['sum'] ?? 0).toDouble();
      int count = (summarySnap.data()?['count'] ?? 0).toInt();

      if (prevData == null) {
        // nouvelle note
        tx.set(ratingDoc, {
          'value': v,
          'rideId': rideId,
          'raterId': raterId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        sum += v;
        count += 1;
      } else {
        // mise à jour (ex : un passager ajuste sa note)
        final old = (prevData['value'] ?? 0).toDouble();
        tx.update(ratingDoc, {
          'value': v,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        sum = sum - old + v; // ajuste la somme, le count ne change pas
      }

      tx.set(summaryDoc, {'sum': sum, 'count': count}, SetOptions(merge: true));
    });
  }

  /// Récupère la note à afficher pour un conducteur :
  /// - S’appuie sur le doc agrégé `rating_summary`.
  /// - Applique l’a priori 3/5 à la moyenne affichée.
  static Future<RatingSummary> getDriverSummary(String driverId) async {
    final snap = await _summaryRef(driverId).get();

    final double sum = (snap.data()?['sum'] ?? 0).toDouble();
    final int count = (snap.data()?['count'] ?? 0).toInt();

    // Moyenne réelle sans a priori (utile debug/analytics)
    final avgReal = (count == 0) ? 0.0 : (sum / count);

    // 👉 Moyenne affichée = (sum + 3) / (count + 1)
    final avgDisplayed = (sum + 3.0) / (count + 1);

    return RatingSummary(
      averageDisplayed: double.parse(avgDisplayed.toStringAsFixed(2)),
      realCount: count,
      averageReal: double.parse(avgReal.toStringAsFixed(2)),
    );
  }

  /// Stream pratique pour UI réactive (Trip list qui se met à jour en live)
  static Stream<RatingSummary> watchDriverSummary(String driverId) {
    return _summaryRef(driverId).snapshots().map((snap) {
      final double sum = (snap.data()?['sum'] ?? 0).toDouble();
      final int count = (snap.data()?['count'] ?? 0).toInt();
      final avgReal = count == 0 ? 0.0 : (sum / count);
      final avgDisplayed = (sum + 3.0) / (count + 1);
      return RatingSummary(
        averageDisplayed: double.parse(avgDisplayed.toStringAsFixed(2)),
        realCount: count,
        averageReal: double.parse(avgReal.toStringAsFixed(2)),
      );
    });
  }
}
