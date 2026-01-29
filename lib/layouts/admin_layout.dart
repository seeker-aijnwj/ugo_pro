import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';
import 'package:ugo_pro/data/models/mocks/mock_admin_user.dart';
import 'package:ugo_pro/data/models/mocks/mock_driver.dart';
import 'package:ugo_pro/data/models/mocks/mock_faq.dart';
import 'package:ugo_pro/data/models/mocks/mock_passenger.dart';
import 'package:ugo_pro/data/models/mocks/mock_ticket.dart';
import 'package:ugo_pro/data/models/trip_ad.dart';
import 'package:ugo_pro/data/services/mock_data_service.dart';
import 'package:ugo_pro/modules/dashboard/dashboard_view.dart';
import 'package:ugo_pro/modules/groups/hr_view.dart';
import 'package:ugo_pro/modules/settings/settings_view.dart';
import 'package:ugo_pro/modules/trip_module/operation_view.dart';
// import '../modules/dashboard/dashboard_view.dart';
import '../modules/finance/finance_view.dart';
// ... autres imports

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  // 0 = Dashboard, 1 = Annonces, 2 = Groupes, 3 = Finance, 4 = Plus, 5 = Compte & Paramètres
  int _selectedTab = 0; 

  // L'élément sélectionné dans la liste (pour l'affichage à droite)
  TripAd? _selectedTrip;

  // L'élément sélectionné dans la liste des plaintes (pour l'affichage à droite)
  MockTicket? _selectedTicket;

  // Gestion de la sous-navigation dans l'onglet RH (Index 2)
  String? _rhSubCategory; // null = Menu principal, 'drivers', 'passengers', 'support', 'admins'

 // Gestion sous-menu "Plus" (Index 4)
  String? _plusSubCategory; // 'tickets', 'faq', 'settings', 'about'

  // Élément sélectionné pour la Zone 3 (On utilise dynamic pour gérer tous les types)
  dynamic _selectedEntity;

  // La liste des vues, propre et rangée
  final List<Widget> _views = [
    const DashboardView(),      // Index 0  
    const OperationView(),     // Index 1 
    const HrView(),             // Index 2 
    const FinanceView(),        // Index 3
    const SettingsView(),        // Index 4 
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    // --- VERSION MOBILE ---
    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: UGOAdminTheme.primaryBlue, // BLEU
          title: const Text(
            "Administration", 
            style: TextStyle(color: Colors.white)
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(onPressed: (){}, icon: const Icon(Icons.search, color: Colors.white))
          ],
        ),
        body: _buildListPanel(isMobile: true),
        floatingActionButton: FloatingActionButton(
          backgroundColor: UGOAdminTheme.accentOrange, // ORANGE
          onPressed: (){},
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (i) => setState(() => _selectedTab = i),
          selectedItemColor: UGOAdminTheme.primaryBlue, // BLEU
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Accueil"),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Annonces"),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Groupes"),
            BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Finances"),
            BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "Plus"),
          ],
        ),
      );
    } 
    
    // --- VERSION DESKTOP (Style WhatsApp Web Adapté) ---
    else {

      return Scaffold(
          backgroundColor: UGOAdminTheme.scaffoldBg, // Gris-Bleu pâle
          body: Stack(
            children: [
              // BANDEAU SUPÉRIEUR (Signature visuelle)
              // On remplace le vert WhatsApp par votre BLEU
              Container(
                height: 127, 
                color: UGOAdminTheme.primaryBlue
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Card(
                  elevation: 8, // Un peu plus d'ombre pour faire ressortir
                  shadowColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                      children: [
                        // ZONE 1 : Navigation (Reste ici car commune à tout le monde)
                        NavigationRail(
                          selectedIndex: _selectedTab,
                          onDestinationSelected: (int index) => setState(() => _selectedTab = index),
                          backgroundColor: Colors.white, // Votre AdminTheme.primaryDark
                          selectedIconTheme: const IconThemeData(color: Colors.black),
                          unselectedIconTheme: const IconThemeData(color: Colors.grey),
                          destinations: const [
                            NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Dashboard")),
                            NavigationRailDestination(icon: Icon(Icons.assignment), label: Text("Trajets")),
                            NavigationRailDestination(icon: Icon(Icons.groups), label: Text("Groupes")),
                            NavigationRailDestination(icon: Icon(Icons.attach_money), label: Text("Finances")),
                            NavigationRailDestination(icon: Icon(Icons.more_horiz), label: Text("Plus")),
                          ],
                        ),

                        // ZONES 2 & 3 : Déléguées aux modules !
                        Expanded(
                          child: _views[_selectedTab], 
                        ),
                      ],
                    ),
                ),
              ),
            ],
          ),
        );
    }
  }


  // --- LISTE (affichage mobile) ---
  Widget _buildListPanel({required bool isMobile}) {

    // Si on est sur l'onglet "Tableau de bord"
    if (_selectedTab == 0) {
      return FutureBuilder<Map<String, dynamic>>(
        future: MockDataService.getGlobalStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text("APERÇU DU JOUR", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Carte Météo 1 : Revenus
              _buildKpiTile(Icons.attach_money, "Chiffre d'affaires", "${data['revenue']} CFA", Colors.green),
              
              // Carte Météo 2 : Trajets
              _buildKpiTile(Icons.directions_bus, "Trajets actifs", "${data['trips']}", UGOAdminTheme.primaryBlue),
              
              // Carte Météo 3 : Alertes RH
              _buildKpiTile(
                Icons.warning_amber_rounded, 
                "Validations en attente", 
                "${data['pending_drivers']}", 
                data['pending_drivers'] > 0 ? UGOAdminTheme.accentOrange : Colors.grey
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              
              // Raccourcis rapides
              const Text("ACCÈS RAPIDE", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: UGOAdminTheme.primaryBlue),
                title: const Text("Nouveau Trajet"),
                onTap: () {
                   setState(() => _selectedTab = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt, color: UGOAdminTheme.primaryBlue),
                title: const Text("Valider Chauffeur"),
                onTap: () => setState(() => _selectedTab = 2), 
              ),
            ],
          );
        },
      );
    }

    // Si on est sur l'onglet "Groupes"
    if (_selectedTab == 2) {
      // SI AUCUNE SOUS-CATÉGORIE N'EST CHOISIE -> AFFICHER LE MENU
      if (_rhSubCategory == null) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 10),
              child: Text("GESTION DES UTILISATEURS", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            _buildGroupsMenuItem("Chauffeurs", Icons.directions_bus, Colors.blue, 'drivers'),
            _buildGroupsMenuItem("Passagers", Icons.groups, Colors.orange, 'passengers'),
            _buildGroupsMenuItem("Équipe Support", Icons.headset_mic, Colors.purple, 'support'),
            const Divider(),
            _buildGroupsMenuItem("Administrateurs", Icons.security, Colors.red, 'admins'),
          ],
        );
      } 
      // SINON -> AFFICHER LA LISTE CORRESPONDANTE AVEC BOUTON RETOUR
      else {
        return Column(
          children: [
            // Header "Retour"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _rhSubCategory = null; // Retour au menu
                        _selectedEntity = null; // On vide la zone 3
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(_rhSubCategory!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // La Liste Dynamique
            Expanded(child: _buildSubCategoryList()),
          ],
        );
      }
    }

    // Si on est sur l'onglet "Plus"
    if (_selectedTab == 4) {

      // NIVEAU 1 : LE MENU RACINE
      if (_plusSubCategory == null) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            const Padding(padding: EdgeInsets.only(left: 16, bottom: 10), child: Text("CENTRE D'ADMINISTRATION", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
            
            // 1. Les Litiges (Anciennement l'onglet support complet)
            _buildSettingsMenuItem("Gestion des Litiges", Icons.support_agent, Colors.red, 'tickets'),
            
            // 2. La FAQ (Contenu éditorial)
            _buildSettingsMenuItem("Foire aux Questions (FAQ)", Icons.help_outline, Colors.blue, 'faq'),
            
            const Divider(height: 30),
            const Padding(padding: EdgeInsets.only(left: 16, bottom: 10), child: Text("CONFIGURATION", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),

            // 3. Paramètres
            _buildSettingsMenuItem("Paramètres", Icons.settings, Colors.grey, 'settings'),
            
            // 4. À propos
            _buildSettingsMenuItem("Mentions Légales", Icons.info_outline, Colors.grey, 'about'),
          ],
        );
      } 
      
      // NIVEAU 2 : LA SOUS-LISTE
      else {
        return Column(
          children: [
            // Header Retour
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _plusSubCategory = null;
                        _selectedEntity = null; // Reset sélection
                        _selectedTicket = null; // Reset ticket si on vient de là
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(_getPlusTitle(_plusSubCategory!), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Contenu de la liste
            Expanded(child: _buildPlusSubList()),
          ],
        );
      }

    }

    // Si on est sur l'onglet "Comptes utilisateur"
    if (_selectedTab == 5) return const Center(child: Text("Compte Utilisateur")); // Placeholder

    // Par défaut (Onglet 1 - Trajets), on affiche les trajets
    return FutureBuilder<List<TripAd>>(
      future: MockDataService.getTrips(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 70),
          itemBuilder: (context, index) {
            final trip = snapshot.data![index];
            final isSelected = _selectedTrip?.id == trip.id;

            return InkWell(
              onTap: () {
                setState(() => _selectedTrip = trip);
              },
              hoverColor: (isSelected && !isMobile) ? const Color(0xFFE3F2FD) : Colors.white, // Bleu très clair si sélectionné
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // AVATAR
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
                      child: const Icon(Icons.route, color: UGOAdminTheme.primaryBlue),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(trip.route.fullRoute, style: UGOAdminTheme.titleStyle.copyWith(fontSize: 15)),
                              Text("14:30", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Chauffeur: ${trip.driverName}", style: UGOAdminTheme.subTitleStyle),
                              // BADGE NOTIFICATION ORANGE/OR
                              if (trip.statut == 'programmé')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: UGOAdminTheme.gold, borderRadius: BorderRadius.circular(4)),
                                  child: const Text("NEW", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
 
  Widget _buildKpiTile(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .05), blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  // Liste des options de l'onglet "Groupes"
  Widget _buildGroupsMenuItem(String title, IconData icon, Color color, String categoryKey) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () => setState(() => _rhSubCategory = categoryKey),
    );
  }

  
  // Liste des options de l'onglet "Plus"
  Widget _buildSettingsMenuItem(String title, IconData icon, Color color, String categoryKey) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: .1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: () => setState(() => _plusSubCategory = categoryKey),
    );
  }


  String _getPlusTitle(String key) {
    switch (key) {
      case 'tickets': return "LITIGES EN COURS";
      case 'faq': return "ÉDITEUR FAQ";
      case 'settings': return "PARAMÈTRES";
      default: return "";
    }
  }


  Widget _buildPlusSubList() {
    
    switch (_plusSubCategory) {
      // CAS 1 : LITIGES (On réutilise votre code précédent pour les tickets)
      case 'tickets': 
        return FutureBuilder<List<MockTicket>>(
          future: MockDataService.getTickets(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (c, i) => const Divider(indent: 70),
              itemBuilder: (context, index) {
                final t = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: t.status == 'ouvert' ? Colors.red[100] : Colors.grey[200], child: Icon(Icons.confirmation_number, size: 16, color: t.status == 'ouvert' ? Colors.red : Colors.grey)),
                  title: Text(t.sujet),
                  subtitle: Text(t.userName),
                  selected: _selectedEntity == t, // On utilise _selectedEntity maintenant
                  selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
                  onTap: () => setState(() => _selectedEntity = t),
                );
              },
            );
          },
        );

      // CAS 2 : FAQ
      case 'faq':
        return FutureBuilder<List<MockFAQ>>(
          future: MockDataService.getFAQs(),
          builder: (context, snapshot) {
             if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
             return ListView.separated(
               itemCount: snapshot.data!.length,
               separatorBuilder: (c, i) => const Divider(indent: 0),
               itemBuilder: (context, index) {
                 final f = snapshot.data![index];
                 return ListTile(
                   title: Text(f.question, maxLines: 1, overflow: TextOverflow.ellipsis),
                   trailing: Icon(Icons.circle, size: 8, color: f.isPublished ? Colors.green : Colors.grey),
                   selected: _selectedEntity == f,
                   selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
                   onTap: () => setState(() => _selectedEntity = f),
                 );
               },
             );
          }
        );

      // CAS 3 : SETTINGS (Liste statique)
      case 'settings':
        return ListView(
          children: [
            ListTile(title: const Text("Notifications"), leading: const Icon(Icons.notifications), onTap: () => setState(() => _selectedEntity = "notif")),
            ListTile(title: const Text("Taxes & Commissions"), leading: const Icon(Icons.percent), onTap: () => setState(() => _selectedEntity = "tax")),
          ],
        );
        
      default: return const Center(child: Text("Section en construction"));
    }
  }


  // Le Switch qui décide quelle liste afficher
  Widget _buildSubCategoryList() {
    switch (_rhSubCategory) {
      case 'drivers': return _buildDriversList(false); // On réutilise votre fonction existante
      case 'passengers': return _buildPassengersList();
      case 'admins': return _buildAdminsList();
      case 'support': return const Center(child: Text("Liste Agents Support (Vide pour démo)"));
      default: return const SizedBox();
    }
  }


  // --- LISTE DES CHAUFFEURS ---
  Widget _buildDriversList(bool isMobile) {
    return FutureBuilder<List<MockDriver>>(
      future: MockDataService.getDrivers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (c, i) => const Divider(indent: 70),
          itemBuilder: (context, index) {
            final driver = snapshot.data![index];
            final isPending = driver.status == 'en_attente';
            
            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: isPending ? UGOAdminTheme.accentOrange.withValues(alpha: .2) : UGOAdminTheme.primaryBlue.withValues(alpha: 0.1),
                    child: Text(driver.nom[0], style: TextStyle(color: isPending ? UGOAdminTheme.accentOrange : UGOAdminTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                  if (isPending)
                    const Positioned(bottom: 0, right: 0, child: Icon(Icons.warning, size: 14, color: UGOAdminTheme.accentOrange))
                ],
              ),
              title: Text(driver.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${driver.telephone} • ${driver.status.toUpperCase()}", style: const TextStyle(fontSize: 12)),
              onTap: () {
                setState(() {
                  _selectedEntity = driver;
                });
              },
              
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              selected: _selectedEntity?.id == driver.id, 
              selectedTileColor: UGOAdminTheme.primaryBlue,
            );
          },
        );
      },
    );
  }

  Widget _buildPassengersList() {
    return FutureBuilder<List<MockPassenger>>(
      future: MockDataService.getPassengers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (c, i) => const Divider(indent: 70),
          itemBuilder: (ctx, i) {
            final p = snapshot.data![i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange[100], 
                foregroundColor: Colors.orange[800],
                child: Text(p.nom[0])
              ),
              title: Text(p.nom),
              subtitle: Text("${p.totalTrajets} trajets • ${p.statut}"),
              selected: _selectedEntity == p,
              selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
              onTap: () => setState(() => _selectedEntity = p),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminsList() {
    return FutureBuilder<List<MockAdminUser>>(
      future: MockDataService.getAdmins(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (c, i) => const Divider(indent: 70),
          itemBuilder: (ctx, i) {
            final a = snapshot.data![i];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red, 
                foregroundColor: Colors.white,
                child: Icon(Icons.security, size: 16), 
              ),
              title: Text(a.nom),
              subtitle: Text(a.role),
              selected: _selectedEntity == a,
              selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
              onTap: () => setState(() => _selectedEntity = a),
            );
          },
        );
      },
    );
  }


}