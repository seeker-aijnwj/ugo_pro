import 'dart:async';
import 'package:flutter/material.dart';

import '../models/mocks/mock_admin_user.dart';
import '../models/mocks/mock_driver.dart';
import '../models/mocks/mock_faq.dart';
import '../models/mocks/mock_passenger.dart';
import '../models/mocks/mock_ticket.dart';
import '../models/mocks/mock_transaction.dart';
import '../models/trip_ad.dart';


class MockDataService {

  // --- MÉMOIRE TEMPORAIRE (Se réinitialise si on relance l'app) ---
  static final List<TripAd> _trips = [
    TripAd("T-901", "B-22", "M. KOFFI Antoine", Ligne(depart: 'Abidjan', arrivee: 'Bouaké'), 'Gare de Bassam - Treichville', Appointment(date: DateTime.now(), time: TimeOfDay.now()), [], 4, 6500, 0.0, 'programmé', 0, []),
    TripAd("T-908", "B-14", "M. KONE Ousmane", Ligne(depart: 'Abidjan', arrivee: 'Yamoussoukro'), 'Gare UTB Adjamé - Abidjan', Appointment(date: DateTime.now().add(const Duration(hours: 3)), time: TimeOfDay.now()), [], 50, 4500, 0.0, 'programmé', 0, []),
  ];

  static final List<MockDriver> _drivers = [
    MockDriver('DR-01', 'Soro Guillaume', '07 07 08 09 10', 'en_attente', 0.0),
    MockDriver('DR-02', 'Diallo Mamadou', '05 04 03 02 01', 'validé', 4.8),
    MockDriver('DR-03', 'Bamba Seydou', '01 02 03 04 05', 'bloqué', 2.5),
  ];

  static final List<MockTicket> _tickets = [
    MockTicket('TKT-001', 'USR-99', 'Awa Diop', 'Bagage oublié dans le car', 'ouvert', 'haute', 
      ['Bonjour, j\'ai oublié mon sac rouge ligne Abidjan-Bouaké.', 'Merci de vérifier avec le chauffeur SVP.']),
    MockTicket('TKT-002', 'USR-54', 'Jean-Marc K.', 'Problème de paiement', 'résolu', 'moyenne', 
      ['Mon compte a été débité deux fois.', 'C\'est réglé, merci.']),
    MockTicket('TKT-003', 'USR-12', 'Moussa T.', 'Chauffeur dangereux', 'ouvert', 'haute', 
      ['Le chauffeur roulait trop vite !', 'Je demande une sanction.']),
  ];

  static final List<MockFAQ> _faqs = [
    MockFAQ('FAQ-01', 'Comment annuler mon billet ?', 'Allez dans "Mes Trajets", sélectionnez le billet et cliquez sur Annuler.', true),
    MockFAQ('FAQ-02', 'Quels sont les modes de paiement ?', 'Nous acceptons Orange Money, Wave et MTN.', true),
    MockFAQ('FAQ-03', 'Bagage supplémentaire', 'Tout bagage > 20kg est facturé 1000F.', false),
  ];

