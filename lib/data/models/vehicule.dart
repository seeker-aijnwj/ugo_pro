class Vehicule {
  final int id;
  final int conducteurId;
  final String marque;
  final String modele;
  final int annee;
  final String couleur;
  final String immatriculation;
  final int nombrePlaces;

  Vehicule({
    required this.id,
    required this.conducteurId,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.couleur,
    required this.immatriculation,
    this.nombrePlaces = 4,
  });

  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      id: json['id'],
      conducteurId: json['conducteurId'],
      marque: json['marque'],
      modele: json['modele'],
      annee: json['annee'],
      couleur: json['couleur'],
      immatriculation: json['immatriculation'],
      nombrePlaces: json['nombrePlaces'] ?? 4, // Default to 4 if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conducteurId': conducteurId,
      'marque': marque,
      'modele': modele,
      'annee': annee,
      'couleur': couleur,
      'immatriculation': immatriculation,
      'nombrePlaces': nombrePlaces,
    };
  }
}
