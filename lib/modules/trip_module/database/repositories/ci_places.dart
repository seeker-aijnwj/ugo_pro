// Cette page présente le modèle de données pour les lieux (CI-Places)
// Elle est utilisée par le module géographique pour les suggestions de lieux.

import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

// ------ Côte d’Ivoire : Grandes villes en Côte d'Ivoire ------
const List<PlaceRef> kCIPoints = [

  // Supermarchés / magasins
  PlaceRef(
    name: "Supermarché CDCI Palmeraie",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.357824,
    lon: -3.965313,
    tags: ["supermarché", "grocery"],
  ),
  PlaceRef(
    name: "Super U Zone 4",
    town: "Zone 4",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.32910,    // estimation (à vérifier)
    lon: -3.97200,   // estimation
    tags: ["supermarché", "hypermarché"],
  ),
  PlaceRef(
    name: "Playce Marcory",
    town: "Marcory",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.29320,    // estimation (à vérifier)
    lon: -3.98650,   // estimation
    tags: ["supermarché", "magasin"],
  ),

  // Centres de santé / cliniques
  PlaceRef(
    name: "Clinique Notre Dame de l’Incarnation (CNDI)",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.3640,    // estimation
    lon: -3.9935,   // estimation
    tags: ["clinique", "santé"],
  ),
  PlaceRef(
    name: "Centre de Santé Soeur Catherine",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.3600,    // estimation
    lon: -4.0500,   // estimation
    tags: ["centre de santé", "dispensaire"],
  ),
  PlaceRef(
    name: "Centre Médical Ananeraie",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.3365,    // estimation
    lon: -4.0305,   // estimation
    tags: ["centre médical", "santé"],
  ),
  PlaceRef(
    name: "Centre Médical Ponce Hope Home Care",
    town: "Yopougon",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.3300,    // estimation
    lon: -4.0500,   // estimation
    tags: ["centre médical", "soins"],
  ),

  // ======= HYPERMARCHÉS / SUPERMARCHÉS =======
  PlaceRef(
    name: "PlaYce Marcory",
    town: "Marcory",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.300300,
    lon: -3.993600,
    tags: ["hypermarché", "shopping"],
  ),
  PlaceRef(
    name: "PlaYce Palmeraie",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.360400, lon: -3.963600,
    tags: ["hypermarché", "shopping"],
  ),
  PlaceRef(
    name: "Cap Sud",
    town: "Marcory",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.304800, lon: -3.990600,
    tags: ["centre commercial", "supermarché"],
  ),
  PlaceRef(
    name: "Gare Gbàka Adjamé Liberté",
    town: "Adjamé",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.354000, lon: -4.016500,
    tags: ["gbaka", "arrêt", "transport"],
  ),
  PlaceRef(
    name: 'Sococé 2 Plateaux', 
    town: 'Cocody',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI", 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Angré 8ème Tranche', 
    town: 'Cocody', 
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Riviera 3', 
    town: 'Cocody',
    city: "Abidjan",
    state: "Grand Abidjan", 
    country: "CI",
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Jardin botanique', 
    town: 'Bingerville',
    city: "Bingerville",
    state: "Grand Abidjan", 
    country: "CI",
    tags: ['jardin', 'loisirs']
  ),
  PlaceRef(
    name: 'Lycée Garçons', 
    town: 'Bingerville',
    city: "Bingerville",
    state: "Grand Abidjan", 
    country: "CI",
    tags: ['lycée', 'scolaire']
  ),
  PlaceRef(
    name: 'Super U Zone 4', 
    town: 'Marcory',
    city: 'Abidjan', 
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Super U Riviera Palmeraie', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Super U Plateau', 
    town: 'Plateau', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Casino Mandjou', 
    town: 'Plateau', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Supermarché CDCI Palmeraie', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Supermarché CDCI Koumassi', 
    town: 'Koumassi',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Supermarché CDCI Abobo', 
    town: 'Abobo',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Cap Nord', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Riviera 2', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Zone 4', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Bonprix Koumassi', 
    town: 'Koumassi', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Bonprix Yopougon', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Bonprix Abobo', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'King Cash Riviera', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'King Cash Marcory', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Market Zone 4', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Market Cocody Danga', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Leader Price Abobo', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Leader Price Yopougon Niangon', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Leader Price Port-Bouët', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Super U Cocody Danga', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Hyper Cité Marcory', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hypermarché']
  ),
  PlaceRef(
    name: 'Hyper Cité Yopougon', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hypermarché']
  ),
  PlaceRef(
    name: 'Hyper Cité Abobo', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hypermarché']
  ),
  PlaceRef(
    name: 'Monoprix Riviera Golf', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Monoprix Zone 4', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Monoprix 2 Plateaux', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Awa Market Angré', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Awa Market Yopougon', 
    town: 'Yopougon',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Treichville', 
    town: 'Treichville', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Koumassi', 
    town: 'Koumassi', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Port-Bouët', 
    town: 'Port-Bouët',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Marcory Zone 4', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Playce Marcory', 
    town: 'Marcory',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['hypermarché']
  ),
  PlaceRef(
    name: 'Casino Cap Sud', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),


// ======= AUTRES SUPERMARCHÉS / PROXIMITÉ =======
  PlaceRef(
    name: 'Mini Prix Riviera Palmeraie', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supérette']
  ),
  PlaceRef(
    name: 'Mini Prix Angré 9e Tranche', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supérette']
  ),
  PlaceRef(
    name: 'U Express Biétry', 
    town: 'Marcory',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'U Express Zone 4', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'U Express Riviera Golf', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Moussa Market Koumassi', 
    town: 'Koumassi', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Moussa Market Marcory', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'GBF Market Abobo', 
    town: 'Abobo',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'GBF Market Yopougon', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'King Cash Port-Bouët', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Market Abatta', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Carrefour Market Angré Djomi', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Leader Price Marcory', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Leader Price Koumassi', 
    town: 'Koumassi', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Leader Price Port-Bouët Gonzagueville', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Abobo Belle Ville', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),
  PlaceRef(
    name: 'Prosuma Angré 9e', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['supermarché']
  ),

// ======= + QUELQUES LIEUX UTILES POUR LE PASSAGER =======
  PlaceRef(
    name: 'Gonzagueville Marché', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['marché', 'repère']
  ),
  PlaceRef(
    name: 'Place Aki Kouté', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Rond-point CHU Yopougon', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']),
  PlaceRef(
    name: 'Rond-point Akwaba', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Duncan', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Solibra', 
    town: 'Treichville', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']),
  PlaceRef(
    name: 'Carrefour Indénié', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Riviera 2', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Jacques Prévert', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour M’badon', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Anono', 
    town: 'Cocody',
    city: 'Abidjan',
    state: 'Grand Abidjan', 
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour 9 Kilos Abobo', 
    town: 'Abobo',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Akéikoi', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Macaci', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Siporex', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Oxfort', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
  PlaceRef(
    name: 'Carrefour Lubafrique', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['repère']
  ),
];