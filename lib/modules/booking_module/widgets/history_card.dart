import 'package:flutter/material.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart';

class HistoryCard extends StatelessWidget {
  final String dateLabel; // “Mardi 28 juin …”
  final String time;
  final String departure;
  final String departureAddress;
  final String arrival;
  final String arrivalAddress;
  final String price;

  /// Remplacé: driverId -> customerId (affichage du client/passager/driver selon contexte)
  final String customerId;

  final double rating;
  final int ratingCount;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.dateLabel,
    required this.time,
    required this.departure,
    required this.departureAddress,
    required this.arrival,
    required this.arrivalAddress,
    required this.price,
    required this.customerId,
    required this.rating,
    required this.ratingCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // On protège contre des chaînes vides pour éviter un rendu “bizarre”
    final priceText = price.isEmpty ? '—' : '$price XOF';
    final customerText = customerId.isEmpty ? '—' : customerId;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header date dynamique
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TxtComponents(
                txt: dateLabel,
                fw: FontWeight.bold,
                txtSize: 16,
                family: "Bold",
              ),
            ),
            const SizedBox(height: 12),

            TxtComponents(
              txt: time,
              fw: FontWeight.bold,
              txtSize: 18,
              family: "Bold",
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.credit_card, size: 36, color: mainColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TxtComponents(
                        txt: departure,
                        fw: FontWeight.bold,
                        txtSize: 16,
                      ),
                      TxtComponents(
                        txt: departureAddress,
                        txtSize: 13,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, size: 24, color: mainColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TxtComponents(
                        txt: arrival,
                        fw: FontWeight.bold,
                        txtSize: 16,
                      ),
                      TxtComponents(
                        txt: arrivalAddress,
                        txtSize: 13,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TxtComponents(
                    txt: customerText, // <- MAJ
                    txtSize: 12,
                    fw: FontWeight.bold,
                  ),
                  TxtComponents(
                    txt: priceText,
                    txtSize: 14,
                    fw: FontWeight.bold,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.badge_outlined, color: mainColor),
                Icon(Icons.analytics_outlined, color: mainColor),
                Icon(Icons.phone_android_outlined, color: mainColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
