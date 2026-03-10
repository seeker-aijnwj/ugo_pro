import 'package:flutter/material.dart';

// ==============================================================================
// 1. MODÈLE DE DONNÉES (Utilisateurs RH)
// ==============================================================================

enum UserRole { passenger, driver, support, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  String status; // 'actif', 'bloqué'
  final String avatarUrl; // Pour simuler une photo
  final String location;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.status = 'actif',
    this.avatarUrl = '',
    this.location = 'Abidjan',
  });
}

// ==============================================================================
// 2. THÈME LOCAL RAPIDE
// ==============================================================================
class HrColors {
  static const Color primary = Color(0xFF128C7E); // Vert style WhatsApp Business
  static const Color secondary = Color(0xFF25D366);
  static const Color background = Color(0xFFECE5DD);
  static const Color red = Color(0xFFE53935);
  static const Color darkText = Color(0xFF075E54);
}

// ==============================================================================
// 3. VUE PRINCIPALE RH
// ==============================================================================

class HrView extends StatefulWidget {
  const HrView({super.key});

  @override
  State<HrView> createState() => _HrViewState();
}

class _HrViewState extends State<HrView> {
  // --- ÉTAT ---
  UserRole? _selectedCategory; // Si null = Affiche le Menu, Sinon = Affiche la Liste
  AppUser? _selectedUser;      // L'utilisateur affiché en Zone 3

