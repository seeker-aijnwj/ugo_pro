class Galerie {
  final String id;
  final String title;
  final String description;
  final String mediaUrl;
  final String mediaType;
  final String altText;
  final bool isVerified;

  Galerie({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaUrl,
    this.mediaType = 'image', // Default to image, can be 'video' or 'audio'
    this.altText = '',
    this.isVerified = false,
  });

  factory Galerie.fromJson(Map<String, dynamic> json) {
    return Galerie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] ?? 'image',
      altText: json['altText'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'altText': altText,
      'isVerified': isVerified,
    };
  }
}