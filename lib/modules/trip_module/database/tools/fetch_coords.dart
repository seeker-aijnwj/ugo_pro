// tool/fetch_coords.dart
//
// Script CLI qui interroge Nominatim pour enrichir une liste de gares
// (Abidjan) avec leurs coordonnées. Le script écrit un fichier Dart
// "lib/data/abidjan_stations.dart" contenant :
//   - la classe Station (modèle)
//   - la liste const abidjanStations = [ ... ] avec lat/lon remplis.
//
// Exécution :
//   dart run tool/fetch_coords.dart
//
// Prérequis :
//   - http ^1.x dans pubspec
//   - connexion internet
//
// Bonnes pratiques Nominatim :
//   - Fournir un User-Agent explicite
//   - Throttle (>= 1s) entre les requêtes
//   - countrycodes=ci pour limiter au pays
//   - limit=1 + viewbox (optionnel) pour cibler Abidjan

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ================== MODÈLE EN MEMOIRE (entrée) ==================
// Tu peux ajouter/retirer des gares. lat/lon seront remplis par la requête.
// "tags" est libre (ex: sotra, gbaka, interurbain, terminus, etc.)
class StationSeed {
  final String name;
  final String town;    // commune
  final String city;    // "Abidjan"
  final String state;   // "Lagunes" (ou District Autonome d'Abidjan)
  final String country; // "CI"
  final List<String> tags;
  const StationSeed({
    required this.name,
    required this.town,
    this.city = 'Abidjan',
    this.state = 'Lagunes',
    this.country = 'CI',
    this.tags = const [],
  });
}

