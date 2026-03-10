import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

/// Liste des principales gares routières et arrêts d’Abidjan aussi
/// Principales gares/terminus dans Abidjan (+ quelques arrêts majeurs)
/// Coordonnées WGS84 (décimal). Tu peux étendre/éditer librement.
const List<PlaceRef> kCIStations = [

  // ---------- ADJAMÉ ----------
  PlaceRef(
    name: "Gare UTB Adjamé",
    town: "Adjamé",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35182,
    lon: -4.02209,
    tags: ["bus", "interurbain", "UTB"],
  ),
  PlaceRef(
    name: "Gare Nord SOTRA (Adjamé)",
    town: "Adjamé",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35852,
    lon: -4.02755,
    tags: ["sotra", "terminus", "urbain"],
  ),
  PlaceRef(
    name: "Adjamé Liberté (220 logements)",
    town: "Adjamé",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35400,
    lon: -4.01652,
    tags: ["gbaka", "woro-woro", "urbain"],
  ),
  PlaceRef(
    name: "Gare GDF Adjamé",
    town: "Adjamé",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35239,
    lon: -4.02208,
    tags: ["bus", "urbain"],
  ),

  // ---------- LE PLATEAU ----------
  PlaceRef(
    name: "Gare Sud SOTRA",
    town: "Le Plateau",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.31467,
    lon: -4.01852,
    tags: ["sotra", "bus", "terminus", "urbain"],
  ),

  // ---------- YOPOUGON ----------
  PlaceRef(
    name: "Gare Siporex (Yopougon)",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35649,
    lon: -4.07344,
    tags: ["gbaka", "woro-woro", "urbain"],
  ),
  PlaceRef(
    name: "Lubafrique (Yopougon)",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.33042,
    lon: -4.10399,
    tags: ["gbaka", "terminus", "urbain"],
  ),

  // ---------- ABOBO ----------
  PlaceRef(
    name: "Abobo Gare",
    town: "Abobo",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.42149,
    lon: -4.01766,
    tags: ["sotra", "terminus", "urbain"],
  ),
  PlaceRef(
    name: "Gare Abobo N'Dotré",
    town: "Abobo",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35562,
    lon: -4.08479,
    tags: ["gbaka", "station", "urbain"],
  ),
  PlaceRef(
    name: "Gare Angré (Pétro Ivoire)",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.42159,
    lon: -4.01604,
    tags: ["woro-woro", "station", "angré"],
  ),

  // ---------- COCODY ----------
  PlaceRef(
    name: "Cocody Saint-Jean (CIE/St-Jean)",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.33842,
    lon: -4.00381,
    tags: ["sotra", "urbain"],
  ),
  PlaceRef(
    name: "Riviera 2 - Gare annexe",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.35450,
    lon: -3.97764,
    tags: ["sotra", "woro-woro", "urbain"],
  ),
  PlaceRef(
    name: "Gare Palmeraie (DGI)",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.36117,
    lon: -3.95787,
    tags: ["woro-woro", "urbain", "palmeraie"],
  ),

  // ---------- MARCORY ----------
  PlaceRef(
    name: "Gare Marcory",
    town: "Marcory",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.30870,
    lon: -3.98377,
    tags: ["sotra", "urbain"],
  ),

  // ---------- KOUMASSI ----------
  PlaceRef(
    name: "Gare Koumassi (Terminus)",
    town: "Koumassi",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.29410,
    lon: -3.95513,
    tags: ["sotra", "terminus", "urbain"],
  ),
  PlaceRef(
    name: "Gare communale (Koumassi/Bacongo)",
    town: "Koumassi",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.29649,
    lon: -3.95483,
    tags: ["woro-woro", "urbain"],
  ),

  // ---------- TREICHVILLE ----------
  PlaceRef(
    name: "Gare de Bassam",
    town: "Treichville",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.29944,
    lon: -4.00276,
    tags: ["gbaka", "sotra", "woro-woro", "bus", "urbain"],
  ),

  // ---------- PORT-BOUËT ----------
  PlaceRef(
    name: "Gare de Port-Bouët",
    town: "Port-Bouët",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.29984,
    lon: -3.98877,
    tags: ["terminus", "sotra", "urbain"],
  ),
  PlaceRef(
    name: "Gare Port-Bouët (arrêt)",
    town: "Port-Bouët",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.25757,
    lon: -3.97296,
    tags: ["bus_stop", "urbain"],
  ),

  // Ajouter des arrêts de gbaka / wôrô-wôrô (exemples estimés)
  PlaceRef(
    name: "Arrêt Gbàka Adjamé Liberté",
    town: "Adjamé",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.3540,    // estimation
    lon: -4.0165,   // estimation
    tags: ["gbaka", "arrêt"],
  ),
  PlaceRef(
    name: "Arrêt Gbàka Yopougon Lubafrique",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.3304,    // estimation
    lon: -4.1040,   // estimation
    tags: ["gbaka", "arrêt"],
  ),
  PlaceRef(
    name: "Arrêt Gbàka Treichville",
    town: "Treichville",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.2994,    // estimation
    lon: -4.0027,   // estimation
    tags: ["gbaka", "arrêt"],
  ),
  PlaceRef(
    name: "Arrêt Gbàka Koumassi",
    town: "Koumassi",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.2941,    // estimation
    lon: -3.9551,   // estimation
    tags: ["gbaka", "arrêt"],
  ),
  
  PlaceRef(
    name: 'Liberté (Arrêt Gbaka)', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt', 'transport']
  ),
  PlaceRef(
    name: 'Gare UTB Adjamé', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['bus', 'interurbain']
  ),
  PlaceRef(
    name: 'Gare Nord SOTRA (Adjamé)', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['sotra', 'terminus']
  ),
  PlaceRef(
    name: 'Gare GDF Adjamé', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['bus', 'urbain']
  ),
  PlaceRef(
    name: 'Saint-Jean Cocody (Arrêt)', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Riviera 2 (Arrêt principal)', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Riviera Palmeraie (Arrêt)', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Angré 8e Tranche (Arrêt)', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: "Lubafrique (Arrêt Gbàka)",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.330420, lon: -4.103990,
    tags: ["gbaka", "arrêt", "transport"],
  ),
  PlaceRef(
    name: 'Siporex (Arrêt Gbàka)', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Niangon Kouté (Arrêt)', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Gesco (Arrêt)', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Abobo Gare (Terminus)', 
    town: 'Abobo',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['sotra', 'terminus']
  ),
  PlaceRef(
    name: 'N’Dotré (Arrêt)', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'PK18 (Arrêt)', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'PlaYce Marcory', 
    town: 'Marcory',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['arrêt', 'bus']
  ),
  PlaceRef(
    name: 'Biétry (Arrêt)', 
    town: 'Marcory',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Zone 4 (Arrêt Bietry)', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Koumassi Terminus', 
    town: 'Koumassi',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['sotra', 'terminus']
  ),
  PlaceRef(
    name: 'Koumassi Remblais (Arrêt)', 
    town: 'Koumassi',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Treichville Arrêt Arras 1', 
    town: 'Treichville', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Gare Sud Plateau', 
    town: 'Plateau', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['sotra', 'terminus']
  ),
  PlaceRef(
    name: 'Place de la République', 
    town: 'Plateau', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['arrêt', 'bus']
  ),
  PlaceRef(
    name: 'Port-Bouët Marché (Arrêt)', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Vridi Canal (Arrêt)', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Attécoubé Santé (Arrêt)', 
    town: 'Attécoubé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Banco (Arrêt)', 
    town: 'Attécoubé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),
  PlaceRef(
    name: 'Williamsville (Arrêt)', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['gbaka', 'arrêt']
  ),

];
