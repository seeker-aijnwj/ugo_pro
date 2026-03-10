// Cette page affiche le tableau de bord du conducteur.
// Elle montre un résumé, un graphique et les annonces récentes.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/driver/driver_home_screen.dart';
import 'package:u_go/modules/booking_module/screens/driver/edit_announce_screen.dart';
import 'package:u_go/modules/booking_module/widgets/announce_card.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:u_go/app/widgets/dashboard_summary.dart';
import 'package:u_go/app/widgets/dashboard_graph.dart';
import 'package:u_go/app/database/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  late final DashboardService _service;

  int _selectedMonthIndex = 0;
  bool _graphIndexInitialized = false;

  @override
  void initState() {
    super.initState();
    _service = DashboardService(_db);
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
        // ✅ Pas de pop/push — on reste dans le shell
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context
                .findAncestorStateOfType<DriverHomeScreenState>()
                ?.navigateToTab(0);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildSummary()),
              const SizedBox(height: 24),
              _buildGraph(),
              const SizedBox(height: 24),
              _buildAnnonces(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final user = _auth.currentUser;
    if (user == null) {
      return const DashboardSummary(annonces: 0, passagers: 0, note: 3.0);
    }
    return StreamBuilder<DashboardSummaryModel>(
      stream: _service.watchSummary(user.uid),
      builder: (context, snap) {
        final s = snap.data;
        return DashboardSummary(
          annonces: s?.annonces ?? 0,
          passagers: s?.passagers ?? 0,
          note: s?.note ?? 3.0,
        );
      },
    );
  }

  Widget _buildGraph() {
    final user = _auth.currentUser;
    if (user == null) {
      return DashboardGraph(
        data: const [0, 0, 0, 0, 0, 0, 0],
        months: const ["—", "—", "—", "—"],
        selectedMonthIndex: 0,
        onMonthSelected: (_) {},
      );
    }

    return StreamBuilder<DashboardGraphPayload>(
      stream: _service.watchGraphPayload(user.uid),
      builder: (context, snap) {
        final p = snap.data;
        if (p == null) {
          return DashboardGraph(
            data: const [0, 0, 0, 0, 0, 0, 0],
            months: const ["—", "—", "—", "—"],
            selectedMonthIndex: 0,
            onMonthSelected: (_) {},
          );
        }

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

        return StatefulBuilder(
          builder: (context, setInner) {
            return DashboardGraph(
              data: p.dataByMonth[_selectedMonthIndex],
              months: p.months,
              selectedMonthIndex: _selectedMonthIndex,
              onMonthSelected: (i) => setInner(() => _selectedMonthIndex = i),
            );
          },
        );
      },
    );
  }

  Widget _buildAnnonces(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return _boxed(child: _emptyBox("Connectez-vous pour voir vos annonces."));
    }

    final query = _db
        .collection('users')
        .doc(user.uid)
        .collection('announces')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(10);

    return _boxed(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TxtComponents(
            txt: "Annonces en cours",
            fw: FontWeight.bold,
            txtSize: 16,
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return _emptyBox("Erreur Firestore : ${snap.error}");
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return _emptyBox("Aucune annonce pour le moment.");
              }

              final docs = snap.data!.docs;

              return Column(
                children: docs.map((doc) {
                  final Map<String, dynamic> d =
                      doc.data() as Map<String, dynamic>;

                  final depart = (d['depart'] ?? '') as String;
                  final destination = (d['destination'] ?? '') as String;
                  final meeting = (d['meetingPlace'] ?? '') as String;
                  final arrival = (d['arrivalPlace'] ?? '') as String;

                  final dateText = (d['dateText'] ?? '') as String;
                  final timeText = (d['timeText'] ?? '') as String;

                  final price = (d['price'] ?? 0).toString();
                  final seats = (d['seats'] as num?)?.toInt() ?? 0;
                  final reservedSeats =
                      (d['reservedSeats'] as num?)?.toInt() ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnnonceCard(
                      departure: depart,
                      departureAddress: meeting,
                      arrival: destination,
                      arrivalAddress: arrival,
                      date: dateText,
                      time: timeText,
                      price: price,
                      seats: seats,
                      reservedSeats: reservedSeats,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            // ⬇️ passe la bonne ref du doc courant
                            builder: (_) =>
                                EditAnnounceScreen(annonceRef: doc.reference),
                          ),
                        );
                      },
                      annonceRef: doc.reference,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _boxed({required Widget child}) {
    return Container(
      width: double.infinity,
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

  Widget _emptyBox(String msg) {
    return Row(
      children: [
        Icon(Icons.info_outline, color: secondColor),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ],
    );
  }
}
