// Cette page présente le modèle de données pour les villes (CI-Towns)
// Elle est utilisée par le module géographique pour les suggestions de lieux.

import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

// ------ Côte d’Ivoire : Grandes villes en Côte d'Ivoire ------
const List<PlaceRef> kCICities = [

// Capitales/Grandes villes
  PlaceRef(
    name: "Bingerville",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["ville", "abidjan"],
  ),
  PlaceRef(
    name: "Grand-Bassam",
    state: "Grand Abidjan",
    country: "CI",
    tags: ["ville", "balnéaire"],
  ),
  PlaceRef(
    name: "Jacqueville",
    state: "Grands Ponts",
    country: "CI",
    tags: ["ville", "balnéaire"],
  ),
  PlaceRef(
    name: "Yamoussoukro",
    state: "District de Yamoussoukro",
    country: "CI",
    tags: ["capitale"],
  ),
  PlaceRef(
      name: "Bouaké",
      state: "Gbêkê",
      country: "CI",
      tags: ["ville"]
  ),
  PlaceRef(
    name: "San-Pédro",
    state: "District de San Pédro",
    country: "CI",
    tags: ["port", "ville"],
  ),
  PlaceRef(
    name: "Daloa",
    state: "Haut-Sassandra",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Korhogo", 
    state: "Poro", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Man",
    state: "Tonkpi",
    country: "CI",
    tags: ["ville", "montagnes"],
  ),
  PlaceRef(
      name: "Gagnoa",
      state: "Gôh",
      country: "CI",
      tags: ["ville"]
  ),
  PlaceRef(
    name: "Abengourou",
    state: "Indénié-Djuablin",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Odienné",
    state: "Kabadougou",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Bondoukou",
    state: "Gontougo",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Divo", 
    state: "Lôh-Djiboua", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Aboisso", 
    state: "Sud-Comoé", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Soubré", 
    state: "Nawa", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Agboville",
    state: "Agneby-Tiassa",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Adzopé", 
    state: "La Mé", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Tiassalé",
    state: "Agneby-Tiassa",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Dabou",
    state: "Grands-Ponts",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Sassandra",
    state: "Gbôklé",
    country: "CI",
    tags: ["ville", "côtière"],
  ),
  PlaceRef(
    name: "Bouaflé", 
    state: "Marahoué", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Daoukro", 
    state: "Iffou", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Ferkessédougou",
    state: "Tchologo",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Katiola", 
    state: "Hambol", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Boundiali", 
    state: "Bagoué", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Tingréla", 
    state: "Bagoué", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Séguéla",
    state: "Worodougou",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Touba", 
    state: "Bafing", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Guiglo", 
    state: "Cavally", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Dimbokro", 
    state: "N’Zi", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Toumodi", 
    state: "Bélier", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Issia",
    state: "Haut-Sassandra",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Lakota",
    state: "Lôh-Djiboua",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Tabou",
    state: "San-Pédro",
    country: "CI",
    tags: ["ville", "frontière"],
  ),
  PlaceRef(
    name: "Zuénoula", 
    state: "Marahoué", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Bouna", 
    state: "Bounkani", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Agnibilékrou",
    state: "Indénié-Djuablin",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Méagui", 
    state: "Nawa", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Vavoua",
    state: "Haut-Sassandra",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Béoumi", 
    state: "Gbêkê", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Sinfra", 
    state: "Marahoué", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Oumé", 
    state: "Gôh", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Duekoué", 
    state: "Guémon", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Facobly", 
    state: "Guémon", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Bangolo", 
    state: "Guémon", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Aboisso-Comoé",
    state: "Sud-Comoé",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Arrah", 
    state: "Moronou", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Bocanda", 
    state: "N’Zi", 
    country: "CI", 
    tags: ["ville"]
  ),
  PlaceRef(
    name: "Gohitafla",
    state: "Marahoué",
    country: "CI",
    tags: ["ville"],
  ),
  PlaceRef(
    name: "Kouassi-Kouassikro",
    state: "N’Zi",
    country: "CI",
    tags: ["ville"],
  ),
  // (Ajoute librement d’autres localités au besoin)

];