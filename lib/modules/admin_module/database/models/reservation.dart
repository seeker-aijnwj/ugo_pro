class Reservation {
  final int id;
  final int passagerId;
  final int trajetId;
  final DateTime dateReservation;
  final int nombrePlaces;

  Reservation({
    required this.id,
    required this.passagerId,
    required this.trajetId,
    required this.dateReservation,
    required this.nombrePlaces,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      passagerId: json['passagerId'],
      trajetId: json['trajetId'],
      dateReservation: DateTime.parse(json['dateReservation']),
      nombrePlaces: json['nombrePlaces'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passagerId': passagerId,
      'trajetId': trajetId,
      'dateReservation': dateReservation.toIso8601String(),
      'nombrePlaces': nombrePlaces,
    };
  }
}
