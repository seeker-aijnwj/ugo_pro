import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';

class PassengerActivityGraph extends StatelessWidget {
  final List<double> averageActivity; // 7 valeurs pour Lun..Dim
  final List<String> months;          // 4 mois (ancien -> récent), dernier = courant
  final int selectedMonthIndex;
  final void Function(int index) onMonthSelected;

  const PassengerActivityGraph({
    super.key,
    required this.averageActivity,
    required this.months,
    required this.selectedMonthIndex,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    const days = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
    final safe = (averageActivity.length == 7)
        ? averageActivity
        : List<double>.filled(7, 0);

    // Max réel du mois sélectionné
    final maxVal = safe.isEmpty ? 0.0 : safe.reduce((a, b) => a > b ? a : b);

    // min visuel TRÈS bas (proportionnel)
    double minVisual;
    if (maxVal > 0) {
      minVisual = (maxVal * 0.02);            // 2% du max
      if (minVisual < 0.01) minVisual = 0.01; // bornes
      if (minVisual > 0.10) minVisual = 0.10;
    } else {
      minVisual = 0.05;                       // tout à 0
    }
    final visual = safe.map((v) => v <= 0 ? minVisual : v).toList();

    // Echelle Y: marge
    final maxY = (maxVal > 0) ? (maxVal * 1.2) : 1.0;

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
          // Mois: ancien -> récent (courant à droite)
          Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(months.length, (i) {
              final isSelected = i == selectedMonthIndex;
              return GestureDetector(
                onTap: () => onMonthSelected(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? mainColor : const Color(0x330D47A1),
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

          // Graphique barres
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    //tooltipBgColor: Colors.black.withOpacity(0.7),
                    getTooltipItem: (group, _, rod, _) {
                      final day = days[group.x.toInt()];
                      final real = safe[group.x.toInt()];
                      return BarTooltipItem(
                        "$day\n${_fmt(real)}",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: visual[i],   // 0 => min très bas, sinon valeur réelle
                        color: mainColor,
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
              CircleAvatar(radius: 6, backgroundColor: mainColor),
              SizedBox(width: 8),
              Text(
                "Moy. réservations / jour",
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
