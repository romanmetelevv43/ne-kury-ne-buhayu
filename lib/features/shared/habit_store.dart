import 'package:flutter/foundation.dart';
import '../../core/data/habit_repository.dart';

enum Habit { smoking, alcohol }

String habitName(Habit h) => h == Habit.smoking ? 'smoking' : 'alcohol';
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class HabitEvent {
  const HabitEvent(this.habit, this.date, {this.note = ''});
  final Habit habit;
  final DateTime date;
  final String note;
  Map<String, dynamic> toJson() => {'habit': habitName(habit), 'date': dayOnly(date).toIso8601String(), 'note': note};
  static HabitEvent? fromJson(dynamic x) {
    if (x is! Map) return null;
    final d = DateTime.tryParse(x['date']?.toString() ?? '');
    final h = x['habit'] == 'smoking' ? Habit.smoking : x['habit'] == 'alcohol' ? Habit.alcohol : null;
    if (d == null || h == null) return null;
    return HabitEvent(h, dayOnly(d), note: x['note']?.toString() ?? '');
  }
}

class SoberPeriod {
  const SoberPeriod(this.habit, this.start, this.end);
  final Habit habit;
  final DateTime start, end;
  int get days => dayOnly(end).difference(dayOnly(start)).inDays + 1;
  bool contains(DateTime d) => !dayOnly(d).isBefore(dayOnly(start)) && !dayOnly(d).isAfter(dayOnly(end));
  Map<String, dynamic> toJson() => {'habit': habitName(habit), 'start': dayOnly(start).toIso8601String(), 'end': dayOnly(end).toIso8601String()};
  static SoberPeriod? fromJson(dynamic x) {
    if (x is! Map) return null;
    final a = DateTime.tryParse(x['start']?.toString() ?? '');
    final b = DateTime.tryParse(x['end']?.toString() ?? '');
    final h = x['habit'] == 'smoking' ? Habit.smoking : x['habit'] == 'alcohol' ? Habit.alcohol : null;
    if (a == null || b == null || h == null || dayOnly(b).isBefore(dayOnly(a))) return null;
    return SoberPeriod(h, dayOnly(a), dayOnly(b));
  }
}

class HabitStore extends ChangeNotifier {
  HabitStore({required this.repository});
  final HabitRepository repository;
  bool smokingEnabled = true, alcoholEnabled = true;
  DateTime smokingStart = dayOnly(DateTime.now()), alcoholStart = dayOnly(DateTime.now());
  int cigarettesPerDay = 10, cigarettesPerPack = 20;
  double packPrice = 200, alcoholWeeklySpend = 1500;
  double actuallySetAside = 0, goalAmount = 100000;
  String goalName = 'Моя большая цель', humor = 'Чёрный';
  final List<HabitEvent> events = [];
  final List<SoberPeriod> periods = [];

  Future<void> load() async {
    final x = await repository.read();
    if (x == null) return;
    try {
      smokingEnabled = x['smokingEnabled'] as bool? ?? true;
      alcoholEnabled = x['alcoholEnabled'] as bool? ?? true;
      smokingStart = DateTime.tryParse(x['smokingStart']?.toString() ?? '') ?? dayOnly(DateTime.now());
      alcoholStart = DateTime.tryParse(x['alcoholStart']?.toString() ?? '') ?? dayOnly(DateTime.now());
      cigarettesPerDay = (x['cigarettesPerDay'] as num?)?.toInt() ?? 10;
      cigarettesPerPack = (x['cigarettesPerPack'] as num?)?.toInt() ?? 20;
      packPrice = (x['packPrice'] as num?)?.toDouble() ?? 200;
      alcoholWeeklySpend = (x['alcoholWeeklySpend'] as num?)?.toDouble() ?? 1500;
      actuallySetAside = (x['actuallySetAside'] as num?)?.toDouble() ?? 0;
      goalAmount = (x['goalAmount'] as num?)?.toDouble() ?? 100000;
      goalName = x['goalName']?.toString() ?? 'Моя большая цель';
      humor = x['humor']?.toString() ?? 'Чёрный';
      events..clear()..addAll(((x['events'] as List?) ?? []).map(HabitEvent.fromJson).whereType<HabitEvent>());
      periods..clear()..addAll(((x['periods'] as List?) ?? []).map(SoberPeriod.fromJson).whereType<SoberPeriod>());
    } catch (_) {
      // Invalid local cache is ignored; the app starts with safe defaults.
    }
  }

