// Cette page affiche le profil du chauffeur
// quelques informations et options de compte.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/onboarding/views/passenger_transition_screen.dart';
import 'package:u_go/modules/booking_module/screens/onboarding/views/welcome_sceen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/edit_profile_sceen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/help_screen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/notifications_screen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/privacy_policy_screen.dart';
import 'package:u_go/modules/payment_module/screens/my_wallet_screen.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/profile_header_widget.dart';
import 'package:u_go/app/widgets/profile_title.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';

// ⚠️ Commente si tu n'as pas encore l'écran d'historique chauffeur
import 'package:u_go/modules/booking_module/screens/driver/driver_history_screen.dart';

import 'package:u_go/app/database/services/role_service.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  Future<void> _onToggleDriver({
    required bool newValue,
    required String uid,
  }) async {
    try {
      await RoleService.applyRole(isDriver: newValue);

      if (!mounted) return;
      if (!newValue) {
        // Quitte le mode chauffeur → transition passager
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PassengerTransitionScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mode Chauffeur activé'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'enregistrer le rôle. Réessaie."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    final email = _auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Compte",
          style: TextStyle(fontFamily: 'Agbalumo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context
              .findAncestorStateOfType<DriverHomeScreenState>()
              ?.navigateToTab(0),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: uid == null
          ? const _AuthRequired()
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _fire.collection('users').doc(uid).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const _LoadingSkeleton();
                }
                if (snap.hasError) {
                  return const _ErrorState();
                }

                final data = snap.data?.data() ?? {};
                final nom = (data['nom'] ?? '').toString().trim();
                final prenom = (data['prenom'] ?? '').toString().trim();
                final numero = (data['numero'] ?? data['phone'] ?? '')
                    .toString()
                    .trim();

                final hasName = nom.isNotEmpty || prenom.isNotEmpty;
                final displayName = hasName
                    ? [prenom, nom].where((s) => s.isNotEmpty).join(' ')
                    : 'Conducteur U-GO';

                final avatar = (data['avatar'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase();
                final imagePath = (avatar == 'boy' || avatar == 'girl')
                    ? 'assets/images/avatars/$avatar.jpg'
                    : '';

                final role = (data['role'] ?? 'driver').toString().trim();
                final isDriver = (role == 'driver');

                return Column(
                  children: [
                    ProfileHeaderWidget(
                      name: displayName,
                      phone: numero.isNotEmpty ? "(+225) $numero" : "—",
                      email: email,
                      imagePath: imagePath,
                      backgroundColor: secondColor,
                      isDriver: isDriver,
                      onToggleDriver: (value) =>
                          _onToggleDriver(newValue: value, uid: uid),
                      /**
                           * (val) async {
                                await RoleService.instance.setDriver(val);
                              },
                           *  */
                    ),

                    const SizedBox(height: 8),

                    if (!hasName) const _NameHintBubble(),

                    Expanded(
                      child: ListView(
                        children: [
                          ProfileTile(
                            title: "Mes informations",
                            icon: Icons.edit,
                            color: secondColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),

                          ProfileTile(
                            title: "Mes notifications",
                            icon: Icons.notifications,
                            color: secondColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),

                          ProfileTile(
                            title: "Mon portefeuille",
                            icon: Icons.account_balance_wallet,
                            color: secondColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyWalletScreen(),
                                ),
                              );
                            },
                          ),

                          // ⚠️ Si tu n'as pas encore l'écran d'historique chauffeur, commente ce bloc + l'import
                          ProfileTile(
                            title: "Historique",
                            icon: Icons.history,
                            color: secondColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DriverHistoryScreen(),
                                ),
                              );
                            },
                          ),

                          ProfileTile(
                            title: "Politique de confidentialité",
                            icon: Icons.privacy_tip,
                            color: secondColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                          ),

                          ProfileTile(
                            title: "Aide",
                            icon: Icons.help_outline,
                            color: secondColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HelpScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ButtonComponent(
                        txtButton: "Déconnexion",
                        colorButton: decoColor,
                        colorText: Colors.white,
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Échec de la déconnexion. Réessaie.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _NameHintBubble extends StatelessWidget {
  const _NameHintBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Veuillez ajouter votre nom et votre prénom dans « Mes informations » pour personnaliser votre profil.",
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthRequired extends StatelessWidget {
  const _AuthRequired();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Veuillez vous connecter pour voir votre profil."),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemCount: 5,
            itemBuilder: (_, _) => Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Une erreur est survenue."));
  }
}
