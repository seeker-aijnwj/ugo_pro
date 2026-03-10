import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';

class ButtonComponent extends StatelessWidget {
  final String txtButton;
  final Color colorButton;
  final Color colorText;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onPressed;
  final double? width;
  final double shadowOpacity; // ✅ Opacité de l'ombre (0 = aucune)
  final Color shadowColor; // ✅ Couleur de l'ombre

  const ButtonComponent({
    super.key,
    required this.txtButton,
    this.colorButton = mainColor,
    this.colorText = Colors.white,
    this.showBorder = false,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    this.onPressed,
    this.width,
    this.shadowOpacity = 0.0, // ✅ 0 = pas de shadow
    this.shadowColor = Colors.black, // ✅ par défaut : ombre noire
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 50,
          width: width ?? MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: colorButton,
            borderRadius: BorderRadius.circular(8),
            border: showBorder
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
            boxShadow: shadowOpacity > 0
                ? [
                    BoxShadow(
                      color: shadowColor.withOpacity(shadowOpacity),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              txtButton,
              style: TextStyle(
                color: colorText,
                fontSize: 18,
                fontFamily: "Bold",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
