import 'package:flutter/material.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/button_component.dart';

// ✅ imports ajoutés
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/app/database/services/wallet_service.dart';
import 'package:u_go/modules/payment_module/screens/my_wallet_screen.dart';

class TripCard extends StatefulWidget {
  final String dateLabel; // libellé date déjà formaté
  final String departure;
  final String departureAddress;
  final String arrival;
  final String arrivalAddress;
  final String time;
  final String price;
  final double rating; // valeur numérique de la note (affichée avec étoile)
  final int ratingCount; // conservé si utilisé ailleurs (non affiché ici)
  final int seats;
  final int reservedSeats;
  final String driverId;
  final List<String> stops; // stops intermédiaires (ligne dédiée)

  /// Appelé après que le débit de 50 FCFA a réussi.
  final Future<void> Function() onReserve;

  const TripCard({
    super.key,
    required this.dateLabel,
    required this.departure,
    required this.departureAddress,
    required this.arrival,
    required this.arrivalAddress,
    required this.time,
    required this.price,
    required this.rating,
    required this.ratingCount,
    required this.seats,
    required this.reservedSeats,
    required this.driverId,
    required this.onReserve,
    this.stops = const [],
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> {
  bool _isLoading = false;

  void _bubble(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white.withOpacity(0.4),
        content: Text(text, style: const TextStyle(color: Colors.black)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _confirmDebitDialog({required int fee}) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm reservation'),
            content: Text(
              '50 FCFA will be deducted from your wallet to confirm this reservation.\n\n'
              'Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleReserve() async {
    if (_isLoading) return; // empêche double clic
    setState(() => _isLoading = true);

    const fee = 50; // 💸 montant à débiter pour réserver
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _bubble('Please log in first.');
        return;
      }

      // 1) Demande de confirmation avec le montant
      final ok = await _confirmDebitDialog(fee: fee);
      if (!ok) return;

      // 2) Débit du wallet (idempotencyKey optionnelle pour éviter double-pay)
      //    On utilise une clé stable basée sur uid + "RESERVATION_FEE" + driverId + date+time.
      final idKey =
          '${user.uid}|RESERVATION_FEE|${widget.driverId}|${widget.dateLabel}_${widget.time}';

      await WalletService.instance.debit(
        uid: user.uid,
        amount: fee,
        reason: 'RESERVATION_FEE',
        tripId: null,
        idempotencyKey: idKey,
      );

      // 3) Succès → on enchaîne ton flux métier existant
      await widget.onReserve();

      if (!mounted) return;
      _bubble('Reservation confirmed ✅  (−$fee FCFA)');
    } catch (e) {
      final msg = '$e';
      if (msg.contains('NEED_TOPUP')) {
        // 4) Solde insuffisant → on redirige vers le wallet
        if (!mounted) return;
        _bubble('Insufficient balance. Please top up.');
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MyWalletScreen()));
      } else {
        if (!mounted) return;
        _bubble('Reservation failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Date du trajet
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TxtComponents(
              txt: widget.dateLabel,
              fw: FontWeight.bold,
              txtSize: 16,
              family: "Bold",
            ),
          ),
          const SizedBox(height: 10),

          // ✅ Heure
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: Colors.black54),
              const SizedBox(width: 6),
              TxtComponents(
                txt: "Heure: ${widget.time}",
                fw: FontWeight.bold,
                txtSize: 16,
                family: "Regular",
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ======= Bloc départ + prix/places =======
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.trip_origin, size: 18, color: mainColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxtComponents(
                      txt: widget.departure,
                      fw: FontWeight.bold,
                      txtSize: 16,
                    ),
                    TxtComponents(
                      txt: widget.departureAddress,
                      txtSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TxtComponents(
                    txt: "${widget.price} XOF",
                    fw: FontWeight.bold,
                    txtSize: 16,
                  ),
                  const SizedBox(height: 4),
                  _SeatDisplay(
                    seats: widget.seats,
                    reservedSeats: widget.reservedSeats,
                    color: secondColor,
                    iconSize: 18,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // ======= Bloc arrivée + note (sur la même ligne) =======
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag, size: 18, color: mainColor),
              const SizedBox(width: 8),
              Expanded(
                child: TxtComponents(
                  txt: widget.arrival,
                  fw: FontWeight.bold,
                  txtSize: 16,
                ),
              ),
              _RatingCompact(value: widget.rating),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26.0), // aligne sous l'icône
            child: TxtComponents(
              txt: widget.arrivalAddress.isEmpty
                  ? "Adresse de dépose non précisée"
                  : widget.arrivalAddress,
              txtSize: 13,
              color: Colors.grey.shade700,
            ),
          ),

          // ======= LIGNE DÉDIÉE (PLEINE LARGEUR) POUR LES STOPS =======
          if (widget.stops.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 3), // aligne sous l'icône
              child: _StopsScroller(stops: widget.stops),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),

          // ======= Features row =======
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.badge_outlined, color: mainColor),
              Icon(Icons.analytics_outlined, color: mainColor),
              Icon(Icons.phone_android_outlined, color: mainColor),
            ],
          ),
          const SizedBox(height: 8),

          ButtonComponent(
            txtButton: _isLoading ? "Réservation..." : "Réserver",
            colorButton: _isLoading ? Colors.grey : secondColor,
            colorText: Colors.white,
            onPressed: _isLoading ? null : _handleReserve,
          ),
        ],
      ),
    );
  }
}