  // --- DONNÉES FICTIVES ---
  final List<AppUser> _allUsers = [
    // Chauffeurs
    AppUser(id: "D-01", name: "Moussa Diakité", email: "moussa.d@trak.ci", phone: "+225 07 07 00 01", role: UserRole.driver, location: "Bouaké"),
    AppUser(id: "D-02", name: "Koffi Kouamé", email: "koffi.k@trak.ci", phone: "+225 05 05 00 02", role: UserRole.driver, location: "Abidjan"),
    AppUser(id: "D-03", name: "Jean Yves", email: "jean.y@trak.ci", phone: "+225 01 01 00 03", role: UserRole.driver, status: 'bloqué'),
    
    // Passagers
    AppUser(id: "P-01", name: "Awa Touré", email: "awa.t@gmail.com", phone: "+225 07 00 00 00", role: UserRole.passenger),
    AppUser(id: "P-02", name: "Bernard Zadi", email: "bernard.z@yahoo.fr", phone: "+225 01 02 03 04", role: UserRole.passenger),
    
    // Admins
    AppUser(id: "A-01", name: "Admin Principal", email: "admin@trak.ci", phone: "+225 00 00 00 00", role: UserRole.admin),
    
    // Support
    AppUser(id: "S-01", name: "Service Client 1", email: "support1@trak.ci", phone: "+225 22 00 00 00", role: UserRole.support),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // -----------------------------------------------------------
          // ZONE 2 : NAVIGATION & LISTES
          // -----------------------------------------------------------
          Expanded(
            flex: 3, // 30% largeur
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  // En-tête Zone 2
                  _buildMenuHeader(),
                  
                  // Contenu dynamique (Menu Catégories OU Liste Utilisateurs)
                  Expanded(
                    child: _selectedCategory == null 
                        ? _buildCategoriesMenu() 
                        : _buildUserList(_selectedCategory!),
                  ),
                ],
              ),
            ),
          ),

          // -----------------------------------------------------------
          // ZONE 3 : DÉTAILS & ACTIONS
          // -----------------------------------------------------------
          if (isDesktop)
            Expanded(
              flex: 7, // 60% largeur
              child: Container(
                color: const Color(0xFFF0F2F5), // Fond gris très clair
                child: _selectedUser != null 
                    ? _buildUserProfile(_selectedUser!)
                    : _buildEmptyState(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // ZONE 2 WIDGETS
  // ============================================================================

  Widget _buildMenuHeader() {
    bool isSubList = _selectedCategory != null;
    
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (isSubList)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: HrColors.darkText),
              onPressed: () => setState(() {
                _selectedCategory = null; // Retour au menu
                _selectedUser = null;     // Désélectionner l'user
              }),
            ),
          Text(
            isSubList ? _getRoleTitle(_selectedCategory!) : "Ressources Humaines",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: HrColors.darkText),
          ),
          const Spacer(),
          if (!isSubList)
             IconButton(
               icon: const Icon(Icons.person_add_alt_1, color: HrColors.primary),
               tooltip: "Ajouter un utilisateur",
               onPressed: () => _showAddUserDialog(),
             ),
        ],
      ),
    );
  }

  // ÉTAT A : MENU TYPE WHATSAPP SETTINGS
  Widget _buildCategoriesMenu() {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        _buildSectionHeader("GESTION DES EFFECTIFS"),
        _buildMenuTile(Icons.groups, "Passagers", "Clients et voyageurs", UserRole.passenger, Colors.blue),
        _buildMenuTile(Icons.drive_eta, "Chauffeurs", "Conducteurs de la flotte", UserRole.driver, Colors.orange),
        const Divider(height: 1),
        
        _buildSectionHeader("ADMINISTRATION"),
        _buildMenuTile(Icons.support_agent, "Support Client", "Agents de liaison", UserRole.support, Colors.purple),
        _buildMenuTile(Icons.admin_panel_settings, "Administrateurs", "Gestionnaires de la plateforme", UserRole.admin, Colors.red),
        
        const Divider(height: 1),
        _buildSectionHeader("ACTIONS RAPIDES"),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.person_add, color: Colors.green),
          ),
          title: const Text("Nouvel Utilisateur", style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          onTap: () => _showAddUserDialog(),
        ),
      ],
    );
  }

  // ÉTAT B : LISTE FILTRÉE
  Widget _buildUserList(UserRole role) {
    // Filtrer la liste
    final users = _allUsers.where((u) => u.role == role).toList();

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("Aucun ${_getRoleTitle(role).toLowerCase()} trouvé.", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (c, i) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelected = _selectedUser?.id == user.id;

        return ListTile(
          selected: isSelected,
          selectedTileColor: HrColors.primary.withValues(alpha: .1),
          leading: CircleAvatar(
            backgroundColor: user.status == 'bloqué' ? Colors.red.shade100 : Colors.grey.shade200,
            child: Text(user.name[0], style: TextStyle(color: user.status == 'bloqué' ? Colors.red : Colors.grey.shade700)),
          ),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(user.phone, style: const TextStyle(fontSize: 12)),
          trailing: user.status == 'bloqué' 
              ? const Chip(label: Text("BLOQUÉ", style: TextStyle(fontSize: 8, color: Colors.white)), backgroundColor: Colors.red, padding: EdgeInsets.all(0)) 
              : null,
          onTap: () {
            setState(() => _selectedUser = user);
          },
        );
      },
    );
  }

  // ============================================================================
  // ZONE 3 WIDGETS (DÉTAILS)
  // ============================================================================

  Widget _buildUserProfile(AppUser user) {
    bool isBlocked = user.status == 'bloqué';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Avatar géant
          CircleAvatar(
            radius: 50,
            backgroundColor: isBlocked ? Colors.red.shade100 : HrColors.primary.withValues(alpha: .1),
            child: Text(user.name[0], style: TextStyle(fontSize: 40, color: isBlocked ? Colors.red : HrColors.primary)),
          ),
          const SizedBox(height: 15),
          Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(_getRoleTitle(user.role), style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isBlocked ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(user.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),

          // Cartes d'info
          _buildInfoSection("Coordonnées", [
            _buildInfoRow(Icons.email, "Email", user.email),
            _buildInfoRow(Icons.phone, "Téléphone", user.phone),
            _buildInfoRow(Icons.location_on, "Ville", user.location),
          ]),
          
          const SizedBox(height: 20),

          // Actions
          _buildInfoSection("Gestion du compte", [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Modifier les informations"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditUserDialog(user),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(isBlocked ? Icons.check_circle : Icons.block, color: isBlocked ? Colors.green : Colors.orange),
              title: Text(isBlocked ? "Débloquer l'utilisateur" : "Bloquer l'utilisateur"),
              subtitle: Text(isBlocked ? "Rétablir l'accès au compte" : "Empêcher toute connexion future"),
              onTap: () {
                setState(() => user.status = isBlocked ? 'actif' : 'bloqué');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Statut mis à jour : ${user.status}")));
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Supprimer le compte", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Logique de suppression
                 showDialog(context: context, builder: (ctx) => AlertDialog(
                   title: const Text("Confirmation"),
                   content: Text("Voulez-vous vraiment supprimer ${user.name} ? Cette action est irréversible."),
                   actions: [
                     TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Annuler")),
                     TextButton(onPressed: (){
                       setState(() {
                         _allUsers.removeWhere((u) => u.id == user.id);
                         _selectedUser = null;
                       });
                       Navigator.pop(ctx);
                     }, child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
                   ],
                 ));
              },
            ),
          ]),
        ],
      ),
    );
  }

  // ============================================================================
  // HELPERS UI
  // ============================================================================

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, UserRole role, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: () {
        setState(() {
          _selectedCategory = role;
          _selectedUser = null; // Reset selection quand on change de catégorie
        });
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 5)]),
          child: Column(children: children),
        )
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text(
            "Sélectionnez un utilisateur\npour gérer son compte",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.passenger: return "Passagers";
      case UserRole.driver: return "Chauffeurs";
      case UserRole.support: return "Support";
      case UserRole.admin: return "Administrateurs";
    }
  }

  // ============================================================================
  // DIALOGUES (ADD / EDIT)
  // ============================================================================

  void _showAddUserDialog() {
    // Version simplifiée pour la démo
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Ajouter un utilisateur"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(decoration: InputDecoration(labelText: "Nom complet", border: OutlineInputBorder())),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
          SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: "Téléphone", border: OutlineInputBorder())),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
        ElevatedButton(onPressed: () {
          // Logique d'ajout mockée
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur ajouté avec succès !")));
          Navigator.pop(ctx);
        }, child: const Text("Ajouter")),
      ],
    ));
  }

   void _showEditUserDialog(AppUser user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Modifier ${user.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Téléphone", border: OutlineInputBorder())),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
        ElevatedButton(onPressed: () {
          // Update simple pour l'UI
          setState(() {
             // Dans une vraie app, on mettrait à jour l'objet ou on appellerait une API
          });
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Modifications enregistrées")));
        }, child: const Text("Sauvegarder")),
      ],
    ));
  }
}