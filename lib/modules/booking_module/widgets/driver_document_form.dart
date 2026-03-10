import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:u_go/app/core/utils/colors.dart';

class DriverDocumentForm extends StatefulWidget {
  final double bubbleHeight;

  /// ✅ Nouveau: callback pour informer le parent si tout est fourni
  final void Function(bool isComplete)? onValidationChanged;

  const DriverDocumentForm({
    super.key,
    this.bubbleHeight = 60,
    this.onValidationChanged,
  });

  @override
  State<DriverDocumentForm> createState() => _DriverDocumentFormState();
}

class _DriverDocumentFormState extends State<DriverDocumentForm> {
  File? licenseFront;
  File? licenseBack;
  File? cniFront;
  File? cniBack;

  final ImagePicker _picker = ImagePicker();

  bool get allDocumentsProvided =>
      licenseFront != null &&
      licenseBack != null &&
      cniFront != null &&
      cniBack != null;

  void _notifyCompletion() {
    widget.onValidationChanged?.call(allDocumentsProvided);
  }

  Future<void> _pickImage(void Function(File) assignFile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        assignFile(File(pickedFile.path));
      });
      // 🔔 Prévenir le parent après mise à jour de l’état
      _notifyCompletion();
    }
  }

  Widget _buildBubbleUpload(String title, File? file, VoidCallback onTap) {
    return Container(
      height: widget.bubbleHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      file,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.camera_alt_outlined, color: secondColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBubbleUpload(
          "Permis de conduire (Recto)",
          licenseFront,
          () => _pickImage((file) => licenseFront = file),
        ),
        _buildBubbleUpload(
          "Permis de conduire (Verso)",
          licenseBack,
          () => _pickImage((file) => licenseBack = file),
        ),
        _buildBubbleUpload(
          "CNI (Recto)",
          cniFront,
          () => _pickImage((file) => cniFront = file),
        ),
        _buildBubbleUpload(
          "CNI (Verso)",
          cniBack,
          () => _pickImage((file) => cniBack = file),
        ),
      ],
    );
  }
}
