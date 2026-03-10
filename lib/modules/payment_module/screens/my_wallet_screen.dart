import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_go/modules/payment_module/services/chariow_payment_service.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  bool _busy = false;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 🔐 LANCE UN PAIEMENT VIA CHARIOW
  Future<void> _topUp({required int amount}) async {
    setState(() => _busy = true);

    try {
      await ChariowPaymentService.instance.pay(amount: amount);

      _snack(
        "Paiement lancé. "
        "Revenez dans l’application après validation.",
      );
    } catch (e) {
      _snack("Erreur paiement : $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final crossAxisCount = size.width < 420 ? 2 : 4;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Wallet")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                isSmall ? 16 : 28,
                16,
                isSmall ? 16 : 28,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1F6FEB), Color(0xFF81A5F9)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('wallets')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snap) {
                  final balance = snap.data?.get('available') ?? 0;
                  return Column(
                    children: [
                      const Text(
                        "Hello 👋",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Your balance",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$balance",
                            style: TextStyle(
                              fontSize: isSmall ? 30 : 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              "FCFA",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ================= OPERATORS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _OperatorTile(
                    label: "Wave",
                    asset: "assets/images/operators/wave.png",
                    disabled: _busy,
                    onTap: _topUp,
                  ),
                  _OperatorTile(
                    label: "Orange",
                    asset: "assets/images/operators/orange.png",
                    disabled: _busy,
                    onTap: _topUp,
                  ),
                  _OperatorTile(
                    label: "MTN",
                    asset: "assets/images/operators/mtn.png",
                    disabled: _busy,
                    onTap: _topUp,
                  ),
                  _OperatorTile(
                    label: "Moov",
                    asset: "assets/images/operators/moov.png",
                    disabled: _busy,
                    onTap: _topUp,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "⚠️ Le solde sera mis à jour après confirmation.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= OPERATOR TILE =================

class _OperatorTile extends StatelessWidget {
  final String label;
  final String asset;
  final bool disabled;
  final void Function({required int amount}) onTap;

  const _OperatorTile({
    required this.label,
    required this.asset,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: disabled
          ? null
          : () async {
              final amount = await _amountDialog(context);
              if (amount != null && amount > 0) {
                onTap(amount: amount);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.payments),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: disabled ? Colors.grey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _amountDialog(BuildContext context) {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Top-up with $label"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Amount (FCFA)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v > 0) {
                Navigator.pop(ctx, v);
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
