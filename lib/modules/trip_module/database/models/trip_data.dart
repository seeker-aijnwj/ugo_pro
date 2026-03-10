import 'package:cloud_firestore/cloud_firestore.dart';

/// Statuts possibles du trajet
enum TripStatus {
  scheduled,
  running,
  completed,
  canceled;

  static TripStatus parse(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'running':
        return TripStatus.running;
      case 'completed':
        return TripStatus.completed;
      case 'canceled':
        return TripStatus.canceled;
      case 'scheduled':
      default:
        return TripStatus.scheduled;
    }
  }

  String get asString => name; // "scheduled"|"running"|...
}

/// Modèle principal d’un trajet
class TripData {
  final String id;                 // doc id (trips/{id})
  final TripStatus status;         // scheduled|running|completed|canceled
  final String driverUserId;       // uid du conducteur
  final List<String> passengerIds; // uids passagers

  // Infos affichage / métier
  final String? title;             // "Trajet Cocody → Yopougon"
  final String? from;              // libellé départ
  final String? to;                // libellé arrivée
  final GeoPoint? fromGeo;         // option : point de départ géo
  final GeoPoint? toGeo;           // option : point d’arrivée géo
  final Timestamp? startTime;      // prévu/début
  final Timestamp? endTime;        // fin prévue/réelle
  final num? price;                // prix par passager (option)

  // Métadonnées
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const TripData({
    required this.id,
    required this.status,
    required this.driverUserId,
    required this.passengerIds,
    this.title,
    this.from,
    this.to,
    this.fromGeo,
    this.toGeo,
    this.startTime,
    this.endTime,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  /// Getters pratiques
  bool get isScheduled => status == TripStatus.scheduled;
  bool get isRunning => status == TripStatus.running;
  bool get isCompleted => status == TripStatus.completed;
  bool get isCanceled => status == TripStatus.canceled;

  /// Validation légère (tu peux enrichir selon tes règles)
  void assertValid() {
    if (driverUserId.isEmpty) {
      throw StateError('driverUserId requis');
    }
  }

  TripData copyWith({
    String? id,
    TripStatus? status,
    String? driverUserId,
    List<String>? passengerIds,
    String? title,
    String? from,
    String? to,
    GeoPoint? fromGeo,
    GeoPoint? toGeo,
    Timestamp? startTime,
    Timestamp? endTime,
    num? price,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return TripData(
      id: id ?? this.id,
      status: status ?? this.status,
      driverUserId: driverUserId ?? this.driverUserId,
      passengerIds: passengerIds ?? this.passengerIds,
      title: title ?? this.title,
      from: from ?? this.from,
      to: to ?? this.to,
      fromGeo: fromGeo ?? this.fromGeo,
      toGeo: toGeo ?? this.toGeo,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mapping Firestore -> Trip
  static TripData fromFirestore(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data() ?? const <String, dynamic>{};

    return TripData(
      id: snap.id,
      status: TripStatus.parse(data['status'] as String?),
      driverUserId: (data['driverUserId'] as String? ?? ''),
      passengerIds: (data['passengerIds'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      title: data['title'] as String?,
      from: data['from'] as String?,
      to: data['to'] as String?,
      fromGeo: data['fromGeo'] as GeoPoint?,
      toGeo: data['toGeo'] as GeoPoint?,
      startTime: data['startTime'] as Timestamp?,
      endTime: data['endTime'] as Timestamp?,
      price: data['price'] as num?,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  /// Mapping Trip -> Firestore (merge-friendly)
  Map<String, dynamic> toFirestore({bool withTimestamps = true}) {
    final now = Timestamp.now();
    return {
      'status': status.asString,
      'driverUserId': driverUserId,
      'passengerIds': passengerIds,
      if (title != null) 'title': title,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (fromGeo != null) 'fromGeo': fromGeo,
      if (toGeo != null) 'toGeo': toGeo,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (price != null) 'price': price,
      if (withTimestamps) 'updatedAt': now,
      if (withTimestamps && createdAt == null) 'createdAt': now,
    };
  }
}

