import 'package:flutter/material.dart';

class UGOAdminTheme {
  // --- PALETTE DE COULEURS ---
  
  // LE BLEU (Dominante) : Remplace le "Teal Green" de WhatsApp
  // Un bleu roi profond, reposant pour les yeux mais autoritaire.
  static const Color primaryBlue = Color(0xFF0D47A1); 
  
  // L'ORANGE (Action) : Pour les boutons, les notifications
  static const Color accentOrange = Color(0xFFFF6F00);

  // LE GRIS-CLAIR (Fond) : Pour les arrière-plans neutres
  static const Color background = Color(0xFFF5F5FA); 

  // LE JAUNE OR (Statut/Highlight) : Pour les éléments "Premium" ou "Important"
  static const Color gold = Color(0xFFFFD700);

  // --- COULEURS DE FOND & CONFORT ---
  
  // Fond général (Scaffold) : Un gris-bleu très pâle, plus moderne que le beige
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  
  // Fond de la zone de détail (Style Chat)
  static const Color detailBg = Color(0xFFE8EAF6); // Bleu très très pâle
  
  // Bulle de message "Envoyé" (Au lieu du vert clair de WhatsApp)
  static const Color bubbleSelf = Color(0xFFBBDEFB); // Bleu ciel doux
  
  // Bulle de message "Reçu"
  static const Color bubbleOther = Colors.white;

  // --- AUTRES COULEURS UTILITAIRES ---
  static const Color green = Color(0xFF00B894);


  static const Color greyText = Color(0xFF636E72);

  // --- TYPOGRAPHIE ---
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold, 
    fontSize: 16, 
    color: Color(0xFF1A237E) // Bleu nuit pour le texte
  );
  
  static const TextStyle subTitleStyle = TextStyle(
    fontSize: 14, 
    color: Colors.blueGrey,
    overflow: TextOverflow.ellipsis
  );
}