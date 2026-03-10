import 'package:flutter/material.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/core/utils/colors.dart';

class DriverHistoryCard extends StatelessWidget {
  final String dateLabel; // ← dynamique (ex: "Mardi 28 juin 2025")
  final String time; // ← dynamique (ex: "22:30")
  final String departure; // ← ex: "Treichville"
  final String departureAddress; // ← ex: "Gare de Bassam"
  final String arrival; // ← ex: "Plateau"
  final String arrivalAddress; // ← ex: "Hyper U Plateau"
  final String price; // ← ex: "1000"
  final int passengerCount; // ← nombre de passagers

  /// Nouveau: callback de reconduction
  final VoidCallback? onReconduire;

  const DriverHistoryCard({
    super.key,
    required this.dateLabel,
    required this.time,
    required this.departure,
    required this.departureAddress,
    required this.arrival,
    required this.arrivalAddress,
    required this.price,
    required this.passengerCount,
    this.onReconduire,
  });

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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bande date (dynamique)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: secondColor.withOpacity(0.08),
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
              const Icon(Icons.credit_card, size: 36, color: secondColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxtComponents(
                      txt: departure,
                      fw: FontWeight.bold,
                      txtSize: 16,
                      family: "Bold",
                    ),
                    TxtComponents(
                      txt: departureAddress,
                      txtSize: 13,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 24, color: secondColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxtComponents(
                      txt: arrival,
                      fw: FontWeight.bold,
                      txtSize: 16,
                      family: "Bold",
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
              color: secondColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TxtComponents(
                  txt: "$passengerCount passager(s)",
                  txtSize: 13,
                  fw: FontWeight.bold,
                  family: "Bold",
                ),
                TxtComponents(
                  txt: "$price XOF",
                  txtSize: 14,
                  fw: FontWeight.bold,
                  family: "Bold",
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.badge_outlined, color: secondColor),
              Icon(Icons.analytics_outlined, color: secondColor),
              Icon(Icons.phone_android_outlined, color: secondColor),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onReconduire,
              icon: const Icon(Icons.refresh),
              label: const Text("Reconduire l’annonce"),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
