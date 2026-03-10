// Ce composant affiche une carte de suivi en temps réel pour un trajet.
// Côté conducteur, elle publie sa position GPS.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../services/live_location_service.dart';

class TrackingMap extends StatefulWidget {
  final String tripId;
  final bool publishSelf;      // true pour conducteur (publie sa position)
  final bool showSelf;         // afficher sa propre position (marker bleu)
  final String? driverUserId;  // uid conducteur à suivre côté passager (marker rouge)

  const TrackingMap({
    super.key,
    required this.tripId,
    this.publishSelf = false,
    this.showSelf = true,
    this.driverUserId,
  });

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  final MapController _mapController = MapController();
  final LocationService _loc = LocationService();
  final LiveLocationService _live = LiveLocationService(db: FirebaseFirestore.instance);

  StreamSubscription<Position>? _selfSub;
  StreamSubscription? _driverSub;

  LatLng? _selfLatLng;
  LatLng? _driverLatLng;

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  Future<void> _initTracking() async {
    try {
      // Permissions / service localisation
      await LocationService.ensurePermissions();

      // Dernière position connue pour centrer au boot
      final last = await LocationService.getLastKnown();
      if (last != null) {
        _selfLatLng = LatLng(last.latitude, last.longitude);
        _mapController.move(_selfLatLng!, 15);
        setState(() {});
      }

      // Stream position locale
      _selfSub = _loc.positionStream(distanceFilterMeters: 10).listen((pos) async {
        _selfLatLng = LatLng(pos.latitude, pos.longitude);

        // Publier côté conducteur
        if (widget.publishSelf) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            await _live.publish(
              tripId: widget.tripId,
              userId: uid,
              position: pos,
            );
          }
        }

        // Mise à jour visuelle
        if (mounted) {
          setState(() {});
        }
      });

      // Écoute du conducteur côté passager
      if (widget.driverUserId != null) {
        _driverSub = _live
            .watchActor(tripId: widget.tripId, userId: widget.driverUserId!)
            .listen((lp) {
          if (lp == null) return;
          _driverLatLng = LatLng(lp.lat, lp.lng);
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      debugPrint('TrackingMap init error: $e');
    }
  }

  @override
  void dispose() {
    _selfSub?.cancel();
    _driverSub?.cancel();
    super.dispose();
  }

  void _recenterOnMe() {
    if (_selfLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Position indisponible pour l’instant.")),
      );
      return;
    }
    final zoom = _mapController.camera.zoom; // conserve le zoom courant
    _mapController.move(_selfLatLng!, zoom > 0 ? zoom : 15);
  }

  @override
  Widget build(BuildContext context) {
    final center = _selfLatLng ?? const LatLng(5.345317, -4.024429); // Abidjan par défaut
    final markers = <Marker>[];

    // Marker bleu: moi
    if (widget.showSelf && _selfLatLng != null) {
      markers.add(
        Marker(
          width: 60,
          height: 60,
          point: _selfLatLng!,
          child: const _Pin(color: Colors.blue, label: 'Moi'),
        ),
      );
    }

    // Marker rouge: conducteur suivi
    if (_driverLatLng != null) {
      markers.add(
        Marker(
          width: 60,
          height: 60,
          point: _driverLatLng!,
          child: const _Pin(color: Colors.red, label: 'Conducteur'),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'u_go.app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
        ),

        // Bouton "Recentrer sur moi"
        Positioned(
          right: 12,
          bottom: 12,
          child: SafeArea(
            top: false,
            child: FloatingActionButton(
              heroTag: 'recenter_me',
              onPressed: _recenterOnMe,
              mini: true,
              elevation: 2,
              shape: const CircleBorder(),
              child: const Icon(Icons.my_location),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pin extends StatelessWidget {
  final Color color;
  final String label;
  const _Pin({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.location_on, size: 38, color: color),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [BoxShadow(blurRadius: 2, spreadRadius: 1)],
          ),
          child: Text(label, style: const TextStyle(fontSize: 11)),
        ),
      ],
    );
  }
}
