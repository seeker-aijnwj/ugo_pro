// Cette page présente le modèle de données pour les villes (CI-Towns)
// Elle est utilisée par le module géographique pour les suggestions de lieux.

import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

// ------ Côte d’Ivoire : Grandes villes en Côte d'Ivoire ------
const List<PlaceRef> kCIQuarters = [

  // Quartiers
  PlaceRef(
    name: 'Abobo Kennedy', 
    town: 'Abobo',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: 'Abobo Avocatier', 
    town: 'Abobo',
    city: 'Abidjan',
    state: 'Grand Abidjan',
    country: 'CI',
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Gonzagueville",
    town: 'Port-Bouët',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Djorogobité",
    town: 'Cocody',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Palmeraie",
    town: 'Cocody',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),  
  PlaceRef(
    name: "Angré 7ème Tranche",
    town: 'Cocody',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),  
  PlaceRef(
    name: "Anoumanbo",
    town: 'Marcory',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "village", "abidjan"],
  ),
  PlaceRef(
    name: "Marcory Champroux",
    town: 'Marcory',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Zone 4",
    town: 'Marcory',
    city: "Abidjan",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),

  
  PlaceRef(
    name: "Quartier millionnaire",
    town: "Gagnoa Commune",
    city: "Gagnoa",
    state: "Gôh",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Garahio",
    town: "Gagnoa Commune",
    city: "Gagnoa",
    state: "Gôh",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Lycée professionnel",
    town: "Gagnoa Commune",
    city: "Gagnoa",
    state: "Gôh",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),
  PlaceRef(
    name: "Au commerce",
    town: "Gagnoa Commune",
    city: "Gagnoa",
    state: "Gôh",
    country: "CI",
    tags: ["quartier", "abidjan"],
  ),

];