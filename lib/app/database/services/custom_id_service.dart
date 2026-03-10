import 'package:cloud_firestore/cloud_firestore.dart';

class CustomIdService {
  static Future<String> nextUserCustomId() async {
    final ref = FirebaseFirestore.instance
        .collection('counters')
        .doc('usersCounter');
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists ? (snap.data()!['value'] ?? 0) as int : 0;
      final next = current + 1;
      tx.set(ref, {'value': next});
      return next.toString().padLeft(5, '0'); // 00001, 00002, ...
    });
  }
}
