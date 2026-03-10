class Utilisateur {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String motDePasse;
  final String role;
  final String photoProfil;
  final String? bio;
  final String adresse;
  final DateTime? dateNaissance;
  final String? genre;
  final bool isVerified;
  final String? token;
  final String? refreshToken;
  final String? wayToVerified;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.motDePasse,
    required this.role,
    required this.photoProfil,
    required this.bio,
    required this.adresse,
    required this.dateNaissance,
    required this.genre,
    required this.isVerified,
    required this.token,
    required this.refreshToken,
    required this.wayToVerified,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      motDePasse: json['motDePasse'],
      role: json['role'],
      telephone: json['telephone'],
      photoProfil: json['photoProfil'],
      bio: json['bio'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'] != null
          ? DateTime.parse(json['dateNaissance'])
          : null,
      genre: json['genre'],
      isVerified: json['isVerified'] ?? false,
      token: json['token'],
      refreshToken: json['refreshToken'],
      wayToVerified: json['wayToVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'motDePasse': motDePasse,
      'role': role,
      'telephone': telephone,
      'photoProfil': photoProfil,
      'bio': bio,
      'adresse': adresse,
      'dateNaissance': dateNaissance?.toIso8601String(),
      'genre': genre,
      'isVerified': isVerified,
      'token': token,
      'refreshToken': refreshToken,
      'wayToVerified': wayToVerified,
    };
  }
}
