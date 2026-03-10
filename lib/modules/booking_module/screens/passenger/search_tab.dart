import 'package:flutter/material.dart';
import 'package:u_go/modules/booking_module/screens/passenger/search.dart';
import 'package:u_go/modules/booking_module/screens/passenger/search_results_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  bool showResults = false;
  String? depart;
  String? destination;
  String? date;

  void showSearchResults(String dep, String dest, String? dat) {
    setState(() {
      depart = dep;
      destination = dest;
      date = dat;
      showResults = true;
    });
  }

  void resetSearch() {
    setState(() {
      showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showResults
        ? SearchResultScreen(
            depart: depart!,
            destination: destination!,
            date: date,
            onBack: resetSearch,
          )
        : SearchScreen(
            onSearch: (dep, dest, dat) => showSearchResults(dep, dest, dat),
          );
  }
}
