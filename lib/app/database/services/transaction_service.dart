class MicroFees {
  final int passengerFee;
  final int driverFee;
  const MicroFees({required this.passengerFee, required this.driverFee});
}

class TransactionService {
  TransactionService._();
  static final TransactionService instance = TransactionService._();

  /// Calcule les micro-frais :
  /// - passager : 50 FCFA
  /// - chauffeur : 1.5% du fareEstimated, min 25, max 100
  MicroFees computeFees({int? fareEstimated}) {
    final passenger = 50;
    int driver;
    if (fareEstimated == null) {
      driver = 25;
    } else {
      final p = (fareEstimated * 0.015).ceil();
      driver = p.clamp(25, 100);
    }
    return MicroFees(passengerFee: passenger, driverFee: driver);
  }

  /// Idempotency key helper
  String idemKey(String userId, String reason, String tripId) =>
      '$userId|$reason|$tripId';
}
