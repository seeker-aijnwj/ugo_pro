// lib/widgets/place_autocomplete_field.dart
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

typedef PlaceSelected = void Function(PlaceRef);

class PlaceAutocompleteField extends StatefulWidget {
  final TextEditingController controller; // contrôleur EXTERNE
  final String label;
  final String placeholder;
  final Icon? prefixIcon;
  final int maxSuggestions;
  final PlaceSelected? onSelected;

  // --- NOUVEAUX PARAMS (tous optionnels) ---
  final ValueChanged<String>? onChanged; // appelé à chaque frappe
  final Widget? trailing; // ex: bouton X pour supprimer l'arrêt
  final bool borderNone; // garde le look FormComponent

  const PlaceAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.prefixIcon,
    this.onSelected,
    this.maxSuggestions = 8,
    this.onChanged, // facultatif
    this.trailing, // facultatif
    this.borderNone = true, // par défaut comme avant
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  TextEditingController? _autoCtrl; // contrôleur interne de RawAutocomplete
  FocusNode? autoFocus;

  // Normalisation accents/casse
  String normalizeString(String s) {
    const from = 'àáâäãåèéêëìíîïòóôöõùúûüýÿçÀÁÂÄÃÅÈÉÊËÌÍÎÏÒÓÔÖÕÙÚÛÜÝÇ';
    const to = 'aaaaaaeeeeiiiiooooouuuuyycAAAAAAEEEEIIIIOOOOOUUUUYC';
    final buf = StringBuffer();
    for (final ch in s.characters) {
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    return buf.toString().toLowerCase().trim();
  }

  Iterable<PlaceRef> _filter(String query) sync* {
    if (query.isEmpty) return;
    final normalizedQuery = normalizeString(query);
    final pref = <PlaceRef>[];
    final contains = <PlaceRef>[];

    for (final categoryPlaces in kCIPlaces) {
      for (final place in categoryPlaces) {
        final critera1 = normalizeString(place.name);
        final critera2 = normalizeString(place.town!);
        final critera3 = normalizeString(place.display);
        final pre = critera1.startsWith(normalizedQuery) || critera2.startsWith(normalizedQuery) || critera3.startsWith(normalizedQuery);
        final sub = !pre && (critera1.contains(normalizedQuery) || critera2.contains(normalizedQuery) || critera3.contains(normalizedQuery));
        if (pre) {
          pref.add(place);
        } else if (sub) {
          contains.add(place);
        }
      }
    }

    // communes d’abord
    pref.sort((a, b) {
      final ac = a.tags.contains('commune') ? 0 : 1;
      final bc = b.tags.contains('commune') ? 0 : 1;
      return ac.compareTo(bc);
    });

    final merged = [...pref, ...contains];
    for (final p in merged.take(widget.maxSuggestions)) {
      yield p;
    }
  }

  // Synchronise le contrôleur interne de RawAutocomplete -> contrôleur externe
  void _bindControllers(TextEditingController c) {
    if (_autoCtrl == c) return;
    _autoCtrl?.removeListener(_mirrorToExternal);
    _autoCtrl = c;

    // init avec la valeur externe si elle existe
    if (widget.controller.text.isNotEmpty &&
        _autoCtrl!.text != widget.controller.text) {
      _autoCtrl!.value = widget.controller.value;
    } else if (_autoCtrl!.text.isNotEmpty &&
        widget.controller.text != _autoCtrl!.text) {
      widget.controller.value = _autoCtrl!.value;
    }

    _autoCtrl!.addListener(_mirrorToExternal);
  }

  void _mirrorToExternal() {
    if (widget.controller.text != _autoCtrl!.text) {
      widget.controller.value = _autoCtrl!.value;
      // propage l'event onChanged si demandé
      widget.onChanged?.call(_autoCtrl!.text);
    }
  }

  @override
  void dispose() {
    _autoCtrl?.removeListener(_mirrorToExternal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<PlaceRef>(
      displayStringForOption: (place) => place.name,
      optionsBuilder: (TextEditingValue tev) => _filter(tev.text),
      onSelected: (place) {
        // Remplit les deux contrôleurs
        _autoCtrl?.text = place.name;
        widget.controller.text = place.name;

        // onSelected externe (facultatif)
        widget.onSelected?.call(place);
        // onChanged externe (facultatif) — utile pour déclencher ta logique d'ajout de stop
        widget.onChanged?.call(place.name);
      },
      fieldViewBuilder:
          (ctx, textEditingController, focusNode, onFieldSubmitted) {
            _bindControllers(textEditingController);
            autoFocus = focusNode;

            // Ajoute du padding à droite si trailing pour éviter chevauchement
            final basePadding = const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            );
            final contentPadding = widget.trailing == null
                ? basePadding
                : basePadding + const EdgeInsets.only(right: 40);

            final textField = SizedBox(
              height: 60,
              child: Center(
                child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (_) => onFieldSubmitted(),
                  // propage aussi onChanged direct (sans attendre le miroir)
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.placeholder,
                    prefixIcon:
                        widget.prefixIcon ??
                        Icon(Icons.search, color: mainColor),
                    border: widget.borderNone
                        ? InputBorder.none
                        : const OutlineInputBorder(),
                    contentPadding: contentPadding,
                  ),
                ),
              ),
            );

            // Si pas de trailing -> on renvoie directement le TextField
            if (widget.trailing == null) return textField;

            // Sinon on superpose le trailing à droite proprement
            return Stack(
              alignment: Alignment.centerRight,
              children: [
                textField,
                Positioned(right: 0, child: widget.trailing!),
              ],
            );
          },
      optionsViewBuilder: (ctx, onSelected, options) {
        final opts = options.toList(growable: false);
        if (opts.isEmpty) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320, minWidth: 280),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: opts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final place = opts[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(place.display),
                    onTap: () => onSelected(place),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
