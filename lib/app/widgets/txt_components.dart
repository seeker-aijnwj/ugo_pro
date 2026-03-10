import 'package:flutter/material.dart';

class TxtComponents extends StatelessWidget {
  final Color color;
  final double txtSize;
  final FontWeight fw;
  final TextAlign txtAlign;
  final String txt;
  final String family;
  final VoidCallback? onTap; // Ajout de onTap

  const TxtComponents({
    super.key,
    required this.txt,
    this.color = Colors.black,
    this.txtSize = 16,
    this.fw = FontWeight.normal,
    this.txtAlign = TextAlign.left,
    this.family = "Regular",
    this.onTap, // Ajout de onTap
  });

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      txt,
      style: TextStyle(
        color: color,
        fontSize: txtSize,
        fontWeight: fw,
        fontFamily: family,
      ),
      textAlign: txtAlign,
    );

    // Si onTap est fourni, rendre le texte cliquable avec effet de ripple et curseur main
    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: textWidget),
      );
    } else {
      return textWidget;
    }
  }
}
