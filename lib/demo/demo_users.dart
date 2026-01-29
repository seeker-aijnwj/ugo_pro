import 'package:flutter/material.dart';

class DemoUsers extends StatelessWidget {
  const DemoUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // SECTION CONDUCTEURS EN ATTENTE
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Conducteurs en attente de validation", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Konan+Ariel')), // Avatar fictif
            title: const Text("Konan Ariel"),
            subtitle: const Text("Permis B • 07 58 96 32 14"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {}), // TODO: Update Firestore role
                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {}),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        
        // SECTION UTILISATEURS ACTIFS
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Utilisateurs Récents", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        // TODO: Liste Firestore des 'users'
        ...List.generate(4, (i) => ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text("Utilisateur Test $i"),
          subtitle: const Text("Passager • Inscrit le 12/12/2025"),
          trailing: const Icon(Icons.more_vert),
        )),
      ],
    );
  }
}