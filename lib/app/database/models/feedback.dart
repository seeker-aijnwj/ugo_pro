class Feedback {
  final int id;
  final int expediteurId;
  final int destinataireId;
  final String sujet;
  final String contenu;
  final DateTime dateFeedback;

  Feedback({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    required this.sujet,
    required this.contenu,
    required this.dateFeedback,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      expediteurId: json['expediteurId'],
      destinataireId: json['destinataireId'],
      sujet: json['sujet'],
      contenu: json['contenu'],
      dateFeedback: DateTime.parse(json['dateFeedback']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expediteurId': expediteurId,
      'destinataireId': destinataireId,
      'sujet': sujet,
      'contenu': contenu,
      'dateFeedback': dateFeedback.toIso8601String(),
    };
  }
}
