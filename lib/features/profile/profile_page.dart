import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../shared/habit_store.dart';
import '../shared/ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key,required this.store});
  final HabitStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation:store,builder:(_,__) => ListView(padding:const EdgeInsets.all(18),children:[
    const PageHeading('Настройки','Настрой приложение под себя.'),
    const SizedBox(height:14),
    const Text('ПРИВЫЧКИ',style:TextStyle(color:AppTheme.muted,fontSize:11,letterSpacing:1)),
    SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('🚬 Отслеживать курение'),value:store.smokingEnabled,activeColor:AppTheme.green,
      onChanged:(v)=>store.update(()=>store.smokingEnabled=v)),
    SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('🍺 Отслеживать алкоголь'),value:store.alcoholEnabled,activeColor:AppTheme.green,
      onChanged:(v)=>store.update(()=>store.alcoholEnabled=v)),
    const Divider(color:Color(0xFF39453C)),
    _dateRow(context,'Дата отказа от курения',store.smokingStart,(d)=>store.update(()=>store.smokingStart=d)),
    _dateRow(context,'Дата отказа от алкоголя',store.alcoholStart,(d)=>store.update(()=>store.alcoholStart=d)),
    const SizedBox(height:12),
    const Text('РАСХОДЫ',style:TextStyle(color:AppTheme.muted,fontSize:11,letterSpacing:1)),
    _numberRow(context,'Сигарет в день',store.cigarettesPerDay.toString(),(v)=>store.update(()=>store.cigarettesPerDay=v.round().clamp(1,100).toInt())),
    _numberRow(context,'Сигарет в пачке',store.cigarettesPerPack.toString(),(v)=>store.update(()=>store.cigarettesPerPack=v.round().clamp(1,100).toInt())),
    _numberRow(context,'Цена пачки, ₽',store.packPrice.toStringAsFixed(0),(v)=>store.update(()=>store.packPrice=v)),
    _numberRow(context,'Расходы на алкоголь в неделю, ₽',store.alcoholWeeklySpend.toStringAsFixed(0),(v)=>store.update(()=>store.alcoholWeeklySpend=v)),
    const SizedBox(height:12),
    const Text('НАКОПЛЕНИЯ',style:TextStyle(color:AppTheme.muted,fontSize:11,letterSpacing:1)),
    _numberRow(context,'Фактически отложено, ₽',store.actuallySetAside.toStringAsFixed(0),(v)=>store.update(()=>store.actuallySetAside=v)),
    _textRow(context,'Название цели',store.goalName,(v)=>store.update(()=>store.goalName=v)),
    _numberRow(context,'Сумма цели, ₽',store.goalAmount.toStringAsFixed(0),(v)=>store.update(()=>store.goalAmount=v<=0?1:v)),
    const SizedBox(height:14),
    const Text('Данные хранятся на устройстве. Приложение работает без регистрации и интернета. Облачная синхронизация будет отдельной опцией.',
      style:TextStyle(color:AppTheme.muted,fontSize:11)),
  ]));

  Widget _dateRow(BuildContext context,String title,DateTime current,Future<void> Function(DateTime) save) => ListTile(
    contentPadding:EdgeInsets.zero,title:Text(title,style:const TextStyle(fontSize:13)),
    subtitle:Text(dateText(current),style:const TextStyle(color:AppTheme.green)),
    trailing:const Icon(Icons.edit_calendar,color:AppTheme.muted),
    onTap:() async {
      final d=await showDatePicker(context:context,initialDate:current.isAfter(DateTime.now())?DateTime.now():current,firstDate:DateTime(2000),lastDate:DateTime.now());
      if(d!=null) await save(d);
    },
  );

  Widget _numberRow(BuildContext context,String title,String initial,Future<void> Function(double) save) => ListTile(
    contentPadding:EdgeInsets.zero,title:Text(title,style:const TextStyle(fontSize:13)),
    subtitle:Text(initial,style:const TextStyle(color:AppTheme.green)),trailing:const Icon(Icons.edit,color:AppTheme.muted),
    onTap:() async {
      final c=TextEditingController(text:initial);
      final v=await showDialog<double>(context:context,builder:(ctx)=>AlertDialog(
        title:Text(title),content:TextField(controller:c,keyboardType:const TextInputType.numberWithOptions(decimal:true),autofocus:true),
        actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Отмена')),
          FilledButton(onPressed:(){final n=double.tryParse(c.text.replaceAll(',','.'));if(n!=null&&n>=0)Navigator.pop(ctx,n);},child:const Text('Сохранить'))],
      ));
      if(v!=null) await save(v);
    },
  );

  Widget _textRow(BuildContext context,String title,String initial,Future<void> Function(String) save) => ListTile(
    contentPadding:EdgeInsets.zero,title:Text(title,style:const TextStyle(fontSize:13)),
    subtitle:Text(initial,style:const TextStyle(color:AppTheme.green)),trailing:const Icon(Icons.edit,color:AppTheme.muted),
    onTap:() async {
      final c=TextEditingController(text:initial);
      final v=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
        title:Text(title),content:TextField(controller:c,autofocus:true),
        actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Отмена')),
          FilledButton(onPressed:()=>Navigator.pop(ctx,c.text.trim()),child:const Text('Сохранить'))],
      ));
      if(v!=null&&v.isNotEmpty) await save(v);
    },
  );
}
