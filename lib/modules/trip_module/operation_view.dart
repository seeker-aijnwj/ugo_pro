import 'package:flutter/material.dart';
import 'package:ugo_pro/core/themes/admin_light_theme.dart';
import 'package:ugo_pro/data/models/trip_ad.dart';


// ==============================================================================
// 3. LA VUE PRINCIPALE (OperationView)
// ==============================================================================

class OperationView extends StatefulWidget {
  const OperationView({super.key});

  @override
  State<OperationView> createState() => _OperationViewState();
}

class _OperationViewState extends State<OperationView> {
  // État local
  TripAd? _selectedTrip;
  String _filterStatus = 'Tous'; // Filtre par défaut

  // Données fictives basées sur VOTRE modèle TripAd
  final List<TripAd> _allTrips = [
    TripAd(
      "T-001", 
      "AB-229-XY", 
      "Moussa Koné", 
      const Ligne(depart: "Abidjan", arrivee: "Bouaké"), 
      "Gare Adjamé Nord",
      Appointment(date: DateTime.now().add(const Duration(hours: 2)), time: const TimeOfDay(hour: 10, minute: 30)),
      ["N'Zianouan", "Toumodi", "Yamoussoukro"],
      70, 
      6500, 
      0.0, 
      "programmé", 
      45, 
      ["Alice", "Bob", "Charlie"]
    ),
    TripAd(
      "T-002", 
      "BK-888-ZZ", 
      "Jean Yves", 
      const Ligne(depart: "Abidjan", arrivee: "Korhogo"), 
      "Gare Yopougon",
      Appointment(date: DateTime.now().subtract(const Duration(hours: 3)), time: const TimeOfDay(hour: 06, minute: 00)),
      ["Bouaké", "Katiola", "Niakara"],
      70, 
      12000, 
      0.45, // 45% du trajet effectué
      "en cours", 
      68, 
      ["David", "Eve"]
    ),
    TripAd(
      "T-003", 
      "CI-101-AA", 
      "Traoré B.", 
      const Ligne(depart: "San-Pedro", arrivee: "Abidjan"), 
      "Gare Routière",
      Appointment(date: DateTime.now().subtract(const Duration(days: 1)), time: const TimeOfDay(hour: 14, minute: 00)),
      ["Sassandra", "Grand-Lahou"],
      50, 
      8000, 
      1.0, 
      "terminé", 
      50, 
      []
    ),
     TripAd(
      "T-004", 
      "XX-000-XX", 
      "N/A", 
      const Ligne(depart: "Abidjan", arrivee: "Man"), 
      "Gare Adjamé",
      Appointment(date: DateTime.now(), time: const TimeOfDay(hour: 08, minute: 00)),
      [],
      60, 
      9000, 
      0.0, 
      "annulé", 
      0, 
      []
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Détection Desktop / Mobile
    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    // Logique de filtrage
    List<TripAd> filteredTrips = _allTrips.where((t) {
      if (_filterStatus == 'Tous') return true;
      return t.statut == _filterStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // -----------------------------------------------------------
          // ZONE GAUCHE : LISTE DES VOYAGES
          // -----------------------------------------------------------
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFilterBar(),
                  Expanded(
                    child: _buildTripList(filteredTrips, isDesktop),
                  ),
                ],
              ),
            ),
          ),
          
          // Séparateur vertical (uniquement sur Desktop)
          if (isDesktop) VerticalDivider(width: 1, color: Colors.grey.shade300),

          // -----------------------------------------------------------
          // ZONE DROITE : DÉTAILS (Uniquement sur Desktop)
          // -----------------------------------------------------------
          if (isDesktop)
            Expanded(
              flex: 7, // La zone de détails est plus large
              child: Container(
                color: UGOAdminTheme.background,
                child: _selectedTrip != null 
                  ? _buildDetailView(_selectedTrip!) 
                  : _buildEmptyState(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGETS DE LA LISTE (GAUCHE)
  // ============================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
      ),
      child: Row(
        children: [
          const Icon(Icons.departure_board, color: UGOAdminTheme.primaryBlue),
          const SizedBox(width: 10),
          const Text('TRAJETS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: UGOAdminTheme.primaryBlue)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Création d'un nouveau trajet...")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UGOAdminTheme.accentOrange,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("NOUVEAU"),
          )
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final statuses = ['Tous', 'programmé', 'en cours', 'terminé', 'annulé'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (c, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _filterStatus == status;
          return ChoiceChip(
            label: Text(status.toUpperCase()),
            selected: isSelected,
            onSelected: (val) => setState(() => _filterStatus = status),
            selectedColor: UGOAdminTheme.primaryBlue.withValues(alpha: 0.1),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? UGOAdminTheme.primaryBlue : UGOAdminTheme.greyText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11
            ),
            side: isSelected ? const BorderSide(color: UGOAdminTheme.primaryBlue) : BorderSide(color: Colors.grey.shade300),
          );
        },
      ),
    );
  }

  Widget _buildTripList(List<TripAd> trips, bool isDesktop) {
    if (trips.isEmpty) {
      return const Center(child: Text("Aucun voyage trouvé pour ce statut."));
    }

    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final isSelected = _selectedTrip?.id == trip.id;
        final color = _getStatusColor(trip.statut);
        
        // Formatage simple de la date/heure
        final dateStr = trip.appointment.date != null 
            ? "${trip.appointment.date!.day}/${trip.appointment.date!.month}" 
            : "--/--";
        final timeStr = trip.appointment.time != null 
            ? "${trip.appointment.time!.hour}h${trip.appointment.time!.minute.toString().padLeft(2, '0')}" 
            : "--h--";

        return Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100))
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            selected: isDesktop && isSelected,
            selectedTileColor: UGOAdminTheme.primaryBlue.withValues(alpha: 0.05),
            
