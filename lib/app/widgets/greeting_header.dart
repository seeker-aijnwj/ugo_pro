import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/passenger/notifications_screen.dart';
import 'package:u_go/app/widgets/notification_bell.dart';

class GreetingHeader extends StatelessWidget {
  final Color? color; // ✅ Couleur personnalisable

  const GreetingHeader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final Color backgroundColor = color ?? mainColor;

    // ✅ Détection si on utilise secondColor
    final bool isUsingSecondColor = backgroundColor == secondColor;

    // ✅ Couleurs du badge selon fond clair ou foncé
    final Color badgeBgColor = isUsingSecondColor ? Colors.white : Colors.red;
    final Color badgeTextColor = isUsingSecondColor ? Colors.red : Colors.white;

    return Container(
      height: screenHeight / 3,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // ✅ "Bonjour" centré
          const Center(
            child: Text(
              "Coucou",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                fontFamily: 'Agbalumo',
                color: Colors.white,
              ),
            ),
          ),

          // ✅ Icône notification avec badge
          // APRÈS (à coller à la place)
          Positioned(
            top: 24,
            right: 16,
            child: NotificationBell(
              iconColor: Colors.white,
              iconSize: 28,
              // garde tes couleurs dynamiques existantes :
              badgeBgColor: badgeBgColor,
              badgeTextColor: badgeTextColor,
              badgeBorderColor: Colors.white,
              isReadField: 'read',

              // Schéma Firestore par défaut : users/{uid}/notifications avec isRead == false
              // Si tu es en collection plate, dis-le moi et je te donne 3 lignes à décommenter.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
