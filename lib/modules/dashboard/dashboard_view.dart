import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  // Simulez un chargement pour l'effet d'apparition
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Petit délai pour simuler le chargement des données API
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // UTILISATION DE LAYOUT BUILDER POUR LE RESPONSIVE
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width > 900;
        final isTablet = width > 600 && width <= 900;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER (Date + Bonjour)
                      _buildHeader(),
                      const SizedBox(height: 20),

                      // 2. KPI CARDS (Les chiffres clés)
                      _buildKPIGrid(width, isDesktop, isTablet),
                      const SizedBox(height: 20),

                      // 3. SECTION PRINCIPALE (Graphique + Carte)
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildRevenueChart()),
                            const SizedBox(width: 20),
                            Expanded(flex: 1, child: _buildLiveFleetMap()),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildRevenueChart(),
                            const SizedBox(height: 20),
                            _buildLiveFleetMap(),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // 4. DERNIÈRES ACTIVITÉS
                      const Text("Activités Récentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: UGOAdminTheme.primaryBlue)),
                      const SizedBox(height: 10),
                      _buildRecentActivityList(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tableau de Bord", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
            Text("Vue d'ensemble du réseau • ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", 
              style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() => _isLoading = true);
            Future.delayed(const Duration(seconds: 1), () => setState(() => _isLoading = false));
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text("Actualiser"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: UGOAdminTheme.primaryBlue),
        )
      ],
    );
  }

  Widget _buildKPIGrid(double width, bool isDesktop, bool isTablet) {
    // Calcul du nombre de colonnes selon l'écran
    int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
    double childAspectRatio = isDesktop ? 1.8 : (isTablet ? 2.5 : 2.2);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard("Chiffre d'Affaires", "2.4M FCFA", "+12%", Icons.attach_money, Colors.green, Colors.green[50]!),
        _buildStatCard("Tickets Vendus", "1,240", "+5%", Icons.confirmation_number, Colors.blue, Colors.blue[50]!),
        _buildStatCard("Taux Remplissage", "84%", "-2%", Icons.pie_chart, Colors.orange, Colors.orange[50]!),
        _buildStatCard("Flotte Active", "18/20", "Stable", Icons.directions_bus, Colors.purple, Colors.purple[50]!),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String trend, IconData icon, Color color, Color bgColor) {
    final isPositive = !trend.contains("-");
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: .1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isPositive ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(12)),
                child: Text(trend, style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: UGOAdminTheme.primaryBlue)),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: .1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Revenus Hebdomadaires", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("Lun", 0.4),
                _buildBar("Mar", 0.6),
                _buildBar("Mer", 0.5),
                _buildBar("Jeu", 0.8), // Pic
                _buildBar("Ven", 0.7),
                _buildBar("Sam", 0.9), // Gros jour
                _buildBar("Dim", 0.6),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percentage),
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Container(
              width: 30, // Largeur de la barre
              height: 200 * value, // Hauteur max 200
              decoration: BoxDecoration(
                color: value > 0.8 ? UGOAdminTheme.accentOrange : UGOAdminTheme.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildLiveFleetMap() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E), // Fond sombre "Tech"
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: .2), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Trafic en Temps Réel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.green, blurRadius: 5)]))
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                // Ligne de route (Abidjan -> Bouaké -> Korhogo)
                Center(child: Container(width: 4, height: double.infinity, color: Colors.white10)),
                
                // Villes (Points fixes)
                const Positioned(bottom: 20, left: 0, right: 0, child: Center(child: Text("ABIDJAN", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)))),
                const Positioned(top: 20, left: 0, right: 0, child: Center(child: Text("KORHOGO", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)))),
                const Center(child: Text("BOUAKÉ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2))),

                // Bus simulés (Animation simple ou position fixe pour démo)
                _buildBusMarker(top: 50, label: "BUS-01"),
                _buildBusMarker(top: 140, label: "BUS-04", isError: true), // Un bus en panne/retard
                _buildBusMarker(bottom: 40, label: "BUS-09"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBusMarker({double? top, double? bottom, required String label, bool isError = false}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isError ? Colors.red : UGOAdminTheme.accentOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2)
              ),
              child: const Icon(Icons.directions_bus, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // Données statiques pour la démo
    final activities = [
      {'title': 'Ticket vendu (Abidjan - Bouaké)', 'time': 'Il y a 2 min', 'icon': Icons.confirmation_number, 'color': Colors.green},
      {'title': 'Départ Bus B-882 validé', 'time': 'Il y a 15 min', 'icon': Icons.departure_board, 'color': Colors.blue},
      {'title': 'Retrait chauffeur Koné M. (25k)', 'time': 'Il y a 45 min', 'icon': Icons.payments, 'color': Colors.orange},
      {'title': 'Incident signalé sur l\'axe Nord', 'time': 'Il y a 2h', 'icon': Icons.warning, 'color': Colors.red},
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true, // Important car dans un SingleChildScrollView
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: (item['color'] as Color).withValues(alpha: .1),
              child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
            ),
            title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(item['time'] as String, style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          );
        },
      ),
    );
  }
}