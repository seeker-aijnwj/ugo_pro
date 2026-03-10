import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/models/announce_data.dart';
import 'package:u_go/modules/booking_module/widgets/announce_form.dart';

class EditAnnounceScreen extends StatefulWidget {
  /// Référence Firestore de l'annonce: users/{driverId}/announces/{announceId}
  final DocumentReference annonceRef;

  const EditAnnounceScreen({super.key, required this.annonceRef});

  @override
  State<EditAnnounceScreen> createState() => _EditAnnounceScreenState();
}

class _EditAnnounceScreenState extends State<EditAnnounceScreen> {
  AnnounceData? _current; // ce que l'utilisateur édite
  bool _saving = false;

  // ---------- Helpers UI ----------
  void _showSmallSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        behavior: SnackBarBehavior.floating, // bulle flottante
        margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Helpers de mapping Firestore <-> AnnounceData ---

  AnnounceData _toAnnounceData(Map<String, dynamic> m) {
    // On accepte plusieurs noms possibles selon tes anciens schémas
    String readString(List<String> keys) {
      for (final k in keys) {
        final v = m[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return '';
    }

    // Date/heure : on lit departureAt si dispo, sinon rien
    DateTime? date;
    TimeOfDay? time;
    final ts = m['departureAt'];
    if (ts != null && ts is Timestamp) {
      final dt = ts.toDate();
      date = DateTime(dt.year, dt.month, dt.day);
      time = TimeOfDay(hour: dt.hour, minute: dt.minute);
    }

    // Stops
    final stopsRaw = (m['stops'] ?? []) as List<dynamic>;
    final stops = stopsRaw.map((e) => e.toString()).toList();

    // Prix/places
    int? readInt(String k) {
      final v = m[k];
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    return AnnounceData(
      depart: readString([
        'departure',
        'depart',
        'from',
        'start',
        'fromPlace',
        'departLabel',
      ]),
      destination: readString([
        'destination',
        'to',
        'arrival',
        'destinationLabel',
      ]),
      meetingPlace: readString(['meetingPlace', 'meeting', 'rendezvous']),
      arrivalPlace: readString(['arrivalPlace', 'dropPlace', 'dropoff']),
      date: date,
      time: time,
      stops: stops,
      seats: readInt('seats'),
      price: readInt('price'),
    );
  }

  /// Construit la payload de mise à jour à partir de l'état courant.
  Map<String, dynamic> _toFirestoreUpdate(
    AnnounceData d,
    Map<String, dynamic> existing,
  ) {
    // Recompose departureAt + timeText si date+heure fournis
    Timestamp? departureAt;
    String? timeText;

    if (d.date != null && d.time != null) {
      final merged = DateTime(
        d.date!.year,
        d.date!.month,
        d.date!.day,
        d.time!.hour,
        d.time!.minute,
      );
      // On stocke en UTC (cohérent côté serveur/clients)
      departureAt = Timestamp.fromDate(merged.toUtc());
      final hh = d.time!.hour.toString().padLeft(2, '0');
      final mm = d.time!.minute.toString().padLeft(2, '0');
      timeText = '$hh:$mm';
    }

    // On n’écrase PAS les champs sensibles (reservedSeats, userId, userCustomId, status)
    // On met à jour uniquement ce qui dépend du formulaire
    final map = <String, dynamic>{
      if (d.depart.trim().isNotEmpty) 'departure': d.depart.trim(),
      if (d.destination.trim().isNotEmpty) 'destination': d.destination.trim(),
      'meetingPlace': d.meetingPlace.trim(),
      'arrivalPlace': d.arrivalPlace.trim(),
      'stops': d.stops,
      if (d.seats != null) 'seats': d.seats,
      if (d.price != null) 'price': d.price,
      if (departureAt != null) 'departureAt': departureAt,
      if (timeText != null) 'timeText': timeText,
    };

    return map;
  }

  Future<void> _save(DocumentSnapshot doc) async {
    if (_current == null) {
      _showSmallSnack(context, 'Formulaire incomplet.');
      return;
    }

    // Validation minimale (à adapter si tu veux)
    if (_current!.depart.trim().isEmpty ||
        _current!.destination.trim().isEmpty ||
        _current!.date == null ||
        _current!.time == null) {
      _showSmallSnack(
        context,
        'Départ, destination, date et heure sont requis.',
      );
      return;
    }

    try {
      setState(() => _saving = true);

      final existing = (doc.data() ?? {}) as Map<String, dynamic>;
      final update = _toFirestoreUpdate(_current!, existing);

      await widget.annonceRef.update(update);

      if (!mounted) return;
      _showSmallSnack(context, 'Annonce mise à jour avec succès.');
      Navigator.of(context).pop(true); // renvoie true pour rafraîchir si besoin
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSmallSnack(context, 'Firebase: ${e.message ?? e.code}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSmallSnack(context, 'Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.annonceRef.snapshots(),
      builder: (context, snap) {
        final loading = !snap.hasData && !snap.hasError;

        return Scaffold(
          appBar: AppBar(title: const Text('Modifier l’annonce')),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : snap.hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Impossible de charger l’annonce.\n${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _buildForm(context, snap.data!),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                onPressed: _saving || !(snap.hasData)
                    ? null
                    : () => _save(snap.data!),
                label: Text(
                  _saving
                      ? 'Enregistrement...'
                      : 'Enregistrer les modifications',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, DocumentSnapshot doc) {
    final raw = (doc.data() ?? {}) as Map<String, dynamic>;
    final initial = _toAnnounceData(raw);

    // Au premier build, si _current est null, on le définit pour ne pas perdre les valeurs
    _current ??= initial;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: AnnounceForm(
        initialData: _current, // alimente les champs
        onChanged: (d) => _current = d, // garde l’état au fil de la saisie
      ),
    );
  }
}
