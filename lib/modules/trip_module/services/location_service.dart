import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Fournit un stream de Position haute précision (foreground).
/// Encapsule la demande de permission + settings.
class LocationService {
  StreamSubscription<Position>? _sub;

  /// Demande les permissions et vérifie que la localisation est active.
  static Future<void> ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Laisse l'app inviter l'utilisateur à activer le GPS
      await Geolocator.openLocationSettings();
      throw Exception('La localisation est désactivée.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permission localisation refusée de façon permanente. Active-la dans les réglages.');
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Permission localisation refusée.');
    }
  }

  /// Retourne un stream de positions pour du suivi temps réel.
  Stream<Position> positionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilterMeters = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    );
  }

  /// Récupère la dernière position connue (utile au boot de la carte).
  static Future<Position?> getLastKnown() => Geolocator.getLastKnownPosition();

  /// Arrête un éventuel abonnement manuel (si tu en fais un dans un ViewModel).
  Future<void> cancel() async {
    await _sub?.cancel();
    _sub = null;
  }
}
