// Modèle Trajet (Mutable)
import 'package:flutter/material.dart';

class Ligne {
  const Ligne({
    required this.depart, 
    required this.arrivee
  });

  final String depart;
  final String arrivee;
  String get fullRoute => '$depart ➔ $arrivee';
}

class Appointment {
  final DateTime? date; // vraie date sélectionnée
  final TimeOfDay? time; // vraie heure sélectionnée
  
  Appointment({
    required this.date,
    required this.time,
  });
}

class TripAd {
  final String id;
  final String vehiculeNumber;
  final String driverName;
  final Ligne route;
  final String meetPoint;
  final Appointment appointment; // Date et heure de départ 
  int totalSeats = 4;
  int reservedSeats = 0;
  List<String> passengers = []; // Noms des passagers
  List<String> stops = []; // Noms des arrêts
  int prix = 1000; // Prix par siège
  double progress = 0.0; // 0.0 à 1.0 pour le GPS
  String statut = 'programmé'; // 'programmé', 'en_cours', 'terminé', 'annulé'

  TripAd(
    this.id, 
    this.vehiculeNumber,
    this.driverName, 
    this.route, 
    this.meetPoint,
    this.appointment,
    this.stops,
    this.totalSeats,
    this.prix,
    this.progress,
    this.statut,
    this.reservedSeats,
    this.passengers
  );
}