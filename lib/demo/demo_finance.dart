import 'package:flutter/material.dart';

class DemoFinance extends StatelessWidget {
  const DemoFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CARTE BANCAIRE VIRTUELLE (Effet Wow)
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF009688)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha: .4), blurRadius: 15, offset: const Offset(0, 10))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("SOLDE PLATEFORME", style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
                    Icon(Icons.account_balance_wallet, color: Colors.white70),
                  ],
                ),
                Text("4 520 000 CFA", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text("**** 8842", style: TextStyle(color: Colors.white)),
                    Spacer(),
                    Text("VISA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                )
              ],
            ),
          ),

          // LISTE DES TRANSACTIONS RÉCENTES
          const Align(alignment: Alignment.centerLeft, child: Text("Dernières Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          
          // Simulation de liste
          // TODO: Remplacer par FirebaseFirestore.collection('bookings').orderBy('createdAt')
          ...List.generate(5, (index) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: const Icon(Icons.arrow_downward, color: Colors.green),
              ),
              title: Text("Paiement Ticket #${4000 + index}"),
              subtitle: Text("Mobile Money • Il y a ${index + 2} min"),
              trailing: const Text("+ 5 500 F", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          )),
        ],
      ),
    );
  }
}