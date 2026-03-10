import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Optionnel: pour ouvrir des liens web externes

class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionTitle("Support & Rapports"),
            _buildActionCard(
              title: "Rapports",
              subtitle: "Voir les plaintes et litiges en cours",
              icon: Icons.gavel_rounded,
              color: Colors.redAccent,
              onTap: () {
                // Naviguer vers la liste détaillée des conflits (votre ancien écran)
              },
            ),

            _buildSectionTitle("Opérations & Conflits"),
            _buildActionCard(
              title: "Gestion des Signalements",
              subtitle: "Voir les plaintes et litiges en cours",
              icon: Icons.gavel_rounded,
              color: Colors.redAccent,
              onTap: () {
                // Naviguer vers la liste détaillée des conflits (votre ancien écran)
              },
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle("Informations Légales"),
            _buildLinkTile(
              title: "Politique de Confidentialité",
              subtitle: "Mise à jour le 15/12/2025",
              icon: Icons.privacy_tip_outlined,
              onTap: () => _openLink("https://votre-site.com/privacy"),
            ),
            
            _buildLinkTile(
              title: "Conditions Générales d'Utilisation",
              subtitle: "Règles de la plateforme (CGU)",
              icon: Icons.description_outlined,
              onTap: () => _openLink("https://votre-site.com/terms"),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Aide & Documentation"),
            _buildLinkTile(
              title: "Guide de l'Administrateur",
              subtitle: "Comment gérer les chauffeurs et les paiements",
              icon: Icons.menu_book_outlined,
              onTap: () {}, // Lien vers un PDF ou Wiki interne
            ),
            
            _buildLinkTile(
              title: "Support Technique Firebase",
              subtitle: "Accéder à la console Google Cloud",
              icon: Icons.cloud_queue,
              onTap: () => _openLink("https://console.firebase.google.com"),
            ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                "Version Admin 1.0.0 • Build 2025",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS DE L'INTERFACE ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Carte principale pour les actions critiques (Signalements)
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // Tuile pour les liens secondaires (Légal, Aide)
  Widget _buildLinkTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Fonction pour ouvrir des liens URL
  Future<void> _openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Impossible d\'ouvrir $url');
    }
  }
}