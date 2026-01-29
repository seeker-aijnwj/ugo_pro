import 'package:flutter/material.dart';
import 'package:ugo_pro/data/models/dispute.dart';

// ==============================================================================
// 1. MODÈLES DE DONNÉES LOCAUX
// ==============================================================================

// Pour les statistiques système (Compteur)
class SystemStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  SystemStat(this.label, this.value, this.icon, this.color);
}

// ==============================================================================
// 2. VUE PRINCIPALE SETTINGS
// ==============================================================================

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Section sélectionnée (Par défaut : 'profile')
  String _selectedSection = 'profile'; 

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // -------------------------------------------------------
          // ZONE 2 : MENU DE NAVIGATION (Hiérarchique)
          // -------------------------------------------------------
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      children: [
                        _buildSectionTitle("MON COMPTE"),
                        _buildMenuTile("profile", Icons.person_outline, "Profil Administrateur", "Modifier mes infos"),
                        _buildMenuTile("notifications", Icons.notifications_outlined, "Notifications", "Alertes et sons"),
                        
                        const Divider(indent: 20, endIndent: 20),
                        _buildSectionTitle("CENTRE DE SUPPORT"),
                        _buildMenuTile("disputes", Icons.gavel, "Gestion des Litiges", "Réclamations en cours", isAlert: true),
                        _buildMenuTile("help", Icons.help_outline, "Aide & FAQ", "Guides d'utilisation"),
                        _buildMenuTile("support", Icons.headset_mic, "Contacter le Super-Admin", "Support technique"),

                        const Divider(indent: 20, endIndent: 20),
                        _buildSectionTitle("SYSTÈME & LÉGAL"),
                        _buildMenuTile("system", Icons.speed, "Moniteur Système", "Compteurs et versions"),
                        _buildMenuTile("privacy", Icons.lock_outline, "Politique de Confidentialité", "RGPD et données"),
                        _buildMenuTile("terms", Icons.description_outlined, "Conditions d'Utilisation", "Règles de la plateforme"),
                      ],
                    ),
                  ),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------
          // ZONE 3 : CONTENU DYNAMIQUE (Détails)
          // -------------------------------------------------------
          if (isDesktop)
            Expanded(
              flex: 7,
              child: Container(
                color: const Color(0xFFF5F7FA), // Gris bleuté très léger
                padding: const EdgeInsets.all(30),
                child: _buildDetailsContent(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // ZONE 2 WIDGETS (MENU)
  // ============================================================================

  Widget _buildHeader() {
    return Container(
      height: 70,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: const Text("Paramètres", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
    );
  }

  Widget _buildMenuTile(String key, IconData icon, String title, String subtitle, {bool isAlert = false}) {
    final isSelected = _selectedSection == key;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF1A1A2E))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: isAlert 
        ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
        : (isSelected ? const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1A1A2E)) : null),
      onTap: () {
        setState(() => _selectedSection = key);
      },
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: .05),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: OutlinedButton.icon(
        onPressed: () {}, // Logique de déconnexion
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade100),
          padding: const EdgeInsets.symmetric(vertical: 18),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  // ============================================================================
  // ZONE 3 CONTENU (SWITCHER)
  // ============================================================================

  Widget _buildDetailsContent() {
    // Animation simple lors du changement de section
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(_selectedSection),
        child: _getSectionWidget(),
      ),
    );
  }

  Widget _getSectionWidget() {
    switch (_selectedSection) {
      case 'profile': return _buildProfileSection();
      case 'disputes': return _buildDisputesSection();
      case 'system': return _buildSystemMonitorSection();
      case 'privacy': return _buildPrivacySection();
      case 'help': return _buildHelpSection();
      // Ajouter les autres cas ici...
      default: return const Center(child: Text("Section en construction"));
    }
  }

  // --- 1. SECTION PROFIL ---
  Widget _buildProfileSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mon Profil", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Center(
            child: Stack(
              children: [
                const CircleAvatar(radius: 60, backgroundImage: NetworkImage("https://i.pravatar.cc/300?img=12")), // Image fictive
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildTextField("Nom complet", "Admin Principal"),
          const SizedBox(height: 20),
          _buildTextField("Email Professionnel", "admin@trak.ci"),
          const SizedBox(height: 20),
          _buildTextField("Rôle", "Super Administrateur", enabled: false),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text("Enregistrer les modifications", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- 2. SECTION GESTION DES LITIGES (FONCTIONNELLE) ---
  Widget _buildDisputesSection() {
    // Données fictives
    final disputes = [
      Dispute("L-004", "Alice Kouadio", "Objet Perdu", "J'ai oublié mon sac dans le Bus B-22.", "Moyenne", "Auj. 10:30"),
      Dispute("L-003", "Marc Zogo", "Remboursement", "Bus annulé, je veux mon argent.", "Haute", "Hier 14:00"),
      Dispute("L-001", "Sophie T.", "Comportement", "Le chauffeur roulait trop vite.", "Haute", "12/01/2024"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Gestion des Litiges", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Chip(label: const Text("3 Ouverts"), backgroundColor: Colors.orange.withValues(alpha: .2), labelStyle: const TextStyle(color: Colors.orange)),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Traitez les réclamations des utilisateurs ici.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        Expanded(
          child: ListView.separated(
            itemCount: disputes.length,
            separatorBuilder: (c, i) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final d = disputes[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: .1), blurRadius: 5)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Icon(Icons.warning_amber, color: d.severity == 'Haute' ? Colors.red : Colors.orange, size: 20),
                          const SizedBox(width: 10),
                          Text(d.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                        Text(d.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(d.description, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 5),
                        Text("Par: ${d.user}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const Spacer(),
                        TextButton(onPressed: (){}, child: const Text("Ignorer", style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                          onPressed: (){}, 
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A2E)),
                          child: const Text("Traiter", style: TextStyle(color: Colors.white, fontSize: 12))
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // --- 3. SECTION MONITEUR SYSTÈME (COMPTEUR) ---
  Widget _buildSystemMonitorSection() {
    final stats = [
      SystemStat("Utilisateurs Actifs", "1,240", Icons.people, Colors.blue),
      SystemStat("Sessions Admin", "4", Icons.admin_panel_settings, Colors.purple),
      SystemStat("Tickets Ouverts", "12", Icons.confirmation_number, Colors.orange),
      SystemStat("Version App", "v2.4.1", Icons.layers, Colors.green),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("État du Système", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 1.8
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final s = stats[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(s.icon, color: s.color, size: 30),
                    const SizedBox(height: 10),
                    Text(s.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text(s.label, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text("Outils Techniques", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white,
            leading: const Icon(Icons.cleaning_services),
            title: const Text("Vider le cache de l'application"),
            trailing: OutlinedButton(onPressed: (){}, child: const Text("Exécuter")),
          ),
        ],
      ),
    );
  }

  // --- 4. SECTION PRIVACY & TEXTE ---
  Widget _buildPrivacySection() {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Politique de Confidentialité", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Text(
            "Dernière mise à jour : 15 Janvier 2026\n\n"
            "1. Collecte des données\n"
            "Nous collectons les informations nécessaires au bon fonctionnement du service de transport, notamment la géolocalisation des bus et les informations de contact des passagers.\n\n"
            "2. Utilisation des données\n"
            "Les données sont utilisées uniquement pour la gestion des trajets, la sécurité et l'amélioration du service.\n\n"
            "3. Partage\n"
            "Aucune donnée n'est vendue à des tiers. Les données peuvent être partagées avec les autorités compétentes en cas de réquisition judiciaire.",
            style: TextStyle(height: 1.6, fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // --- 5. SECTION AIDE ---
  Widget _buildHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Centre d'Aide", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: "Rechercher une solution...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: const [
              ExpansionTile(
                title: Text("Comment ajouter un nouveau chauffeur ?"),
                children: [Padding(padding: EdgeInsets.all(15), child: Text("Allez dans l'onglet RH > Chauffeurs > Bouton '+' en haut à droite."))],
              ),
              ExpansionTile(
                title: Text("Comment annuler un trajet en urgence ?"),
                children: [Padding(padding: EdgeInsets.all(15), child: Text("Allez dans Opérations, sélectionnez le trajet, puis cliquez sur 'Modifier' > 'Annuler'."))],
              ),
              ExpansionTile(
                title: Text("Le GPS du bus ne répond pas"),
                children: [Padding(padding: EdgeInsets.all(15), child: Text("Vérifiez que le boîtier du bus est allumé. Sinon contactez le support technique."))],
              ),
            ],
          ),
        )
      ],
    );
  }

  // Helper pour les champs de texte
  Widget _buildTextField(String label, String value, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          enabled: enabled,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}