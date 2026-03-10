// lib/widgets/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Affiche une cloche avec badge = nb de notifications non lues.
/// Compte à la fois:
///  - documents avec `isRead == false`
///  - ET/OU documents avec `read == false`
/// (on dédoublonne par id pour éviter le double comptage).
class NotificationBell extends StatelessWidget {
  final VoidCallback? onTap;

  // --- UI ---
  final Color iconColor;
  final double iconSize;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final Color badgeBorderColor;

  // --- Firestore layout ---
  /// true => `users/{uid}/notifications`
  /// false => collection plate `notifications` + filtre sur targetUserIdField == uid
  final bool useUserSubcollection;
  final String userSubcollectionPath; // ex: 'users/{uid}/notifications'
  final String flatCollectionName; // ex: 'notifications'
  final String targetUserIdField; // ex: 'targetUserId'

  /// Nom du champ "est lu" n°1 (par défaut 'isRead')
  final String isReadField;

  /// Nom du champ "est lu" n°2 (par défaut 'read')
  final String readField;

  /// Ignorer les notifs silencieuses => where('silent', isEqualTo:false)
  final bool excludeSilent;

  const NotificationBell({
    super.key,
    this.onTap,
    // UI
    this.iconColor = Colors.white,
    this.iconSize = 28,
    this.badgeBgColor = Colors.red,
    this.badgeTextColor = Colors.white,
    this.badgeBorderColor = Colors.white,
    // Firestore
    this.useUserSubcollection = true,
    this.userSubcollectionPath = 'users/{uid}/notifications',
    this.flatCollectionName = 'notifications',
    this.targetUserIdField = 'targetUserId',
    // fields
    this.isReadField = 'isRead',
    this.readField = 'read',
    this.excludeSilent = false,
  });

  Query<Map<String, dynamic>> _baseQuery(String uid) {
    final fs = FirebaseFirestore.instance;

    if (useUserSubcollection) {
      final path = userSubcollectionPath.replaceAll('{uid}', uid);
      return fs.collection(path);
    } else {
      return fs
          .collection(flatCollectionName)
          .where(targetUserIdField, isEqualTo: uid);
    }
  }

  Query<Map<String, dynamic>> _applyCommonFilters(
    Query<Map<String, dynamic>> q,
  ) {
    if (excludeSilent) {
      return q.where('silent', isEqualTo: false);
    }
    return q;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Utilisateur non connecté => simple icône sans badge
    if (uid == null) {
      return IconButton(
        onPressed: onTap,
        icon: Icon(
          Icons.notifications_none_rounded,
          color: iconColor,
          size: iconSize,
        ),
        tooltip: 'Notifications',
      );
    }

    final base = _baseQuery(uid);

    // Stream 1 : isRead == false
    final qIsReadFalse = _applyCommonFilters(
      base,
    ).where(isReadField, isEqualTo: false);
    final sIsRead = qIsReadFalse.snapshots();

    // Stream 2 : read == false (uniquement si différent du précédent)
    final bool needsSecond =
        readField.trim().isNotEmpty && readField != isReadField;
    final Stream<QuerySnapshot<Map<String, dynamic>>>? sRead = needsSecond
        ? _applyCommonFilters(
            base,
          ).where(readField, isEqualTo: false).snapshots()
        : null;

    // On combine les 2 streams via 2 StreamBuilder imbriqués et on dédoublonne par id
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: sIsRead,
      builder: (context, snap1) {
        final docs1 = snap1.data?.docs ?? const [];

        if (!needsSecond) {
          final count = docs1.length;
          return _buildIcon(count);
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: sRead,
          builder: (context, snap2) {
            final docs2 = snap2.data?.docs ?? const [];

            // union par id pour éviter double comptage si un doc possède les deux champs = false
            final ids = <String>{};
            for (final d in docs1) {
              ids.add(d.id);
            }
            for (final d in docs2) {
              ids.add(d.id);
            }
            final count = ids.length;

            return _buildIcon(count);
          },
        );
      },
    );
  }

  Widget _buildIcon(int count) {
    final showBadge = count > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(
            Icons.notifications_none_rounded,
            color: iconColor,
            size: iconSize,
          ),
          tooltip: 'Notifications',
        ),
        if (showBadge)
          Positioned(
            right: -2,
            top: -2,
            child: _Badge(
              count: count,
              bg: badgeBgColor,
              fg: badgeTextColor,
              border: badgeBorderColor,
            ),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color bg;
  final Color fg;
  final Color border;

  const _Badge({
    required this.count,
    required this.bg,
    required this.fg,
    required this.border,
  });

  String get _label => count > 99 ? '99+' : '$count';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
        boxShadow: const [
          BoxShadow(blurRadius: 2, offset: Offset(0, 1), color: Colors.black26),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Center(
        child: Text(
          _label,
          style: TextStyle(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
