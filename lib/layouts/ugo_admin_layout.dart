import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';
import 'package:ugo_pro/data/models/trip_ad.dart';
import '../data/services/mock_data_service.dart';
import '../data/models/mocks/mock_admin_user.dart';
import '../data/models/mocks/mock_driver.dart';
import '../data/models/mocks/mock_faq.dart';
import '../data/models/mocks/mock_passenger.dart';
import '../data/models/mocks/mock_ticket.dart';
import '../data/models/mocks/mock_transaction.dart';

class UGOAdminLayout extends StatefulWidget {
  const UGOAdminLayout({super.key});

  @override
  State<UGOAdminLayout> createState() => _UGOAdminLayoutState();
}

class _UGOAdminLayoutState extends State<UGOAdminLayout> {
  
  // 0 = Dashboard, 1 = Annonces, 2 = Groupes, 3 = Finance, 4 = Plus, 5 = Compte & Paramètres
  int _selectedTab = 0; 

  // L'élément sélectionné dans la liste (pour l'affichage à droite)
  TripAd? _selectedTrip;

  // L'élément sélectionné dans la liste des plaintes (pour l'affichage à droite)
  MockTicket? _selectedTicket;

  // L'élément sélectionné dans la liste des transactions (pour l'affichage à droite)
  MockTransaction? _selectedTransaction;

  // Gestion de la sous-navigation dans l'onglet RH (Index 2)
  String? _rhSubCategory; // null = Menu principal, 'drivers', 'passengers', 'support', 'admins'

 // Gestion sous-menu "Plus" (Index 4)
  String? _plusSubCategory; // 'tickets', 'faq', 'settings', 'about'

  // Élément sélectionné pour la Zone 3 (On utilise dynamic pour gérer tous les types)
  dynamic _selectedEntity;

  @override
  void initState() {
    super.initState();
    // On charge une donnée par défaut pour la démo PC
    MockDataService.getTrips().then((trips) {
      if (trips.isNotEmpty) setState(() => _selectedTrip = trips.first);
    });
  }

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
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // ZONE 1 : BARRE DE NAVIGATION (Gauche)
                    Container(
                      width: 60,
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildNavIcon(Icons.dashboard_outlined, 0),
                          _buildNavIcon(Icons.assignment_outlined, 1),
                          _buildNavIcon(Icons.groups_outlined, 2),
                          _buildNavIcon(Icons.payments_outlined, 3),
                          _buildNavIcon(Icons.more_horiz_outlined, 4),
                          const Spacer(),
                          const Divider(),
                          _buildNavIcon(Icons.account_circle_outlined, 5),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.grey), // Séparateur fin

                    // ZONE 2 : LA LISTE
                    Container(
                      width: 350,
                      color: Colors.white,
                      child: Column(
                        children: [
                          // Header de la liste
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: const Color(0xFFF5F5F5), // Gris très clair
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(_getTitle(_selectedTab), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: UGOAdminTheme.primaryBlue)),
                                const Spacer(),
                                // C'est ici qu'on ajoute les actions
                                IconButton(icon: const Icon(Icons.filter_list, color: Colors.grey), onPressed: (){}),
                                
                                // Si on est sur l'onglet FINANCE (3)
                                if (_selectedTab == 3)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: UGOAdminTheme.accentOrange, size: 28),
                                    tooltip: "Nouvelle transaction",
                                    onPressed: () => _showAddTransactionDialog(context),
                                  ),
                                
