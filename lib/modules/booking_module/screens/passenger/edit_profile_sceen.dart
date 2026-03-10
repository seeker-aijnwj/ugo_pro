import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_go/app/core/utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _numeroCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();

  bool _saving = false;
  String? _docId;

  /// "boy" | "girl" | null
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _docId = user?.uid;
    _emailCtrl.text = user?.email ?? '';

    if (_docId != null) {
      _fire
          .collection('users')
          .doc(_docId)
          .get()
          .then((snap) {
            final d = snap.data();
            _numeroCtrl.text = (d?['numero'] ?? '').toString();
            _nomCtrl.text = (d?['nom'] ?? '').toString();
            _prenomCtrl.text = (d?['prenom'] ?? '').toString();
            _selectedAvatar = (d?['avatar'] ?? '').toString();
            if (_selectedAvatar!.isEmpty) _selectedAvatar = null;
            setState(() {});
          })
          .catchError((_) {});
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _emailCtrl.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_docId == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final dataToUpdate = <String, dynamic>{
        'numero': _numeroCtrl.text.trim(),
        'nom': _nomCtrl.text.trim(),
        'prenom': _prenomCtrl.text.trim(),
        'avatar': _selectedAvatar ?? '',
      };

      await _fire
          .collection('users')
          .doc(_docId)
          .set(dataToUpdate, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Mes informations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  _ProfileHeader(
                    selectedAvatar: _selectedAvatar,
                    onAvatarSelect: (avatar) {
                      setState(() => _selectedAvatar = avatar);
                    },
                  ),
                  const SizedBox(height: 16),

                  _CardBubble(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _LabeledField(
                            label: 'Nom',
                            child: TextFormField(
                              controller: _nomCtrl,
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Nom requis'
                                  : null,
                              decoration: _decoration('Votre nom'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _LabeledField(
                            label: 'Prénom',
                            child: TextFormField(
                              controller: _prenomCtrl,
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Prénom requis'
                                  : null,
                              decoration: _decoration('Votre prénom'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _LabeledField(
                            label: 'Email',
                            child: TextFormField(
                              controller: _emailCtrl,
                              readOnly: true,
                              enabled: false,
                              style: const TextStyle(color: Colors.grey),
                              decoration: _decoration(
                                'Votre email',
                                readOnly: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _LabeledField(
                            label: 'Numéro',
                            child: TextFormField(
                              controller: _numeroCtrl,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty) return 'Le numéro est requis';
                                if (t.length < 8) return 'Numéro invalide';
                                return null;
                              },
                              decoration: _decoration('Ex: 0701020304'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor: Colors.black.withOpacity(0.25),
                      ),
                      child: Text(_saving ? 'Modification...' : 'Modifier'),
                    ),
                  ),
                ],
              ),
            ),

            if (_saving)
              Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, {bool readOnly = false}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: readOnly ? const Color(0xFFF9FAFB) : Colors.white,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? selectedAvatar;
  final Function(String) onAvatarSelect;

  const _ProfileHeader({
    required this.selectedAvatar,
    required this.onAvatarSelect,
  });

  @override
  Widget build(BuildContext context) {
    final avatarPath = (selectedAvatar != null && selectedAvatar!.isNotEmpty)
        ? 'assets/images/avatars/$selectedAvatar.jpg'
        : null;

    return _CardBubble(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          // Avatar actuel (ou icône personne)
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: avatarPath != null ? AssetImage(avatarPath) : null,
            child: avatarPath == null
                ? const Icon(Icons.person, size: 56, color: Colors.white70)
                : null,
          ),
          const SizedBox(height: 12),
          const Text(
            'Choisir un avatar',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Deux choix : boy / girl
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarChoice(
                label: 'Homme',
                asset: 'assets/images/avatars/boy.jpg',
                selected: selectedAvatar == 'boy',
                onTap: () => onAvatarSelect('boy'),
              ),
              const SizedBox(width: 24),
              _AvatarChoice(
                label: 'Femme',
                asset: 'assets/images/avatars/girl.jpg',
                selected: selectedAvatar == 'girl',
                onTap: () => onAvatarSelect('girl'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mini widget pour un choix d’avatar avec halo de sélection
class _AvatarChoice extends StatelessWidget {
  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarChoice({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(44),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? mainColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: mainColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(asset),
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? mainColor : Colors.black54,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _CardBubble({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
