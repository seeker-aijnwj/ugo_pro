import 'package:flutter/material.dart';
import '../screens/desktop/admin_dashboard_screen.dart';
import 'demo_trips.dart';
import 'demo_users.dart';
import 'demo_finance.dart';

class DemoAdminLayout extends StatefulWidget {
  const DemoAdminLayout({super.key});

  @override
  State<DemoAdminLayout> createState() => _DemoAdminLayoutState();
}

class _DemoAdminLayoutState extends State<DemoAdminLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DemoDashboard(),
    const DemoTrips(),
    const DemoUsers(),
    const DemoFinance(),
  ];

  final List<String> _titles = [
    "Tableau de Bord",
    "Supervision Trajets",
    "Gestion Utilisateurs",
    "Finance & Revenus",
  ];

  @override
  Widget build(BuildContext context) {
    // Détection PC vs Mobile
    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Row(
          children: [
            // BARRE LATÉRALE (Desktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
              backgroundColor: Colors.white,
              elevation: 5,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.green[800]),
              ),
              extended: true, // Texte visible
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text("Dashboard")),
                NavigationRailDestination(icon: Icon(Icons.map), label: Text("Trajets")),
                NavigationRailDestination(icon: Icon(Icons.people), label: Text("Utilisateurs")),
                NavigationRailDestination(icon: Icon(Icons.monetization_on), label: Text("Finance")),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  // En-tête
                  Container(
                    height: 80,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(_titles[_selectedIndex], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  // Contenu
                  Expanded(child: Padding(padding: const EdgeInsets.all(20), child: _screens[_selectedIndex])),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      // VERSION MOBILE
      return Scaffold(
        appBar: AppBar(title: Text(_titles[_selectedIndex]), backgroundColor: Colors.green[800], foregroundColor: Colors.white),
        body: _screens[_selectedIndex],
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(child: Center(child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.green))),
              ListTile(title: const Text("Dashboard"), onTap: () => setState(() { _selectedIndex = 0; Navigator.pop(context); })),
              ListTile(title: const Text("Trajets"), onTap: () => setState(() { _selectedIndex = 1; Navigator.pop(context); })),
              // ... autres liens
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Trajets"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
            BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Finance"),
          ],
        ),
      );
    }
  }
}