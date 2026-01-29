import 'package:flutter/material.dart';

class DemoDriver extends StatelessWidget {
  const DemoDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Espace Conducteur"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          Switch(value: true, onChanged: (v) {}, activeThumbColor: Colors.green), // Mode "En ligne"
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // 1. KPI DU JOUR (L'argent motive)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black87,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: "Gains du jour", value: "32 000 F"),
                _StatItem(label: "Trajets", value: "2"),
                _StatItem(label: "Note", value: "4.8 ⭐"),
              ],
            ),
          ),

          // 2. PROCHAIN TRAJET (Carte d'action)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PROCHAIN DÉPART", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.orange),
                              SizedBox(width: 10),
                              Text("Départ dans 45 min", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                          const Divider(height: 30),
                          _buildRouteRow(Icons.circle, Colors.blue, "Abidjan, Gare Nord"),
                          _buildVerticalLine(),
                          _buildRouteRow(Icons.location_on, Colors.green, "Yamoussoukro, Place de la Paix"),
                          
                          const SizedBox(height: 20),
                          // Liste des passagers (Aperçu)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              children: [
                                Icon(Icons.people),
                                SizedBox(width: 10),
                                Text("14 Passagers réservés / 18 places"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                  
                  // 3. GROS BOUTON D'ACTION (Facile à cliquer)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 30),
                      label: const Text("DÉMARRER L'EMBARQUEMENT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 15),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  static Widget _buildVerticalLine() {
    return Container(
      margin: const EdgeInsets.only(left: 9, top: 2, bottom: 2),
      height: 20,
      width: 2,
      color: Colors.grey[300],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}