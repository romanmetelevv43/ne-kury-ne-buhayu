import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/local_habit_repository.dart';
import 'features/shared/habit_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = HabitStore(repository: LocalHabitRepository());
  await store.load();
  runApp(NoSmokeNoBoozeApp(store: store));
}
