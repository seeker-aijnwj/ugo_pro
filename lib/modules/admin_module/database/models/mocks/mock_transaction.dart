// Modèle Transaction
class MockTransaction {
  final String id;
  final String type; // 'ticket_in', 'payout_out', 'commission'
  final String description;
  final double montant;
  final String operateur; // 'Wave', 'Orange Money', 'MTN', 'Cash'
  final DateTime date;
  String statut; // 'succès', 'en_attente', 'échec'

  MockTransaction(this.id, this.type, this.description, this.montant, this.operateur, this.date, this.statut);
}