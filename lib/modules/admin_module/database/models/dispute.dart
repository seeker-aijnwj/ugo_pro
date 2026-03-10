// Pour la gestion des litiges
class Dispute {
  final String id;
  final String user;
  final String type; // 'Remboursement', 'Objet Perdu', 'Comportement'
  final String description;
  final String severity; // 'Haute', 'Moyenne', 'Basse'
  final String date;

  Dispute(
    this.id, 
    this.user, 
    this.type, 
    this.description, 
    this.severity, 
    this.date
  );
}