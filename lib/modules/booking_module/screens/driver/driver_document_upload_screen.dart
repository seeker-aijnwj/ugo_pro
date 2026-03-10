// Cette page permet au conducteur de télécharger ses documents.
// Elle utilise un formulaire (DriverDocumentForm) et un bouton de validation.

import 'package:flutter/material.dart';
import 'package:u_go/modules/booking_module/widgets/driver_document_form.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/onboarding/views/announce_success_screen.dart';

class DriverDocumentUploadScreen extends StatefulWidget {
  const DriverDocumentUploadScreen({super.key});

  @override
  State<DriverDocumentUploadScreen> createState() =>
      _DriverDocumentUploadScreenState();
}

class _DriverDocumentUploadScreenState
    extends State<DriverDocumentUploadScreen> {
  bool allDocsProvided = false;

  void updateValidationStatus(bool status) {
    setState(() {
      allDocsProvided = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Terminer son inscription",
          style: TextStyle(fontFamily: 'Agbalumo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 🟠 Formulaire bulle (on câble le callback)
            DriverDocumentForm(onValidationChanged: updateValidationStatus),

            const SizedBox(height: 30),

            // 🔘 Bouton de validation
            ButtonComponent(
              txtButton: "Valider",
              colorButton: allDocsProvided ? secondColor : Colors.grey,
              colorText: Colors.white,
              onPressed: allDocsProvided
                  ? () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnounceSuccessScreen(),
                        ),
                        (_) => false,
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
