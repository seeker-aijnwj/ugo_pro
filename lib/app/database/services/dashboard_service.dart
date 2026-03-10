// dashboard_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===================== MODELS =====================

class DashboardSummaryModel {
  final int annonces; // nb d'annonces complétées
  final int passagers; // somme des reservedSeats
  final double note; // note arrondie (x / x.5), plafonnée 4.5
  final int ratingCount; // nb de notes reçues

  DashboardSummaryModel({
    required this.annonces,
    required this.passagers,
    required this.note,
    required this.ratingCount,
  });

  Map<String, dynamic> toMap() => {
    'annonces': annonces,
    'passagers': passagers,
    'note': note,
    'ratingCount': ratingCount,
  };

  factory DashboardSummaryModel.fromMap(Map<String, dynamic> map) =>
      DashboardSummaryModel(
        annonces: (map['annonces'] as num).toInt(),
        passagers: (map['passagers'] as num).toInt(),
        note: (map['note'] as num).toDouble(),
        ratingCount: (map['ratingCount'] as num).toInt(),
      );
}

class DashboardGraphPayload {
  /// Ex: ["Mai", "Juin", "Juil.", "Août"] — 4 derniers mois (ancien -> récent)
  final List<String> months;

  /// dataByMonth[i] = 7 valeurs (Lun..Dim) pour months[i]
  final List<List<double>> dataByMonth;

  /// Index par défaut: dernier = mois courant
  final int selectedMonthIndexDefault;

  DashboardGraphPayload({
    required this.months,
    required this.dataByMonth,
    required this.selectedMonthIndexDefault,
  });

  Map<String, dynamic> toMap() => {
    'months': months,
    'dataByMonth': dataByMonth,
    'selectedMonthIndexDefault': selectedMonthIndexDefault,
  };

  factory DashboardGraphPayload.fromMap(Map<String, dynamic> map) =>
      DashboardGraphPayload(
        months: (map['months'] as List).cast<String>(),
        dataByMonth: (map['dataByMonth'] as List)
            .map<List<double>>(
              (row) => (row as List).map((e) => (e as num).toDouble()).toList(),
            )
            .toList(),
        selectedMonthIndexDefault: (map['selectedMonthIndexDefault'] as num)
            .toInt(),
      );
}

/// ===================== HELPERS =====================

extension _DateHelpers on DateTime {
  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  DateTime get firstDayNextMonth =>
      (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
}

double _roundToHalf(double x) => (x * 2).round() / 2.0;
double _capAt4_5(double x) => x > 4.5 ? 4.5 : x;

/// ===================== CACHE =====================

class _DashCache {
  final SharedPreferences _prefs;
  _DashCache(this._prefs);

  static const _kSummaryKeyPrefix = 'dash_summary_';
  static const _kGraphKeyPrefix = 'dash_graph_';

  static Future<_DashCache> get instance async =>
      _DashCache(await SharedPreferences.getInstance());

  String _summaryKey(String driverId) => '$_kSummaryKeyPrefix$driverId';
  String _graphKey(String driverId) => '$_kGraphKeyPrefix$driverId';

  Future<void> saveSummary(String driverId, DashboardSummaryModel model) async {
    await _prefs.setString(_summaryKey(driverId), jsonEncode(model.toMap()));
    await _prefs.setString(
      '${_summaryKey(driverId)}_ts',
      DateTime.now().toIso8601String(),
    );
  }

  DashboardSummaryModel? getSummary(String driverId) {
    final s = _prefs.getString(_summaryKey(driverId));
    if (s == null) return null;
    return DashboardSummaryModel.fromMap(jsonDecode(s));
  }

  DateTime? getSummaryTs(String driverId) {
    final s = _prefs.getString('${_summaryKey(driverId)}_ts');
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> saveGraph(String driverId, DashboardGraphPayload payload) async {
    await _prefs.setString(_graphKey(driverId), jsonEncode(payload.toMap()));
    await _prefs.setString(
      '${_graphKey(driverId)}_ts',
      DateTime.now().toIso8601String(),
    );
  }

  DashboardGraphPayload? getGraph(String driverId) {
    final s = _prefs.getString(_graphKey(driverId));
    if (s == null) return null;
    return DashboardGraphPayload.fromMap(jsonDecode(s));
  }

  DateTime? getGraphTs(String driverId) {
    final s = _prefs.getString('${_graphKey(driverId)}_ts');
    return s == null ? null : DateTime.tryParse(s);
  }
}

/// ===================== SERVICE =====================

class DashboardService {
  final FirebaseFirestore _db;
  DashboardService(this._db);

  /// CONSEIL (optionnel) : activer le cache Firestore si ce n’est pas déjà fait
  /// à l’initialisation de l’app :
  /// FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // ---------- API "cache d'abord" (renvoie un Stream) ----------

  /// Sert le cache immédiatement, puis rafraîchit en fond et émet la nouvelle valeur.
  Stream<DashboardSummaryModel> watchSummary(String driverId) async* {
    final cache = await _DashCache.instance;
    final cached = cache.getSummary(driverId);
    if (cached != null) {
      yield cached; // affichage instantané
    }

    // rafraîchissement silencieux
    final fresh = await _computeSummary(driverId);
    await cache.saveSummary(driverId, fresh);
    yield fresh;
  }

  /// Sert le cache immédiatement, puis rafraîchit en fond et émet la nouvelle valeur.
  Stream<DashboardGraphPayload> watchGraphPayload(String driverId) async* {
    final cache = await _DashCache.instance;
    final cached = cache.getGraph(driverId);
    if (cached != null) {
      yield cached; // affichage instantané
    }

    // rafraîchissement silencieux
    final fresh = await _computeGraphPayload(driverId);
    await cache.saveGraph(driverId, fresh);
    yield fresh;
  }

