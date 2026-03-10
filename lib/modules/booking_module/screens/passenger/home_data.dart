import 'package:flutter/material.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/passenger/home_screen.dart'; // Pour HomeScreenState
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/greeting_header.dart';
import 'package:u_go/modules/booking_module/widgets/recent_trips_widget.dart';

class HomeData extends StatelessWidget {
  const HomeData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // ✅ Gris très doux
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const GreetingHeader(),
              const SizedBox(height: 30),
              const RecentTripsWidget(),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonComponent(
                      txtButton: "Rechercher",
                      colorButton: mainColor,
                      colorText: Colors.white,
                      shadowOpacity: 0.3,
                      shadowColor: Colors.black,
                      width: MediaQuery.of(context).size.width * 0.4,
                      onPressed: () {
                        (context.findAncestorStateOfType<HomeScreenState>())
                            ?.navigateToTab(1);
                      },
                    ),
                    ButtonComponent(
                      txtButton: "Suivre",
                      colorButton: mainColor,
                      colorText: Colors.white,
                      shadowOpacity: 0.3,
                      shadowColor: Colors.black,
                      width: MediaQuery.of(context).size.width * 0.4,
                      onPressed: () {
                        (context.findAncestorStateOfType<HomeScreenState>())
                            ?.navigateToTab(2);
                      },
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
