import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_go/modules/trip_module/database/models/trajet.dart';

class TrajetService {
  final CollectionReference trajetsCollection =
      FirebaseFirestore.instance.collection('trajets');

  // CREATE
  Future<void> ajouterTrajet(Trajet trajet) async {
    await trajetsCollection.add(trajet.toMap());
  }

  // READ (récupérer tous les trajets)
  Stream<List<Trajet>> listeTrajets() {
    return trajetsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trajet.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // UPDATE
  Future<void> modifierTrajet(Trajet trajet) async {
    await trajetsCollection.doc(trajet.id.toString()).update(trajet.toMap());
  }

  // DELETE
  Future<void> supprimerTrajet(String id) async {
    await trajetsCollection.doc(id).delete();
  }
}
