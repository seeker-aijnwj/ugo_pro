import 'package:flutter/material.dart';
import '../../data/services/mock_data_service.dart';

class DemoDashboard extends StatelessWidget {
  const DemoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // RÉCUPÉRATION DES DONNÉES (Simulée)
    // TODO: Remplacer par StreamBuilder sur Firestore collection('stats')
    return FutureBuilder<Map<String, dynamic>>(
      future: MockDataService.getStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Aujourd'hui", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 15),
              
              // GRILLE DES KPI
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildKpiCard("Volume d'Affaires", "${data['revenue_day']} F", Icons.attach_money, Colors.green),
                  _buildKpiCard("Trajets Actifs", "12", Icons.directions_bus, Colors.blue),
                  _buildKpiCard("Nouveaux Inscrits", "+24", Icons.group_add, Colors.orange),
                  _buildKpiCard("Note Moyenne", "${data['satisfaction']}/5", Icons.star, Colors.purple),
                ],
              ),

              const SizedBox(height: 16),              
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dernières annonces", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Voir tout", style: TextStyle(color: Color(0xFF008000))),
                ],
              ),
              const SizedBox(height: 15),
              // Liste horizontale de trajets (Moderne)
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildTripCard("Abidjan", "Gagnoa", "14:00", "4 500 F", Colors.blueAccent),
                    _buildTripCard("Abidjan", "Bouaké", "15:30", "6 500 F", Colors.orangeAccent),
                    _buildTripCard("Abidjan", "San Pedro", "08:00", "7 000 F", Colors.teal),
                  ],
                ),
              ),
              
              
              // "Prochains départs" (Cartes visuelles)
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Départs Populaires", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Voir tout", style: TextStyle(color: Color(0xFF008000))),
                ],
              ),
              const SizedBox(height: 15),

              // Liste horizontale de trajets (Moderne)
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildTripCard("Abidjan", "Yamoussoukro", "14:00", "4 000 F", Colors.blueAccent),
                    _buildTripCard("Abidjan", "Bouaké", "15:30", "6 500 F", Colors.orangeAccent),
                    _buildTripCard("Abidjan", "San Pedro", "08:00", "7 000 F", Colors.teal),
                  ],
                ),
              ),
        

              const SizedBox(height: 16),
              const Text("Performance Mensuelle", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 15),
              
              // GRAPHIQUE SIMULÉ (Barres de progression)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    _buildBarChartRow("Semaine 1", 0.4),
                    _buildBarChartRow("Semaine 2", 0.55),
                    _buildBarChartRow("Semaine 3", 0.7),
                    _buildBarChartRow("Semaine 4 (En cours)", 0.85, isActive: true),
                  ],
                ),
              ), 

            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBarChartRow(String label, double pct, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: Colors.grey[100],
              color: isActive ? Colors.green : Colors.green[300],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildTripCard(String from, String to, String time, String price, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Icon(Icons.commute_outlined, color: color, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(to, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Depuis $from", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }

}