// ➜ Remplis/édite ta liste “brute” ici.
// Astuce : préciser la commune (town) améliore la précision Nominatim.
const seeds = <StationSeed>[
  StationSeed(name: 'Gare UTB Adjamé', town: 'Adjamé', tags: ['bus', 'interurbain', 'UTB']),
  StationSeed(name: 'Gare Nord SOTRA', town: 'Adjamé', tags: ['sotra', 'terminus', 'urbain']),
  StationSeed(name: 'Adjamé Liberté', town: 'Adjamé', tags: ['gbaka', 'urbain']),
  StationSeed(name: 'Gare GDF Adjamé', town: 'Adjamé', tags: ['bus', 'urbain']),
  StationSeed(name: 'Gare Sud (Plateau)', town: 'Le Plateau', tags: ['sotra', 'terminus']),
  StationSeed(name: 'Gare Siporex', town: 'Yopougon', tags: ['gbaka', 'urbain']),
  StationSeed(name: 'Lubafrique', town: 'Yopougon', tags: ['gbaka', 'terminus']),
  StationSeed(name: 'Abobo Gare', town: 'Abobo', tags: ['sotra', 'terminus']),
  StationSeed(name: 'Abobo N\'Dotré', town: 'Abobo', tags: ['gbaka', 'urbain']),
  StationSeed(name: 'Cocody Saint-Jean', town: 'Cocody', tags: ['sotra', 'urbain']),
  StationSeed(name: 'Riviera 2 Gare', town: 'Cocody', tags: ['sotra', 'urbain']),
  StationSeed(name: 'Palmeraie DGI', town: 'Cocody', tags: ['urbain']),
  StationSeed(name: 'Gare Marcory', town: 'Marcory', tags: ['sotra', 'urbain']),
  StationSeed(name: 'Gare Koumassi', town: 'Koumassi', tags: ['sotra', 'terminus']),
  StationSeed(name: 'Gare communale Koumassi', town: 'Koumassi', tags: ['woro-woro', 'urbain']),
  StationSeed(name: 'Gare wôrô-wôrô Treichville', town: 'Treichville', tags: ['gbaka', 'urbain']),
  StationSeed(name: 'Gare de Port-Bouët', town: 'Port-Bouët', tags: ['terminus', 'sotra']),

  // ======= HYPERMARCHÉS / SUPERMARCHÉS =======
  StationSeed(name: 'PlaYce Marcory', town: 'Marcory', tags: ['hypermarché', 'shopping']),
  StationSeed(name: 'PlaYce Palmeraie', town: 'Cocody', tags: ['hypermarché', 'shopping']),
  StationSeed(name: 'Cap Sud', town: 'Marcory', tags: ['centre commercial', 'supermarché']),
  StationSeed(name: 'Prima Center', town: 'Marcory', tags: ['centre commercial', 'supermarché']),
  StationSeed(name: 'Sococé 2 Plateaux', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Angré 8ème Tranche', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Riviera 3', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Super U Zone 4', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Super U Riviera Palmeraie', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Casino Mandjou', town: 'Plateau', tags: ['supermarché']),
  StationSeed(name: 'Supermarché CDCI Palmeraie', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Supermarché CDCI Koumassi', town: 'Koumassi', tags: ['supermarché']),
  StationSeed(name: 'Supermarché CDCI Abobo', town: 'Abobo', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Cap Nord', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Riviera 2', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Zone 4', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Bonprix Koumassi', town: 'Koumassi', tags: ['supermarché']),
  StationSeed(name: 'Bonprix Yopougon', town: 'Yopougon', tags: ['supermarché']),
  StationSeed(name: 'Bonprix Abobo', town: 'Abobo', tags: ['supermarché']),
  StationSeed(name: 'King Cash Riviera', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'King Cash Marcory', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Market Zone 4', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Market Cocody Danga', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Leader Price Abobo', town: 'Abobo', tags: ['supermarché']),
  StationSeed(name: 'Leader Price Yopougon Niangon', town: 'Yopougon', tags: ['supermarché']),
  StationSeed(name: 'Leader Price Port-Bouët', town: 'Port-Bouët', tags: ['supermarché']),
  StationSeed(name: 'Super U Cocody Danga', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Hyper Cité Marcory', town: 'Marcory', tags: ['hypermarché']),
  StationSeed(name: 'Hyper Cité Yopougon', town: 'Yopougon', tags: ['hypermarché']),
  StationSeed(name: 'Hyper Cité Abobo', town: 'Abobo', tags: ['hypermarché']),
  StationSeed(name: 'Monoprix Riviera Golf', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Monoprix Zone 4', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Monoprix 2 Plateaux', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Awa Market Angré', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Awa Market Yopougon', town: 'Yopougon', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Treichville', town: 'Treichville', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Koumassi', town: 'Koumassi', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Port-Bouët', town: 'Port-Bouët', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Marcory Zone 4', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Playce Marcory', town: 'Marcory', tags: ['hypermarché']),
  StationSeed(name: 'Casino Cap Sud', town: 'Marcory', tags: ['supermarché']),

  // ======= ARRÊTS GBAKA / WÔRÔ-WÔRÔ =======
  StationSeed(name: 'Adjamé Liberté (Arrêt Gbàka)', town: 'Adjamé', tags: ['gbaka', 'arrêt', 'transport']),
  StationSeed(name: 'Gare UTB Adjamé', town: 'Adjamé', tags: ['bus', 'interurbain']),
  StationSeed(name: 'Gare Nord SOTRA (Adjamé)', town: 'Adjamé', tags: ['sotra', 'terminus']),
  StationSeed(name: 'Gare GDF Adjamé', town: 'Adjamé', tags: ['bus', 'urbain']),
  StationSeed(name: 'Saint-Jean Cocody (Arrêt)', town: 'Cocody', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Riviera 2 (Arrêt principal)', town: 'Cocody', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Riviera Palmeraie (Arrêt)', town: 'Cocody', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Angré 8e Tranche (Arrêt)', town: 'Cocody', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Lubafrique (Arrêt Gbàka)', town: 'Yopougon', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Siporex (Arrêt Gbàka)', town: 'Yopougon', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Niangon Kouté (Arrêt)', town: 'Yopougon', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Gesco (Arrêt)', town: 'Yopougon', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Abobo Gare (Terminus)', town: 'Abobo', tags: ['sotra', 'terminus']),
  StationSeed(name: 'N’Dotré (Arrêt)', town: 'Abobo', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'PK18 (Arrêt)', town: 'Abobo', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'PlaYce Marcory – Arrêt', town: 'Marcory', tags: ['arrêt', 'bus']),
  StationSeed(name: 'Biétry (Arrêt)', town: 'Marcory', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Zone 4 (Arrêt Bietry)', town: 'Marcory', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Koumassi Terminus', town: 'Koumassi', tags: ['sotra', 'terminus']),
  StationSeed(name: 'Koumassi Remblais (Arrêt)', town: 'Koumassi', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Treichville Arrêt Arras 1', town: 'Treichville', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Gare Sud Plateau', town: 'Plateau', tags: ['sotra', 'terminus']),
  StationSeed(name: 'Plateau Place de la République (Arrêt)', town: 'Plateau', tags: ['arrêt', 'bus']),
  StationSeed(name: 'Port-Bouët Marché (Arrêt)', town: 'Port-Bouët', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Vridi Canal (Arrêt)', town: 'Port-Bouët', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Attécoubé Santé (Arrêt)', town: 'Attécoubé', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Banco (Arrêt)', town: 'Attécoubé', tags: ['gbaka', 'arrêt']),
  StationSeed(name: 'Williamsville (Arrêt)', town: 'Adjamé', tags: ['gbaka', 'arrêt']),

  // ======= SANTÉ : HOPITAUX / CLINIQUES / CENTRES =======
  StationSeed(name: 'CHU de Treichville', town: 'Treichville', tags: ['hopital', 'public']),
  StationSeed(name: 'CHU de Cocody', town: 'Cocody', tags: ['hopital', 'public']),
  StationSeed(name: 'CHU d’Angré', town: 'Cocody', tags: ['hopital', 'public']),
  StationSeed(name: 'CHU de Yopougon', town: 'Yopougon', tags: ['hopital', 'public']),
  StationSeed(name: 'Institut de Cardiologie d’Abidjan', town: 'Cocody', tags: ['hopital', 'spécialisé']),
  StationSeed(name: 'Hôpital Militaire d’Abidjan (HMA)', town: 'Treichville', tags: ['hopital', 'militaire']),
  StationSeed(name: 'Hôpital Général d’Adjamé', town: 'Adjamé', tags: ['hopital']),
  StationSeed(name: 'Hôpital Général d’Abobo', town: 'Abobo', tags: ['hopital']),
  StationSeed(name: 'Hôpital Général de Koumassi', town: 'Koumassi', tags: ['hopital']),
  StationSeed(name: 'Hôpital Général de Port-Bouët', town: 'Port-Bouët', tags: ['hopital']),
  StationSeed(name: 'Hôpital Général d’Anyama', town: 'Anyama', tags: ['hopital']),
  StationSeed(name: 'Clinique Sainte Marie', town: 'Cocody', tags: ['clinique']),
  StationSeed(name: 'Clinique Hôtel-Dieu', town: 'Treichville', tags: ['clinique']),
  StationSeed(name: 'Polyclinique Farah', town: 'Marcory', tags: ['clinique']),
  StationSeed(name: 'Polyclinique Internationale Sainte Anne-Marie (PISAM)', town: 'Cocody', tags: ['clinique']),
  StationSeed(name: 'Polyclinique Avicenne', town: 'Marcory', tags: ['clinique']),
  StationSeed(name: 'Clinique Danga', town: 'Cocody', tags: ['clinique']),
  StationSeed(name: 'Clinique de l’Indénié', town: 'Adjamé', tags: ['clinique']),
  StationSeed(name: 'Clinique Bethsaida', town: 'Yopougon', tags: ['clinique']),
  StationSeed(name: 'Clinique La Providence', town: 'Yopougon', tags: ['clinique']),
  StationSeed(name: 'Centre de Santé Urbain d’Adjamé', town: 'Adjamé', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Urbain de Treichville', town: 'Treichville', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Communautaire Abobo Avocatier', town: 'Abobo', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Communautaire Abobo Kennedy', town: 'Abobo', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Urbain de Marcory', town: 'Marcory', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Communautaire de Port-Bouët', town: 'Port-Bouët', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Communautaire d’Attécoubé', town: 'Attécoubé', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Urbain de Koumassi', town: 'Koumassi', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Urbain de Yopougon Toit Rouge', town: 'Yopougon', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Urbain de Yopougon Niangon', town: 'Yopougon', tags: ['centre de santé']),
  StationSeed(name: 'Centre Médical la Grâce', town: 'Abobo', tags: ['centre médical']),
  StationSeed(name: 'Centre Médical Ananeraie', town: 'Yopougon', tags: ['centre médical']),
  StationSeed(name: 'Centre Médical St Viateur', town: 'Cocody', tags: ['centre médical']),
  StationSeed(name: 'Centre Médical Mermoz', town: 'Cocody', tags: ['centre médical']),
  StationSeed(name: 'Centre Médical de Biétry', town: 'Marcory', tags: ['centre médical']),
  StationSeed(name: 'Centre de Santé Akandjé', town: 'Cocody', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé d’Anoumabo', town: 'Marcory', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé de Gonzagueville', town: 'Port-Bouët', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé d’Abia Koumassi', town: 'Koumassi', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé d’Anoumabo Extension', town: 'Marcory', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé de Petit Bassam', town: 'Port-Bouët', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Banco Nord', town: 'Attécoubé', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Plateau Dokui', town: 'Cocody', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Riviera M’pouto', town: 'Cocody', tags: ['centre de santé']),
  StationSeed(name: 'Centre de Santé Riviera 3', town: 'Cocody', tags: ['centre de santé']),

  // ======= AUTRES SUPERMARCHÉS / PROXIMITÉ =======
  StationSeed(name: 'Mini Prix Riviera Palmeraie', town: 'Cocody', tags: ['supérette']),
  StationSeed(name: 'Mini Prix Angré 9e Tranche', town: 'Cocody', tags: ['supérette']),
  StationSeed(name: 'U Express Biétry', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'U Express Zone 4', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'U Express Riviera Golf', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Moussa Market Koumassi', town: 'Koumassi', tags: ['supermarché']),
  StationSeed(name: 'Moussa Market Marcory', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'GBF Market Abobo', town: 'Abobo', tags: ['supermarché']),
  StationSeed(name: 'GBF Market Yopougon', town: 'Yopougon', tags: ['supermarché']),
  StationSeed(name: 'King Cash Port-Bouët', town: 'Port-Bouët', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Market Abatta', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Carrefour Market Angré Djomi', town: 'Cocody', tags: ['supermarché']),
  StationSeed(name: 'Leader Price Marcory', town: 'Marcory', tags: ['supermarché']),
  StationSeed(name: 'Leader Price Koumassi', town: 'Koumassi', tags: ['supermarché']),
  StationSeed(name: 'Leader Price Port-Bouët Gonzagueville', town: 'Port-Bouët', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Abobo Belle Ville', town: 'Abobo', tags: ['supermarché']),
  StationSeed(name: 'Prosuma Angré 9e', town: 'Cocody', tags: ['supermarché']),

  // ======= + QUELQUES LIEUX UTILES POUR LE PASSAGER =======
  StationSeed(name: 'Gonzagueville Marché', town: 'Port-Bouët', tags: ['marché', 'repère']),
  StationSeed(name: 'Place Aki Kouté', town: 'Yopougon', tags: ['repère']),
  StationSeed(name: 'Rond-point CHU Yopougon', town: 'Yopougon', tags: ['repère']),
  StationSeed(name: 'Rond-point Akwaba', town: 'Port-Bouët', tags: ['repère']),
  StationSeed(name: 'Carrefour Duncan', town: 'Marcory', tags: ['repère']),
  StationSeed(name: 'Carrefour Solibra', town: 'Treichville', tags: ['repère']),
  StationSeed(name: 'Carrefour Indénié', town: 'Adjamé', tags: ['repère']),
  StationSeed(name: 'Carrefour Riviera 2', town: 'Cocody', tags: ['repère']),
  StationSeed(name: 'Carrefour Jacques Prévert', town: 'Cocody', tags: ['repère']),
  StationSeed(name: 'Carrefour M’badon', town: 'Cocody', tags: ['repère']),
  StationSeed(name: 'Carrefour Anono', town: 'Cocody', tags: ['repère']),
  StationSeed(name: 'Carrefour 9 Kilos Abobo', town: 'Abobo', tags: ['repère']),
  StationSeed(name: 'Carrefour Akéikoi', town: 'Abobo', tags: ['repère']),
  StationSeed(name: 'Carrefour Macaci', town: 'Yopougon', tags: ['repère']),
  StationSeed(name: 'Carrefour Siporex', town: 'Yopougon', tags: ['repère']),
  StationSeed(name: 'Carrefour Oxfort', town: 'Yopougon', tags: ['repère']),
  StationSeed(name: 'Carrefour Lubafrique', town: 'Yopougon', tags: ['repère']),
];

// ================== PARAMS NOMINATIM ==================
//
// - On utilise l’endpoint /search (geocoding) avec format=jsonv2
// - countrycodes=ci pour restreindre la recherche à la Côte d’Ivoire
// - limit=1 pour récupérer le meilleur match
// - accept-language=fr pour avoir des noms FR si dispo
// - viewbox + bounded=1 (optionnel) pour contraindre autour d’Abidjan
//
// NB : Respecte la politique d’utilisation de Nominatim (requests limitées).
// Doc: https://nominatim.org/release-docs/latest/api/Search/

const _host = 'nominatim.openstreetmap.org';
const _userAgent = 'u-go.app/1.0 (support contact: support@u-go.example)'; // ⇐ mets ton contact/app
const _countryCode = 'ci';
const _limit = 1;
const _delayBetweenRequestsMs = 1200; // 1,2s pour throttle

// viewbox ~ Abidjan (approx): left,top,right,bottom
// (longitude min/max, latitude max/min)
const _viewbox = '-4.20,5.45,-3.85,5.20'; // Ouest/Est & Nord/Sud (grossière bbox)
// Pour restreindre davantage, mets bounded=1
const _bounded = '1';

// ================== MOTEUR ==================

Future<void> main() async {
  // print('== U-GO: Fetch coordinates from Nominatim ==');
  final results = <_StationOut>[];

  for (var i = 0; i < seeds.length; i++) {
    final s = seeds[i];
    // Construire une requête de recherche explicite :
    // "Nom, Commune, Abidjan, Côte d'Ivoire"
    final q = '${s.name}, ${s.town}, Abidjan, Côte d\'Ivoire';

    final uri = Uri.https(_host, '/search', {
      'format': 'jsonv2',
      'q': q,
      'addressdetails': '1',
      'limit': '$_limit',
      'countrycodes': _countryCode,
      'viewbox': _viewbox,
      'bounded': _bounded,
    });

    _StationOut? out;

    // On tente jusqu’à 3 fois (429 / erreurs réseau)
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final resp = await http.get(uri, headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
          'Accept-Language': 'fr',
        });

        if (resp.statusCode == 200) {
          final list = jsonDecode(resp.body) as List<dynamic>;
          if (list.isEmpty) {
            // print('[$i/${seeds.length}] ⚠️ Aucun match pour "$q"');
            break;
          }

          final first = list.first as Map<String, dynamic>;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lon = double.tryParse(first['lon']?.toString() ?? '');

          if (lat == null || lon == null) {
            // print('[$i/${seeds.length}] ⚠️ lat/lon introuvables pour "$q"');
            break;
          }

          out = _StationOut(
            name: s.name,
            town: s.town,
            city: s.city,
            state: s.state,
            country: s.country,
            lat: lat,
            lon: lon,
            tags: s.tags,
          );
          // print('[$i/${seeds.length}] ✅ ${s.name} => ($lat,$lon)');
          break; // succès → on sort de la boucle retry
        } else if (resp.statusCode == 429) {
          final wait = 1500 * attempt;
          // print('[$i/${seeds.length}] ⏳ 429 Too Many Requests, retry dans ${wait}ms');
          await Future.delayed(Duration(milliseconds: wait));
        } else {
          // print('[$i/${seeds.length}] ❌ HTTP ${resp.statusCode} pour "$q"');
          break;
        }
      } catch (e) {
        final wait = 800 * attempt;
        // print('[$i/${seeds.length}] ⚠️ Erreur réseau ($e), retry dans ${wait}ms');
        await Future.delayed(Duration(milliseconds: wait));
      }
    }

    if (out != null) {
      results.add(out);
    }

    // Throttle entre les requêtes pour respecter Nominatim
    await Future.delayed(const Duration(milliseconds: _delayBetweenRequestsMs));
  }

  // Générer le fichier Dart
  await _writeDartFile(results);
  // print('== Fini. ${results.length} stations écrites dans lib/data/abidjan_stations.dart ==');
}

// ================== SORTIE (fichier Dart) ==================

class _StationOut {

  final String name;
  final String town;
  final String city;
  final String state;
  final String country;
  final double lat;
  final double lon;
  final List<String> tags;

  _StationOut({
    required this.name,
    required this.town,
    required this.city,
    required this.state,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tags,
  });

}

Future<void> _writeDartFile(List<_StationOut> stations) async {
  // Contenu du fichier généré
  final buffer = StringBuffer()
    ..writeln('// GENERATED BY tool/fetch_coords.dart — DO NOT EDIT BY HAND')
    ..writeln('// Source: Nominatim (OpenStreetMap)')
    ..writeln('')
    ..writeln('class Station {')
    ..writeln('  final String name;')
    ..writeln('  String get normalizedName => name.toLowerCase().trim();')
    ..writeln('  final String town;')
    ..writeln('  final String city;')
    ..writeln('  final String state;')
    ..writeln('  final String country;')
    ..writeln('  final double lat;')
    ..writeln('  final double lon;')
    ..writeln('  final List<String> tags;')
    ..writeln('  const Station({')
    ..writeln('    required this.name,')
    ..writeln('    required this.town,')
    ..writeln('    required this.city,')
    ..writeln('    required this.state,')
    ..writeln('    required this.country,')
    ..writeln('    required this.lat,')
    ..writeln('    required this.lon,')
    ..writeln('    this.tags = const [],')
    ..writeln('  });')
    ..writeln('}')
    ..writeln('')
    ..writeln('const List<Station> abidjanStations = [');

  // Tri alpha par commune+nom pour la lisibilité
  stations.sort((a, b) {
    final t = a.town.compareTo(b.town);
    return t != 0 ? t : a.name.compareTo(b.name);
  });

  for (final s in stations) {
    final safeName = _dartEscape(s.name);
    final safeTown = _dartEscape(s.town);
    final safeCity = _dartEscape(s.city);
    final safeState = _dartEscape(s.state);
    final safeCountry = _dartEscape(s.country);

    final tags = s.tags.map(_dartEscape).map((t) => "'$t'").join(', ');

    buffer
      ..writeln('  Station(')
      ..writeln("    name: '$safeName',")
      ..writeln("    town: '$safeTown',")
      ..writeln("    city: '$safeCity',")
      ..writeln("    state: '$safeState',")
      ..writeln("    country: '$safeCountry',")
      ..writeln('    lat: ${s.lat.toStringAsFixed(6)},')
      ..writeln('    lon: ${s.lon.toStringAsFixed(6)},')
      ..writeln('    tags: [$tags],')
      ..writeln('  ),');
  }

  buffer.writeln('];');

  final outPath = 'lib/data/abidjan_stations.dart';
  final file = File(outPath);
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

// Petite fonction utilitaire pour échapper les quotes / backslashes
String _dartEscape(String v) => v
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'");
