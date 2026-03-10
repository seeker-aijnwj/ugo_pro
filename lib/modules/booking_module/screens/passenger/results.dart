// 📄 search_results_screen.dart
import 'package:flutter/material.dart';
import '../../../../app/screens/base_page.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  Widget buildTripCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Mardi 28 juin",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("22:30", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Treichville",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Gare de Bassam, en face de la boulangerie ARRAS",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Text(
                  "1000 XOF",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Plateau", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Hyper U Plateau, en face de l'arrêt de bus",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.group, size: 18, color: Colors.blue),
                    SizedBox(width: 4),
                    Icon(Icons.group, size: 18, color: Colors.grey),
                    SizedBox(width: 4),
                    Icon(Icons.group, size: 18, color: Colors.grey),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.star, size: 18),
                    SizedBox(width: 4),
                    Text("3.5"),
                    SizedBox(width: 4),
                    Text("(16)", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.credit_card),
                Icon(Icons.bar_chart),
                Icon(Icons.phone_iphone),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  // TODO: Action réserver

                  // Création d'un nouveau trajet
                  
                },
                child: const Text(
                  "Réserver",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      currentIndex: 1,
      onTabSelected: (index) {
        // TODO: Navigation
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Treichville → Plateau",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2FA9E1),
                ),
                onPressed: () {},
                child: const Text("Tous les jours"),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2FA9E1),
                ),
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
                label: const Text("Filtre"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) => buildTripCard(),
            ),
          ),
        ],
      ),
    );
  }
}
