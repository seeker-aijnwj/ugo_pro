// Modèle Admin/Staff
class MockAdminUser {
  final String id;
  final String nom;
  final String role; // 'Super Admin', 'Support', 'Modérateur'
  final String statut;

  MockAdminUser(this.id, this.nom, this.role, this.statut);
}