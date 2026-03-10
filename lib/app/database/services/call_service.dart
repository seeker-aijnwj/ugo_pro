// lib/app/core/services/call_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart'; // optionnel
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart'; // optionnel

const String _defaultCountryCode = '225';

// --- utils ---
void _smallSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
    ),
  );
}

String _normalizePhone(String raw, {String? defaultCountryCode}) {
  final t = raw.trim();
  if (t.startsWith('+')) {
    return '+${t.replaceAll(RegExp(r'[^0-9+]'), '').replaceFirst('+', '')}';
  }
  if (t.startsWith('00')) {
    final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
    return '+${digits.substring(2)}';
  }
  final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('0') && (defaultCountryCode ?? '').isNotEmpty) {
    return '+$defaultCountryCode${digits.substring(1)}';
  }
  return digits;
}

Future<void> _openDialer(BuildContext context, String rawPhone) async {
  final normalized = _normalizePhone(
    rawPhone,
    defaultCountryCode: _defaultCountryCode,
  );
  final ok = await launchUrl(
    Uri(scheme: 'tel', path: normalized),
    mode: LaunchMode.externalApplication,
  );
  if (!ok) _smallSnack(context, "Impossible d’ouvrir l’app Téléphone.");
}

Future<void> _tryDirectCallOrFallback(
  BuildContext context,
  String rawPhone,
) async {
  final normalized = _normalizePhone(
    rawPhone,
    defaultCountryCode: _defaultCountryCode,
  );
  if (!Platform.isAndroid) {
    await _openDialer(context, normalized);
    return;
  }
  var status = await Permission.phone.status;
  if (!status.isGranted) status = await Permission.phone.request();

  if (status.isGranted) {
    final ok = await FlutterPhoneDirectCaller.callNumber(normalized);
    if (ok == true) return;
  } else {
    _smallSnack(context, "Permission d’appel refusée. Ouverture du composeur…");
  }
  await _openDialer(context, normalized);
}

/// -------- PUBLIC: classe visible partout --------
class DriverHints {
  final String? driverId; // id Firestore du conducteur
  final String? inlinePhone; // si tu as déjà le numéro
  const DriverHints({this.driverId, this.inlinePhone});
}

/// Fonction principale
Future<void> callDriver(
  BuildContext context,
  DriverHints hints, {
  bool preferDirectCall = false,
}) async {
  try {
    // 1) Numéro déjà fourni ?
    if ((hints.inlinePhone ?? '').trim().isNotEmpty) {
      final p = hints.inlinePhone!.trim();
      return preferDirectCall
          ? _tryDirectCallOrFallback(context, p)
          : _openDialer(context, p);
    }

    // 2) Sinon, on lit users/{driverId}
    final driverId = hints.driverId?.trim();
    if (driverId == null || driverId.isEmpty) {
      _smallSnack(
        context,
        "Impossible de trouver l’identifiant du conducteur.",
      );
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .get();
    if (!snap.exists || snap.data() == null) {
      _smallSnack(context, "Conducteur introuvable.");
      return;
    }
    final phone = (snap.data()!['numero']?.toString() ?? '').trim();
    if (phone.isEmpty) {
      _smallSnack(context, "Aucun numéro enregistré pour le conducteur.");
      return;
    }

    preferDirectCall
        ? await _tryDirectCallOrFallback(context, phone)
        : await _openDialer(context, phone);
  } on FirebaseException catch (e) {
    _smallSnack(context, "Firebase : ${e.message ?? e.code}");
  } catch (e) {
    _smallSnack(context, "Erreur : $e");
  }
}

/// (Facultatif) helpers si tu ne veux pas créer DriverHints
Future<void> callDriverById(
  BuildContext c,
  String driverId, {
  bool preferDirectCall = false,
}) => callDriver(
  c,
  DriverHints(driverId: driverId),
  preferDirectCall: preferDirectCall,
);

Future<void> callNumber(
  BuildContext c,
  String phone, {
  bool preferDirectCall = false,
}) => callDriver(
  c,
  DriverHints(inlinePhone: phone),
  preferDirectCall: preferDirectCall,
);
