import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_go/app/database/services/transaction_service.dart';

class TripStatusService {
  TripStatusService();

  final _db = FirebaseFirestore.instance;

  /// Ensemble des statuts autorisés (pour validation).
  static const String scheduled = 'scheduled';
  static const String running = 'running';
  static const String completed = 'completed';
  static const String canceled = 'canceled';

  static const Set<String> allowedStatuses = {
    scheduled,
    running,
    completed,
    canceled,
  };

  /// Valide une valeur de statut (retourne `true` si autorisée).
  bool isValidStatus(String? status) {
    if (status == null) return false;
    return allowedStatuses.contains(status.toLowerCase());
  }

  DocumentReference<Map<String, dynamic>> _tripRef(String tripId) =>
      _db.collection('trips').doc(tripId);

  /// Stream du statut du trip (running/completed/…)
  Stream<String?> watchStatus(String tripId) {
    return _tripRef(tripId).snapshots().map((snap) {
      if (!snap.exists) return null;
      final s = snap.data()?['status'];
      return (s is String) ? s.toLowerCase() : null;
    });
  }

  /// Termine le trip (idempotent). NE FAIT AUCUN DÉBIT.
  ///
  /// Comportement:
  /// - Si status==completed -> retour silencieux (idempotent)
  /// - Si passengerUserId manque -> on termine quand même (on log l’info)
  /// - Écrit des métadonnées utiles (completedAt, flags settlement)
  Future<void> completeTripAndCharge(String tripId) async {
    final tRef = _tripRef(tripId);

    await _db.runTransaction((txn) async {
      final snap = await txn.get(tRef);
      if (!snap.exists) {
        throw Exception('TRIP_NOT_FOUND');
      }

      final data = snap.data()!;
      final currentStatus =
          (data['status'] as String?)?.toLowerCase() ?? 'running';
      if (currentStatus == 'completed') {
        // Idempotence: déjà terminé → rien à faire
        return;
      }

      final passengerId = data['passengerUserId'] as String?;
      final driverId = data['driverUserId'] as String?;
      final fareEstimated = (data['fareEstimated'] as num?)?.toInt();

      // (Facultatif) calcul de frais pour logs/analytics
      final fees = TransactionService.instance.computeFees(
        fareEstimated: fareEstimated,
      );

      // Mise à jour unique: on termine + on journalise l’état de “settlement”
      txn.update(tRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'metadata': {
          // pur log/analytics, pas de débit ici
          'fareEstimated': fareEstimated,
          'feesPreview': {
            'passengerFee': fees.passengerFee,
            'driverFee': fees.driverFee,
          },
        },
        'settlement': {
          // Ces flags indiquent que ce sont LES UTILISATEURS qui finalisent côté UI
          'passengerIdPresent': passengerId != null && passengerId.isNotEmpty,
          'driverIdPresent': driverId != null && driverId.isNotEmpty == true,
          'handledByUsers': true, // clé business claire: pas de débit système
          'passengerHandled': false,
          'driverHandled': false,
        },
      });

      // Optionnel : pousser une “notification” Firestore pour l’app
      final nRef = _db.collection('notifications');
      final now = FieldValue.serverTimestamp();
      if (driverId != null && driverId.isNotEmpty) {
        txn.set(nRef.doc(), {
          'userId': driverId,
          'type': 'TRIP_COMPLETED_DRIVER_TODO',
          'tripId': tripId,
          'createdAt': now,
          'payload': {
            'message':
                'Course terminée. Invitez le passager à confirmer/payer et demandez/attribuez une note.',
          },
          'read': false,
        });
      }
      if (passengerId != null && passengerId.isNotEmpty) {
        txn.set(nRef.doc(), {
          'userId': passengerId,
          'type': 'TRIP_COMPLETED_PASSENGER_TODO',
          'tripId': tripId,
          'createdAt': now,
          'payload': {
            'message':
                'Course terminée. Merci de confirmer le paiement et d’évaluer le conducteur.',
          },
          'read': false,
        });
      }
    });
  }

  /// Option: transition atomique avec check de l'état courant.
  /// Exemple d'usage:
  ///   await updateStatusIfCurrent(tripId, from: 'scheduled', to: 'running');
  /// Retourne `true` si la transition a été appliquée, `false` sinon.
  Future<bool> updateStatusIfCurrent({
    required String tripId,
    required String from,
    required String to,
  }) async {
    final fromNorm = from.toLowerCase();
    final toNorm = to.toLowerCase();
    if (!isValidStatus(fromNorm) || !isValidStatus(toNorm)) {
      throw ArgumentError('Transition invalide: $from -> $to');
    }

    return _db.runTransaction<bool>((tx) async {
      final ref = _tripRef(tripId);
      final snap = await tx.get(ref);
      if (!snap.exists) {
        // Si le document n'existe pas, on peut décider de le créer uniquement si from == scheduled.
        if (fromNorm != scheduled) return false;
        tx.set(ref, {'status': toNorm}, SetOptions(merge: true));
        return true;
      }

      final data = snap.data();
      final current = (data?['status'] as String?)?.toLowerCase() ?? scheduled;

      if (current != fromNorm) {
        // L'état courant ne correspond pas à "from" → on n'applique pas.
        return false;
      }

      tx.set(ref, {'status': toNorm}, SetOptions(merge: true));
      return true;
    });
  }
}