  int daysSince(DateTime start) {
    final d = dayOnly(DateTime.now()).difference(dayOnly(start)).inDays;
    return d < 0 ? 0 : d;
  }
  DateTime startFor(Habit h) => h == Habit.smoking ? smokingStart : alcoholStart;
  bool enabled(Habit h) => h == Habit.smoking ? smokingEnabled : alcoholEnabled;
  int currentDays(Habit h) => daysSince(startFor(h));
  int totalDays(Habit h) => periods.where((p) => p.habit == h).fold(0, (n,p) => n+p.days) + currentDays(h);
  int bestStreak(Habit h) {
    var best = currentDays(h);
    for (final p in periods.where((p) => p.habit == h)) { if (p.days > best) best = p.days; }
    return best;
  }
  int get combinedDays {
    final a = <int>[if (smokingEnabled) currentDays(Habit.smoking), if (alcoholEnabled) currentDays(Habit.alcohol)];
    return a.isEmpty ? 0 : a.reduce((x,y) => x < y ? x : y);
  }
  int get cigarettesAvoided => smokingEnabled ? cigarettesPerDay * totalDays(Habit.smoking) : 0;
  double get smokingSaved => smokingEnabled ? cigarettesPerDay / cigarettesPerPack * packPrice * totalDays(Habit.smoking) : 0;
  double get alcoholSaved => alcoholEnabled ? alcoholWeeklySpend / 7 * totalDays(Habit.alcohol) : 0;
  double get totalSaved => smokingSaved + alcoholSaved;
  int lapseCount(Habit h) => events.where((e) => e.habit == h).length;
  List<HabitEvent> eventsOn(Habit h, DateTime d) => events.where((e) => e.habit == h && dayOnly(e.date) == dayOnly(d)).toList();
  bool wasSoberOn(Habit h, DateTime d) {
    if (eventsOn(h,d).isNotEmpty) return false;
    if (periods.any((p) => p.habit == h && p.contains(d))) return true;
    return !dayOnly(d).isBefore(dayOnly(startFor(h))) && !dayOnly(d).isAfter(dayOnly(DateTime.now()));
  }

  Future<void> update(void Function() change) async { change(); await _save(); notifyListeners(); }

  Future<void> recordLapse(Habit h) async {
    final today = dayOnly(DateTime.now());
    final start = dayOnly(startFor(h));
    final end = today.subtract(const Duration(days: 1));
    if (!start.isAfter(end)) periods.add(SoberPeriod(h, start, end));
    events.add(HabitEvent(h, today));
    if (h == Habit.smoking) { smokingStart = today; } else { alcoholStart = today; }
    await _save(); notifyListeners();
  }

  Future<void> _save() async {
    await repository.write({
      'schemaVersion': 1, 'smokingEnabled': smokingEnabled, 'alcoholEnabled': alcoholEnabled,
      'smokingStart': smokingStart.toIso8601String(), 'alcoholStart': alcoholStart.toIso8601String(),
      'cigarettesPerDay': cigarettesPerDay, 'cigarettesPerPack': cigarettesPerPack,
      'packPrice': packPrice, 'alcoholWeeklySpend': alcoholWeeklySpend,
      'actuallySetAside': actuallySetAside, 'goalAmount': goalAmount,
      'goalName': goalName, 'humor': humor,
      'events': events.map((e) => e.toJson()).toList(), 'periods': periods.map((p) => p.toJson()).toList(),
    });
  }
}
