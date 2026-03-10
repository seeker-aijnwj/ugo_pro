import 'package:flutter/material.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/app/widgets/search_form.dart';
//import 'package:u_go/screens/passenger/search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  final void Function(String depart, String destination, String? date) onSearch;

  const SearchScreen({super.key, required this.onSearch});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onSearchPressed() {
    final dep = _departController.text.trim();
    final dest = _destinationController.text.trim();
    final dat = _dateController.text.trim().isEmpty
        ? null
        : _dateController.text.trim();

    if (dep.isEmpty || dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir départ et destination."),
        ),
      );
      return;
    }
    widget.onSearch(dep, dest, dat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Rechercher un trajet",
          style: TextStyle(fontFamily: 'Agbalumo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 35),
            SearchForm(
              departController: _departController,
              destinationController: _destinationController,
              dateController: _dateController,
            ),
            const SizedBox(height: 35),
            ButtonComponent(
              txtButton: "Rechercher",
              colorButton: mainColor,
              colorText: Colors.white,
              shadowOpacity: 0.3,
              shadowColor: Colors.black,
              width: MediaQuery.of(context).size.width * 0.6,
              onPressed: _onSearchPressed,
            ),
          ],
        ),
      ),
    );
  }
}
