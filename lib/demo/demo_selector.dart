/// Dites : "Notre plateforme est un écosystème complet. 
/// Elle s'adapte à chaque acteur."

/// Cliquez sur Passager : "Pour le client, c'est la 
/// simplicité extrême. Regardez, il choisit sa destination,
///  voit le prix, et réserve. Pas de friction." 
/// (Revenez en arrière).

/// Cliquez sur Conducteur : "Pour le chauffeur, c'est un 
/// outil de travail. Gros boutons, visibilité sur les 
/// gains. Ça les fidélise." (Revenez en arrière).

/// Cliquez sur Admin : "Et pour vous et nous, c'est la 
/// tour de contrôle. On voit l'argent rentrer et on gère 
/// la flotte."
/// C'est là que vous allez les séduire. La simplicité 
/// pour l'utilisateur, la puissance pour l'admin.
/// 
/// Oui, pour une démonstration investisseur, tout est absolument prêt ! 🚀

/// Vous avez maintenant entre les mains un MVP Visuel 
/// 
/// (Minimum Viable Product) complet. C'est l'outil parfait
///  pour vendre votre vision sans risquer les bugs 
/// techniques d'une application en développement.

/// Voici un dernier récapitulatif pour être sûr que vous 
/// êtes paré au décollage :

/// ✅ Ce que vous avez dans le kit :
///L'Expérience Client (Passager) : Vous montrez la 
///simplicité de réservation (style Uber/Yango).

///L'Outil de Travail (Conducteur) : Vous montrez comment 
///vous allez fidéliser les chauffeurs (gains, clarté).

///La Tour de Contrôle (Admin) : Vous rassurez 
///l'investisseur sur la gestion de l'argent et la sécurité.
///Le Sélecteur Magique : Pour passer d'un rôle à l'autre 
///sans redémarrer l'application.

///⚠️ Trois conseils capitaux pour votre présentation
///Pour que l'effet "Whaou" soit total, respectez ces 
///règles d'or lors du pitch :

///1. Restez sur le "Chemin Heureux" (Happy Path) C'est 
///une démo fictive. Ne cliquez pas sur tous les petits 
///boutons annexes (comme "Mot de passe oublié" ou 
///"Paramètres avancés") car ils ne mènent probablement 
///nulle part dans ce code de démo.

/// Action : Répétez votre présentation 3 ou 4 fois seul 
/// avant le jour J pour mémoriser exactement où cliquer.

///2. Racontez une histoire, ne décrivez pas des écrans 
///Ne dites pas : "Ici il y a un bouton vert et une liste.
///" Dites plutôt : "Imaginez Moussa. Il est pressé. Il 
///ouvre l'appli. En 3 secondes, il voit un départ pour 
///Bouaké. Il clique. C'est fait. Maintenant, regardons 
///Koné, le chauffeur..."

/// 3. Soyez transparent sur l'état technique Si un 
/// investisseur technique demande : "C'est connecté à 
/// une vraie base de données ?" Répondez honnêtement : 
/// "Pour cette présentation, nous utilisons des données 
/// de simulation pour vous montrer la fluidité de 
/// l'interface cible. Le backend (Firebase) est déjà en 
/// cours de développement sur notre version technique." 
/// (C'est la vérité, puisque nous avons fait le Module 1 
/// ensemble).

/// 🔜 Et après la démo ?
/// Une fois que vous aurez impressionné les
///  investisseurs et validé le concept :

///On ne jette pas ce code ! Il servira de référence 
///visuelle (Design System).

/// Nous reprendrons le code du Module 1 (Auth) et 
/// nous intégrerons petit à petit ces beaux écrans en 
/// remplaçant les fausses données par les vraies données 
/// de Cloud Firestore.

///Êtes-vous prêt à lancer la commande flutter run et 
///à conquérir le monde du transport ivoirien ? 
///😉 Bonne chance !


import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';
import 'package:ugo_pro/layouts/admin_layout.dart';
import 'package:ugo_pro/layouts/ugo_admin_layout.dart';
import 'demo_admin_layout.dart';
import 'demo_passenger.dart';
import 'demo_driver.dart';

class DemoSelector extends StatelessWidget {
  const DemoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.commute, size: 120, color: Colors.grey),
                const SizedBox(height: 20),
                const Text("Gare Routière Numérique", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text("Sélecteur de Démonstration", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 50),
        
                _buildDemoButton(
                  context, 
                  "👨‍💼 Banques & Invests", 
                  UGOAdminTheme.gold, 
                  Icons.assured_workload,
                  const DemoAdminLayout()
                ),
                const SizedBox(height: 20),
                _buildDemoButton(
                  context, 
                  "👨‍💼 Admin & Support (Clean Code)", 
                  UGOAdminTheme.primaryBlue, // Vert WhatsApp
                  Icons.admin_panel_settings,
                  const AdminLayout()
                  // const UGOAdminLayout() // <--- Le nouveau fichier
                ),
                const SizedBox(height: 20),
                _buildDemoButton(
                  context, 
                  "👨‍💼 Admin & Support (Old Code)", 
                  UGOAdminTheme.primaryBlue, // Vert WhatsApp
                  Icons.admin_panel_settings,
                  const UGOAdminLayout() // <--- Le nouveau fichier
                ),
                const SizedBox(height: 20),
                _buildDemoButton(
                  context, 
                  "🙋‍♂️ Interface Passager", 
                  const Color(0xFF008000), 
                  Icons.person,
                  const DemoPassenger()
                ),
                const SizedBox(height: 20),
                _buildDemoButton(
                  context, 
                  "🚌 Interface Conducteur", 
                  Colors.black87, 
                  Icons.drive_eta,
                  const DemoDriver()
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton(BuildContext context, String title, Color color, IconData icon, Widget screen) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}