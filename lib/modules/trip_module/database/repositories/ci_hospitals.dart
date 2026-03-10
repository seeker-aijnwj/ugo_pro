// Cette page présente le modèle de données pour les lieux (CI-Places)
// Elle est utilisée par le module géographique pour les suggestions de lieux.

import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

// ------ Côte d’Ivoire : Centres de santé, hôpitaux et polycliniques en Côte d'Ivoire ------
const List<PlaceRef> kCIHospitals = [

// ======= SANTÉ : HOPITAUX / CLINIQUES / CENTRES =======
  PlaceRef(
    name: "CHU de Treichville",
    town: "Treichville",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.301700, lon: -4.007600,
    tags: ["hopital", "santé", "public"],
  ),
  PlaceRef(
    name: "CHU de Cocody",
    town: "Cocody",
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    lat: 5.350900, lon: -3.986400,
    tags: ["hopital", "santé", "public"],
  ),
  PlaceRef(
    name: 'CHU d’Angré', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'santé', 'public']
  ),
  PlaceRef(
    name: 'CHU de Yopougon', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'santé', 'public']
  ),
  PlaceRef(
    name: 'Institut de Cardiologie d’Abidjan', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'santé', 'spécialisé']
  ),
  PlaceRef(
    name: 'Hôpital Militaire d’Abidjan (HMA)', 
    town: 'Treichville', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'santé', 'militaire']
  ),
  PlaceRef(
    name: 'Hôpital Général d’Adjamé', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'santé', 'public']
  ),
  PlaceRef(
    name: 'Hôpital Général d’Abobo', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'santé', 'public']
  ),
  PlaceRef(
    name: 'Hôpital Général de Koumassi', 
    town: 'Koumassi', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital', 'public', 'santé']
  ),
  PlaceRef(
    name: 'Hôpital Général de Port-Bouët', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital']
  ),
  PlaceRef(
    name: 'Hôpital Général d’Anyama', 
    town: 'Anyama', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['hopital']
  ),
  PlaceRef(
    name: 'Clinique Sainte Marie', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Clinique Hôtel-Dieu', 
    town: 'Treichville', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Polyclinique Farah', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'PISAM', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Polyclinique Avicenne', 
    town: 'Marcory',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Clinique Danga', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Clinique de l’Indénié', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Clinique Bethsaida', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Clinique La Providence', 
    town: 'Yopougon', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['clinique']
  ),
  PlaceRef(
    name: 'Centre de Santé Urbain d’Adjamé', 
    town: 'Adjamé', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Urbain de Treichville', 
    town: 'Treichville', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Communautaire Abobo Avocatier', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Communautaire Abobo Kennedy', 
    town: 'Abobo', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Urbain de Marcory', 
    town: 'Marcory',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Communautaire de Port-Bouët', 
    town: 'Port-Bouët', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Communautaire d’Attécoubé', 
    town: 'Attécoubé',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Urbain de Koumassi', 
    town: 'Koumassi',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Urbain de Yopougon Toit Rouge', 
    town: 'Yopougon',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Urbain de Yopougon Niangon', 
    town: 'Yopougon',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre Médical la Grâce', 
    town: 'Abobo',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre médical']
  ),
  PlaceRef(
    name: 'Centre Médical Ananeraie', 
    town: 'Yopougon',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre médical']
  ),
  PlaceRef(
    name: 'Centre Médical St Viateur', 
    town: 'Cocody',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre médical']
  ),
  PlaceRef(
    name: 'Centre Médical Mermoz', 
    town: 'Cocody',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre médical']
  ),
  PlaceRef(
    name: 'Centre Médical de Biétry', 
    town: 'Marcory', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI', 
    tags: ['centre médical']
  ),
  PlaceRef(
    name: 'Centre de Santé Akandjé', 
    town: 'Cocody',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé d’Anoumabo', 
    town: 'Marcory',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé de Gonzagueville', 
    town: 'Port-Bouët',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé d’Abia Koumassi', 
    town: 'Koumassi',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé d’Anoumabo Extension', 
    town: 'Marcory',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé de Petit Bassam', 
    town: 'Port-Bouët',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Banco Nord', 
    town: 'Attécoubé',  
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Plateau Dokui', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Riviera M’pouto', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),
  PlaceRef(
    name: 'Centre de Santé Riviera 3', 
    town: 'Cocody', 
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ['centre de santé']
  ),

];