// lib/widgets/poi_autocomplete_field.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/trip_module/database/models/place_ref.dart';
import 'package:u_go/modules/trip_module/services/poi_service.dart';

typedef PlaceSelected = void Function(PlaceRef);

class PoiAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final Icon? prefixIcon;

  /// Commune à filtrer (ex: "Treichville", "Cocody", "Le Plateau")
  final String? commune;

  /// Nombre max de suggestions à afficher
  final int maxSuggestions;

  /// Nombre minimum de caractères avant de chercher (1 par défaut)
  final int minChars;

  final PlaceSelected? onSelected;

  const PoiAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.prefixIcon,
    this.commune,
    this.onSelected,
    this.maxSuggestions = 25,
    this.minChars = 1,
  });

  @override
  State<PoiAutocompleteField> createState() => _PoiAutocompleteFieldState();
}

class _PoiAutocompleteFieldState extends State<PoiAutocompleteField> {
  TextEditingController? _autoCtrl;
  FocusNode? autoFocus;

  final _options = <PlaceRef>[];
  Timer? _debounce;
  bool _loading = false;
  String lastQuery = '';
  String? lastCommune;

  @override
  void didUpdateWidget(covariant PoiAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commune != widget.commune) {
      lastCommune = widget.commune;
      _options.clear(); // change de commune -> on vide les anciennes options
      setState(() {});
      // Pas de préchargement : on attend que l'utilisateur tape >= minChars
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ---------- Fetch / debounce ----------
  void _scheduleFetch(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _fetch(q));
  }

  Future<void> _fetch(String q) async {
    if (!mounted) return;
    final commune = widget.commune?.trim();
    if (commune == null || commune.isEmpty) {
      setState(() {
        _options.clear();
        _loading = false;
      });
      return;
    }
    lastQuery = q;
    lastCommune = commune;

    setState(() => _loading = true);
    try {
      final res = await PoiService.searchPOIs(
        commune: commune,
        query: q,
        limit: widget.maxSuggestions,
      );
      if (!mounted) return;
      setState(() {
        _options
          ..clear()
          ..addAll(res);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _options.clear();
        _loading = false;
      });
    }
  }

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

  void _bindControllers(TextEditingController c) {
    if (_autoCtrl == c) return;
    _autoCtrl = c;

    // sync initiale externe -> interne
    if (widget.controller.text.isNotEmpty &&
        _autoCtrl!.text != widget.controller.text) {
      _autoCtrl!.value = widget.controller.value;
    }

    // écoute la saisie pour déclencher le fetch
    _autoCtrl!.addListener(() {
      final raw = _autoCtrl!.text;
      final q = raw.trim();
      // miroir vers le contrôleur externe
      if (widget.controller.text != _autoCtrl!.text) {
        widget.controller.value = _autoCtrl!.value;
      }

      if (widget.commune == null || widget.commune!.trim().isEmpty) {
        // pas de commune => pas de fetch
        setState(() => _options.clear());
        return;
      }

      if (q.length < widget.minChars) {
        // moins que minChars => on nettoie la liste
        setState(() => _options.clear());
        return;
      }

      // Asynchrone : on va chercher côté Overpass
      _scheduleFetch(q);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCommune =
        widget.commune != null && widget.commune!.trim().isNotEmpty;

    return RawAutocomplete<PlaceRef>(
      displayStringForOption: (p) => p.display,
      optionsBuilder: (tev) {
        // On ne renvoie des options que si l'utilisateur a tapé minChars et si commune connue
        final q = tev.text.trim();
        if (!hasCommune || q.length < widget.minChars) {
          return const Iterable<PlaceRef>.empty();
        }
        return _options;
      },
      onSelected: (place) {
        _autoCtrl?.text = place.display;
        widget.controller.text = place.display;
        widget.onSelected?.call(place);
      },
      fieldViewBuilder:
          (ctx, textEditingController, focusNode, onFieldSubmitted) {
            _bindControllers(textEditingController);
            autoFocus = focusNode;

            return SizedBox(
              height: 60,
              child: Center(
                child: TextField(
                  enabled: true, // toujours éditable
                  controller: textEditingController,
                  focusNode: focusNode,
                  onSubmitted: (_) => onFieldSubmitted(),
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: hasCommune
                        ? widget.placeholder
                        : "Sélectionnez d'abord la commune",
                    prefixIcon:
                        widget.prefixIcon ??
                        Icon(Icons.search, color: mainColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    suffixIcon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            );
          },
      optionsViewBuilder: (ctx, onSelected, options) {
        final opts = options.toList(growable: false);
        if (opts.isEmpty) return const SizedBox.shrink();
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
                  final p = opts[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      p.display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(p.display),
                    onTap: () => onSelected(p),
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
