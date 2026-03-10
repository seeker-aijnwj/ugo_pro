import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:u_go/app/database/services/wallet_service.dart';

class PaymentSelectionsScreen extends StatefulWidget {
  final int? requiredAmount;
  final VoidCallback? onMockSuccess;

  const PaymentSelectionsScreen({
    super.key,
    this.requiredAmount,
    this.onMockSuccess,
  });

  @override
  State<PaymentSelectionsScreen> createState() =>
      _PaymentSelectionsScreenState();
}

class _PaymentSelectionsScreenState extends State<PaymentSelectionsScreen> {
  bool _busy = false;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    final data = await WalletService.instance.getOrCreateWallet(u.uid);
    setState(() => _current = (data['available'] as num?)?.toInt() ?? 0);
  }

  Future<void> _mockTopup(int amount, String provider) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    setState(() => _busy = true);
    try {
      await WalletService.instance.credit(
        uid: u.uid, // 🔧 uid au lieu de userId
        amount: amount,
        reason: 'TOPUP_$provider', // ok
        simulated: true, // pas de param provider dans le service seed=250
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white.withOpacity(0.4),
          content: const Text(
            'Recharge effectuée ✅',
            style: TextStyle(color: Colors.black),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await _load();
      widget.onMockSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.white.withOpacity(0.4),
          content: Text(
            'Échec de la recharge: $e',
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final required = widget.requiredAmount ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Recharge / Paiement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Le paiement de la course se fait directement au chauffeur (cash / MoMo).',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Solde actuel: $_current FCFA'),
          if (required > 0) ...[
            const SizedBox(height: 8),
            Text('Montant minimum requis: $required FCFA'),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              _QuickAmount(amount: 200, onTap: () => _mockTopup(200, 'ORANGE')),
              _QuickAmount(amount: 300, onTap: () => _mockTopup(300, 'MTN')),
              _QuickAmount(amount: 500, onTap: () => _mockTopup(500, 'MOOV')),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: _busy ? const Text('Traitement...') : const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;
  const _QuickAmount({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onTap, child: Text('$amount FCFA'));
  }
}
