// ✅ Fichier : widgets/profile_tile.dart
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color; // ✅ Nouvelle couleur personnalisable

  const ProfileTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color, // ✅ Peut être null (prend mainColor par défaut)
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? mainColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: tileColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: tileColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
