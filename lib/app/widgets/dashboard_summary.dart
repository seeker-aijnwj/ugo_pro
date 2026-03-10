import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';

class DashboardSummary extends StatelessWidget {
  final int annonces;
  final int passagers;
  final double note; // affichage numérique uniquement (pas d'étoiles)

  const DashboardSummary({
    super.key,
    required this.annonces,
    required this.passagers,
    required this.note,
  });

  String _fmtNote(double n) =>
      (n % 1 == 0) ? n.toStringAsFixed(0) : n.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Bascule en 2 colonnes si l'espace est trop étroit
        final bool isNarrow = constraints.maxWidth < 360;
        final int columns = isNarrow ? 2 : 3;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          // Ratio pour garder une hauteur stable (ajuste si besoin)
          childAspectRatio: _computeAspectRatio(constraints.maxWidth, columns),
          children: [
            _buildItem("Annonces", annonces.toString()),
            _buildItem("Passagers", passagers.toString()),
            _buildItem("Note", _fmtNote(note)),
          ],
        );
      },
    );
  }

  double _computeAspectRatio(double maxWidth, int columns) {
    // On vise ~110 px de hauteur carte
    final double targetHeight = 110.0;
    final double itemWidth = (maxWidth - (12 * (columns - 1))) / columns;
    return itemWidth / targetHeight;
  }

  Widget _buildItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empêche le retour à la ligne qui déformait la carte
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: lightCardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            // Valeur centrée, taille fixe visuelle
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
