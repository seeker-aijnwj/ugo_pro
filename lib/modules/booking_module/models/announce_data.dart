// lib/models/announce_data.dart
import 'package:flutter/material.dart' show TimeOfDay;

class AnnounceData {
  final String depart;
  final String destination;
  final String meetingPlace;
  final String arrivalPlace; // Nouveau champ
  final DateTime? date; // vraie date sélectionnée
  final TimeOfDay? time; // vraie heure sélectionnée
  final List<String> stops; // arrêts non vides
  final int? seats; // nombre de places
  final int? price; // prix en FCFA

  const AnnounceData({
    required this.depart,
    required this.destination,
    required this.meetingPlace,
    required this.arrivalPlace, // NEW
    required this.date,
    required this.time,
    required this.stops,
    required this.seats,
    required this.price,
  });

  bool get isMinimalValid =>
      depart.isNotEmpty &&
      destination.isNotEmpty &&
      meetingPlace.isNotEmpty &&
      date != null &&
      time != null &&
      seats != null &&
      seats! > 0 &&
      price != null &&
      price! >= 0;

  DateTime? get departureAt {
    if (date == null || time == null) return null;
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }

  Map<String, dynamic> toJson({required String userId}) {
    return {
      'userId': userId,
      'depart': depart,
      'destination': destination,
      'meetingPlace': meetingPlace,
      'arrivalPlace': arrivalPlace, // NEW
      'stops': stops,
      'seats': seats,
      'price': price,
      'dateText': date != null ? "${date!.toLocal()}".split(' ')[0] : null,
      'timeText': time != null
          ? "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}"
          : null,
      'departureAt': departureAt,
      'createdAt': DateTime.now(),
      'status': 'draft',
    };
  }
}
