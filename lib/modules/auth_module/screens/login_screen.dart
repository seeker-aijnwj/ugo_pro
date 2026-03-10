import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:u_go/modules/auth_module/screens/forget_screen.dart';
import 'package:u_go/modules/auth_module/screens/signin_screen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/home_screen.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/form_component.dart';
import 'package:u_go/app/widgets/space.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/widgets/top_message.dart';

// 🔹 Adapte le chemin si besoin
import 'package:u_go/app/database/services/role_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool agree = false;
  bool hidePassword = true;
  bool isLoading = false;

  /// 'passenger' | 'driver'
  String selectedRole = 'passenger';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalRole();
  }

  /// Pré-sélectionne l’UI selon le rôle local mémorisé
  Future<void> _loadLocalRole() async {
    final local = await RoleService.getLocalRole(); // 'driver' | 'passenger'
    if (!mounted) return;
    setState(() {
      selectedRole = (local == 'driver') ? 'driver' : 'passenger';
    });
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      TopMessage.show(context, "Veuillez remplir tous les champs.");
      return;
    }
    if (!agree) {
      TopMessage.show(
        context,
        "Vous devez accepter la politique de confidentialité.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1) Connexion directe
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2) Appliquer le rôle choisi (local/Firestore si tu l’utilises)
      await RoleService.applyRole(isDriver: selectedRole == 'driver');
      await RoleService.setLocalRole(selectedRole);

      // 3) Navigation
      final destination = (selectedRole == 'driver')
          ? const DriverHomeScreen()
          : const HomeScreen();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          TopMessage.show(context, "Aucun compte trouvé avec cet email.");
          break;
        case 'wrong-password':
          TopMessage.show(context, "Mot de passe incorrect.");
          break;
        case 'invalid-email':
          TopMessage.show(context, "Adresse email invalide.");
          break;
        case 'user-disabled':
          TopMessage.show(context, "Ce compte est désactivé.");
          break;
        case 'too-many-requests':
          TopMessage.show(context, "Trop de tentatives. Réessayez plus tard.");
          break;
        case 'network-request-failed':
          TopMessage.show(
            context,
            "Problème réseau. Vérifiez votre connexion.",
          );
          break;
        default:
          TopMessage.show(
            context,
            "Erreur lors de la connexion : ${e.message}",
          );
      }
    } catch (e) {
      TopMessage.show(context, "Erreur inattendue : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildRoleBox(
    String text,
    IconData icon,
    bool selected,
    Color activeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? activeColor : Colors.grey,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _openPolicy() async {
    final url = Uri.parse('https://tonsite.com/politique');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      TopMessage.show(context, "Impossible d’ouvrir le lien.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // En-tête (inchangé)
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: const Center(
                  child: TxtComponents(
                    txt: "Se connecter",
                    txtSize: 50,
                    family: "Agbalumo",
                    txtAlign: TextAlign.center,
                  ),
                ),
              ),

              // Corps
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponent(
                        label: "Email",
                        placeholder: "utilisateur@gmail.com",
                        controller: emailController,
                        textInputType: TextInputType.emailAddress,
                      ),
                      spaceHeight(20),
                      FormComponent(
                        label: "Mot de passe",
                        placeholder: "********",
                        controller: passwordController,
                        hide: hidePassword,
                        textInputType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => hidePassword = !hidePassword),
                        ),
                      ),
                      spaceHeight(20),

                      // Sélection du rôle
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => selectedRole = "passenger");
                                // ✅ mémorise localement pour prochaine ouverture
                                await RoleService.setLocalRole('passenger');
                              },
                              child: buildRoleBox(
                                "Passager",
                                Icons.person_outline,
                                selectedRole == "passenger",
                                Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => selectedRole = "driver");
                                // ✅ mémorise localement pour prochaine ouverture
                                await RoleService.setLocalRole('driver');
                              },
                              child: buildRoleBox(
                                "Chauffeur",
                                Icons.directions_car,
                                selectedRole == "driver",
                                Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceHeight(20),

                      // Politique
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: agree,
                            onChanged: (v) =>
                                setState(() => agree = v ?? false),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _openPolicy,
                              child: const Text.rich(
                                TextSpan(
                                  text: "Je confirme avoir lu et approuvé la ",
                                  children: [
                                    TextSpan(
                                      text: "politique de confidentialité",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ],
                      ),
                      spaceHeight(30),

                      // Bouton connexion
                      ButtonComponent(
                        txtButton: isLoading ? "Connexion..." : "Se connecter",
                        colorButton: mainColor,
                        colorText: Colors.white,
                        onPressed: (agree && !isLoading) ? _handleLogin : null,
                      ),
                      spaceHeight(20),

                      // Mot de passe oublié
                      Center(
                        child: TxtComponents(
                          txt: "Mot de passe oublié ?",
                          color: mainColor,
                          txtAlign: TextAlign.center,
                          family: "Agbalumo",
                          txtSize: 14,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgetScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              spaceHeight(20),

              // Bouton s'inscrire (masqué quand le clavier est ouvert)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isKeyboardOpen
                    ? const SizedBox.shrink(key: ValueKey('hidden'))
                    : ButtonComponent(
                        key: const ValueKey('signup'),
                        txtButton: "S'inscrire",
                        colorButton: Colors.white,
                        colorText: mainColor,
                        showBorder: true,
                        borderColor: mainColor,
                        borderWidth: 4.0,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          );
                        },
                      ),
              ),
              if (!isKeyboardOpen) spaceHeight(20),
            ],
          ),
        ),
      ),
    );
  }
}
