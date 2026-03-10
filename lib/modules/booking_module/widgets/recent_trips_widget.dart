// lib/widgets/recent_trips_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/services/reservation_history_service.dart';

// 👉 Ajuste ce chemin selon ton projet
import 'package:u_go/modules/booking_module/screens/passenger/history_screen.dart'; // change si nécessaire

class RecentTripsWidget extends StatelessWidget {
  final int limit;

  const RecentTripsWidget({super.key, this.limit = 3});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return _buildContainer(context, const [], forceFixedHeight: true);
    }

    return StreamBuilder<List<Reservation>>(
      stream: HistoryService.historyForPassengerUid(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildContainer(
            context,
            List.generate(limit, (_) => const {'from': '...', 'to': '...'}),
            forceFixedHeight: true,
            isLoading: true,
          );
        }
        if (snapshot.hasError) {
          return _buildContainer(context, const [], forceFixedHeight: true);
        }

        final reservations = snapshot.data ?? [];
        reservations.sort((a, b) => b.historyDate.compareTo(a.historyDate));

        final trips = <Map<String, String>>[];
        final seen = <String>{};

        for (final r in reservations) {
          final from = r.depart ?? r.meta?['depart'] ?? r.meta?['from'] ?? '';
          final to =
              r.destination ?? r.meta?['destination'] ?? r.meta?['to'] ?? '';
          if (from.isEmpty || to.isEmpty) continue;

          final key = '$from→$to';
          if (seen.add(key)) {
            trips.add({'from': from, 'to': to});
          }
          if (trips.length >= limit) break;
        }

        return _buildContainer(context, trips, forceFixedHeight: true);
      },
    );
  }

  Widget _buildContainer(
    BuildContext context,
    List<Map<String, String>> trips, {
    bool forceFixedHeight = false,
    bool isLoading = false,
  }) {
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 375.0);
    final itemHeight = (44.0 * scale).clamp(40.0, 56.0);
    final titleSize = (16.0 * scale).clamp(15.0, 18.0);
    final textSize = (14.0 * scale).clamp(13.0, 16.0);

    final isEmpty = trips.isEmpty;

    // hauteur totale forcée = 3 items
    final totalHeight = itemHeight * limit + (12 * (limit - 1));

    final List<Widget> listItems = [];
    if (isEmpty) {
      listItems.add(
        SizedBox(
          height: totalHeight,
          child: _EmptyRow(fontSize: textSize.toDouble()),
        ),
      );
    } else {
      final display = trips.take(limit).toList();
      for (final trip in display) {
        listItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: itemHeight,
              child: _TripRow(
                from: trip['from']!,
                to: trip['to']!,
                fontSize: textSize.toDouble(),
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
              txt: "Mes Trajets Récents",
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
                  foregroundColor: mainColor,
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
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
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

class _TripRow extends StatelessWidget {
  final String from;
  final String to;
  final double fontSize;

  const _TripRow({
    required this.from,
    required this.to,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.08),
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
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final double fontSize;
  const _EmptyRow({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "Vous n’avez pas de trajet récent. Faites-en un dès maintenant !",
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
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
      child: Icon(Icons.directions_car, color: mainColor, size: 20),
    );
  }
}
