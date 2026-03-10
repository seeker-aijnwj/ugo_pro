// Cette 

import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/greeting_header.dart';
import 'package:u_go/modules/booking_module/widgets/recent_announces_widget.dart';


/// DriverHomeDataScreen
/// ----------------
/// Liste les trajets du conducteur courant (scheduled/running)
/// et permet de :
///  - DÉMARRER la course (status -> running) puis ouvrir la carte
///  - OUVRIR la carte si déjà en cours
///
/// Hypothèses Firestore:
///  - Collection: trips
///  - Champs minimum: { driverUserId: string, status: "scheduled"|"running"|...,
///                      title?: string, from?: string, to?: string }


class DriverHomeDataScreen extends StatelessWidget {
  const DriverHomeDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // Header de bienvenue "Coucou, [Prénom]"
              const GreetingHeader(color: secondColor),
              
              const SizedBox(height: 30),
              
              // Liste des annonces récentes
              const RecentAnnouncesWidget(),
              
              const SizedBox(height: 30),
              
              // Deux boutons "Annoncer" et "Suivre"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonComponent(
                      txtButton: "Annoncer",
                      colorButton: secondColor,
                      colorText: Colors.white,
                      shadowOpacity: 0.3,
                      shadowColor: Colors.black,
                      width: MediaQuery.of(context).size.width * 0.4,
                      onPressed: () => context
                          .findAncestorStateOfType<DriverHomeScreenState>()
                          ?.navigateToTab(1),
                    ),
                    ButtonComponent(
                      txtButton: "Suivre",
                      colorButton: secondColor,
                      colorText: Colors.white,
                      shadowOpacity: 0.3,
                      shadowColor: Colors.black,
                      width: MediaQuery.of(context).size.width * 0.4,
                      onPressed: () => context
                          .findAncestorStateOfType<DriverHomeScreenState>()
                          ?.navigateToTab(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