  static Future<List<MockFAQ>> getFAQs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_faqs);
  }

  static final List<MockTransaction> _transactions = [
    MockTransaction('TX-998', 'ticket_in', 'Billet Abidjan-Bouaké (Awa D.)', 5500, 'Wave', DateTime.now().subtract(const Duration(minutes: 5)), 'succès'),
    MockTransaction('TX-997', 'ticket_in', 'Billet Korhogo-Abidjan', 10000, 'Orange Money', DateTime.now().subtract(const Duration(minutes: 12)), 'succès'),
    MockTransaction('TX-996', 'payout_out', 'Retrait Chauffeur (Koné M.)', -25000, 'MTN', DateTime.now().subtract(const Duration(hours: 1)), 'en_attente'),
    MockTransaction('TX-995', 'ticket_in', 'Billet Express', 6000, 'Wave', DateTime.now().subtract(const Duration(hours: 2)), 'succès'),
    MockTransaction('TX-994', 'payout_out', 'Règlement Partenaire', -150000, 'Virement', DateTime.now().subtract(const Duration(days: 1)), 'succès'),
  ];

  // --- GESTION TRAJETS ---
  static Future<List<TripAd>> getTrips() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Latence artificielle
    return List.from(_trips); // Retourne une copie pour l'affichage
  }

  static Future<void> addTrip(TripAd trip) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Latence "écriture"
    _trips.insert(0, trip); // Ajoute en haut de la liste
  }

  // --- GESTION CHAUFFEURS ---
  static Future<List<MockDriver>> getDrivers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_drivers);
  }

  static Future<void> validateDriver(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _drivers.indexWhere((d) => d.id == id);
    if (index != -1) {
      _drivers[index].status = 'validé';
    }
  }

  static Future<void> deleteDriver(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _drivers.removeWhere((d) => d.id == id);
  }

  static Future<List<MockTicket>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tickets);
  }

  static Future<void> closeTicket(String id) async {
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index != -1) {
      // Astuce pour modifier un champ final en démo : on recrée l'objet ou on le rend mutable (plus simple ici de rendre mutable)
      // Pour faire simple dans le code existant, supposons que vous avez rendu les champs 'status' mutables (non final)
      // Sinon :
      // _tickets[index] = MockTicket(...copie avec nouveau statut...);
    }
  }
  
  // Simulation : Bannir un utilisateur
  static Future<void> banUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // En vrai, on changerait un flag dans la table Users
  }

  static final List<MockPassenger> _passengers = [
    MockPassenger('USR-01', 'Awa Diop', '01 02 03 04 05', 12, 'actif'),
    MockPassenger('USR-02', 'Koffi Jean', '05 06 07 08 09', 3, 'bloqué'),
    MockPassenger('USR-03', 'Marie Koné', '07 08 09 10 11', 45, 'actif'),
  ];

  static final List<MockAdminUser> _admins = [
    MockAdminUser('ADM-01', 'Vous (Admin)', 'Super Admin', 'actif'),
    MockAdminUser('SUP-01', 'Paul Manager', 'Responsable Support', 'actif'),
    MockAdminUser('MOD-01', 'Eric Sécu', 'Modérateur', 'suspendu'),
  ];

  // Getters
  static Future<List<MockPassenger>> getPassengers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_passengers);
  }

  static Future<List<MockAdminUser>> getAdmins() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_admins);
  }

  static Future<List<MockTransaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_transactions);
  }

  // Ajouter une transaction manuelle
  static Future<void> addTransaction(MockTransaction tx) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Latence réseau simulée
    _transactions.insert(0, tx); // Ajoute en haut de la liste
  }

  // Action : Valider un retrait
  static Future<void> approvePayout(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index].statut = 'succès';
    }
  }
 
  // --- STATISTIQUES SIMPLIFIÉES ---
  static Future<Map<String, dynamic>> getStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'revenue_day': 125000,
      'revenue_month': 4500000,
      'active_drivers': 42,
      'total_users': 1250,
      'satisfaction': 4.7,
    };
  }

  // --- STATISTIQUES GLOBALES ---
  static Future<Map<String, dynamic>> getGlobalStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // On calcule dynamiquement basé sur les listes actuelles
    int tripsCount = _trips.length;
    int driversCount = _drivers.length;
    int pendingDrivers = _drivers.where((d) => d.status == 'en_attente').length;
    
    // Simulation revenue
    int revenue = _trips.fold(0, (sum, t) => sum + (t.prix * 14)); // Supposons 14 places vendues/trajet

    return {
      'revenue': revenue,
      'trips': tripsCount,
      'drivers': driversCount,
      'pending_drivers': pendingDrivers,
      'users': 1240, // Statique pour l'instant
    };
  }

}