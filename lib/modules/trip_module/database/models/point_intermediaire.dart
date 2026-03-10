class PointIntermediaire {
  final int id;
  final int trajetId;
  final String libelle;
  final double latitude;
  final double longitude;
  final int ordre;
  final String? description;
  
  PointIntermediaire({
    required this.id,
    required this.trajetId,
    required this.libelle,
    required this.ordre,
    this.description,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory PointIntermediaire.fromJson(Map<String, dynamic> json) {
    return PointIntermediaire(
      id: json['id'],
      trajetId: json['trajetId'],
      libelle: json['libelle'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      ordre: json['ordre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trajetId': trajetId,
      'libelle': libelle,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'ordre': ordre,
    };
  }
  
}