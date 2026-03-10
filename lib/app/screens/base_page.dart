import 'package:flutter/material.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final void Function(int)? onTabSelected;
  final String? title;
  final bool showNotificationIcon;

  const BasePage({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onTabSelected,
    this.title,
    this.showNotificationIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (showNotificationIcon)
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        selectedItemColor: Color(0xFF2FA9E1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Rechercher",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Historique",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
        ],
      ),
    );
  }
}
