// lib/models/announce_draft.dart
import 'package:flutter/material.dart';

class AnnounceDraft {
  final String depart;
  final String destination;
  final String meetingPlace; // Lieu de rencontre (départ)
  final String arrivalPlace; // Lieu d’arrivée (point de dépose)
  final DateTime? date;
  final TimeOfDay? time;
  final int? seats;
  final int? price;

  const AnnounceDraft({
    required this.depart,
    required this.destination,
    required this.meetingPlace,
    required this.arrivalPlace,
    required this.date,
    required this.time,
    required this.seats,
    required this.price,
  });
}
