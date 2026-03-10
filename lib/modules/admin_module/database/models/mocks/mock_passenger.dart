
// Modèle Passager
class MockPassenger {
  final String id;
  final String nom;
  final String telephone;
  final int totalTrajets;
  String statut; // 'actif', 'bloqué'

  MockPassenger(this.id, this.nom, this.telephone, this.totalTrajets, this.statut);
}
