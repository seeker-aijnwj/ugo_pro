// lib/screens/auth/otp_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_go/app/database/services/custom_id_service.dart';
import 'package:u_go/app/core/utils/colors.dart';

// ✅ email_otp (compatible 1.1.0) — pas de verifyOTP ni isExpired
import 'package:email_otp/email_otp.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/space.dart';
import 'package:u_go/app/widgets/top_message.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/modules/booking_module/screens/passenger/home_screen.dart';


class OtpScreen extends StatefulWidget {
  final String role;
  final String email;
  final String password;

  const OtpScreen({
    super.key,
    required this.role,
    required this.email,
    required this.password,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool isVerifying = false;
  bool canResend = false;
  int remainingSeconds = 0;
  int resendDelay = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      remainingSeconds = resendDelay;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        setState(() => canResend = true);
        timer.cancel();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<void> resendOtp() async {
    if (!canResend) return;

    setState(() {
      canResend = false;
      resendDelay *= 2; // double chaque renvoi: 60 -> 120 -> 240...
      remainingSeconds = resendDelay;
    });
    startResendTimer();

    try {
      // Envoi d’un nouveau code via email_otp 1.1.0
      final sent = await EmailOTP.sendOTP(email: widget.email);
      if (!sent) {
        TopMessage.show(context, "Échec d'envoi. Réessaie.");
        return;
      }

      // Récupère le nouvel OTP généré (si dispo) pour le stocker en local Firestore (fallback/trace)
      String? newOtp;
      try {
        newOtp = EmailOTP.getOTP();
      } catch (_) {
        newOtp = null;
      }

      // Met à jour le doc temporaire
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docRef = query.docs.first.reference;
        await docRef.update({
          'otp': newOtp,
          'otpSentAt': FieldValue.serverTimestamp(), // reset TTL
        });
      }

      TopMessage.show(context, "Code renvoyé avec succès.");
    } catch (e) {
      TopMessage.show(context, "Erreur de renvoi : ${e.toString()}");
    }
  }

  Future<void> _verifyOtp() async {
    // Concatène les 4 caractères saisis
    final code = _otpControllers.map((c) => c.text).join();

    if (code.length < 4) {
      TopMessage.show(context, "Code incomplet.");
      return;
    }

    setState(() => isVerifying = true);

    try {
      // 1) Récupérer le doc temporaire par email
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        TopMessage.show(context, "Utilisateur introuvable.");
        setState(() => isVerifying = false);
        return;
      }

      final tempDoc = query.docs.first;
      final tempData = tempDoc.data();

      // 2) Contrôle d’expiration basé sur Firestore (TTL = 5 minutes)
      const otpTtl = Duration(minutes: 5);
      final sentAt = tempData['otpSentAt'] as Timestamp?;
      if (sentAt == null ||
          DateTime.now().toUtc().isAfter(sentAt.toDate().toUtc().add(otpTtl))) {
        TopMessage.show(context, "OTP expiré. Renvoyez un nouveau code.");
        setState(() => isVerifying = false);
        return;
      }

      // 3) Comparaison OTP locale (compatible email_otp 1.1.0)
      final storedOtp = (tempData['otp'] ?? '').toString();
      if (storedOtp.isEmpty || storedOtp != code) {
        TopMessage.show(context, "Code incorrect.");
        setState(() => isVerifying = false);
        return;
      }

      // 4) Suite: création du compte Firebase Auth + profil + suppression temporaire
      final email = (tempData['email'] ?? widget.email) as String?;
      final password = (tempData['password'] ?? widget.password) as String?;
      final role = (tempData['role'] ?? widget.role) as String?;
      final numero = tempData['numero'] as String?;

      if (email == null || password == null) {
        TopMessage.show(
          context,
          "Informations incomplètes pour créer le compte.",
        );
        setState(() => isVerifying = false);
        return;
      }

      // 3.1) Créer le compte Auth
      UserCredential cred;
      try {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        TopMessage.show(context, "Erreur de création du compte : ${e.message}");
        setState(() => isVerifying = false);
        return;
      }

      final user = cred.user!;

      // 3.2) Générer un customId lisible
      final customId = await CustomIdService.nextUserCustomId();

      // 3.3) Écrire le profil users/{uid}
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'customId': customId,
        'email': email,
        'numero': numero,
        'role': role ?? 'passenger',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3.4) Marquer vérifié et supprimer le temporaire
      await tempDoc.reference.update({'isVerified': true});
      await tempDoc.reference.delete();

      // 5) Router selon le rôle — et on efface TOUT l’historique
      final destination = (role == "driver")
          ? const DriverHomeScreen()
          : const HomeScreen();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (_) => false,
      );
    } catch (e) {
      TopMessage.show(context, "Erreur : ${e.toString()}");
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 🔒 Bloque le bouton "retour" Android pendant l’OTP
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          // ❌ Pas de flèche retour pour éviter pop visuel pendant l’OTP
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: const TxtComponents(
            txt: "Vérification OTP",
            txtSize: 28,
            family: "Agbalumo",
            txtAlign: TextAlign.center,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    spaceHeight(20),
                    const TxtComponents(
                      txt: "Entrer le code à 4 chiffres envoyé sur votre email",
                      color: txtgray,
                      family: "Agbalumo",
                      txtAlign: TextAlign.center,
                    ),
                    spaceHeight(40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          height: 60,
                          width: 60,
                          child: TextField(
                            controller: _otpControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                            maxLength: 1,
                            onChanged: (value) {
                              if (value.length == 1 && index < 3) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    spaceHeight(20),
                    ButtonComponent(
                      txtButton: isVerifying
                          ? "Vérification..."
                          : "Valider le code",
                      onPressed: isVerifying ? null : _verifyOtp,
                    ),
                    spaceHeight(16),
                    Center(
                      child: canResend
                          ? TxtComponents(
                              txt: "Renvoyer le code ?",
                              color: mainColor,
                              txtAlign: TextAlign.center,
                              family: "Agbalumo",
                              txtSize: 14,
                              onTap: resendOtp,
                            )
                          : TxtComponents(
                              txt:
                                  "Renvoyer dans ${formatTime(remainingSeconds)}",
                              color: Colors.grey,
                              txtAlign: TextAlign.center,
                              family: "Agbalumo",
                              txtSize: 14,
                            ),
                    ),
                    spaceHeight(20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
