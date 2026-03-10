import 'package:flutter/material.dart';

class FormComponent extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextInputType textInputType;
  final bool hide;
  final bool borderNone;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged; // ✅ Ajouté ici
  final String? Function(String?)? validator; // ✅ Ajouté ici

  const FormComponent({
    super.key,
    this.label = '',
    this.placeholder = '',
    this.hide = false,
    this.borderNone = false,
    this.textInputType = TextInputType.emailAddress,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.onChanged, // ✅ Ajouté au constructeur
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      obscureText: hide,
      onChanged: onChanged, // ✅ Ajouté ici pour déclencher la logique
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: borderNone ? InputBorder.none : const UnderlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
