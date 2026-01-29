
// Modèle Chauffeur
class MockDriver {
  final String id;
  final String nom;
  final String telephone;
  String status; // 'en_attente', 'validé', 'bloqué'
  final double note;

  // Nouvelles infos pour vérification
  final String permisType;
  final String matriculeVehicule;
  final DateTime dateInscription;

  MockDriver(this.id, this.nom, this.telephone, this.status, this.note, 
      {this.permisType = 'Permis C', this.matriculeVehicule = '1234-CI-01', DateTime? date}) 
      : dateInscription = date ?? DateTime.now();
}