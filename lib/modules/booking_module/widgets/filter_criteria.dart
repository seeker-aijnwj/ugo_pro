// lib/widgets/filter_criteria.dart
import 'package:flutter/material.dart';

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

Weekday? weekdayFromInt(int? v) {
  if (v == null) return null;
  switch (v) {
    case 1:
      return Weekday.monday;
    case 2:
      return Weekday.tuesday;
    case 3:
      return Weekday.wednesday;
    case 4:
      return Weekday.thursday;
    case 5:
      return Weekday.friday;
    case 6:
      return Weekday.saturday;
    case 7:
      return Weekday.sunday;
  }
  return null;
}

int? intFromWeekday(Weekday? d) {
  if (d == null) return null;
  return d.index + 1; // Monday=1 ... Sunday=7
}

@immutable
class FilterCriteria {
  final Weekday? day; // null = Tous les jours
  final String? departureQuery; // "Abidjan"
  final String? arrivalQuery; // "Yamoussoukro"
  final double? minPrice; // CFA
  final double? maxPrice; // CFA
  final TimeOfDay? startTime; // Heure min
  final TimeOfDay? endTime; // Heure max
  final bool onlyAvailableSeats; // places > reserved

  const FilterCriteria({
    this.day,
    this.departureQuery,
    this.arrivalQuery,
    this.minPrice,
    this.maxPrice,
    this.startTime,
    this.endTime,
    this.onlyAvailableSeats = false,
  });

  FilterCriteria copyWith({
    Weekday? day,
    String? departureQuery,
    String? arrivalQuery,
    double? minPrice,
    double? maxPrice,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? onlyAvailableSeats,
  }) {
    return FilterCriteria(
      day: day,
      departureQuery: departureQuery ?? this.departureQuery,
      arrivalQuery: arrivalQuery ?? this.arrivalQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      onlyAvailableSeats: onlyAvailableSeats ?? this.onlyAvailableSeats,
    );
  }

  static const empty = FilterCriteria();

  bool get isEmpty =>
      day == null &&
      (departureQuery == null || departureQuery!.isEmpty) &&
      (arrivalQuery == null || arrivalQuery!.isEmpty) &&
      minPrice == null &&
      maxPrice == null &&
      startTime == null &&
      endTime == null &&
      !onlyAvailableSeats;
}
