// Cette page affiche les annonces récentes du conducteur


// lib/widgets/recent_announces_widget.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart';

// Voir plus -> historique complet
import 'package:u_go/modules/booking_module/screens/driver/driver_history_screen.dart';
// Tap sur une bulle -> détail
import 'package:u_go/modules/booking_module/screens/driver/driver_announce_detail_screen.dart';

class RecentAnnouncesWidget extends StatelessWidget {
  /// Nombre d’éléments max affichés ET hauteur figée (3 “slots”).
  final int limit;

  const RecentAnnouncesWidget({super.key, this.limit = 3});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return _buildContainer(context, const [], forceFixedHeight: true);
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('announces_effectuees')
        .orderBy('completedAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildContainer(
            context,
            List.generate(
              limit,
              (_) => const {'id': '', 'from': '...', 'to': '...'},
            ),
            forceFixedHeight: true,
            isLoading: true,
          );
        }
        if (snap.hasError) {
          return _buildContainer(context, const [], forceFixedHeight: true);
        }

        final docs = snap.data?.docs ?? [];
        final annonces = <Map<String, String>>[];
        for (final doc in docs) {
          final d = doc.data();
          final from = (d['depart'] ?? d['from'] ?? '').toString();
          final to = (d['destination'] ?? d['to'] ?? '').toString();
          if (from.isEmpty || to.isEmpty) continue;
          annonces.add({'id': doc.id, 'from': from, 'to': to});
          if (annonces.length >= limit) break;
        }

        return _buildContainer(context, annonces, forceFixedHeight: true);
      },
    );
  }

  Widget _buildContainer(
    BuildContext context,
    List<Map<String, String>> items, {
    bool forceFixedHeight = false,
    bool isLoading = false,
  }) {
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 375.0);
    final itemHeight = (44.0 * scale).clamp(40.0, 56.0);
    final titleSize = (16.0 * scale).clamp(15.0, 18.0);
    final textSize = (14.0 * scale).clamp(13.0, 16.0);

    final isEmpty = items.isEmpty;
    final totalHeight = itemHeight * limit + (12 * (limit - 1));

    final List<Widget> listItems = [];
    if (isEmpty) {
      listItems.add(SizedBox(height: totalHeight, child: const _EmptyRow()));
    } else {
      final display = items.take(limit).toList();

      for (int i = 0; i < display.length; i++) {
        final a = display[i];
        final id = (a['id'] ?? '').trim();
        final hasId = id.isNotEmpty;

        final row = SizedBox(
          height: itemHeight,
          child: _AnnounceRow(
            from: a['from']!,
            to: a['to']!,
            fontSize: textSize.toDouble(),
            onTap: hasId
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DriverAnnounceDetailScreen(announceId: id),
                      ),
                    );
                  }
                : null,
          ),
        );

        listItems.add(
          Padding(
            padding: EdgeInsets.only(bottom: i == display.length - 1 ? 0 : 12),
            child: hasId
                ? row
                : Opacity(opacity: isLoading ? 0.3 : 1.0, child: row),
          ),
        );
      }

      final missing = limit - display.length;
      for (int i = 0; i < missing; i++) {
        listItems.add(
          Padding(
            padding: EdgeInsets.only(bottom: i == missing - 1 ? 0 : 12),
            child: SizedBox(
              height: itemHeight,
              child: Opacity(
                opacity: isLoading ? 0.3 : 0.0,
                child: _AnnounceRow(
                  from: '—',
                  to: '—',
                  fontSize: textSize.toDouble(),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TxtComponents(
              txt: "Mes Annonces Récentes",
              txtSize: titleSize.toDouble(),
              family: "Agbalumo",
              txtAlign: TextAlign.start,
            ),
            const SizedBox(height: 16),

            ...listItems,

            Align(
              alignment: Alignment.center,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: secondColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  textStyle: TextStyle(
                    fontSize: (14.0 * scale).clamp(12.0, 15.0).toDouble(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DriverHistoryScreen(),
                    ),
                  );
                },
                child: const Text("Voir plus"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnounceRow extends StatelessWidget {
  final String from;
  final String to;
  final double fontSize;
  final VoidCallback? onTap;

  const _AnnounceRow({
    required this.from,
    required this.to,
    required this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: secondColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const _AnimatedCarIcon(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$from → $to",
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
        ],
      ),
    );

    return onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: content,
            ),
          );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Vous n’avez pas encore d’annonce récente. Faites au plus vite une annonce !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: "Roboto",
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCarIcon extends StatefulWidget {
  const _AnimatedCarIcon();

  @override
  State<_AnimatedCarIcon> createState() => _AnimatedCarIconState();
}

class _AnimatedCarIconState extends State<_AnimatedCarIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: Icon(Icons.directions_car, color: secondColor, size: 20),
    );
  }
}
