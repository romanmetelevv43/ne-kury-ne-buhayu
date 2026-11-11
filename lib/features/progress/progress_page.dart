import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../shared/habit_store.dart';
import '../shared/ui.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.store});
  final HabitStore store;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (_, __) => ListView(padding: const EdgeInsets.all(18), children: [
      const PageHeading('Твой прогресс', 'Каждый отмеченный день имеет значение.'),
      const SizedBox(height: 14),
      _summary('🚬 Курение', Habit.smoking),
      _summary('🍺 Алкоголь', Habit.alcohol),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: (!store.smokingEnabled && !store.alcoholEnabled) ? null : () => _lapseDialog(context),
        icon: const Icon(Icons.history), label: const Text('Зафиксировать срыв')),
      const SizedBox(height: 16),
      _Calendar(store: store, habit: Habit.smoking, title: '🚬 Календарь курения'),
      const SizedBox(height: 12),
      _Calendar(store: store, habit: Habit.alcohol, title: '🍺 Календарь алкоголя'),
      const SizedBox(height: 14),
      const Text('Последние события', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      if (store.events.isEmpty) const Text('Пока событий нет.', style: TextStyle(color: AppTheme.muted))
      else ...store.events.reversed.take(8).map((e) => ListTile(
        contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_note, color: AppTheme.muted),
        title: Text(e.habit == Habit.smoking ? 'Срыв: курение' : 'Срыв: алкоголь'),
        subtitle: Text(dateText(e.date)),
      )),
    ]),
  );

  Widget _summary(String title, Habit h) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppTheme.panel, borderRadius: BorderRadius.circular(15)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
      Text(store.enabled(h) ? '${store.currentDays(h)} дней сейчас' : 'Учёт выключен',
        style: const TextStyle(color: AppTheme.green, fontSize: 20, fontWeight: FontWeight.w800)),
      Text('Лучшая серия: ${store.bestStreak(h)} дней · Срывов: ${store.lapseCount(h)}',
        style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
    ]),
  );

  Future<void> _lapseDialog(BuildContext context) async {
    var selected = store.smokingEnabled ? Habit.smoking : Habit.alcohol;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Зафиксировать срыв'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (store.smokingEnabled) RadioListTile(value: Habit.smoking, groupValue: selected,
            onChanged: (v) => setState(() => selected = v!), title: const Text('🚬 Курение')),
          if (store.alcoholEnabled) RadioListTile(value: Habit.alcohol, groupValue: selected,
            onChanged: (v) => setState(() => selected = v!), title: const Text('🍺 Алкоголь')),
          const Text('Прошлая история сохранится. Новая серия начнётся только для выбранной категории.',
            style: TextStyle(color: AppTheme.muted, fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить')),
        ],
      ),
    ));
    if (ok == true) await store.recordLapse(selected);
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({required this.store, required this.habit, required this.title});
  final HabitStore store;
  final Habit habit;
  final String title;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now(), first = DateTime(now.year, now.month, 1);
    final offset = first.weekday - 1, count = DateTime(now.year, now.month + 1, 0).day;
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.panel, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5), Text('${monthName(now.month)} ${now.year}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
        const SizedBox(height: 10),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          for (final d in ['Пн','Вт','Ср','Чт','Пт','Сб','Вс']) SizedBox(width: 30, child: Center(child: Text(d, style: TextStyle(color: AppTheme.muted, fontSize: 10))))]),
        const SizedBox(height: 8),
        Wrap(spacing: 5, runSpacing: 5, children: [
          for (var i=0; i<offset; i++) const SizedBox(width: 34,height: 34),
          for (var d=1; d<=count; d++) _cell(DateTime(now.year,now.month,d)),
        ]),
        const SizedBox(height: 8),
        const Wrap(spacing: 12, children: [
          _Legend(const Color(0xFF286B3D), 'Без срыва'),
          _Legend(const Color(0xFF9B3C3C), 'Срыв'),
          _Legend(Color(0xFF29332B), 'Нет отметки'),
        ]),
      ]),
    );
  }
  Widget _cell(DateTime date) {
    final today = dayOnly(DateTime.now());
    final future = dayOnly(date).isAfter(today);
    final lapse = store.eventsOn(habit,date).isNotEmpty;
    final sober = !future && store.wasSoberOn(habit,date);
    final color = lapse ? const Color(0xFF9B3C3C) : sober ? const Color(0xFF286B3D) : const Color(0xFF29332B);
    return Container(width:34,height:34,alignment:Alignment.center,
      decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(9)),
      child:Text('${date.day}',style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600)));
  }
}
class _Legend extends StatelessWidget {
  const _Legend(this.color,this.label);
  final Color color; final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize:MainAxisSize.min,children:[
    Container(width:9,height:9,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(3))),
    const SizedBox(width:5),Text(label,style:const TextStyle(color:AppTheme.muted,fontSize:10)),
  ]);
}
