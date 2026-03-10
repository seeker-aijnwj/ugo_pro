import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:u_go/app/core/utils/colors.dart';

import 'package:u_go/modules/booking_module/widgets/passenger_activity_graph.dart';
import 'package:u_go/modules/booking_module/widgets/reservation_card.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/modules/booking_module/services/passenger_dashboard_service.dart';

class DashboardPassengerScreen extends StatefulWidget {
  const DashboardPassengerScreen({super.key});

  @override
  State<DashboardPassengerScreen> createState() =>
      _DashboardPassengerScreenState();
}

class _DashboardPassengerScreenState extends State<DashboardPassengerScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  late final PassengerDashboardService _service;

  Future<PassengerGraphPayload>? _graphFut;
  int _selectedMonthIndex = 0;
  bool _graphIndexInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _service = PassengerDashboardService(_db);

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _graphFut = _service.getPassengerGraphPayload(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Suivi",
          style: TextStyle(fontFamily: 'Agbalumo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // ⚠️ pas de flèche back qui push HomeData : on laisse le bouton physique gérer
        // Optionnel : si tu tiens à un bouton qui ramène à l'onglet 0 :
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     context.findAncestorStateOfType<HomeScreenState>()?.navigateToTab(0);
        //   },
        // ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPassengerGraph(),
            const SizedBox(height: 24),
            _buildReservations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerGraph() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return PassengerActivityGraph(
        averageActivity: const [0, 0, 0, 0, 0, 0, 0],
        months: const ["—", "—", "—", "—"],
        selectedMonthIndex: 0,
        onMonthSelected: (_) {},
      );
    }

    return FutureBuilder<PassengerGraphPayload>(
      future: _graphFut,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _boxed(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snap.hasError) {
          return _boxed(_InfoBox(message: "Erreur (graphe) : ${snap.error}"));
        }
        if (!snap.hasData) {
          return PassengerActivityGraph(
            averageActivity: const [0, 0, 0, 0, 0, 0, 0],
            months: const ["—", "—", "—", "—"],
            selectedMonthIndex: 0,
            onMonthSelected: (_) {},
          );
        }

        final p = snap.data!;
        if (!_graphIndexInitialized) {
          _selectedMonthIndex = p.selectedMonthIndexDefault.clamp(
            0,
            p.months.length - 1,
          );
          _graphIndexInitialized = true;
        } else {
          _selectedMonthIndex = _selectedMonthIndex.clamp(
            0,
            p.months.length - 1,
          );
        }

        return PassengerActivityGraph(
          averageActivity: p.dataByMonth[_selectedMonthIndex],
          months: p.months,
          selectedMonthIndex: _selectedMonthIndex,
          onMonthSelected: (i) => setState(() => _selectedMonthIndex = i),
        );
      },
    );
  }

  Widget _buildReservations(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return _boxed(
        const _InfoBox(
          message: "Veuillez vous connecter pour voir vos réservations.",
        ),
      );
    }

    final query = _db
        .collection('users')
        .doc(uid)
        .collection('reservations')
        .where('passengerId', isEqualTo: uid)
        .where('status', isEqualTo: 'en_cours')
        .orderBy('createdAt', descending: true);

    return _boxed(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TxtComponents(
            txt: "Réservations en cours",
            fw: FontWeight.bold,
            txtSize: 16,
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const _InfoBox(
                  message:
                      "Impossible de charger vos réservations.\nRéessayez plus tard.",
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const _InfoBox(
                  message: "Aucune réservation en cours pour le moment.",
                );
              }

              return Column(
                children: docs.map((doc) {
                  final r = doc.data();

                  final departure = (r['depart'] ?? '').toString();
                  final departureAddress = (r['departureAddress'] ?? '')
                      .toString();
                  final arrival = (r['destination'] ?? '').toString();

                  final dateText = (r['dateText'] ?? '').toString();
                  final timeText = (r['timeText'] ?? '').toString();
                  final price = (r['price'] ?? 0).toString();

                  return ReservationCard(
                    departure: departure,
                    departureAddress: departureAddress,
                    arrival: arrival,
                    arrivalAddress: arrival,
                    date: dateText.isNotEmpty
                        ? dateText
                        : DateFormat("d MMMM", "fr_FR").format(DateTime.now()),
                    time: timeText.isNotEmpty
                        ? timeText
                        : DateFormat("HH:mm", "fr_FR").format(DateTime.now()),
                    price: price,
                    reservationRef: doc.reference,
                    onCanceled: () {},
                    onCall: () {
                      // ⚠️ si tu as supprimé les routes nommées, remplace par un MaterialPageRoute vers l'écran d'appel
                      // Navigator.pushNamed(context, "/call_driver");
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _boxed(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String message;
  const _InfoBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
