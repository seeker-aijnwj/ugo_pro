import 'package:cloud_firestore/cloud_firestore.dart';

/// Service unique pour marquer une course complétée et gérer les notations.
/// - Archive ou Inline (configurable)
/// - Notifications idempotentes (docId = reservationId)
/// - MAJ des réservations passagers + announce_reservations/{announceId}
/// - Le rating agrège sur users/{driverId} et sur l'annonce (archivée de préférence)
class RideService {
  RideService._();
  static final _db = FirebaseFirestore.instance;

  static Future<void> markCourseCompleted({
    DocumentReference? annonceRef,
    String? driverId,
    String? announceId,
    CompletionMode mode = CompletionMode.archive,
    String passengersSubcollectionName = 'passengers',
    bool dedupeNotifications = true,
    bool updateAnnounceReservationsStatus = true,
  }) async {
    // ---- Résolution des refs
    late final String resolvedDriverId;
    late final String resolvedAnnounceId;
    late final DocumentReference<Map<String, dynamic>> resolvedAnnounceRef;

    if (annonceRef != null) {
      resolvedDriverId = annonceRef.parent.parent?.id ?? '';
      resolvedAnnounceId = annonceRef.id;
      resolvedAnnounceRef = annonceRef.withConverter<Map<String, dynamic>>(
        fromFirestore: (s, _) => s.data() ?? <String, dynamic>{},
        toFirestore: (d, _) => d,
      );
    } else {
      if ((driverId ?? '').isEmpty || (announceId ?? '').isEmpty) {
        throw Exception("Fournis soit annonceRef, soit driverId+announceId.");
      }
      resolvedDriverId = driverId!;
      resolvedAnnounceId = announceId!;
      resolvedAnnounceRef = _db
          .collection('users')
          .doc(resolvedDriverId)
          .collection('announces')
          .doc(resolvedAnnounceId)
          .withConverter<Map<String, dynamic>>(
            fromFirestore: (s, _) => s.data() ?? <String, dynamic>{},
            toFirestore: (d, _) => d,
          );
    }

    final mapRef = _db
        .collection('announce_reservations')
        .doc(resolvedAnnounceId);

    // ---- Lire l'annonce d'origine
    final announceSnap = await resolvedAnnounceRef.get();
    if (!announceSnap.exists) {
      throw Exception("Annonce introuvable.");
    }
    final announceData = Map<String, dynamic>.from(announceSnap.data() ?? {});
    announceData.remove('id');

    // ---- Récupérer les passagers depuis announce_reservations
    final passengersSnap = await mapRef
        .collection(passengersSubcollectionName)
        .get();

    // ✅ NOUVEAU: Récupérer AUSSI les réservations directement via collectionGroup
    final reservationsQuery = await _db
        .collectionGroup('reservations')
        .where('announceId', isEqualTo: resolvedAnnounceId)
        .get();

    final batch = _db.batch();

    // ---- 1) Archive vs in-place
    if (mode == CompletionMode.archive) {
      final doneRef = _db
          .collection('users')
          .doc(resolvedDriverId)
          .collection('announces_effectuees')
          .doc(resolvedAnnounceId);

      batch.set(doneRef, {
        ...announceData,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.delete(resolvedAnnounceRef);
    } else {
      batch.set(resolvedAnnounceRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // ---- 2) Map announce_reservations
    if (updateAnnounceReservationsStatus) {
      batch.set(mapRef, {
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // ---- 3) Notifs + MAJ réservations (méthode announce_reservations/passengers)
    for (final p in passengersSnap.docs) {
      final d = Map<String, dynamic>.from(p.data());
      final passengerId = (d['passengerId'] ?? '').toString();
      final reservationId = (d['reservationId'] ?? '').toString();
      final status = (d['status'] ?? '').toString();

      if (passengerId.isEmpty || reservationId.isEmpty) continue;
      if (status == 'canceled') continue;

      final notifColl = _db
          .collection('users')
          .doc(passengerId)
          .collection('notifications');
      final notifRef = dedupeNotifications
          ? notifColl.doc(reservationId)
          : notifColl.doc();

      final notifData = {
        'type': 'rate_driver',
        'title': 'Course effectuée — donnez une note',
        'body': 'Veuillez noter le conducteur.',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'read': false,
        'consumed': false,
        'announceId': resolvedAnnounceId,
        'reservationId': reservationId,
        'driverId': resolvedDriverId,
      };

      batch.set(
        notifRef,
        notifData,
        dedupeNotifications ? SetOptions(merge: true) : null,
      );

      final resRef = _db
          .collection('users')
          .doc(passengerId)
          .collection('reservations')
          .doc(reservationId);

      batch.set(resRef, {
        'status': 'awaiting_rating',
        'ratePromptAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // ---- 4) ✅ NOUVEAU: Mise à jour directe via collectionGroup
    // Pour toutes les réservations non traitées ci-dessus
    for (final resDoc in reservationsQuery.docs) {
      final data = resDoc.data();
      final passengerId = (data['passengerId'] ?? '') as String;
      final status = (data['status'] ?? '') as String;

      if (passengerId.isEmpty) continue;
      if (status == 'canceled') continue;
      if (status == 'awaiting_rating') continue; // Déjà traité

      // Mise à jour du statut
      batch.set(resDoc.reference, {
        'status': 'awaiting_rating',
        'ratePromptAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Notification
      final notifRef = _db
          .collection('users')
          .doc(passengerId)
          .collection('notifications')
          .doc(resDoc.id);

      batch.set(notifRef, {
        'type': 'rate_driver',
        'title': 'Course effectuée — donnez une note',
        'body': 'Veuillez noter le conducteur.',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'read': false,
        'consumed': false,
        'announceId': resolvedAnnounceId,
        'reservationId': resDoc.id,
        'driverId': resolvedDriverId,
      }, dedupeNotifications ? SetOptions(merge: true) : null);
    }

    await batch.commit();
  }

  /// ✅ NOUVEAU: Mise à jour directe des réservations via collectionGroup
  /// Utilisé en complément de markCourseCompleted si announce_reservations/passengers est vide
  static Future<void> updateReservationsStatusDirect({
    required String announceId,
    required String driverId,
    bool dedupeNotifications = true,
  }) async {
    // Query toutes les réservations liées à cette annonce
    final reservationsQuery = await _db
        .collectionGroup('reservations')
        .where('announceId', isEqualTo: announceId)
        .get();

    if (reservationsQuery.docs.isEmpty) return;

    final batch = _db.batch();

    for (final resDoc in reservationsQuery.docs) {
      final data = resDoc.data();
      final passengerId = (data['passengerId'] ?? '') as String;
      final status = (data['status'] ?? '') as String;

      if (passengerId.isEmpty) continue;
      if (status == 'canceled') continue;
      if (status == 'awaiting_rating' || status == 'rated') continue;

      // Mise à jour du statut
      batch.set(resDoc.reference, {
        'status': 'awaiting_rating',
        'ratePromptAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Création de la notification
      final notifColl = _db
          .collection('users')
          .doc(passengerId)
          .collection('notifications');
      final notifRef = dedupeNotifications
          ? notifColl.doc(resDoc.id)
          : notifColl.doc();

      batch.set(notifRef, {
        'type': 'rate_driver',
        'title': 'Course effectuée — donnez une note',
        'body': 'Veuillez noter le conducteur.',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'read': false,
        'consumed': false,
        'announceId': announceId,
        'reservationId': resDoc.id,
        'driverId': driverId,
      }, dedupeNotifications ? SetOptions(merge: true) : null);
    }

    await batch.commit();
  }

  /// Enregistrer une note (1..5) pour le conducteur.
  /// - Idempotent via users/{driverId}/ratings/{reservationId}
  /// - Agrège sur users/{driverId}
  /// - Agrège sur l'annonce (archivée si existe, sinon inline)
  /// - Met la réservation passager à 'rated' et clôture la notif si fournie
  static Future<void> submitDriverRating({
    required String driverId,
    required String passengerId,
    required String announceId,
    required String reservationId,
    required int rating, // 1..5
    DocumentReference? notifRef,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception("La note doit être comprise entre 1 et 5.");
    }

    final driverRef = _db.collection('users').doc(driverId);
    final announceArchivedRef = driverRef
        .collection('announces_effectuees')
        .doc(announceId);
    final announceInlineRef = driverRef.collection('announces').doc(announceId);
    final ratingRef = driverRef.collection('ratings').doc(reservationId);
    final resRef = _db
        .collection('users')
        .doc(passengerId)
        .collection('reservations')
        .doc(reservationId);

    await _db.runTransaction((tx) async {
      // ---------------- READS D'ABORD ----------------
      // 1) Anti-doublon
      final ratingSnap = await tx.get(ratingRef);
      if (ratingSnap.exists) return;

      // 2) Driver aggregates
      final dSnap = await tx.get(driverRef);
      final dData = (dSnap.data() ?? {});
      final dCount = (dData['ratingCount'] ?? 0) as int;
      final dTotal = (dData['ratingTotal'] ?? 0) as num;

      // 3) Choisir la bonne annonce (archivée si existe)
      final archSnap = await tx.get(announceArchivedRef);
      final announceTargetRef = archSnap.exists
          ? announceArchivedRef
          : announceInlineRef;

      // 4) Lire l'annonce cible
      final aSnap = await tx.get(announceTargetRef);
      final aData = (aSnap.data() ?? {});
      final aCount = (aData['ratingCount'] ?? 0) as int;
      final aTotal = (aData['ratingTotal'] ?? 0) as num;

      // ---------------- CALCULS ----------------
      final newDCount = dCount + 1;
      final newDTotal = dTotal + rating;
      final newDAvg = newDTotal / newDCount;

      final newACount = aCount + 1;
      final newATotal = aTotal + rating;
      final newAAvg = newATotal / newACount;

      // ---------------- WRITES APRÈS TOUTES LES READS ----------------
      // Note (idempotence assurée par le check)
      tx.set(ratingRef, {
        'rating': rating,
        'passengerId': passengerId,
        'announceId': announceId,
        'reservationId': reservationId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Agrégats driver
      tx.set(driverRef, {
        'ratingCount': newDCount,
        'ratingTotal': newDTotal,
        'rating': newDAvg,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Agrégats annonce
      tx.set(announceTargetRef, {
        'ratingCount': newACount,
        'ratingTotal': newATotal,
        'rating': newAAvg,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Réservation passager
      tx.set(resRef, {
        'status': 'rated',
        'ratedAt': FieldValue.serverTimestamp(),
        'driverRating': rating,
      }, SetOptions(merge: true));

      // Clôture notif
      if (notifRef != null) {
        tx.set(notifRef, {
          'read': true,
          'consumed': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }
}

/// Mode de complétion d'une annonce terminée.
enum CompletionMode {
  /// Archive (recommandé)
  archive,

  /// Mise à jour "in-place"
  inline,
}
