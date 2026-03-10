// lib/app/core/services/ensure_min_balance.dart
//
// Utilitaire: vérifier un minimum de solde, sinon ouvrir PaymentSelectionsScreen.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_go/app/database/services/wallet_service.dart';
import 'package:u_go/modules/trip_module/screens/payment_selections_screen.dart';

class EnsureMinBalance {
  EnsureMinBalance._();
  static final EnsureMinBalance instance = EnsureMinBalance._();

  /// Retourne true si OK, sinon ouvre l'écran de recharge et retourne false.
  Future<bool> ensure({
    required BuildContext context,
    required int minAmount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final available = await WalletService.instance.getAvailable(user.uid);
    if (available >= minAmount) return true;

    // Redirige vers l'écran de sélection de paiement / recharge
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSelectionsScreen(
          requiredAmount: minAmount - available,
          onMockSuccess: () {
            // Rien : PaymentSelectionsScreen fait la recharge simulée
          },
        ),
      ),
    );
    return false;
  }
}
