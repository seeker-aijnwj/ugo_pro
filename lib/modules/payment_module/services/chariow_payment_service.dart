import 'package:url_launcher/url_launcher.dart';

/// Service de paiement Chariow
/// ----------------------------------------------------
/// - Paiement par redirection externe
/// - Aucun secret dans l'application
/// - Montants strictement autorisés (whitelist)
/// - Adapté à un MVP en production
/// ----------------------------------------------------
class ChariowPaymentService {
  ChariowPaymentService._();
  static final ChariowPaymentService instance = ChariowPaymentService._();

  /// 🔒 Montants AUTORISÉS UNIQUEMENT
  /// Chaque montant correspond à un produit Chariow
  static const Map<int, String> _paymentLinks = {
    600: 'https://vjqeadyi.mychariow.shop/prd_d6uygk/checkout',
    1000: 'https://pay.chariow.com/p/YYYY',
    5000: 'https://pay.chariow.com/p/ZZZZ',
  };

  /// Lance le paiement Chariow
  ///
  /// ⚠️ Aucun crédit wallet ici
  /// ⚠️ Aucune validation de succès
  Future<void> pay({required int amount}) async {
    // 1️⃣ Vérification du montant
    final url = _paymentLinks[amount];
    if (url == null) {
      throw ArgumentError('Montant non autorisé pour le paiement');
    }

    // 2️⃣ Vérification URL
    final uri = Uri.parse(url);
    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      throw Exception('Impossible d’ouvrir la page de paiement');
    }

    // 3️⃣ Redirection externe (sécurité)
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// (Optionnel) Liste des montants disponibles
  /// utile pour l’UI
  static List<int> get supportedAmounts => _paymentLinks.keys.toList()..sort();
}
