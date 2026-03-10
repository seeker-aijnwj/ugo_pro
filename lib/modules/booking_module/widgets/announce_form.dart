// lib/widgets/announce_form.dart

import 'package:flutter/material.dart';
import 'package:u_go/app/widgets/form_component.dart';
import 'package:u_go/modules/trip_module/widgets/place_autocomplete_field.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/models/announce_data.dart';

// +++ AUTOCOMPLÉTION LIEUX +++
import 'package:u_go/modules/trip_module/database/models/place_ref.dart';

class AnnounceForm extends StatefulWidget {
  const AnnounceForm({super.key, required this.onChanged, this.initialData});

  final ValueChanged<AnnounceData> onChanged;
  final AnnounceData? initialData;

  @override
  State<AnnounceForm> createState() => _AnnounceFormState();
}

class _AnnounceFormState extends State<AnnounceForm> {
  // Contrôleurs
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _meetingController = TextEditingController();
  final TextEditingController _arrivalPlaceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final double bubbleHeight = 55;
  final List<TextEditingController> _stops = [TextEditingController()];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // (Optionnel) garder la sélection réelle si tu veux les coords plus tard
  PlaceRef? fromPlace;
  PlaceRef? toPlace;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    if (d != null) {
      _departController.text = d.depart;
      _destinationController.text = d.destination;
      _meetingController.text = d.meetingPlace;
      _arrivalPlaceController.text = d.arrivalPlace;

      _selectedDate = d.date;
      _selectedTime = d.time;
      if (d.date != null) {
        _dateController.text = "${d.date!.toLocal()}".split(' ')[0];
      }
      if (d.time != null) {
        _timeController.text =
            "${d.time!.hour.toString().padLeft(2, '0')}:${d.time!.minute.toString().padLeft(2, '0')}";
      }
      if (d.seats != null) _seatsController.text = d.seats.toString();
      if (d.price != null) _priceController.text = d.price.toString();

      if (d.stops.isNotEmpty) {
        _stops.clear();
        _stops.addAll(d.stops.map((s) => TextEditingController(text: s)));
        _stops.add(TextEditingController());
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => _emitChange());
    }
  }

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _meetingController.dispose();
    _arrivalPlaceController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    for (final c in _stops) {
      c.dispose();
    }
    super.dispose();
  }

  void _emitChange() {
    final stopsClean = _stops
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final seats = int.tryParse(_seatsController.text.trim());
    final price = int.tryParse(_priceController.text.trim());

    final data = AnnounceData(
      depart: _departController.text.trim(),
      destination: _destinationController.text.trim(),
      meetingPlace: _meetingController.text.trim(),
      arrivalPlace: _arrivalPlaceController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      stops: stopsClean,
      seats: seats,
      price: price,
    );
    widget.onChanged(data);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _dateController.text = "${_selectedDate!.toLocal()}".split(' ')[0];
      });
      _emitChange();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
      _emitChange();
    }
  }

  void _handleStopChanged(int index) {
    if (_stops[index].text.isNotEmpty && index == _stops.length - 1) {
      setState(() {
        _stops.add(TextEditingController());
      });
    }
    _emitChange();
  }

  void _removeStop(int index) {
    setState(() {
      final c = _stops.removeAt(index);
      c.dispose();
    });
    _emitChange();
  }

  Widget _buildBubbleForm({required Widget child}) {
    return Container(
      height: bubbleHeight,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === AUTOCOMPLÉTION : DÉPART ===
        _buildBubbleForm(
          child: PlaceAutocompleteField(
            controller: _departController,
            label: "Départ",
            placeholder: "Tapez un lieu (ex : Treichville, Bouaké...)",
            prefixIcon: Icon(Icons.location_on_outlined, color: secondColor),
            onSelected: (p) {
              fromPlace = p; // si tu veux ses tags/region plus tard
              _emitChange();
            },
          ),
        ),

        // === AUTOCOMPLÉTION : DESTINATION ===
        _buildBubbleForm(
          child: PlaceAutocompleteField(
            controller: _destinationController,
            label: "Destination",
            placeholder: "Tapez une destination (ex : Cocody, San-Pédro...)",
            prefixIcon: Icon(Icons.flag_outlined, color: secondColor),
            onSelected: (p) {
              toPlace = p;
              _emitChange();
            },
          ),
        ),

        // (les deux champs ci-dessous restent en saisie libre, on fera l’autocomplétion plus tard)
        _buildBubbleForm(
          child: FormComponent(
            label: "Lieu de rencontre",
            placeholder: "Entrez le lieu de rencontre",
            controller: _meetingController,
            onChanged: (_) => _emitChange(),
            prefixIcon: Icon(Icons.location_city_outlined, color: secondColor),
            borderNone: true,
          ),
        ),
        _buildBubbleForm(
          child: FormComponent(
            label: "Lieu de dépot",
            placeholder: "Ex : Hyper U Plateau, arrêt précis...",
            controller: _arrivalPlaceController,
            onChanged: (_) => _emitChange(),
            prefixIcon: Icon(Icons.place_outlined, color: secondColor),
            borderNone: true,
          ),
        ),

        _buildBubbleForm(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: FormComponent(
                label: "Date | Jour de la semaine",
                placeholder: "Choisissez une date",
                controller: _dateController,
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: secondColor,
                ),
                borderNone: true,
              ),
            ),
          ),
        ),
        _buildBubbleForm(
          child: GestureDetector(
            onTap: () => _selectTime(context),
            child: AbsorbPointer(
              child: FormComponent(
                label: "Heure de départ",
                placeholder: "Choisissez l'heure",
                controller: _timeController,
                prefixIcon: Icon(Icons.access_time, color: secondColor),
                borderNone: true,
              ),
            ),
          ),
        ),

        // Arrêts dynamiques
        ..._stops.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return _buildBubbleForm(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                // Le champ d’auto-complétion
                PlaceAutocompleteField(
                  controller: controller,
                  label: "Arrêt (facultatif)",
                  placeholder: "Ex : Yopougon, Adjamé, etc.",
                  prefixIcon: Icon(
                    Icons.transfer_within_a_station,
                    color: secondColor,
                  ),
                  onChanged: (_) => _handleStopChanged(index),
                  onSelected: (place) {
                    controller.text = place.display;
                    _handleStopChanged(index);
                  },
                  borderNone: true,
                ),

                // Bouton X superposé à droite (sans chevaucher le texte grâce au padding)
                if (_stops.length > 1)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeStop(index),
                      tooltip: "Supprimer cet arrêt",
                    ),
                  ),
              ],
            ),
          );
        }),

        _buildBubbleForm(
          child: FormComponent(
            label: "Nombre de places",
            placeholder: "Entrez le nombre de places",
            controller: _seatsController,
            onChanged: (_) => _emitChange(),
            textInputType: TextInputType.number,
            prefixIcon: Icon(Icons.person_outline, color: secondColor),
            borderNone: true,
          ),
        ),
        _buildBubbleForm(
          child: FormComponent(
            label: "Prix",
            placeholder: "Entrez le prix en FCFA",
            controller: _priceController,
            onChanged: (_) => _emitChange(),
            textInputType: TextInputType.number,
            prefixIcon: Icon(Icons.attach_money, color: secondColor),
            borderNone: true,
          ),
        ),
      ],
    );
  }
}
