import 'package:flutter_test/flutter_test.dart';
import 'package:ne_kuryu_ne_buhayu/features/shared/habit_store.dart';

void main() {
  test('sober period counts both boundary days', () {
    final p = SoberPeriod(Habit.smoking, DateTime(2026, 11, 1), DateTime(2026, 11, 7));
    expect(p.days, 7);
    expect(p.contains(DateTime(2026, 11, 7)), isTrue);
    expect(p.contains(DateTime(2026, 11, 8)), isFalse);
  });

  test('event survives JSON conversion', () {
    final e = HabitEvent(Habit.alcohol, DateTime(2026, 11, 9), note: 'test');
    final restored = HabitEvent.fromJson(e.toJson());
    expect(restored, isNotNull);
    expect(restored!.habit, Habit.alcohol);
    expect(restored.note, 'test');
  });

  test('unknown event type is ignored', () {
    expect(HabitEvent.fromJson({'habit':'other','date':'2026-11-09'}), isNull);
  });
}
