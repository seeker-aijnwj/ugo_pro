import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service minimal pour Passwordless Sign-In (Email Link)
class EmailLinkAuthService {
  EmailLinkAuthService._();
  static final _auth = FirebaseAuth.instance;

  // Remplace par ton URL de redirection hébergée (doit être "authorized domain")
  static const _redirectUrl = 'https://u-go.web.app/finishSignUp';

  /// 1) Envoie le lien à [email] + stocke localement l'email (sécurité: ne jamais le passer dans l'URL)
  static Future<void> sendLink(String email) async {
    final acs = ActionCodeSettings(
      url: _redirectUrl, // peut contenir ?state=... (ex. role)
      handleCodeInApp: true,
      androidPackageName: 'com.ugo.app', // ← remplace par ton package
      androidInstallApp: true,
      androidMinimumVersion: '21',
      iOSBundleId: 'com.ugo.app.ios', // ← remplace par ton bundle id
      // linkDomain est géré automatiquement via Hosting; url doit être sur un domaine autorisé
    );

    await _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailForSignIn', email);
  }

  /// 2) Tente de finaliser la connexion depuis un lien entrant
  /// Retourne le UserCredential si succès, sinon null
  static Future<UserCredential?> completeSignInFromLink(String link) async {
    try {
      if (!_auth.isSignInWithEmailLink(link)) return null;

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('emailForSignIn');

      // Si l’utilisateur ouvre le lien sur un autre appareil,
      // savedEmail peut être null → il faut ré-afficher un champ email.
      if (savedEmail == null || savedEmail.isEmpty) {
        return null;
      }

      final cred = await _auth.signInWithEmailLink(
        email: savedEmail,
        emailLink: link,
      );

      // Nettoyage
      await prefs.remove('emailForSignIn');
      return cred;
    } catch (e) {
      // Log minimal, à remplacer par ton TopMessage
      // print('Error signInWithEmailLink: $e');
      return null;
    }
  }
}