            // Icône de statut
            leading: Container(
              width: 45, height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), 
                borderRadius: BorderRadius.circular(10)
              ),
              child: Icon(Icons.directions_bus, color: color),
            ),
            
            // Titre et Sous-titre
            title: Text(
              trip.route.fullRoute, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Dép: $dateStr à $timeStr", style: const TextStyle(fontSize: 12)),
                Text("${trip.reservedSeats}/${trip.totalSeats} places • ${trip.vehiculeNumber}", 
                  style: TextStyle(fontSize: 11, color: UGOAdminTheme.greyText)),
              ],
            ),
            
            // Badge à droite
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4)
              ),
              child: Text(trip.statut.toUpperCase(), style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
            ),
            
            onTap: () {
              if (isDesktop) {
                setState(() => _selectedTrip = trip);
              } else {
                // Version Mobile : Navigation vers une nouvelle page
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => Scaffold(
                    appBar: AppBar(title: Text("Détails ${trip.id}")),
                    body: _buildDetailView(trip), // On réutilise la même vue détail
                  ))
                );
              }
            },
          ),
        );
      },
    );
  }

  // ============================================================================
  // WIDGETS DE DÉTAILS (DROITE - OU PAGE MOBILE)
  // ============================================================================

  Widget _buildDetailView(TripAd trip) {
    final color = _getStatusColor(trip.statut);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- EN-TÊTE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(trip.statut.toUpperCase()),
                backgroundColor: color.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
                padding: const EdgeInsets.all(0),
              ),
              Text("ID: ${trip.id}", style: TextStyle(color: UGOAdminTheme.greyText, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(trip.route.fullRoute, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: UGOAdminTheme.primaryBlue)),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: UGOAdminTheme.greyText),
              const SizedBox(width: 5),
              Text("Point de rencontre : ${trip.meetPoint}", style: const TextStyle(color: UGOAdminTheme.greyText)),
            ],
          ),
          const SizedBox(height: 25),

          // --- INFO GRID (Chauffeur, Prix, Véhicule) ---
          Row(
            children: [
              Expanded(child: _buildInfoCard(Icons.person, "Chauffeur", trip.driverName)),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoCard(Icons.directions_car, "Véhicule", trip.vehiculeNumber)),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoCard(Icons.payments, "Prix Ticket", "${trip.prix} FCFA")),
            ],
          ),
          const SizedBox(height: 25),

          // --- GPS TRACKING (Si en cours) ---
          if (trip.statut == 'en cours') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("SUIVI TEMPS RÉEL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                       Text("${(trip.progress * 100).toInt()}% Complété", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                     ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: trip.progress, color: Colors.green, backgroundColor: Colors.green.shade50, minHeight: 8),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],

          // --- ITINÉRAIRE ET ARRÊTS ---
          const Text("Itinéraire & Arrêts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildStopLine("DÉPART", trip.route.depart, isFirst: true),
                // Affichage dynamique des arrêts
                ...trip.stops.map((s) => _buildStopLine("ARRÊT", s)), // .toList(),
                _buildStopLine("ARRIVÉE", trip.route.arrivee, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // --- PASSAGERS ---
          Text("Passagers (${trip.passengers.length}/${trip.reservedSeats})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: trip.passengers.isEmpty 
              ? const Text("Aucun passager enregistré.", style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trip.passengers.map((p) => Chip(
                    avatar: CircleAvatar(child: Text(p[0])),
                    label: Text(p),
                    backgroundColor: Colors.grey.shade100,
                  )).toList(),
                ),
          ),
          const SizedBox(height: 30),

          // --- BOUTONS D'ACTION ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                     // Logique pour modifier le TripAd
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("MODIFIER"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: UGOAdminTheme.primaryBlue)
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text("GÉRER"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UGOAdminTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // --- Petits composants utilitaires pour les détails ---

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]),
          const SizedBox(height: 6),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStopLine(String type, String city, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                // Ligne du haut
                Expanded(child: Container(width: 2, color: isFirst ? Colors.transparent : Colors.grey.shade300)),
                // Point
                Icon(Icons.circle, size: 12, color: isFirst || isLast ? UGOAdminTheme.primaryBlue : Colors.grey),
                // Ligne du bas
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Colors.grey.shade300)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(city, style: TextStyle(fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                  Text(type, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Sélectionnez un voyage\npour voir les détails",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'programmé': return Colors.blue;
      case 'en cours': return const Color(0xFFFF7900); // Orange
      case 'terminé': return UGOAdminTheme.green;
      case 'annulé': return Colors.red;
      default: return Colors.grey;
    }
  }
}