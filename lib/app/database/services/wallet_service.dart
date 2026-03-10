import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _walletRef(String uid) =>
      _db.collection('wallets').doc(uid);
  CollectionReference<Map<String, dynamic>> get _txCol =>
      _db.collection('transactions');

  /// Crée le wallet si absent, avec 250 FCFA seed + log tx.
  Future<Map<String, dynamic>> getOrCreateWallet(String uid) async {
    final ref = _walletRef(uid);
    final snap = await ref.get();
    if (snap.exists) return snap.data()!;
    final data = {
      'available': 250,
      'locked': 0,
      'currency': 'XOF',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    await ref.set(data);

    final txRef = _txCol.doc();
    await txRef.set({
      'id': txRef.id,
      'userId': uid,
      'tripId': null,
      'type': 'CREDIT',
      'reason': 'WALLET_SEED',
      'amount': 250,
      'status': 'SUCCEEDED',
      'provider': null,
      'providerRef': null,
      'idempotencyKey': 'SEED|$uid',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return data;
  }

  Future<int> getAvailable(String uid) async {
    final data = await getOrCreateWallet(uid);
    return (data['available'] as num?)?.toInt() ?? 0;
  }

  /// CREDIT avec idempotence. simulated=true pour le MVP.
  Future<void> credit({
    required String uid,
    required int amount,
    required String reason, // TOPUP_ORANGE / TOPUP_MTN ...
    bool simulated = true,
    String? idempotencyKey,
  }) async {
    if (amount <= 0) return;
    final txKey = idempotencyKey ?? '$uid|$reason|$amount|CREDIT';
    final txId = _txCol.doc().id;

    await _db.runTransaction((txn) async {
      final idem = await _txCol
          .where('idempotencyKey', isEqualTo: txKey)
          .limit(1)
          .get();
      if (idem.docs.isNotEmpty) return;

      final wRef = _walletRef(uid);
      final wSnap = await txn.get(wRef);
      final current = (wSnap.data()?['available'] as num?)?.toInt() ?? 0;

      txn.set(_txCol.doc(txId), {
        'id': txId,
        'userId': uid,
        'tripId': null,
        'type': 'CREDIT',
        'reason': reason,
        'amount': amount,
        'status': simulated ? 'SIMULATED' : 'SUCCEEDED',
        'provider': null,
        'providerRef': null,
        'idempotencyKey': txKey,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.update(wRef, {
        'available': current + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// DEBIT avec idempotence. Throw 'NEED_TOPUP' si insuffisant.
  Future<void> debit({
    required String uid,
    required int amount,
    required String
    reason, // PASSENGER_FEE / DRIVER_FEE / RESERVATION_FEE / ANNOUNCE_FEE
    String? tripId,
    String? idempotencyKey,
  }) async {
    if (amount <= 0) return;
    final txKey =
        idempotencyKey ?? '$uid|$reason|${tripId ?? "_"}|DEBIT|$amount';
    final txId = _txCol.doc().id;

    await _db.runTransaction((txn) async {
      final idem = await _txCol
          .where('idempotencyKey', isEqualTo: txKey)
          .limit(1)
          .get();
      if (idem.docs.isNotEmpty) return;

      final wRef = _walletRef(uid);
      final wSnap = await txn.get(wRef);
      if (!wSnap.exists) throw Exception('WALLET_NOT_FOUND');

      final available = (wSnap.data()?['available'] as num?)?.toInt() ?? 0;
      if (available < amount) throw Exception('NEED_TOPUP');

      txn.set(_txCol.doc(txId), {
        'id': txId,
        'userId': uid,
        'tripId': tripId,
        'type': 'DEBIT',
        'reason': reason,
        'amount': amount,
        'status': 'SUCCEEDED',
        'provider': null,
        'providerRef': null,
        'idempotencyKey': txKey,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.update(wRef, {
        'available': available - amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Flux d’historique pour l’écran
  Stream<QuerySnapshot<Map<String, dynamic>>> watchTransactions(String uid) {
    return _txCol
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }
}
