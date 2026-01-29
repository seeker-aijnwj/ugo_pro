// Fichier: lib/widgets/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    required this.desktopBody,
  });

  // Points de rupture (Breakpoints) en pixels
  static const int mobileWidth = 600;
  static const int tabletWidth = 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileWidth) {
          return mobileBody; // Téléphone
        } else if (constraints.maxWidth < tabletWidth && tabletBody != null) {
          return tabletBody!; // Tablette (optionnel)
        } else {
          return desktopBody; // PC / Web
        }
      },
    );
  }
}