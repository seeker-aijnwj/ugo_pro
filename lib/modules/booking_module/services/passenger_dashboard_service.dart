import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PassengerGraphPayload {
  /// Ex: ["Mai","Juin","Juil.","Août"] — ordre: ancien -> récent (dernier = courant)
  final List<String> months;

  /// dataByMonth[i] = 7 valeurs (Lun..Dim) pour months[i]
  final List<List<double>> dataByMonth;

  /// index par défaut = mois courant (à droite)
  final int selectedMonthIndexDefault;

  PassengerGraphPayload({
    required this.months,
    required this.dataByMonth,
    required this.selectedMonthIndexDefault,
  });
}

extension _DateHelpers on DateTime {
  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  DateTime get firstDayNextMonth =>
      (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
}

class PassengerDashboardService {
  final FirebaseFirestore _db;
  PassengerDashboardService(this._db);

  // -------------------- Mois utils (identique au driver) --------------------

  /// 4 derniers mois (mois courant inclus) en partant du plus récent
  List<DateTime> _last4MonthsStarts(DateTime now) {
    final m0 = now.firstDayOfMonth;
    return [
      m0,
      DateTime(m0.year, m0.month - 1, 1),
      DateTime(m0.year, m0.month - 2, 1),
      DateTime(m0.year, m0.month - 3, 1),
    ];
  }

  /// Libellé FR du mois (capit.) avec fallback si la locale n'est pas prête
  String _monthLabel(DateTime monthStart) {
    try {
      final f = DateFormat.MMMM('fr_FR');
      final label = f.format(monthStart);
      return label[0].toUpperCase() + label.substring(1);
    } catch (_) {
      const months = [
        "Janvier",
        "Février",
        "Mars",
        "Avril",
        "Mai",
        "Juin",
        "Juillet",
        "Août",
        "Septembre",
        "Octobre",
        "Novembre",
        "Décembre",
      ];
      final name = months[monthStart.month - 1];
      return name;
    }
  }

  int _weekdayOccurrencesInMonth(DateTime monthStart, int weekday) {
    final end = monthStart.firstDayNextMonth;
    int count = 0;
    for (
      DateTime d = monthStart;
      d.isBefore(end);
      d = d.add(const Duration(days: 1))
    ) {
      if (d.weekday == weekday) count++;
    }
    return count;
  }

  // -------------------- Moyenne réservations / jour (Lun..Dim) --------------------

  /// Compte **1 par réservation** du passager (peu importe reservedSeats).
  /// Fenêtre: createdAt ∈ [monthStart, monthEnd)
  /// On ignore seulement les réservations annulées (status "cancelled"/"annulee").
  Future<List<double>> _weekdayAveragesForMonth({
    required String passengerId,
    required DateTime monthStart,
  }) async {
    final monthEnd = monthStart.firstDayNextMonth;

    final q = _db
        .collection('users')
        .doc(passengerId)
        .collection('reservations')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(monthEnd));

    final snap = await q.get();

    final totals = List<double>.filled(7, 0.0);

    for (final doc in snap.docs) {
      final Map<String, dynamic> r = doc.data();

      final status = (r['status'] ?? '').toString().toLowerCase();
      if (status == 'cancelled' || status == 'annulee' || status == 'annulée') {
        continue;
      }

      final ts = r['createdAt'] as Timestamp?;
      if (ts == null) continue;

      final dt = ts.toDate();
      final i = dt.weekday - 1; // 0..6 (Lun..Dim)

      totals[i] += 1.0; // chaque réservation = 1
    }

    // moyenne = total / nb d'occurrences du weekday dans le mois
    for (int w = 1; w <= 7; w++) {
      final occ = _weekdayOccurrencesInMonth(monthStart, w);
      if (occ > 0) totals[w - 1] = totals[w - 1] / occ;
    }

    return totals;
  }

  /// Public: payload complet pour le graphe passager (même logique que driver)
  Future<PassengerGraphPayload> getPassengerGraphPayload(
    String passengerId,
  ) async {
    final now = DateTime.now();

    // On veut afficher: ancien -> récent (mois courant à droite)
    final recentFirst = _last4MonthsStarts(now); // [courant, -1, -2, -3]
    final oldestFirst = recentFirst.reversed
        .toList(); // [ -3, -2, -1, courant ]

    final monthsLabels = oldestFirst.map(_monthLabel).toList();

    final dataByMonth = <List<double>>[];
    for (final m in oldestFirst) {
      final averages = await _weekdayAveragesForMonth(
        passengerId: passengerId,
        monthStart: m,
      );
      dataByMonth.add(averages);
    }

    return PassengerGraphPayload(
      months: monthsLabels,
      dataByMonth: dataByMonth,
      selectedMonthIndexDefault:
          monthsLabels.length - 1, // dernier = mois courant
    );
  }
}
