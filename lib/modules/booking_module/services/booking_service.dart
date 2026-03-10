import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  BookingService._();
  static final _db = FirebaseFirestore.instance;

  /// Annulation d'une réservation par le passager
  /// - reservationRef: users/{passengerId}/reservations/{reservationId}
  /// Effets:
  ///   - reservations.status = "canceled" + canceledAt
  ///   - users/{driverId}/announces/{announceId}.reservedSeats --
  ///   - announce_reservations/{announceId}.reservedCount --
  ///   - announce_reservations/{announceId}/passengers/{passengerId} : status/canceledAt (merge)
  ///   - notif pour le conducteur
  static Future<void> cancelReservation({
    required DocumentReference reservationRef,
  }) async {
    await _db.runTransaction((tx) async {
      // 1) Lire la réservation
      final resSnap = await tx.get(reservationRef);
      if (!resSnap.exists) throw Exception("Réservation introuvable.");
      final res = resSnap.data() as Map<String, dynamic>;

      final status = (res['status'] ?? '').toString();
      final announceId = (res['announceId'] ?? '').toString();
      final driverId = (res['driverId'] ?? '').toString();
      final passengerId = (res['passengerId'] ?? '').toString();
      final seatsBooked = (res['seatsBooked'] ?? 1) as int;

      if (status == 'canceled') return; // idempotent
      if (announceId.isEmpty || driverId.isEmpty || passengerId.isEmpty) {
        throw Exception("Données incomplètes sur la réservation.");
      }

      // 2) Pointeurs utiles
      final announceRef = _db
          .collection('users')
          .doc(driverId)
          .collection('announces')
          .doc(announceId);

      final mapRef = _db.collection('announce_reservations').doc(announceId);
      final passengerMapRef = mapRef.collection('passengers').doc(passengerId);

      // 3) Relire l'annonce pour assurer un décrément non négatif
      final annSnap = await tx.get(announceRef);
      if (!annSnap.exists) throw Exception("Annonce introuvable.");
      final ann = annSnap.data() as Map<String, dynamic>;
      final reservedSeats = (ann['reservedSeats'] ?? 0) as int;
      final newReserved = (reservedSeats - seatsBooked) < 0
          ? 0
          : reservedSeats - seatsBooked;

      // 4) Écritures atomiques
      tx.update(reservationRef, {
        'status': 'canceled',
        'canceledAt': FieldValue.serverTimestamp(),
      });

      tx.update(announceRef, {'reservedSeats': newReserved});

      tx.set(mapRef, {
        'reservedCount': FieldValue.increment(-seatsBooked),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(passengerMapRef, {
        'status': 'canceled',
        'canceledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5) Notification conducteur
      final notifRef = _db
          .collection('users')
          .doc(driverId)
          .collection('notifications')
          .doc();
      tx.set(notifRef, {
        'type': 'reservation_canceled',
        'title': 'Annulation de réservation',
        'body': 'Un passager a annulé sa réservation.',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'announceId': announceId,
        'reservationId': reservationRef.id,
        'actorId': passengerId,
        'roleTarget': 'driver',
        'silent': false,
      });
    });
  }

  /// Annulation d'une annonce par le conducteur
  /// Effets:
  ///  - users/{driverId}/announces/{announceId}.status = "canceled"
  ///  - Pour chaque passager actif: users/{passengerId}/reservations/{reservationId}.status = "canceled_by_driver"
  ///  - Notifs envoyées à chaque passager
  ///  - announce_reservations/{announceId}.status = "canceled"
  static Future<void> cancelAnnounce({
    required String driverId,
    required String announceId,
  }) async {
    final announceRef = _db
        .collection('users')
        .doc(driverId)
        .collection('announces')
        .doc(announceId);

    final mapRef = _db.collection('announce_reservations').doc(announceId);
    final passengersSnap = await mapRef.collection('passengers').get();

    final batch = _db.batch();

    // 1) Marquer l’annonce comme annulée (on garde le doc pour l’historique)
    batch.set(announceRef, {
      'status': 'canceled',
      'canceledAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2) Marquer la map comme annulée
    batch.set(mapRef, {
      'status': 'canceled',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 3) Propager vers chaque passager + notif
    for (final p in passengersSnap.docs) {
      final passengerId = (p.data()['passengerId'] ?? '').toString();
      final reservationId = (p.data()['reservationId'] ?? '').toString();
      if (passengerId.isEmpty || reservationId.isEmpty) continue;

      final resRef = _db
          .collection('users')
          .doc(passengerId)
          .collection('reservations')
          .doc(reservationId);

      batch.set(resRef, {
        'status': 'canceled_by_driver',
        'canceledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final notifRef = _db
          .collection('users')
          .doc(passengerId)
          .collection('notifications')
          .doc();
      batch.set(notifRef, {
        'type': 'announce_canceled',
        'title': 'Trajet annulé par le conducteur',
        'body': 'Votre réservation a été annulée par le conducteur.',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'announceId': announceId,
        'reservationId': reservationId,
        'actorId': driverId,
        'roleTarget': 'passenger',
        'silent': false,
      });
    }

    await batch.commit();
  }
}
