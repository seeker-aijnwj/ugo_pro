// lib/widgets/dashboard_graph.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';

class DashboardGraph extends StatelessWidget {
  final List<double> data; // 7 valeurs (Lun..Dim)
  final List<String> months; // 4 labels (ancien -> récent)
  final int selectedMonthIndex;
  final void Function(int index) onMonthSelected;

  const DashboardGraph({
    super.key,
    required this.data,
    required this.months,
    required this.selectedMonthIndex,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<double> safeData = (data.length == 7)
        ? data
        : List<double>.filled(7, 0);

    const List<String> days = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

    // Max réel des données
    final double maxVal = safeData.isEmpty
        ? 0
        : safeData.reduce((a, b) => a > b ? a : b);
    final bool isAllZero = safeData.every((v) => v <= 0.0);

    // Échelle qui se réajuste toujours :
    // - s'il y a des valeurs > 0 : maxY = maxVal (avec un plancher 1.0 pour éviter une échelle trop serrée)
    // - si tout est à 0 : maxY = 1.0
    final double maxY = isAllZero ? 1.0 : (maxVal < 1.0 ? 1.0 : maxVal);

    // Affichage des zéros à 5% de la hauteur
    const double zeroFraction = 0.05;
    final double zeroVisual = maxY * zeroFraction;

    // Données visuelles pour les barres : on remplace 0 -> 5% de l’échelle
    final List<double> visualData = safeData
        .map((v) => v <= 0 ? zeroVisual : v)
        .toList();

    String shortMonth(String m) => (m.length <= 4) ? m : m.substring(0, 4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sélecteur de mois
          Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(months.length, (i) {
              final isSelected = i == selectedMonthIndex;
              return GestureDetector(
                onTap: () => onMonthSelected(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? secondColor : lightCardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shortMonth(months[i]),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Graphique
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY, // échelle réajustée dynamiquement
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, _) {
                      final day = days[group.x.toInt()];
                      final realValue = safeData[group.x.toInt()];
                      return BarTooltipItem(
                        "$day\n${_fmt(realValue)}",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) => Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          days[value.toInt()],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: visualData[i],
                        color: secondColor,
                        width: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              CircleAvatar(radius: 6, backgroundColor: secondColor),
              SizedBox(width: 8),
              Text(
                "Taux d’activité (moyenne/jour)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double n) =>
      (n % 1 == 0) ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
}
