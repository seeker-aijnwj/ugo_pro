class Trajet {
  final int id;
  final int conducteurId;
  //final int vehiculeId;
  final DateTime date;
  final String time;
  final String lieuDepart;
  final double longLieuDepart;
  final double latLieuDepart;
  final String lieuArrivee;
  final double longLieuArrivee;
  final double latLieuArrivee;
  final String lieuRencontre;
  final double prixParPlace;
  final String? description;
  int placesDisponibles;
  bool isCompleted;
  bool isActive;


  Trajet({
    required this.id, 
    required this.conducteurId, 
    // required this.vehiculeId, 
    required this.date, 
    required this.time,
    required this.lieuDepart,
    required this.lieuRencontre, 
    this.longLieuDepart = 0.0, 
    this.latLieuDepart = 0.0,
    required this.lieuArrivee, 
    this.longLieuArrivee = 0.0, 
    this.latLieuArrivee = 0.0,  
    required this.prixParPlace, 
    this.description,  
    this.placesDisponibles = 4,
    this.isCompleted = false, 
    this.isActive = true
  });

  factory Trajet.fromMap(String id, Map<String, dynamic> map) {
    return Trajet(
      id: -1,
      time: map['time'] ?? '',
      conducteurId: int.tryParse(map['conducteurId']?.toString() ?? '0') ?? 0,
      //vehiculeId: int.tryParse(map['vehiculeId']?.toString()
      lieuDepart: map['lieuDepart'] ?? '',
      lieuArrivee: map['lieuArrivee'] ?? '',
      lieuRencontre: map['lieuRencontre'] ?? '',
      date: DateTime.parse(map['date']),
      prixParPlace: (map['prix'] ?? 0).toDouble(),
      description: map['description'],
      placesDisponibles: map['placesDisponibles'] ?? 4,
    );
  }

  factory Trajet.fromJson(Map<String, dynamic> json) {
    return Trajet(
      id: json['id'],
      conducteurId: json['conducteurId'],
      //vehiculeId: json['vehiculeId'],
      date: DateTime.parse(json['date']),
      lieuDepart: json['lieuDepart'],
      lieuArrivee: json['lieuArrivee'],
      lieuRencontre: json['lieuRencontre'],
      time: json['time'],
      longLieuDepart: json['longLieuDepart'],
      latLieuDepart: json['latLieuDepart'],
      longLieuArrivee: json['longLieuArrivee'],
      latLieuArrivee: json['latLieuArrivee'],
      prixParPlace: json['prixParPlace'],
      placesDisponibles: json['placesDisponibles'] ?? 4,
      description: json['description'],
      isCompleted: json['isCompleted'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conducteurId': conducteurId,
      //'vehiculeId': vehiculeId,
      'date': date.toIso8601String(),
      'lieuDepart': lieuDepart,
      'lieuArrivee': lieuArrivee,
      'lieuRencontre': lieuRencontre,
      'time': time,
      'longLieuDepart': longLieuDepart,
      'latLieuDepart': latLieuDepart,
      'longLieuArrivee': longLieuArrivee,
      'latLieuArrivee': latLieuArrivee,
      'prixParPlace': prixParPlace,
      'placesDisponibles': placesDisponibles,
      'description': description,
      'isCompleted': isCompleted,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conducteurId': conducteurId,
      //'vehiculeId': vehiculeId,
      'date': date.toIso8601String(),
      'lieuDepart': lieuDepart,
      'lieuArrivee': lieuArrivee,
      'lieuRencontre': lieuRencontre,
      'time': time,
      'longLieuDepart': longLieuDepart,
      'latLieuDepart': latLieuDepart,
      'longLieuArrivee': longLieuArrivee,
      'latLieuArrivee': latLieuArrivee,
      'prixParPlace': prixParPlace,
      'placesDisponibles': placesDisponibles,
      'description': description,
      'isCompleted': isCompleted,
      'isActive': isActive,
    };
  }

  Trajet copyWith({
    String? lieuDepart,
    String? lieuArrivee,
    String? lieuRencontre,
    DateTime? date,
    String? time,
    int? conducteurId,
    double? prixParPlace,
  }) {
    return Trajet(
      id: id,
      conducteurId: conducteurId ?? this.conducteurId,
      lieuDepart: lieuDepart ?? this.lieuDepart,
      lieuArrivee: lieuArrivee ?? this.lieuArrivee,
      lieuRencontre: lieuRencontre ?? this.lieuRencontre,
      date: date ?? this.date,
      time: time ?? this.time,
      prixParPlace: prixParPlace ?? this.prixParPlace,
    );
  }
}