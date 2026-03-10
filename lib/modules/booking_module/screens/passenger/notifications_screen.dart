import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/app/core/utils/colors.dart'; // pour backgroundColor / mainColor si tu les as

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _fs = FirebaseFirestore.instance;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  Query<Map<String, dynamic>> _query() {
    // Notifications triées de la plus récente à la plus ancienne
    return _fs
        .collection('users/${_uid!}/notifications')
        .orderBy('createdAt', descending: true);
  }

  Future<void> _markAllAsRead() async {
    if (_uid == null) return;
    final batch = _fs.batch();

    // prendre tout ce qui n'est PAS lu (via isRead=false OU read=false)
    final q1 = await _fs
        .collection('users/${_uid!}/notifications')
        .where('isRead', isEqualTo: false)
        .get();
    final q2 = await _fs
        .collection('users/${_uid!}/notifications')
        .where('read', isEqualTo: false)
        .get();

    // merge unique refs (set pour éviter doublons)
    final toUpdate = <DocumentReference>{
      ...q1.docs.map((d) => d.reference),
      ...q2.docs.map((d) => d.reference),
    };

    for (final ref in toUpdate) {
      batch.set(ref, {'isRead': true, 'read': true}, SetOptions(merge: true));
    }
    await batch.commit();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les notifications ont été lues.')),
    );
  }

  Future<void> _markAsReadOnce(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data() ?? {};
    final alreadyRead =
        (data['isRead'] as bool?) ?? (data['read'] as bool?) ?? false;
    if (alreadyRead) return;
    await doc.reference.set({
      'isRead': true,
      'read': true,
    }, SetOptions(merge: true));
  }

  String _formatRelativeTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'à l’instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';

    // sinon date courte
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
    // tu peux remplacer par intl si tu utilises déjà DateFormat.
  }

  @override
  Widget build(BuildContext context) {
    // Gris soft (si tu as déjà backgroundColor dans ton projet, on l’utilise)
    final Color pageBg = backgroundColor; // gris très doux
    final Color accent = mainColor; // pour le bouton/puce si besoin

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        title: const Text(
          'Mes notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Tout lire',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _uid == null
          ? const _CenteredInfo(
              text: 'Vous devez être connecté pour voir vos notifications.',
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _query().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _CenteredInfo(text: 'Chargement…');
                }
                if (snapshot.hasError) {
                  return const _CenteredInfo(
                    text: 'Impossible de charger les notifications.',
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _CenteredInfo(
                    text: 'Aucune notification pour le moment.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final title = (data['title'] as String?) ?? 'Notification';
                    final body = (data['body'] as String?) ?? '';
                    final isRead = (data['isRead'] as bool?) ?? false;
                    final createdAt = data['createdAt'] as Timestamp?;

                    return GestureDetector(
                      onTap: () => _markAsReadOnce(doc),
                      child: _NotificationBubble(
                        title: title,
                        body: body,
                        timeLabel: _formatRelativeTime(createdAt),
                        isRead: isRead,
                        accent: accent,
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemCount: docs.length,
                );
              },
            ),
    );
  }
}

class _NotificationBubble extends StatelessWidget {
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final Color accent;

  const _NotificationBubble({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Fond blanc pour la bulle
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Ombre douce pour contraster avec la page grise
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        // Option : bordure très légère
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Petite pastille d’état (non lu)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: isRead ? Colors.transparent : accent,
              shape: BoxShape.circle,
              border: Border.all(color: isRead ? Colors.black26 : accent),
            ),
          ),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre + date relative
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Corps
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredInfo extends StatelessWidget {
  final String text;
  const _CenteredInfo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54, fontSize: 14),
      ),
    );
  }
}
