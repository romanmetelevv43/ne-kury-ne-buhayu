import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.subtitle, {super.key});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
  ]);
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.value, required this.caption, this.icon});
  final String title, value, caption;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.panel, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [if (icon != null) Icon(icon, color: AppTheme.green, size: 18), if (icon != null) const SizedBox(width: 7),
        Expanded(child: Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 11)))]),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(caption, style: const TextStyle(color: AppTheme.muted, fontSize: 10)),
    ]),
  );
}

String money(double value) => value.round().toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
String dateText(DateTime d) => '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
String monthName(int m) => const ['Январь','Февраль','Март','Апрель','Май','Июнь','Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'][m-1];

void showSupport(BuildContext context) => showModalBottomSheet<void>(
  context: context, isScrollControlled: true, backgroundColor: AppTheme.panel,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (_) => const _SupportSheet(),
);

class _SupportSheet extends StatefulWidget {
  const _SupportSheet();
  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}
class _SupportSheetState extends State<_SupportSheet> {
  bool waited = false;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22,24,22,30),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('НЕ СЕЙЧАС. 💀', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(waited ? 'Ты переждал волну. Это уже маленькая победа.' : 'Тяга — это не приказ. Не обязательно подчиняться ей прямо сейчас.',
        style: const TextStyle(color: AppTheme.green, fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text(waited ? 'Смени обстановку, пройдись или позвони близкому.' : 'Отложи решение на пять минут. Выпей воды, смени обстановку, сделай несколько спокойных вдохов.',
        style: const TextStyle(color: AppTheme.muted, height: 1.4)),
      const SizedBox(height: 16),
      if (!waited) FilledButton(onPressed: () => setState(() => waited = true), child: const Text('Я переждал эту волну')),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
      const Text('При зависимости резкая отмена алкоголя может быть опасна. При судорогах, спутанности сознания или галлюцинациях нужна срочная медицинская помощь.',
        style: TextStyle(color: AppTheme.muted, fontSize: 10)),
    ]),
  );
}
