// Code pour représenter une référence à un lieu géographique

import 'dart:convert';
import '../repositories/ci_cities.dart';
import '../repositories/ci_towns.dart';
import '../repositories/ci_quarters.dart';
import '../repositories/ci_places.dart';
import '../repositories/ci_stations.dart';
import '../repositories/ci_hospitals.dart';

// lib/data/models/place_ref.dart
class PlaceRef {
  final String name; // Nom du lieu (ville/commune)
  String? get normalizedName => name.toLowerCase().trim();
  final String? description;
  final String? town; // commune
  final String? city; // ville
  final String? state; // état, province, région
  final String country; // "CI"
  final double? lat; // Optionnel (tu peux ajouter plus tard)
  final double? lon; // Optionnel
  final List<String> tags; // ["commune"], ["ville"], ["prefecture"], ...

  const PlaceRef({
    required this.name,
    required this.country,
    this.description,
    this.town,
    this.city,
    this.state,
    this.lat,
    this.lon,
    this.tags = const [],
  });

  // String get display => admin.isEmpty ? name : "$name, $admin";
  String get display => "$name - ${city ?? ''}, $state";

  factory PlaceRef.fromNominatimJson(Map<String, dynamic> j) {
    final display = j['display_name'] as String? ?? '';
    // petit label court:
    final short =
        j['name'] as String? ??
        (display.contains(',') ? display.split(',').first : display);
    return PlaceRef(
      name: short,
      town: j['town'] as String?,
      city: j['city'] as String?,
      state: j['state'] as String?,
      country: j['country'] as String,
      lat: double.tryParse(j['lat']?.toString() ?? '') ?? 0,
      lon: double.tryParse(j['lon']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'town': town,
    'city': city,
    'state': state,
    'country': country,
    'lat': lat,
    'lon': lon,
  };

  factory PlaceRef.fromJson(Map<String, dynamic> j) => PlaceRef(
    name: j['name'] as String,
    city: j['city'] as String?,
    lat: (j['lat'] as num).toDouble(),
    lon: (j['lon'] as num).toDouble(),
    state: j['state'] as String?,
    country: j['country'] as String,
  );

  static String cacheKey(String query, {String? countryCode}) {
    final q = query.trim().toLowerCase();
    return jsonEncode({'q': q, 'cc': (countryCode ?? '').toLowerCase()});
  }
}

const List<List<PlaceRef>> kCIPlaces = [
  kCICities,

  kCIHospitals,

  kCITowns,

  kCIQuarters,

  kCIPoints,

  kCIStations,
];
