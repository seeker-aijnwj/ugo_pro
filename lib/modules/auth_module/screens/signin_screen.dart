// lib/screens/auth/sign_in_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ← pour le lien e-mail (no-reply)
import 'package:shared_preferences/shared_preferences.dart'; // ← stocker l'email pour terminer le flux

// ✅ email_otp (compatible 1.1.0)
import 'package:email_otp/email_otp.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/form_component.dart';
import 'package:u_go/app/widgets/space.dart';
import 'package:u_go/app/widgets/top_message.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:url_launcher/url_launcher.dart';

import './otp_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool hidePassword = true;
  String selectedRole = "passenger";
  bool agree = false;
  bool isLoading = false;
  bool passwordMatch = true;

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    confirmPasswordController.addListener(checkPasswordsMatch);
    passwordController.addListener(checkPasswordsMatch);

    // ✅ Configure email_otp ici (tu ne veux pas toucher à main.dart)
    EmailOTP.config(
      appName: 'U-GO',
      otpLength: 4, // ton écran OTP est à 4 chiffres
      otpType: OTPType.numeric,
      expiry: 300000, // 5 minutes (info interne au package)
      emailTheme: EmailTheme.v6,
      // appEmail: 'ugo.noreply@votredomaine.com', // optionnel si SMTP
    );

    // (Optionnel) SMTP si tu veux envoyer depuis TON expéditeur (Gmail/SendGrid, etc.)
    // EmailOTP.setSMTP(
    //   host: 'smtp.gmail.com',
    //   emailPort: EmailPort.port587,
    //   secureType: SecureType.tls,
    //   username: 'ugo.noreply@gmail.com',
    //   password: 'APP_PASSWORD_OU_TOKEN',
    // );
  }

  @override
  void dispose() {
    numeroController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void checkPasswordsMatch() {
    setState(() {
      passwordMatch = passwordController.text == confirmPasswordController.text;
    });
  }

  bool _looksLikeEmail(String s) {
    final v = s.trim();
    if (v.isEmpty) return false;
    final r = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return r.hasMatch(v);
  }

  /// 🔐 Flux: inscription avec OTP (email_otp 1.1.0) + stockage temporaire
  Future<void> _register() async {
    if (!_looksLikeEmail(emailController.text)) {
      TopMessage.show(context, "Email invalide.");
      return;
    }

    if (!passwordMatch) {
      TopMessage.show(context, "Les mots de passe ne correspondent pas.");
      return;
    }

    if (passwordController.text.trim().length < 8) {
      TopMessage.show(
        context,
        "Le mot de passe doit contenir au moins 8 caractères.",
      );
      return;
    }

    if (!agree) {
      TopMessage.show(
        context,
        "Veuillez accepter la politique de confidentialité.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Vérifier si email déjà utilisé (profil final)
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        TopMessage.show(context, "Cet email est déjà utilisé.");
        setState(() => isLoading = false);
        return;
      }

      final email = emailController.text.trim();
      final numero = numeroController.text.trim();
      final password = passwordController.text.trim();

      // Envoi OTP par e-mail (email_otp 1.1.0)
      final sent = await EmailOTP.sendOTP(email: email);
      if (!sent) {
        TopMessage.show(context, "Échec d'envoi de l'OTP. Réessaie.");
        setState(() => isLoading = false);
        return;
      }

      // Récupère l’OTP généré par la lib (1.1.0: getOTP existe)
      String? generatedOtp;
      try {
        generatedOtp = EmailOTP.getOTP();
      } catch (_) {
        generatedOtp =
            null; // Si indisponible, on s’appuie uniquement sur l’email envoyé
      }

      // Sauvegarde temporaire dans users/ (on respecte ton flux et ton UI)
      final tempUserRef = await FirebaseFirestore.instance
          .collection('users')
          .add({
            'email': email,
            'numero': numero,
            'password': password, // temporaire (évite en prod; sinon chiffrer)
            'role': selectedRole,
            'otp': generatedOtp, // pour comparaison locale
            'isVerified': false,
            'createdAt': Timestamp.now(),
            'otpSentAt': FieldValue.serverTimestamp(), // TTL côté client
          });

      // Nettoyage côté client après 10 min si non vérifié (limité: app doit rester ouverte)
      Future.delayed(const Duration(minutes: 10), () async {
        final doc = await tempUserRef.get();
        if (doc.exists && (doc.data()?['isVerified'] == false)) {
          await tempUserRef.delete();
        }
      });

      // Aller à l’OTP en remplaçant SignIn (UI inchangée)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpScreen(role: selectedRole, email: email, password: password),
        ),
      );
    } catch (e) {
      TopMessage.show(context, "Erreur : ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// ✉️ Option NO-PASSWORD (no-reply) : envoi d’un lien de connexion Firebase
  Future<void> _sendEmailLinkNoPassword() async {
    final email = emailController.text.trim();
    if (!_looksLikeEmail(email)) {
      TopMessage.show(
        context,
        "Renseignez un email valide pour recevoir le lien.",
      );
      return;
    }
    if (!agree) {
      TopMessage.show(
        context,
        "Veuillez accepter la politique de confidentialité.",
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      const redirectUrl = 'https://u-go.web.app/finishSignUp'; // à adapter

      final acs = ActionCodeSettings(
        url: redirectUrl,
        handleCodeInApp: true,
        androidPackageName: 'com.ugo.app', // ← remplace par ton package Android
        androidInstallApp: true,
        androidMinimumVersion: '21',
        iOSBundleId: 'com.ugo.app.ios', // ← remplace par ton bundle iOS
      );

      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emailForSignIn', email);
      await prefs.setString('pendingRole', selectedRole);

      TopMessage.show(
        context,
        "Lien envoyé. Vérifiez votre boîte mail (expéditeur no-reply).",
      );
    } on FirebaseAuthException catch (e) {
      TopMessage.show(context, e.message ?? "Échec d’envoi du lien.");
    } catch (_) {
      TopMessage.show(context, "Échec d’envoi du lien.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildRoleBox(
    String text,
    IconData icon,
    bool selected,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? borderColor : Colors.grey,
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
          const SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Entête (inchangé)
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
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
                        txt: "S'inscrire",
                        txtSize: 50,
                        family: "Agbalumo",
                        txtAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Formulaire (inchangé)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponent(
                        label: "Numéro",
                        placeholder: "+225 0505050505",
                        controller: numeroController,
                        textInputType: TextInputType.phone,
                      ),
                      spaceHeight(20),
                      FormComponent(
                        label: "Email",
                        placeholder: "utilisateur@gmail.com",
                        textInputType: TextInputType.emailAddress,
                        controller: emailController,
                      ),
                      spaceHeight(20) ,
                      FormComponent(
                        label: "Mot de passe",
                        placeholder: "********",
                        hide: hidePassword,
                        textInputType: TextInputType.visiblePassword,
                        controller: passwordController,
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
                      FormComponent(
                        label: "Confirmer le mot de passe",
                        placeholder: "********",
                        hide: hidePassword,
                        textInputType: TextInputType.visiblePassword,
                        controller: confirmPasswordController,
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
                      if (confirmPasswordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            passwordMatch
                                ? "Les mots de passe correspondent"
                                : "Les mots de passe ne correspondent pas",
                            style: TextStyle(
                              color: passwordMatch ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      spaceHeight(20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: agree,
                            onChanged: (value) =>
                                setState(() => agree = value ?? false),
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  "Je confirme avoir lu et approuvé la ",
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse(
                                      'https://tonsite.com/politique',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: const Text(
                                    "politique de confidentialité.",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      spaceHeight(20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => selectedRole = "passenger"),
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
                              onTap: () =>
                                  setState(() => selectedRole = "driver"),
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
                      spaceHeight(50),
                      // Bouton d'inscription (flux OTP maison)
                      ButtonComponent(
                        txtButton: isLoading ? "Inscription..." : "S'inscrire",
                        onPressed: (agree && !isLoading) ? _register : null,
                      ),
                      spaceHeight(20),
                      // Option — lien e-mail no-reply
                      Center(
                        child: TxtComponents(
                          txt: "Se connecter par lien e-mail (no-reply)",
                          txtAlign: TextAlign.center,
                          family: "Agbalumo",
                          txtSize: 14,
                          color: Colors.blue,
                          onTap: isLoading ? null : _sendEmailLinkNoPassword,
                        ),
                      ),
                      spaceHeight(20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
