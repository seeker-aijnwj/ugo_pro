// lib/widgets/search_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/widgets/filter_criteria.dart';

typedef FilterChanged = void Function(FilterCriteria criteria);

class SearchFilterBar extends StatelessWidget {
  final FilterCriteria criteria;
  final FilterChanged onChanged;
  final VoidCallback? onOpenSort; // pour ouvrir la feuille "Trier par"
  final Color backgroundColor;

  const SearchFilterBar({
    super.key,
    required this.criteria,
    required this.onChanged,
    this.onOpenSort,
    this.backgroundColor = mainColor,
  });

  Future<void> _pickDay(BuildContext context) async {
    final selected = await showModalBottomSheet<Weekday?>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => const _DayPickerSheet(),
    );
    if (selected == null) return;
    onChanged(criteria.copyWith(day: selected));
  }

  Future<void> _openFilters(BuildContext context) async {
    final updated = await showModalBottomSheet<FilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _AdvancedFilterSheet(initial: criteria),
    );
    if (updated == null) return;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = () {
      if (criteria.day == null) return "Tous les jours";
      switch (criteria.day!) {
        case Weekday.monday:
          return "Lundi";
        case Weekday.tuesday:
          return "Mardi";
        case Weekday.wednesday:
          return "Mercredi";
        case Weekday.thursday:
          return "Jeudi";
        case Weekday.friday:
          return "Vendredi";
        case Weekday.saturday:
          return "Samedi";
        case Weekday.sunday:
          return "Dimanche";
      }
    }();

    return Container(
      color: backgroundColor,
      child: Row(
        children: [
          // Jour
          Expanded(
            flex: 4,
            child: TextButton(
              onPressed: () => _pickDay(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                dayLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Regular",
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white),
          // Filtres
          Expanded(
            flex: 2,
            child: TextButton.icon(
              onPressed: () => _openFilters(context),
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                "Filtre",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Regular",
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          // Tri
          Container(width: 1, height: 40, color: Colors.white),
          Expanded(
            flex: 2,
            child: TextButton.icon(
              onPressed: onOpenSort,
              icon: const Icon(Icons.sort, color: Colors.white, size: 20),
              label: const Text(
                "Trier",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Regular",
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPickerSheet extends StatelessWidget {
  const _DayPickerSheet();

  @override
  Widget build(BuildContext context) {
    final items = <(String, Weekday?)>[
      ("Tous les jours", null),
      ("Lundi", Weekday.monday),
      ("Mardi", Weekday.tuesday),
      ("Mercredi", Weekday.wednesday),
      ("Jeudi", Weekday.thursday),
      ("Vendredi", Weekday.friday),
      ("Samedi", Weekday.saturday),
      ("Dimanche", Weekday.sunday),
    ];
    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (_, i) {
          final (label, val) = items[i];
          return ListTile(
            title: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.of(context).pop(val),
          );
        },
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemCount: items.length,
      ),
    );
  }
}

class _AdvancedFilterSheet extends StatefulWidget {
  final FilterCriteria initial;
  const _AdvancedFilterSheet({required this.initial});

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  late TextEditingController _depCtrl;
  late TextEditingController _arrCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  bool _onlySeats = false;
  TimeOfDay? _start, _end;

  @override
  void initState() {
    super.initState();
    _depCtrl = TextEditingController(text: widget.initial.departureQuery ?? "");
    _arrCtrl = TextEditingController(text: widget.initial.arrivalQuery ?? "");
    _minCtrl = TextEditingController(
      text: widget.initial.minPrice?.toStringAsFixed(0) ?? "",
    );
    _maxCtrl = TextEditingController(
      text: widget.initial.maxPrice?.toStringAsFixed(0) ?? "",
    );
    _onlySeats = widget.initial.onlyAvailableSeats;
    _start = widget.initial.startTime;
    _end = widget.initial.endTime;
  }

  @override
  void dispose() {
    _depCtrl.dispose();
    _arrCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (isStart ? _start : _end) ?? const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  void _apply() {
    double? minP = double.tryParse(_minCtrl.text.trim().replaceAll(',', '.'));
    double? maxP = double.tryParse(_maxCtrl.text.trim().replaceAll(',', '.'));
    if (minP != null && maxP != null && minP > maxP) {
      final tmp = minP;
      minP = maxP;
      maxP = tmp;
    }

    final updated = widget.initial.copyWith(
      departureQuery: _depCtrl.text.trim().isEmpty
          ? null
          : _depCtrl.text.trim(),
      arrivalQuery: _arrCtrl.text.trim().isEmpty ? null : _arrCtrl.text.trim(),
      minPrice: minP,
      maxPrice: maxP,
      startTime: _start,
      endTime: _end,
      onlyAvailableSeats: _onlySeats,
    );
    Navigator.of(context).pop(updated);
  }

  void _clear() {
    Navigator.of(context).pop(const FilterCriteria());
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filtres avancés",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _depCtrl,
                decoration: const InputDecoration(
                  labelText: "Départ (ville ou adresse)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _arrCtrl,
                decoration: const InputDecoration(
                  labelText: "Arrivée (ville ou adresse)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Prix min",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Prix max",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(true),
                      child: Text(
                        _start == null
                            ? "Heure début"
                            : "${_start!.hour.toString().padLeft(2, '0')}:${_start!.minute.toString().padLeft(2, '0')}",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(false),
                      child: Text(
                        _end == null
                            ? "Heure fin"
                            : "${_end!.hour.toString().padLeft(2, '0')}:${_end!.minute.toString().padLeft(2, '0')}",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Uniquement les annonces avec places disponibles",
                ),
                value: _onlySeats,
                onChanged: (v) => setState(() => _onlySeats = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Text("Réinitialiser"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: const Text("Appliquer"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
