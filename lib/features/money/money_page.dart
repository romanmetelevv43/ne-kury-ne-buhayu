import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../shared/habit_store.dart';
import '../shared/ui.dart';

class MoneyPage extends StatelessWidget {
  const MoneyPage({super.key, required this.store});
  final HabitStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: store, builder: (_, __) {
    final progress = (store.actuallySetAside / (store.goalAmount <= 0 ? 1 : store.goalAmount)).clamp(0.0,1.0).toDouble();
    return ListView(padding: const EdgeInsets.all(18), children: [
      const PageHeading('Твои деньги', 'Расчётная экономия отдельно от реальных накоплений.'),
      const SizedBox(height: 16),
      InfoCard(title:'РАСЧЁТНАЯ ЭКОНОМИЯ', value:'${money(store.totalSaved)} ₽', caption:'По заданным расходам и сохранённым периодам.'),
      const SizedBox(height:10),
      InfoCard(title:'ФАКТИЧЕСКИ ОТЛОЖЕНО', value:'${money(store.actuallySetAside)} ₽', caption:'Эту сумму укажи самостоятельно в настройках.'),
      const SizedBox(height:10),
      Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppTheme.panel,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('🎯 ${store.goalName}',style:const TextStyle(fontWeight:FontWeight.bold)),
        const SizedBox(height:6),Text('${money(store.actuallySetAside)} / ${money(store.goalAmount)} ₽',style:const TextStyle(color:AppTheme.green)),
        const SizedBox(height:8),LinearProgressIndicator(value:progress,minHeight:7),
        const SizedBox(height:4),Text('${(progress*100).toStringAsFixed(1)}% цели',style:const TextStyle(color:AppTheme.muted,fontSize:10)),
      ])),
      const SizedBox(height:10),
      InfoCard(title:'🚬 КУРЕНИЕ',value:'${money(store.smokingSaved)} ₽',caption:'${store.totalDays(Habit.smoking)} суммарных дней без курения.'),
      const SizedBox(height:10),
      InfoCard(title:'🍺 АЛКОГОЛЬ',value:'${money(store.alcoholSaved)} ₽',caption:'${store.totalDays(Habit.alcohol)} суммарных дней без алкоголя.'),
    ]);
  });
}
