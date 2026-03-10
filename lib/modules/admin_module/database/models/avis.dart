class Avis {
  final int id;
  final int conducteurId;
  final int passagerId;
  final int trajetId;
  final double note;
  final DateTime dateAvis;

  Avis({
    required this.id,
    required this.conducteurId,
    required this.passagerId,
    required this.trajetId,
    required this.note,
    required this.dateAvis,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['id'],
      conducteurId: json['conducteurId'],
      passagerId: json['passagerId'],
      trajetId: json['trajetId'],
      note: json['note'],
      dateAvis: DateTime.parse(json['dateAvis']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conducteurId': conducteurId,
      'passagerId': passagerId,
      'trajetId': trajetId,
      'note': note,
      'dateAvis': dateAvis.toIso8601String(),
    };
  }
}
