// Fichier: lib/screens/admin/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater les dates
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ugo_pro/data/models/utilisateur.dart';
import '../../../widgets/responsive_layout.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream de tous les utilisateurs
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        
        // 1. Gestion des états de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }
        
        final users = snapshot.data!.docs;

        // 2. Affichage Adaptatif
        return ResponsiveLayout(
          // --- MOBILE : Liste Verticale ---
          mobileBody: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              return _buildMobileUserCard(userData, users[index].id, context);
            },
          ),

          // --- DESKTOP : Grand Tableau ---
          desktopBody: Card(
            elevation: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity, // Prendre toute la largeur
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Rôle Actif')),
                    DataColumn(label: Text('Téléphone')),
                    DataColumn(label: Text('Inscrit le')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: users.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildDesktopDataRow(data, doc.id, context);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS HELPERS ---

  // Ligne du tableau Desktop
  DataRow _buildDesktopDataRow(Map<String, dynamic> data, String uid, BuildContext context) {
    // Formatage date

    final utilisateur = Utilisateur(
      uid: uid, 
      name: Name(first: (data['prenom'] ?? '').toString().trim(), last: (data['nom'] ?? '').toString().trim()), 
      email: data['email'] ?? '', 
      role: data['role'] ?? 'passenger', 
      lastActive: DateTime.now()
    );

    final date = data['createdAt'] != null 
        ? DateFormat('dd/MM/yyyy').format((data['createdAt'] as Timestamp).toDate())
        : 'N/A';
    
    final bool isDriver = data['role'] == 'driver';

    return DataRow(cells: [
      DataCell(Row(
        children: [
          CircleAvatar(
            backgroundColor: isDriver ? Colors.orange[100] : Colors.blue[100],
            child: Icon(isDriver ? Icons.drive_eta : Icons.person, size: 16),
          ),
          const SizedBox(width: 10),
          Text(utilisateur.name.fullName),
        ],
      )),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDriver ? Colors.orange.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(isDriver ? 'Conducteur' : 'Passager', style: const TextStyle(fontSize: 12)),
        )
      ),
      DataCell(Text(data['numero'] ?? data['phone'] ?? '-')),
      DataCell(Text(date)),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}), // TODO: Edit
          IconButton(
            icon: const Icon(Icons.block, color: Colors.red), 
            onPressed: () => _showBanDialog(context, uid, data['nom']),
          ),
        ],
      )),
    ]);
  }

  // Carte Mobile
  Widget _buildMobileUserCard(Map<String, dynamic> data, String uid, BuildContext context) {
    final bool isDriver = data['role'] == 'driver';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDriver ? Colors.orange : Colors.blue,
          child: Icon(isDriver ? Icons.drive_eta : Icons.person, color: Colors.white),
        ),
        title: Text(data['nom'] ?? 'Inconnu'),
        subtitle: Text(data['numero'] ?? data['phone'] ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Afficher options sur mobile
            showModalBottomSheet(context: context, builder: (ctx) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.red),
                  title: const Text("Bannir l'utilisateur"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showBanDialog(context, uid, data['nom']);
                  },
                )
              ],
            ));
          },
        ),
      ),
    );
  }

  // Dialogue de bannissement (Logique fictive pour l'exemple)
  void _showBanDialog(BuildContext context, String uid, String? name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Bannir $name ?"),
        content: const Text("Cet utilisateur ne pourra plus se connecter."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: Mettre à jour Firestore : { 'isBanned': true }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur banni (Simulation)")));
            },
            child: const Text("Confirmer le Ban"),
          ),
        ],
      ),
    );
  }
}