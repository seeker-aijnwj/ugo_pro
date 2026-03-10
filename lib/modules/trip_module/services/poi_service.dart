import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

class PoiService {
  // Plusieurs miroirs Overpass (on tente dans l'ordre si 429/5xx)
  static const _overpassEndpoints = <String>[
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];

  // --- PUBLIC API -----------------------------------------------------------
  /// Récupère des POI nommés dans la commune (bbox via Nominatim) filtrés par [query].
  static Future<List<PlaceRef>> searchPOIs({
    required String commune,
    String query = '',
    int limit = 25,
  }) async {
    final cleaned = _normalizeCommune(commune);
    final bbox = await _nominatimBBox(cleaned);
    if (bbox == null) return [];

    final regex = query.trim();
    final elements = await _overpassFetchBBox(bbox, regex, limit);
    if (elements.isEmpty) return [];

    // Convert → PlaceRef
    final out = <PlaceRef>[];
    for (final e in elements) {
      final tags = (e['tags'] ?? {}) as Map<String, dynamic>;
      final name = (tags['name'] ?? '') as String;
      if (name.isEmpty) continue;

      double? lat, lon;
      if (e['lat'] != null && e['lon'] != null) {
        lat = (e['lat'] as num).toDouble();
        lon = (e['lon'] as num).toDouble();
      } else if (e['center'] != null) {
        lat = (e['center']['lat'] as num?)?.toDouble();
        lon = (e['center']['lon'] as num?)?.toDouble();
      }

      out.add(
        PlaceRef(
          name: name,
          country: 'CI',
          lat: lat,
          lon: lon,
          tags: _tagsFromOverpass(tags),
        ),
      );
      if (out.length >= limit) break;
    }

    // Déduplique par nom (garde le 1er)
    final seen = <String>{};
    final dedup = <PlaceRef>[];
    for (final p in out) {
      final k = '${p.name.toLowerCase()}|${p.display}';
      if (seen.add(k)) dedup.add(p);
    }
    return dedup;
  }

  // --- NOMINATIM: geocode bbox --------------------------------------------
  /// Retourne [south, west, north, east]
  static Future<List<double>?> _nominatimBBox(String commune) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeQueryComponent("$commune, Côte d’Ivoire")}'
      '&format=jsonv2&addressdetails=1&limit=1&countrycodes=ci',
    );
    final res = await http.get(
      uri,
      headers: {
        'User-Agent': 'U-GO/1.0 (contact@ugo.app)',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode != 200) return null;

    final List data = jsonDecode(res.body);
    if (data.isEmpty) return null;

    final bbox = (data.first['boundingbox'] as List?)?.cast<String>();
    if (bbox == null || bbox.length != 4) return null;

    final south = double.tryParse(bbox[0]);
    final north = double.tryParse(bbox[1]);
    final west = double.tryParse(bbox[2]);
    final east = double.tryParse(bbox[3]);
    if ([south, west, north, east].any((v) => v == null)) return null;

    // [south, west, north, east]
    return [south!, west!, north!, east!];
  }

  // --- OVERPASS: query by bbox --------------------------------------------
  static Future<List> _overpassFetchBBox(
    List<double> bbox,
    String q,
    int limit,
  ) async {
    // bbox order for Overpass: (south,west,north,east)
    final south = bbox[0], west = bbox[1], north = bbox[2], east = bbox[3];

    // (?i) for case-insensitive; if empty, match any name
    final nameClause = q.trim().isEmpty
        ? '["name"]'
        : '["name"~"(?i)${_escapeRegex(q)}"]';

    final query =
        '''
[out:json][timeout:25];
(
  node$nameClause($south,$west,$north,$east);
  way$nameClause($south,$west,$north,$east);
  relation$nameClause($south,$west,$north,$east);
);
out center ${max(1, limit)};
''';

    for (final ep in _overpassEndpoints) {
      try {
        final res = await http.post(
          Uri.parse(ep),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'U-GO/1.0 (contact@ugo.app)',
          },
          body: {'data': query},
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final elements = (data['elements'] ?? []) as List;
          return elements;
        }
        // Si 429/5xx, on tente le prochain miroir
      } catch (_) {
        // try next
      }
    }
    return [];
  }

  // --- Utils ---------------------------------------------------------------
  static String _normalizeCommune(String name) {
    final n = name.trim();
    final low = n.toLowerCase();
    if (low.startsWith("le ")) return n.substring(3);
    if (low.startsWith("la ")) return n.substring(3);
    if (low.startsWith("les ")) return n.substring(4);
    if (low.startsWith("l'")) return n.substring(2);
    return n;
  }

  static String _escapeRegex(String s) =>
      s.replaceAllMapped(RegExp(r'([\\^$.|?*+(){}\[\]])'), (m) => '\\${m[1]}');

  static List<String> _tagsFromOverpass(Map<String, dynamic> t) {
    const keys = [
      'amenity',
      'shop',
      'tourism',
      'public_transport',
      'highway',
      'leisure',
      'office',
      'building',
      'place',
      'healthcare',
      'man_made',
      'railway',
    ];
    for (final k in keys) {
      final v = t[k];
      if (v is String && v.isNotEmpty) return ['poi', '$k:$v'];
    }
    return ['poi'];
  }
}