  // ---------- Implémentations existantes (inchangées, mais internes) ----------

  Future<DashboardSummaryModel> _computeSummary(String driverId) async {
    // 1) Annonces complétées
    final annoncesSnap = await _db
        .collection('users')
        .doc(driverId)
        .collection('announces_effectuees')
        .where('status', isEqualTo: 'completed')
        .get();

    final annoncesCount = annoncesSnap.docs.length;

    // 2) Somme des reservedSeats UNIQUEMENT
    int totalPassengers = 0;
    for (final d in annoncesSnap.docs) {
      final Map<String, dynamic> data = d.data();
      final reservedSeats = (data['reservedSeats'] as num?)?.toInt() ?? 0;
      totalPassengers += reservedSeats;
    }

    // 3) Note globale (prio: users/{driverId}.rating / ratingCount ; fallback: users/{driverId}/ratings)
    final (note, ratingCount) = await _getDriverRating(driverId);

    return DashboardSummaryModel(
      annonces: annoncesCount,
      passagers: totalPassengers,
      note: note,
      ratingCount: ratingCount,
    );
  }

  Future<(double note, int count)> _getDriverRating(String driverId) async {
    // A) lecture directe sur users/{driverId}
    final userSnap = await _db.collection('users').doc(driverId).get();
    if (userSnap.exists) {
      final Map<String, dynamic> data = userSnap.data() as Map<String, dynamic>;
      final raw = (data['rating'] as num?)?.toDouble();
      final count = (data['ratingCount'] as num?)?.toInt() ?? 0;
      if (raw != null) {
        var rounded = _roundToHalf(raw);
        rounded = _capAt4_5(rounded);
        return (rounded, count);
      }
    }

    // B) fallback : recalcule depuis users/{driverId}/ratings (si présent)
    final ratingsCol = _db
        .collection('users')
        .doc(driverId)
        .collection('ratings');
    final rSnap = await ratingsCol.get();
    final values = rSnap.docs
        .map((d) {
          final Map<String, dynamic> data = d.data();
          return (data['value'] as num?)?.toDouble();
        })
        .whereType<double>()
        .toList();

    // Règles U‑GO : inclure 3.0 par défaut dans la moyenne
    final all = [3.0, ...values];
    final avg = all.reduce((a, b) => a + b) / all.length;

    var rounded = _roundToHalf(avg);
    rounded = _capAt4_5(rounded);

    return (rounded, values.length);
  }

  /// ---------- Graphe (moyennes/jour sur 4 derniers mois) ----------
  List<DateTime> _last4MonthsStarts(DateTime now) {
    final m0 = now.firstDayOfMonth;
    return [
      m0,
      DateTime(m0.year, m0.month - 1, 1),
      DateTime(m0.year, m0.month - 2, 1),
      DateTime(m0.year, m0.month - 3, 1),
    ];
  }

  String _monthLabel(DateTime monthStart) {
    final f = DateFormat.MMMM('fr_FR');
    final label = f.format(monthStart);
    return label[0].toUpperCase() + label.substring(1);
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

  Future<List<double>> _weekdayAveragesForMonth({
    required String driverId,
    required DateTime monthStart,
  }) async {
    final monthEnd = monthStart.firstDayNextMonth;

    // 1) Essai avec departureAt
    Query q = _db
        .collection('users')
        .doc(driverId)
        .collection('announces_effectuees')
        .where('status', isEqualTo: 'completed')
        .where(
          'departureAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
        )
        .where('departureAt', isLessThan: Timestamp.fromDate(monthEnd));

    var snap = await q.get();

    // 2) Fallback si pas de departureAt -> createdAt
    if (snap.docs.isEmpty) {
      q = _db
          .collection('users')
          .doc(driverId)
          .collection('announces_effectuees')
          .where('status', isEqualTo: 'completed')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(monthEnd));
      snap = await q.get();
    }

    // Totaux par weekday (index 0..6 -> Lun..Dim)
    final totals = List<double>.filled(7, 0.0);

    for (final d in snap.docs) {
      final Map<String, dynamic> data = d.data() as Map<String, dynamic>;
      final ts = (data['departureAt'] ?? data['createdAt']) as Timestamp?;
      if (ts == null) continue;

      final dt = ts.toDate();
      final i = dt.weekday - 1; // 1..7 -> 0..6

      // Activité = reservedSeats UNIQUEMENT
      final reservedSeats = (data['reservedSeats'] as num?)?.toDouble() ?? 0.0;
      totals[i] += reservedSeats;
    }

    // Moyenne = total / nb d’occurrences du weekday dans le mois
    for (int w = 1; w <= 7; w++) {
      final occ = _weekdayOccurrencesInMonth(monthStart, w);
      if (occ > 0) totals[w - 1] = totals[w - 1] / occ;
    }

    return totals;
  }

  Future<DashboardGraphPayload> _computeGraphPayload(String driverId) async {
    final now = DateTime.now();

    // Récents d'abord
    final monthsRecentFirst = _last4MonthsStarts(now);
    // On veut ancien -> récent (mois actuel à DROITE)
    final monthsOldestFirst = monthsRecentFirst.reversed.toList();

    final monthLabels = monthsOldestFirst.map(_monthLabel).toList();

    final dataByMonth = <List<double>>[];
    for (final m in monthsOldestFirst) {
      final averages = await _weekdayAveragesForMonth(
        driverId: driverId,
        monthStart: m,
      );
      dataByMonth.add(averages);
    }

    return DashboardGraphPayload(
      months: monthLabels, // ["Mai","Juin","Juil.","Août"]
      dataByMonth: dataByMonth, // même ordre
      selectedMonthIndexDefault:
          monthLabels.length - 1, // dernier = mois courant
    );
  }
}
