import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../widgets/responsive_layout.dart';

class AdminFinanceScreen extends StatelessWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Format monétaire local (Franc CFA)
    final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'F. CFA', decimalDigits: 0);

    return StreamBuilder<QuerySnapshot>(
      // On écoute la collection des réservations (à créer au Module 3)
      stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        
        // Calcul des KPI (Totaux)
        double totalVolume = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            // On suppose que le champ 'totalPrice' existe dans une réservation
            totalVolume += (data['totalPrice'] ?? 0);
          }
        }
        
        // Supposons que la plateforme prend 10%
        double totalCommission = totalVolume * 0.10; 

        return ResponsiveLayout(
          // --- MOBILE : Cartes KPI + Liste ---
          mobileBody: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKpiCard("Volume d'affaires", totalVolume, Colors.blue, currencyFormat),
              const SizedBox(height: 10),
              _buildKpiCard("Commissions (10%)", totalCommission, Colors.green, currencyFormat),
              const SizedBox(height: 20),
              const Text("Dernières Transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              if (snapshot.hasData)
                ...snapshot.data!.docs.map((doc) => _buildTransactionTile(doc.data() as Map<String, dynamic>, currencyFormat))
            ],
          ),

          // --- DESKTOP : KPI en haut + Tableau en bas ---
          desktopBody: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zone des KPIs
                Row(
                  children: [
                    Expanded(child: _buildKpiCard("Volume Total (GMV)", totalVolume, Colors.blue, currencyFormat)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildKpiCard("Revenu Plateforme (Net)", totalCommission, Colors.green, currencyFormat)),
                    const SizedBox(width: 20),
                    // Carte statique pour l'exemple
                    Expanded(child: _buildKpiCard("Frais de Passerelle (Mobile Money)", totalVolume * 0.02, Colors.orange, currencyFormat)),
                  ],
                ),
                const SizedBox(height: 40),
                
                const Text("Historique des Transactions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                // Tableau des transactions
                Card(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Passager')),
                        DataColumn(label: Text('Trajet')),
                        DataColumn(label: Text('Montant')),
                        DataColumn(label: Text('État')),
                      ],
                      rows: snapshot.hasData 
                        ? snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DataRow(cells: [
                              DataCell(Text(DateFormat('dd/MM/yyyy').format((data['createdAt'] as Timestamp).toDate()))),
                              DataCell(Text(data['userName'] ?? 'Client')),
                              DataCell(Text(data['route'] ?? 'Abidjan - Gagnoa')), // Exemple
                              DataCell(Text(currencyFormat.format(data['totalPrice'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                                child: const Text("Payé", style: TextStyle(color: Colors.green, fontSize: 12)),
                              )),
                            ]);
                          }).toList()
                        : [],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS HELPERS ---

  Widget _buildKpiCard(String title, double amount, Color color, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: color),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text(fmt.format(amount), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> data, NumberFormat fmt) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.receipt, color: Colors.grey)),
        title: Text(data['userName'] ?? 'Client Inconnu'),
        subtitle: Text(DateFormat('dd/MM HH:mm').format((data['createdAt'] as Timestamp).toDate())),
        trailing: Text(fmt.format(data['totalPrice'] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }
}