                                // Si on est sur l'onglet TRAJETS (1) (Votre ancien bouton)
                                if (_selectedTab == 1)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, color: UGOAdminTheme.accentOrange, size: 28),
                                    onPressed: () => _showAddTripDialog(context),
                                  ),
                                // --------------------
                              ],
                            ),
                          ),
                          // Barre de recherche
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Rechercher...",
                                prefixIcon: const Icon(Icons.search, size: 20, color: UGOAdminTheme.primaryBlue),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                filled: true,
                                fillColor: const Color(0xFFF0F2F5),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: UGOAdminTheme.primaryBlue, width: 1)),
                              ),
                            ),
                          ),
                          Expanded(child: _buildListPanel(isMobile: false)),
                        ],
                      ),
                    ),

                    // ZONE 3 : DÉTAILS
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: UGOAdminTheme.detailBg, // Fond bleu pâle
                          // image: DecorationImage(...) // Vous pourrez mettre votre logo en filigrane ici
                        ),
                        child: _buildRightPanelContent(), // <--- Nouvelle méthode intelligente
                        
                      ),
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


  String _getTitle(int index) {
    switch (index) {
      case 0: return "Tableau de Bord";
      case 1: return "Trajets";
      case 2: return "Utilisateurs";
      case 3: return "Transactions";
      case 4: return "Autres";
      case 5: return "Compte & Paramètres";
      default: return "Admin";
    }
  }

  String _getPlusTitle(String key) {
    switch (key) {
      case 'tickets': return "LITIGES EN COURS";
      case 'faq': return "ÉDITEUR FAQ";
      case 'settings': return "PARAMÈTRES";
      default: return "";
    }
  }


  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedTab == index;
    return Container(
      decoration: isSelected ? const BoxDecoration(
        border: Border(left: BorderSide(color: UGOAdminTheme.accentOrange, width: 4)) // Marqueur ORANGE à gauche
      ) : null,
      child: IconButton(
        icon: Icon(icon),
        // Icône BLEUE si sélectionnée, grise sinon
        color: isSelected ? UGOAdminTheme.primaryBlue : Colors.grey, 
        iconSize: 26,
        onPressed: () => setState(() => _selectedTab = index),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  // --- LISTE (Zone 2 et affichage mobile) ---
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

    // Si on est sur l'onglet "Transactions"
    if (_selectedTab == 3) {
      return FutureBuilder<List<MockTransaction>>(
        future: MockDataService.getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (c, i) => const Divider(indent: 70, height: 1),
            itemBuilder: (context, index) {
              final tx = snapshot.data![index];
              final isPositive = tx.montant > 0;
              final isPending = tx.statut == 'en_attente';
              
              return ListTile(
                selected: _selectedTransaction == tx,
                selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: .1),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange.withValues(alpha: .1) : (isPositive ? Colors.green.withValues(alpha: .1) : Colors.red.withValues(alpha: .1)),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Icon(
                    isPending ? Icons.hourglass_empty : (isPositive ? Icons.arrow_downward : Icons.arrow_upward),
                    color: isPending ? Colors.orange : (isPositive ? Colors.green : Colors.red),
                    size: 20
                  ),
                ),
                title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("${tx.date.hour}:${tx.date.minute} • ${tx.operateur}", style: const TextStyle(fontSize: 11)),
                trailing: Text(
                  "${isPositive ? '+' : ''}${tx.montant.toInt()} F",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isPositive ? Colors.green[700] : Colors.red[700]
                  ),
                ),
                onTap: () => setState(() => _selectedTransaction = tx),
              );
            },
          );
        },
      );
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

  Widget _buildTransactionReceipt() {
    final tx = _selectedTransaction!;
    final isPending = tx.statut == 'en_attente';

    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 20, offset: const Offset(0, 10))]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(tx.montant > 0 ? "+${tx.montant} FCFA" : "${tx.montant} FCFA", 
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: tx.montant > 0 ? Colors.green : Colors.black)),
            Text(tx.statut.toUpperCase(), style: TextStyle(color: isPending ? Colors.orange : Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 30),
            const Divider(),
            _rowDetail("Référence", tx.id),
            _rowDetail("Opérateur", tx.operateur),
            _rowDetail("Date", "${tx.date.day}/${tx.date.month} à ${tx.date.hour}:${tx.date.minute}"),
            _rowDetail("Motif", tx.description),
            const Divider(),
            const SizedBox(height: 20),
            
            if (isPending && tx.type == 'payout_out')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    await MockDataService.approvePayout(tx.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paiement validé et envoyé !")));
                  },
                  child: const Text("VALIDER LE VIREMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            else
              TextButton.icon(
                onPressed: () => setState(() => _selectedTransaction = null), 
                icon: const Icon(Icons.close), 
                label: const Text("Fermer le reçu")
              )
          ],
        ),
      ),
    );
  }

  // Affichage Zone 3
  Widget _buildRightPanelContent() {
    
    // Si on est sur l'onglet Tableau de bord (0)
    if (_selectedTab == 0) return _buildDashboardDetailsPanel();

    // Si on est sur l'onglet Trajets (1)
    if (_selectedTab == 1) {
      if (_selectedTrip == null) return const Center(child: Text("Sélectionnez un trajet"));
      return _buildTripDetailsPanel(); // Votre ancienne méthode pour les trajets
    }
    
    // Si on est sur l'onglet Groupes (2)
    if (_selectedTab == 2) {
      
      if (_selectedEntity == null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            const Text("Sélectionnez une catégorie puis une personne", style: TextStyle(color: Colors.grey)),
          ],
        );
      }
      
      // Détection du type d'objet pour afficher la bonne vue
      if (_selectedEntity is MockDriver) return _buildDriverDetailsPanel(); // (Votre ancienne fonction, adapter pour utiliser _selectedEntity)
      
      if (_selectedEntity is MockPassenger) return _buildPassengerDetailsPanel();
      
      // if (_selectedEntity is MockAdminUser) return _buildAdminDetailsPanel();
      
      if (_selectedEntity) return const Center(child: Text("Sélectionnez un chauffeur pour voir son dossier"));
      
      return _buildDriverDetailsPanel(); // <--- La nouvelle méthode ci-dessous
    }
    
    // Si on est sur l'onglet Transactions (3)
    if (_selectedTab == 3) {
      if (_selectedTransaction != null) return _buildTransactionReceipt();
      return _buildGlobalWalletView();
    }

    // Si on est sur l'onglet Plus (4)
    if (_selectedTab == 4) {
      if (_selectedEntity == null) return const Center(child: Text("Sélectionnez un élément dans le menu"));
      
      // Si c'est un Ticket (Litige) -> On affiche le Chat
      if (_selectedEntity is MockTicket) {
         _selectedTicket = _selectedEntity; // Hack pour réutiliser votre ancienne vue
         return _buildTicketDetailsPanel(); 
      }

      // Si c'est une FAQ -> On affiche l'éditeur
      if (_selectedEntity is MockFAQ) return _buildFAQEditor();

      // Si c'est un String (Settings)
      if (_selectedEntity is String) return const Center(child: Text("Panneau de configuration (Simulé)"));
    }

    if (_selectedTab == 5) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.account_circle, size: 100, color: Colors.grey),
              SizedBox(height: 15),
              Text(
                "Compte & Paramètres",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text("Gérez votre compte et vos paramètres selon vos besoins."),
            ],
          ),
        ); // Placeholder
    }


    return const Center(child: Text("Sélectionnez un élément"));
  }

  // --- DÉTAIL ---
  Widget _buildTripDetailsPanel() {

    return Column(
      children: [
        // Header Détail
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Row(
            children: [
              Text("Détail du trajet #${_selectedTrip!.id}", style: UGOAdminTheme.titleStyle),
              const Spacer(),
              // Actions principales en ORANGE
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UGOAdminTheme.accentOrange,
                  foregroundColor: Colors.white,
                  elevation: 0
                ),
                onPressed: (){}, 
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Gérer")
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UGOAdminTheme.accentOrange,
                  foregroundColor: Colors.white,
                  elevation: 0
                ),
                onPressed: () => _showAddTripDialog(context), 
                icon: const Icon(Icons.add_road, size: 16),
                label: const Text("Ajouter un trajet")
              )
            ],
          ),
        ),
        const Divider(height: 1),

        // Contenu Scrollable
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // CARTE D'INFO PRINCIPALE (Bleu clair)
              _buildInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: UGOAdminTheme.primaryBlue),
                        const SizedBox(width: 10),
                        Text("Informations Générales", style: UGOAdminTheme.titleStyle.copyWith(color: UGOAdminTheme.primaryBlue)),
                      ],
                    ),
                    const Divider(height: 20, color: Colors.blueAccent),
                    _rowDetail("Départ", _selectedTrip!.route.depart),
                    _rowDetail("Arrivée", _selectedTrip!.route.arrivee),
                    _rowDetail("Prix", "${_selectedTrip!.prix} F. CFA", isBold: true),
                  ],
                ),
                color: Colors.white
              ),

              const SizedBox(height: 15),

              // CARTE STATUS (Avec accent OR)
              _buildInfoCard(
                child: Row(
                  children: [
                    const Text("Statut Actuel : ", style: TextStyle(fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedTrip!.statut == 'annulé' ? Colors.red[100] : UGOAdminTheme.gold.withValues(alpha: .3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _selectedTrip!.statut == 'annulé' ? Colors.red : UGOAdminTheme.gold)
                      ),
                      child: Text(
                        _selectedTrip!.statut.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: _selectedTrip!.statut == 'annulé' ? Colors.red : Colors.black87
                        )
                      ),
                    ),
                  ],
                ),
                color: Colors.white
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required Widget child, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
      ),
      child: child,
    );
  }

  Widget _rowDetail(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDriverDetailsPanel() {
    final d = _selectedEntity!;
    final bool isPending = d.status == 'en_attente';

    return Column(
      children: [
        // --- HEADER DU PROFIL ---
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isPending ? UGOAdminTheme.accentOrange : UGOAdminTheme.primaryBlue,
                child: Text(d.nom[0], style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.nom, style: UGOAdminTheme.titleStyle.copyWith(fontSize: 22)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? UGOAdminTheme.gold : (d.status == 'validé' ? Colors.green[100] : Colors.red[100]),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(d.status.toUpperCase(), 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, 
                        color: isPending ? Colors.black : (d.status == 'validé' ? Colors.green[800] : Colors.red[800]))),
                  )
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // --- INFOS DÉTAILLÉES ---
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildInfoCard(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Informations Personnelles", style: TextStyle(color: UGOAdminTheme.primaryBlue, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _rowDetail("Téléphone", d.telephone, isBold: true),
                    _rowDetail("Date inscription", "${d.dateInscription.day}/${d.dateInscription.month}/${d.dateInscription.year}"),
                  ],
                )
              ),
              const SizedBox(height: 15),
              _buildInfoCard(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Véhicule & Permis", style: TextStyle(color: UGOAdminTheme.primaryBlue, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _rowDetail("Type de Permis", d.permisType),
                    _rowDetail("Matricule Véhicule", d.matriculeVehicule, isBold: true),
                    const SizedBox(height: 10),
                    // Simulation d'une photo de permis
                    Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, color: Colors.grey),
                          Text("Photo du Permis (Simulée)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    )
                  ],
                )
              ),
            ],
          ),
        ),

        // --- BARRE D'ACTIONS ---
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              // Bouton SUPPRIMER (Poubelle)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: "Supprimer définitivement",
                onPressed: () => _confirmDeleteDriver(d),
              ),
              const Spacer(),
              
              // Bouton MODIFIER (Gris)
              OutlinedButton(
                onPressed: () {
                  // TODO: Ouvrir popup d'édition (similaire à ajout trajet)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Module d'édition en cours...")));
                },
                child: const Text("Modifier"),
              ),
              const SizedBox(width: 10),

              // Boutons de DÉCISION (Si en attente)
              if (isPending) ...[
                // REFUSER
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  onPressed: () async {
                    d.status = 'refusé'; // Mise à jour locale
                    setState(() {});
                  },
                  child: const Text("Refuser"),
                ),
                const SizedBox(width: 10),
                // VALIDER
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () async {
                    await MockDataService.validateDriver(d.id);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chauffeur validé et activé !")));
                  },
                  child: const Text("Valider"),
                ),
              ] else 
                // Si déjà traité
                const Text("Dossier clôturé", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTicketDetailsPanel() {
    final t = _selectedTicket!;
    
    return Column(
      children: [
        // HEADER TICKET
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Ticket #${t.id}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: t.priority == 'haute' ? Colors.red : Colors.blue, borderRadius: BorderRadius.circular(4)),
                        child: Text(t.priority.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(t.sujet, style: UGOAdminTheme.titleStyle.copyWith(fontSize: 18)),
                ],
              ),
              const Spacer(),
              // ACTIONS RAPIDES UTILISATEUR
              Tooltip(
                message: "Voir profil utilisateur",
                child: IconButton(icon: const Icon(Icons.person_search, color: UGOAdminTheme.primaryBlue), onPressed: (){}),
              ),
              Tooltip(
                message: "Bannir cet utilisateur",
                child: IconButton(
                  icon: const Icon(Icons.block, color: Colors.red), 
                  onPressed: () => _showBanDialog(context, t.userName)
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ZONE DE CHAT SIMULÉE
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: t.messages.length,
            itemBuilder: (ctx, i) {
              // On alterne pour faire semblant (Pair = User, Impair = Admin)
              // Dans la vraie vie, l'objet message aurait un 'senderId'
              final isMe = i % 2 != 0; 
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    color: isMe ? UGOAdminTheme.bubbleSelf : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 2, offset: const Offset(0, 1))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.messages[i], style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(isMe ? "Admin (Vous)" : t.userName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ZONE DE RÉPONSE ET CLÔTURE
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Suggestions de réponses (Gain de temps pour l'admin)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickReply("Désolé pour ce désagrément."),
                    _buildQuickReply("Nous contactons le chauffeur."),
                    _buildQuickReply("Remboursement effectué."),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Écrire une réponse...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton.small(
                    backgroundColor: UGOAdminTheme.primaryBlue,
                    onPressed: (){}, 
                    child: const Icon(Icons.send, color: Colors.white)
                  ),
                  const SizedBox(width: 10),
                  // BOUTON CLÔTURER
                  if (t.status != 'fermé')
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        // Action de fermeture mockée
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ticket clôturé et archivé.")));
                        // Mise à jour visuelle locale
                        // setState(() => t.status = 'fermé'); 
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text("Résolu")
                    )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPassengerDetailsPanel() {
    final MockPassenger passenger = _selectedEntity;
    final bool isBlocked = passenger.statut == 'bloqué';

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Row(
            children: [
              CircleAvatar(radius: 36, backgroundColor: Colors.orange, child: Text(passenger.nom[0], style: const TextStyle(fontSize: 30, color: Colors.white))),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(passenger.nom, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: UGOAdminTheme.primaryBlue)),
                  Text("Client fidèle", style: TextStyle(color: Colors.grey[600])),
                ],
              )
            ],
          ),
        ),
        const Divider(height: 1),
        
        // Infos
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildInfoCard(
                color: Colors.white,
                child: Column(
                  children: [
                    _rowDetail("Téléphone", passenger.telephone, isBold: true),
                    _rowDetail("Nombre de voyages", "${passenger.totalTrajets}"),
                    _rowDetail("Dernier voyage", "Abidjan - Bouaké (Hier)"),
                    _rowDetail("Statut Compte", passenger.statut.toUpperCase(), isBold: true),
                  ],
                )
              ),
            ],
          ),
        ),

        // BARRE D'ACTIONS (Bannir, Contacter, etc.)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: (){}, // Ouvrirait l'historique complet
                icon: const Icon(Icons.history),
                label: const Text("Historique"),
              ),
              const SizedBox(width: 10),
              if (!isBlocked)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.block, color: Colors.white),
                  label: const Text("Bloquer", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                     // Action bloquer
                     setState(() => passenger.statut = 'bloqué');
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${passenger.nom} a été bloqué")));
                  },
                )
              else
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text("Débloquer", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                     setState(() => passenger.statut = 'actif');
                  },
                )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildQuickReply(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.grey[50],
        onPressed: () {
          // Remplirait le champ texte en vrai
        },
      ),
    );
  }

  Widget _buildDashboardDetailsPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.insights, color: UGOAdminTheme.primaryBlue, size: 30),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Performance de la Plateforme", style: UGOAdminTheme.titleStyle.copyWith(fontSize: 20)),
                  const Text("Vue d'ensemble sur les 7 derniers jours", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.download), 
                label: const Text("Exporter Rapport")
              )
            ],
          ),
        ),
        const Divider(height: 1),

        // Contenu Scrollable
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(30),
            children: [
              // GRAPHIQUE SIMULÉ (Barres)
              _buildInfoCard(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Évolution des Ventes (Billets)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar("Lun", 0.4),
                          _buildBar("Mar", 0.6),
                          _buildBar("Mer", 0.5),
                          _buildBar("Jeu", 0.8),
                          _buildBar("Ven", 0.9),
                          _buildBar("Sam", 0.7),
                          _buildBar("Dim", 0.5, isToday: true),
                        ],
                      ),
                    )
                  ],
                )
              ),

              const SizedBox(height: 20),

              // DUAL CARDS (Notifications & Activité)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte Notifications
                  Expanded(
                    child: _buildInfoCard(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.notifications_none, color: UGOAdminTheme.accentOrange),
                            SizedBox(width: 10),
                            Text("Dernières Alertes", style: TextStyle(fontWeight: FontWeight.bold))
                          ]),
                          const Divider(height: 30),
                          _buildNotifItem("Chauffeur 'Bamba' a annulé TR-005"),
                          _buildNotifItem("Nouvelle inscription : Diallo M."),
                          _buildNotifItem("Pic de trafic détecté sur Abidjan"),
                        ],
                      )
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Carte État du système
                  Expanded(
                    child: _buildInfoCard(
                      color: UGOAdminTheme.primaryBlue, // Fond bleu pour changer
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.dns, color: Colors.white),
                            SizedBox(width: 10),
                            Text("État du Système", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                          ]),
                          Divider(height: 30, color: Colors.white24),
                          Text("Serveur API : EN LIGNE", style: TextStyle(color: Colors.white)),
                          SizedBox(height: 10),
                          Text("Base de données : CONNECTÉE", style: TextStyle(color: Colors.white)),
                          SizedBox(height: 10),
                          Text("SMS Gateway : ACTIF (Solde: 84%)", style: TextStyle(color: Colors.white)),
                        ],
                      )
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // Helpers pour le graphique et notifs
  Widget _buildBar(String label, double pct, {bool isToday = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * pct,
          decoration: BoxDecoration(
            color: isToday ? UGOAdminTheme.accentOrange : UGOAdminTheme.primaryBlue.withValues(alpha: .3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: isToday ? UGOAdminTheme.accentOrange : Colors.grey)),
      ],
    );
  }

  Widget _buildNotifItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
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

  Widget _buildFAQEditor() {
    final MockFAQ f = _selectedEntity;
    final TextEditingController qCtrl = TextEditingController(text: f.question);
    final TextEditingController rCtrl = TextEditingController(text: f.reponse);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.edit_note, size: 30, color: UGOAdminTheme.primaryBlue),
              const SizedBox(width: 15),
              const Text("Éditer la Question", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Switch(value: f.isPublished, onChanged: (v) => setState(() => f.isPublished = v)),
              const Text("En ligne")
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Question", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(controller: qCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
                const SizedBox(height: 20),
                const Text("Réponse", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: rCtrl, 
                    maxLines: 10, 
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Écrivez la réponse ici...")
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: UGOAdminTheme.primaryBlue),
                    onPressed: () {
                      f.question = qCtrl.text;
                      f.reponse = rCtrl.text;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("FAQ mise à jour !")));
                    }, 
                    child: const Text("ENREGISTRER LES MODIFICATIONS", style: TextStyle(color: Colors.white))
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGlobalWalletView() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [UGOAdminTheme.primaryBlue, Color(0xFF1E88E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Solde Disponible", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 10),
              const Text("2 450 000 FCFA", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildWalletBadge(Icons.call_made, "Entrées: +3.2M", Colors.greenAccent),
                  const SizedBox(width: 15),
                  _buildWalletBadge(Icons.call_received, "Sorties: -750k", Colors.orangeAccent),
                ],
              )
            ],
          ),
        ),
        
        // Actions
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("ACTIONS RAPIDES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              _buildActionCard(Icons.account_balance, "Virement Bancaire", "Transférer vers NSIA Banque"),
              const SizedBox(height: 10),
              _buildActionCard(Icons.payments, "Payer les Commissions", "Générer les paiements partenaires"),
              
              const SizedBox(height: 30),
              // Alerte visuelle pour démo
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: .3))),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 15),
                    const Expanded(child: Text("3 demandes de retrait de chauffeurs sont en attente de validation depuis plus de 2h.")),
                    TextButton(onPressed: (){}, child: const Text("Voir"))
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWalletBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, color: color, size: 14), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))]),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String sub) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: UGOAdminTheme.primaryBlue.withValues(alpha: .1), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: UGOAdminTheme.primaryBlue)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _confirmDeleteDriver(MockDriver deletingDriver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer ce chauffeur ?"),
        content: Text("Êtes-vous sûr de vouloir supprimer ${deletingDriver.nom} ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await MockDataService.deleteDriver(deletingDriver.id);
              setState(() {
                _selectedEntity = null; // On désélectionne car il n'existe plus
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chauffeur supprimé.")));
            }, 
            child: const Text("Supprimer", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // 👉 Intégration : Reliez cette fonction au bouton + (ou IconButton) 
  // dans la colonne du milieu de votre layout (ZONE 2).
  // --- ACTION : AJOUTER UN TRAJET ---
  void _showAddTripDialog(BuildContext context) {
    String depart = "Abidjan";
    String arrivee = "Bouaké";
    String prix = "5000";
    String chauffeur = "Koné Moussa";
    DateTime date = DateTime.now().add(const Duration(days: 1));
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Planifier un trajet", style: TextStyle(color: UGOAdminTheme.primaryBlue)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                  Expanded(child: _buildSimpleInput("Départ", (v) => depart = v, "Abidjan")),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.arrow_forward, color: Colors.grey)),
                  Expanded(child: _buildSimpleInput("Arrivée", (v) => arrivee = v, "Bouaké")),
              ]),
              const SizedBox(height: 15),
              _buildSimpleInput("Chauffeur", (v) => chauffeur = v, "Koné Moussa"),
              const SizedBox(height: 15),
              _buildSimpleInput("Prix (FCFA)", (v) => prix = v, "5000"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UGOAdminTheme.accentOrange, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx); // Fermer d'abord
              
              // Création de l'objet
              final newTrip = TripAd(
                "TR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}", 
                "B-557-XYZ",
                chauffeur,
                Ligne(depart: depart, arrivee: arrivee),
                "", 
                Appointment(date: date, time: time), 
                [],
                4,
                int.tryParse(prix) ?? 5000,
                0.0,
                "programmé",
                0,
                []
              );
              
              await MockDataService.addTrip(newTrip); // Ajout mocké
              setState(() {}); // Rafraîchissement global
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Trajet publié avec succès"), backgroundColor: UGOAdminTheme.primaryBlue)
              );
            },
            child: const Text("Publier"),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: const [Icon(Icons.warning, color: Colors.red), SizedBox(width: 10), Text("Bannir l'utilisateur")]),
        content: Text("Voulez-vous vraiment bloquer l'accès de $userName à l'application ?\nIl ne pourra plus réserver de billets."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$userName a été bloqué(e)."), backgroundColor: Colors.red));
            },
            child: const Text("CONFIRMER LE BLOCAGE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    // Variables locales
    bool isExpense = false; // False = Entrée (Vert), True = Sortie (Rouge)
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    final TextEditingController phoneCtrl = TextEditingController();
    
    String selectedOperator = "Espèces"; // Par défaut
    bool isProcessing = false; // Pour l'effet de chargement

    // Liste des opérateurs avec leurs couleurs
    final List<Map<String, dynamic>> operators = [
      {'name': 'Espèces', 'color': Colors.green, 'icon': Icons.money},
      {'name': 'Wave', 'color': const Color(0xFF1DC4FF), 'icon': Icons.waves}, // Bleu Wave
      {'name': 'Orange Money', 'color': const Color(0xFFFF7900), 'icon': Icons.circle}, // Orange OM
      {'name': 'MTN MoMo', 'color': const Color(0xFFFFCC00), 'icon': Icons.mobile_friendly}, // Jaune MTN
    ];

    showDialog(
      context: context,
      barrierDismissible: false, // On oblige à attendre ou annuler
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final themeColor = isExpense ? Colors.red : Colors.green;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(isExpense ? Icons.output : Icons.input, color: themeColor),
                  const SizedBox(width: 10),
                  Text(isExpense ? "Émettre un Paiement" : "Encaisser", style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: isProcessing 
                ? _buildProcessingView(selectedOperator) // VUE CHARGEMENT
                : Column( // VUE FORMULAIRE
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TYPE (Entrée / Sortie)
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          _buildTabButton("ENTRÉE (+)", !isExpense, Colors.green, () => setModalState(() => isExpense = false)),
                          _buildTabButton("SORTIE (-)", isExpense, Colors.red, () => setModalState(() => isExpense = true)),
                        ],
                      ),
                    ),

                    // 2. SÉLECTEUR OPÉRATEUR (VISUEL)
                    const Text("Choisir l'opérateur", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: operators.map((op) {
                        final isSelected = selectedOperator == op['name'];
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedOperator = op['name']),
                          child: Column(
                            children: [
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: op['name'] == 'Espèces' ? Colors.green.shade100 : op['color'].withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: op['color'], width: 3) : null,
                                ),
                                child: Icon(op['icon'], color: op['color']),
                              ),
                              const SizedBox(height: 5),
                              Text(op['name'], style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // 3. CHAMPS DE SAISIE
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Montant (F. CFA)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Champ téléphone conditionnel (Seulement si Mobile Money)
                    if (selectedOperator != 'Espèces')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Numéro $selectedOperator du client",
                            hintText: "ex: 07 08 09 10 11",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.phone_android),
                          ),
                        ),
                      ),

                    TextFormField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: "Motif de la transaction",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
              actions: isProcessing ? null : [ // Cacher les boutons pendant le chargement
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: () async {
                    if (amountCtrl.text.isEmpty) return;

                    // DÉCLENCHER LA SIMULATION DE PAIEMENT
                    setModalState(() => isProcessing = true);

                    // Simulation d'attente API (2 secondes)
                    await Future.delayed(const Duration(seconds: 2));

                    // Création réelle
                    double amount = double.parse(amountCtrl.text);
                    if (isExpense) amount = -amount;

                    final newTx = MockTransaction(
                      "PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}", 
                      isExpense ? 'manual_expense' : 'manual_income', 
                      descCtrl.text.isEmpty ? "Paiement $selectedOperator" : descCtrl.text, 
                      amount, 
                      selectedOperator, 
                      DateTime.now(), 
                      'succès'
                    );

                    await MockDataService.addTransaction(newTx);
                    
                    if (context.mounted) {
                      Navigator.pop(ctx); // Fermer la popup
                      setState(() {}); // Rafraîchir la liste principale
                      
                      // Message de succès personnalisé
                      String msg = isExpense 
                          ? "Transfert $selectedOperator envoyé avec succès !" 
                          : "Paiement $selectedOperator reçu avec succès !";
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), backgroundColor: Colors.green)
                      );
                    }
                  },
                  child: Text(
                    isExpense ? "ENVOYER LE PAIEMENT" : "LANCER L'ENCAISSEMENT", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Petit helper pour les boutons Entrée/Sortie
  Widget _buildTabButton(String label, bool isActive, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : null
          ),
          child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? color : Colors.grey))),
        ),
      ),
    );
  }

  // Vue de chargement pendant le "Paiement"
  Widget _buildProcessingView(String operator) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text("Connexion à $operator...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          const Text("Envoi de la requête USSD en cours...", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          const Text("Veuillez patienter", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSimpleInput(String label, Function(String) onChange, String initial) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.all(12)),
      onChanged: onChange,
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

}