import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../shared/habit_store.dart';
import '../shared/ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.store});
  final HabitStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (_, __) => ListView(padding: const EdgeInsets.fromLTRB(18,18,18,24), children: [
      const Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('НЕ КУРЮ И НЕ БУХАЮ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 4), Text('ТВОЯ ЖИЗНЬ. ТВОИ ПРАВИЛА.', style: TextStyle(color: AppTheme.muted, fontSize: 10, letterSpacing: 1.2)),
        ])),
        Icon(Icons.bolt, color: AppTheme.green, size: 28),
      ]),
      const SizedBox(height: 22),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.panelAlt, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ТВОЯ ОБЩАЯ СЕРИЯ', style: TextStyle(color: AppTheme.muted, fontSize: 11, letterSpacing: 1.2)),
        const SizedBox(height: 7), Text('${store.combinedDays} дней', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
        const Text('Каждый день — решение в твою пользу.', style: TextStyle(color: AppTheme.green)),
      ])),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: InfoCard(title: '🚬 Курение', value: store.smokingEnabled ? '${store.currentDays(Habit.smoking)} дн.' : 'Пауза',
          caption: store.smokingEnabled ? '${store.cigarettesAvoided} сигарет не выкурено' : 'Учёт выключен', icon: Icons.smoke_free)),
        const SizedBox(width: 10),
        Expanded(child: InfoCard(title: '🍺 Алкоголь', value: store.alcoholEnabled ? '${store.currentDays(Habit.alcohol)} дн.' : 'Пауза',
          caption: store.alcoholEnabled ? 'Серия без алкоголя' : 'Учёт выключен', icon: Icons.no_drinks)),
      ]),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppTheme.panel, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ТВОЯ РАСЧЁТНАЯ ЭКОНОМИЯ', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
        const SizedBox(height: 5), Text('${money(store.totalSaved)} ₽', style: const TextStyle(color: AppTheme.green, fontSize: 30, fontWeight: FontWeight.w900)),
        const Text('Расчёт по заданным расходам, не фактически отложенные деньги.', style: TextStyle(color: AppTheme.muted, fontSize: 10)),
      ])),
      const SizedBox(height: 12),
      const Text('💀 Твои бывшие привычки опять без денег. Финансово наказаны.', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: () => showSupport(context), icon: const Icon(Icons.support_agent),
        label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('МЕНЯ НАКРЫВАЕТ', style: TextStyle(fontWeight: FontWeight.w900)))),
    ]),
  );
}
