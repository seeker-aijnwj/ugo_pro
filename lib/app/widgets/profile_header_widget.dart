import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String phone;
  final String email;

  /// Peut être vide ou null si pas de photo. Accepte URL (http/https) ou chemin d’asset.
  final String? imagePath;
  final Color backgroundColor;
  final bool isDriver;
  final ValueChanged<bool> onToggleDriver;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    this.imagePath,
    required this.isDriver,
    required this.onToggleDriver,
    this.backgroundColor = mainColor,
  });

  //bool get _hasImage => (imagePath != null && imagePath!.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ PHOTO GAUCHE + TEXTE DROITE ALIGNÉ À GAUCHE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟠 AVATAR À GAUCHE
              _buildAvatar(),
              const SizedBox(width: 16),

              // 🟢 TEXTE ALIGNÉ À GAUCHE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom forcé en MAJUSCULE
                    Text(
                      name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ ZONE SWITCH CENTRÉE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: switchContainerColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text(
                  "Mode actif",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.drive_eta, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Chauffeur",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Bold",
                          ),
                        ),
                      ],
                    ),
                    Transform.scale(
                      scale: 0.95,
                      child: Switch(
                        value: isDriver, // RoleService.instance.isDriver true = Chauffeur, false = Passager
                        onChanged: onToggleDriver,
                        activeColor: Colors.greenAccent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit l’avatar :
  /// - Si imagePath commence par http -> Image.network
  /// - Sinon, si imagePath contient déjà un '/' -> on le traite comme un chemin asset complet
  /// - Sinon, on interprète imagePath comme un alias ('boy' | 'girl') et
  ///   on cherche d'abord .jpg puis .png dans assets/images/avatars/
  Widget _buildAvatar() {
    final radius = 40.0;
    final raw = (imagePath ?? '').trim();

    if (raw.isEmpty) {
      return _iconAvatar(radius);
    }

    // URL réseau
    if (raw.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          raw,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _iconAvatar(radius),
        ),
      );
    }

    // Asset local
    // - si raw contient un '/', on considère que c'est un chemin complet d'asset
    // - sinon, on mappe 'boy' -> assets/images/avatars/boy.jpg (fallback .png)
    final String assetJpg = raw.contains('/')
        ? raw
        : 'assets/images/avatars/${raw.toLowerCase()}.jpg';

    // On tente d'abord le .jpg ; s'il échoue et que raw ne contenait pas '/',
    // on retente automatiquement en .png
    return ClipOval(
      child: Image.asset(
        assetJpg,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          // si raw est déjà un chemin complet -> fallback icône
          if (raw.contains('/')) return _iconAvatar(radius);

          // sinon, on essaie la variante .png
          final assetPng = 'assets/images/avatars/${raw.toLowerCase()}.png';
          return Image.asset(
            assetPng,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _iconAvatar(radius),
          );
        },
      ),
    );
  }

  Widget _iconAvatar(double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withOpacity(0.25),
      child: const Icon(Icons.person, size: 40, color: Colors.white),
    );
  }
}
