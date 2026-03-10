import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  static const _prefsKey = 'role'; // 'driver' | 'passenger'

  /// Lit le rôle localement (fallback 'passenger' si rien).
  static Future<String> getLocalRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey) ?? 'passenger';
  }

  /// Écrit le rôle localement.
  static Future<void> setLocalRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, role);
  }

  /// Met à jour Firestore: users/{uid}.role
  static Future<void> setRemoteRole(String role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'role': role,
    }, SetOptions(merge: true));
  }

  /// Essaie de lire Firestore (optionnel si tu veux forcer la vérité locale d’abord)
  static Future<String?> getRemoteRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!snap.exists) return null;
    return (snap.data()?['role'] as String?)?.trim();
  }

  /// Convenience: applique local + remote
  static Future<void> applyRole({required bool isDriver}) async {
    final role = isDriver ? 'driver' : 'passenger';
    await setLocalRole(role);
    await setRemoteRole(role);
  }
}
