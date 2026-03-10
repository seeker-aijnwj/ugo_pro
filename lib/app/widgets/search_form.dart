// lib/widgets/search_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/form_component.dart'; // pour le champ Date existant
import 'package:u_go/modules/trip_module/database/models/place_ref.dart';
import 'package:u_go/modules/trip_module/widgets/place_autocomplete_field.dart';
//import 'package:latlong2/latlong.dart';


class SearchForm extends StatefulWidget {
  final TextEditingController departController;
  final TextEditingController destinationController;
  final TextEditingController dateController;

  const SearchForm({
    super.key,
    required this.departController,
    required this.destinationController,
    required this.dateController,
  });

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final double bulleHeight = 60;

  // ignore: unused_field
  PlaceRef? _fromPlace;
  // ignore: unused_field
  PlaceRef? _toPlace;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('fr'),
    );
    if (picked != null) {
      widget.dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBulle(
          child: PlaceAutocompleteField(
            controller: widget.departController,
            label: "Point de départ",
            placeholder: "Commencez à taper (ex: Treichville)",
            prefixIcon: Icon(Icons.location_on_outlined, color: mainColor),
            onSelected: (place) => _fromPlace = place as PlaceRef?,
          ),
        ),
        const SizedBox(height: 12),
        _buildBulle(
          child: PlaceAutocompleteField(
            controller: widget.destinationController,
            label: "Destination",
            placeholder: "Commencez à taper (ex: Cocody)",
            prefixIcon: Icon(Icons.flag_outlined, color: mainColor),
            onSelected: (place) => _toPlace = place as PlaceRef?,
          ),
        ),
        const SizedBox(height: 12),
        _buildBulle(
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: FormComponent(
                label: "Date (optionnelle)",
                placeholder: "Choisir une date",
                controller: widget.dateController,
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: mainColor,
                ),
                textInputType: TextInputType.none,
                borderNone: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulle({required Widget child}) {
    return Container(
      height: bulleHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      child: child,
    );
  }
}
