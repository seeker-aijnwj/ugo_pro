class Paiement {
  final int id;
  final int reservationId;
  final double montant;
  final String methode;
  final DateTime datePaiement;
  final bool isSuccessful;

  Paiement({
    required this.id,
    required this.reservationId,
    required this.montant,
    required this.methode,
    required this.datePaiement,
    this.isSuccessful = false
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      reservationId: json['reservationId'],
      montant: json['montant'],
      methode: json['methode'],
      datePaiement: DateTime.parse(json['datePaiement']),
      isSuccessful: json['isSuccessful'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationId': reservationId,
      'montant': montant,
      'methode': methode,
      'datePaiement': datePaiement.toIso8601String(),
      'isSuccessful': isSuccessful,
    };
  }
}
