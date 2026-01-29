import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';

class AdminDriverScreen extends StatelessWidget {
  const AdminDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          
          // 1. LA PROMESSE : "Où allez-vous ?"
          const Text("Bonjour, Admin | Support 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Où souhaitez-vous aller aujourd'hui ?", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

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
          const SizedBox(height: 15),

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
                _buildAssignmentField(Icons.my_location, "Abidjan (Ma position)", isSource: true),
                const Divider(height: 30),
                _buildAssignmentField(Icons.flag_outlined, "Donnez la destination (ex: Gagnoa)", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.join_inner, "Tapez le lieu de rencontre (ex: Gare de Bassam, Treichville)", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.location_on_outlined, "Marquez la fin du parcours (ex: Lycée Professionnel)", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.event, "Choisissez le jour du départ", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.alarm_on, "Choisissez l'heure de départ", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.multiple_stop, "Liste des arrêts (facultative)", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.airline_seat_recline_normal, "Nombre de places", isSource: false),
                const SizedBox(height: 30),
                _buildAssignmentField(Icons.account_balance_wallet, "Prix par place", isSource: false),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: UGOAdminTheme.accentOrange),
                    onPressed: () {}, 
                    child: const Text("Publier l'annonce", style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),
           
        ],       
      ),
    );
  }

  Widget _buildAssignmentField(IconData icon, String text, {required bool isSource}) {
    return Row(
      children: [
        Icon(icon, color: isSource ? Colors.blue : UGOAdminTheme.accentOrange),
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