/// ================================================
/// Affichage des places
/// - Si seats ≤ 4 : icônes individuelles
/// - Si seats > 4 : "reserved/total" + 1 icône remplie partiellement
/// ================================================
class _SeatDisplay extends StatelessWidget {
  final int seats;
  final int reservedSeats;
  final Color color;
  final double iconSize;

  const _SeatDisplay({
    required this.seats,
    required this.reservedSeats,
    required this.color,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final int total = seats.clamp(0, 9999);
    final int reserved = reservedSeats.clamp(0, total);
    final double ratio = total == 0 ? 0 : reserved / total;

    if (total <= 4) {
      return Wrap(
        spacing: 2,
        children: List.generate(total, (index) {
          final isReserved = index < reserved;
          return Icon(
            isReserved ? Icons.person : Icons.person_outline,
            size: iconSize,
            color: isReserved ? color : Colors.grey,
          );
        }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$reserved/$total",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        _PartialFillIcon(
          size: iconSize + 2,
          outlineColor: Colors.grey,
          fillColor: color,
          ratio: ratio,
        ),
      ],
    );
  }
}

/// Icône "person" remplie de bas en haut selon [ratio] (0.0 → 1.0)
class _PartialFillIcon extends StatelessWidget {
  final double size;
  final Color outlineColor;
  final Color fillColor;
  final double ratio;

  const _PartialFillIcon({
    required this.size,
    required this.outlineColor,
    required this.fillColor,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = ratio.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.person_outline, size: size, color: outlineColor),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: SizedBox(
                width: size,
                height: size * clamped,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.person, size: size, color: fillColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// Rendu des stops : ligne dédiée, scroll horizontal
/// =======================
class _StopsScroller extends StatelessWidget {
  final List<String> stops;
  const _StopsScroller({required this.stops});

  @override
  Widget build(BuildContext context) {
    final items = stops.where((s) => s.trim().isNotEmpty).toList();
    const double h = 36;

    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) => _StopChip(label: items[i]),
      ),
    );
  }
}

class _StopChip extends StatelessWidget {
  final String label;
  const _StopChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      backgroundColor: mainColor.withOpacity(0.08),
      shape: StadiumBorder(
        side: BorderSide(color: mainColor.withOpacity(0.25)),
      ),
      avatar: const Icon(Icons.route, size: 16, color: mainColor),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}

/// Note compacte : "4.5 ★"
class _RatingCompact extends StatelessWidget {
  final double value;
  const _RatingCompact({required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.isFinite ? value.clamp(0.0, 5.0) : 0.0;
    final bool isInt = v == v.roundToDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isInt ? v.toStringAsFixed(0) : v.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, size: 16, color: Colors.amber),
      ],
    );
  }
}
