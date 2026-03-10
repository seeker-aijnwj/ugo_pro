// Cette page permet de créer une annonce de covoiturage.
// Elle utilise un formulaire (AnnounceForm) pour collecter les données.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_document_upload_screen.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/modules/booking_module/widgets/announce_form.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/modules/booking_module/models/announce_data.dart';

// Ajouts:
import 'package:u_go/modules/booking_module/services/announce_prefill_service.dart';
import 'package:u_go/modules/booking_module/models/announce_draft.dart';

// ✅ Ajouts pour le débit wallet et redirection
import 'package:u_go/app/database/services/wallet_service.dart';
import 'package:u_go/modules/payment_module/screens/my_wallet_screen.dart';

class AnnounceScreen extends StatefulWidget {
  const AnnounceScreen({super.key});

  @override
  State<AnnounceScreen> createState() => _AnnounceScreenState();
}

class _AnnounceScreenState extends State<AnnounceScreen> {
  AnnounceData? _currentData;
  AnnounceData? _initialFromDraft;
  bool _loading = false;

  static const int _announceFee = 50; // 💸 frais d'annonce

  @override
  void initState() {
    super.initState();
    // Consommer un éventuel draft déposé par l’Historique
    final draft = AnnouncePrefillService().takeDraft();
    if (draft != null) {
      _initialFromDraft = _convertDraftToData(draft);
    }
  }

  AnnounceData _convertDraftToData(AnnounceDraft d) {
    return AnnounceData(
      depart: d.depart,
      destination: d.destination,
      meetingPlace: d.meetingPlace,
      arrivalPlace: d.arrivalPlace, // NEW
      date: d.date,
      time: d.time,
      stops: const [],
      seats: d.seats,
      price: d.price,
    );
  }

  Future<bool> _confirmDebitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmer la publication'),
            content: Text(
              '$_announceFee FCFA seront débités de votre porte-monnaie pour publier cette annonce.\n\n'
              'Voulez-vous continuer ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Valider'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _saveAndGo() async {
    final data = _currentData;

    if (data == null || !data.isMinimalValid) {
      _toastTop(
        "Veuillez remplir tous les champs obligatoires (départ, destination, lieu de rencontre, date, heure, places, prix).",
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _toastTop("Vous devez être connecté pour publier une annonce.");
        setState(() => _loading = false);
        return;
      }

      // 🔐 Demande de confirmation avec le montant
      final confirmed = await _confirmDebitDialog();
      if (!confirmed) {
        setState(() => _loading = false);
        return;
      }

      // 💳 Débit des 50 FCFA AVANT l’enregistrement de l’annonce
      // Idempotence: clé basée sur uid + ANNOUNCE_FEE + date + time + depart + destination
      final idKey =
          '${user.uid}|ANNOUNCE_FEE|${data.date}_${data.time}|${data.depart}|${data.destination}';

      await WalletService.instance.debit(
        uid: user.uid,
        amount: _announceFee,
        reason: 'ANNOUNCE_FEE',
        tripId: null,
        idempotencyKey: idKey,
      );

      // 1) Lire customId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userCustomId = userDoc.data()?['customId'] as String?;
      if (userCustomId == null || userCustomId.isEmpty) {
        _toastTop(
          "Votre compte n'a pas encore de numéro (customId). Réessayez après connexion.",
        );
        setState(() => _loading = false);
        return;
      }

      // 2) Construire payload
      final payload = data.toJson(userId: user.uid)
        ..addAll({
          'userCustomId': userCustomId,
          'createdAt': FieldValue.serverTimestamp(),
          'reservedSeats': 0,
        });

      // 3) Enregistrer
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('announces')
          .add(payload);

      // 4) Numéro lisible
      final number = 'AN-${docRef.id.substring(0, 6).toUpperCase()}';
      await docRef.update({'announceNumber': number});

      // 5) Continuer le flow
      if (!mounted) return;
      _toastTop("Annonce publiée ✅  (−$_announceFee FCFA)");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DriverDocumentUploadScreen()),
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('NEED_TOPUP')) {
        // Solde insuffisant → redirection vers My Wallet
        if (!mounted) return;
        _toastTop("Solde insuffisant. Veuillez recharger votre porte-monnaie.");
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MyWalletScreen()));
      } else {
        _toastTop("Erreur lors de l’enregistrement: $e");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toastTop(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Annoncer",
          style: TextStyle(fontFamily: 'Agbalumo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context
              .findAncestorStateOfType<DriverHomeScreenState>()
              ?.navigateToTab(0),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnnounceForm(
              initialData: _initialFromDraft, // <-- pré-remplissage
              onChanged: (data) => _currentData = data,
            ),

            const SizedBox(height: 20),
            Center(
              child: ButtonComponent(
                txtButton: _loading ? "Enregistrement..." : "Valider",
                colorButton: secondColor,
                colorText: Colors.white,
                onPressed: _loading ? null : _saveAndGo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
