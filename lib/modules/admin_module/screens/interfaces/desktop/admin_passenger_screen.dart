import 'package:flutter/material.dart';

class AdminPassengerScreen extends StatelessWidget {
  const AdminPassengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. LA PROMESSE : "Où allez-vous ?"
          const Text("Bonjour, Moussa 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Où souhaitez-vous aller aujourd'hui ?", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          // 2. LA RECHERCHE (Le cœur de l'app)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                _buildLocationField(Icons.my_location, "Donnez des précisions", isSource: true),
                const Divider(height: 30),
                _buildLocationField(Icons.location_on_outlined, "Lieu de départ (ex: Treichville)", isSource: false),
                const SizedBox(height: 30),
                _buildLocationField(Icons.flag_outlined, "Destination (ex: Gagnoa Commune)", isSource: false),
                const SizedBox(height: 30),
                _buildLocationField(Icons.event, "Lieu de rencontre (ex: Bouaké)", isSource: false),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {}, 
                    child: const Text("Rechercher un départ", style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          // 3. LA SÉDUCTION : "Prochains départs" (Cartes visuelles)
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
        ],       
      ),
    );
  }

  Widget _buildLocationField(IconData icon, String text, {required bool isSource}) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 15),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 16, color: isSource ? Colors.black : Colors.grey[400], fontWeight: isSource ? FontWeight.bold : FontWeight.normal)),
        ),
      ],
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
              Icon(Icons.directions_bus, color: color, size: 20),
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