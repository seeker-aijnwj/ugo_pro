import 'package:flutter/material.dart';
import 'package:u_go/modules/booking_module/services/rating_service.dart';

class DriverRatingBadge extends StatelessWidget {
  final String driverId;
  final TextStyle? valueStyle;
  final TextStyle? countStyle;
  final double iconSize;
  final MainAxisAlignment mainAxisAlignment;

  const DriverRatingBadge({
    super.key,
    required this.driverId,
    this.valueStyle,
    this.countStyle,
    this.iconSize = 16,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  double roundToHalf(double value) {
    return (value * 2).round() / 2.0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RatingSummary>(
      stream: RatingService.watchDriverSummary(driverId),
      builder: (context, snap) {
        final double rating = (snap.data?.averageDisplayed ?? 3.0);
        final int count = (snap.data?.realCount ?? 0);

        // ✅ arrondi au demi
        double rounded = roundToHalf(rating);

        // ✅ plafonner à 4.5
        if (rounded > 4.5) {
          rounded = 4.5;
        }

        // ✅ format d’affichage
        String displayValue;
        if (rounded == rounded.toInt()) {
          displayValue = rounded.toInt().toString(); // entier
        } else {
          displayValue = rounded.toString(); // ex: 3.5
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Text(
              displayValue,
              style:
                  valueStyle ??
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Icon(Icons.star, size: iconSize, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              "($count)",
              style:
                  countStyle ??
                  const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        );
      },
    );
  }
}
