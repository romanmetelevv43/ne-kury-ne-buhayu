import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../shared/habit_store.dart';
import '../shared/ui.dart';

class AwardsPage extends StatelessWidget {
  const AwardsPage({super.key,required this.store});
  final HabitStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation:store,builder:(_,__) {
    final streaks=[if(store.smokingEnabled) store.bestStreak(Habit.smoking),if(store.alcoholEnabled) store.bestStreak(Habit.alcohol)];
    final best=streaks.isEmpty?0:streaks.reduce((a,b)=>a>b?a:b);
    final awards=[
      ['🌱','Первый шаг','1 день',best>=1],
      ['🔥','Неделя свободы','7 дней подряд',best>=7],
      ['🛡️','Две недели','14 дней подряд',best>=14],
      ['🏆','Месяц силы','30 дней подряд',best>=30],
      ['💎','Легенда','100 дней подряд',best>=100],
      ['💰','Кошелёк ожил','10 000 ₽ расчётной экономии',store.totalSaved>=10000],
    ];
    return ListView(padding:const EdgeInsets.all(18),children:[
      const PageHeading('Достижения','Срыв не стирает то, чего ты уже добился.'),
      const SizedBox(height:16),
      for(final a in awards) Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(14),
        decoration:BoxDecoration(color:AppTheme.panel,borderRadius:BorderRadius.circular(15)),
        child:Row(children:[
          Text(a[0] as String,style:const TextStyle(fontSize:28)),const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(a[1] as String,style:const TextStyle(fontWeight:FontWeight.bold)),
            Text(a[2] as String,style:const TextStyle(color:AppTheme.muted,fontSize:11)),
          ])),
          Icon((a[3] as bool)?Icons.check_circle:Icons.lock_outline,color:(a[3] as bool)?AppTheme.green:AppTheme.muted),
        ]),
      ),
    ]);
  });
}
