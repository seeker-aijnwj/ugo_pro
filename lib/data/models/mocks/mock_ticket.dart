
// Modèle Ticket de Support
class MockTicket {
  final String id;
  final String userId;
  final String userName;
  final String sujet; // ex: "Bagage oublié", "Remboursement"
  final String status; // 'ouvert', 'résolu', 'fermé'
  final String priority; // 'haute', 'moyenne', 'basse'
  final List<String> messages; // Simulation historique chat

  MockTicket(this.id, this.userId, this.userName, this.sujet, this.status, this.priority, this.messages);
}
