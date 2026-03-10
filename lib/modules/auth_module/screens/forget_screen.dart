import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/form_component.dart';
import 'package:u_go/app/widgets/space.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/widgets/top_message.dart';
import 'package:u_go/modules/auth_module/screens/confirm_change.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      TopMessage.show(context, "Veuillez entrer votre email.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        TopMessage.show(context, "Aucun utilisateur trouvé avec cet email.");
        return;
      }

      // ✅ Si tu veux activer l'envoi réel plus tard, décommente cette partie :
      /*
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      */

      // ✅ Redirection vers la page de confirmation (sans retour arrière)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ConfirmChange()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        TopMessage.show(context, "Adresse email invalide.");
      } else {
        TopMessage.show(context, "Erreur : ${e.message}");
      }
    } catch (e) {
      TopMessage.show(context, "Erreur inconnue : ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 110,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: TxtComponents(
                          txt: "",
                          txtSize: 50,
                          family: "Agbalumo",
                          txtAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 180),
                const TxtComponents(
                  txt: "Mot de passe oublié",
                  txtSize: 40,
                  family: "Agbalumo",
                  txtAlign: TextAlign.center,
                ),
                spaceHeight(20),
                const TxtComponents(
                  txt: "Veuillez entrer votre adresse email",
                  color: txtgray,
                  family: "Agbalumo",
                ),
                spaceHeight(40),
                FormComponent(
                  label: "Email",
                  placeholder: "utilisateur@gmail.com",
                  controller: emailController,
                ),
                spaceHeight(20),
                ButtonComponent(
                  txtButton: isLoading ? "Envoi..." : "Envoyer",
                  onPressed: isLoading ? null : _sendResetLink,
                ),
                spaceHeight(40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
