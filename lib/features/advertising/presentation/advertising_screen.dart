import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class AdvertisingScreen extends StatelessWidget {
  const AdvertisingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.advertisingTitle)),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(AppStrings.advertisingSubtitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      _Plan(title: 'Пешбарӣ — 1 рӯз', subtitle: 'Эълон дар ҷойи намоён', icon: Icons.rocket_launch_outlined),
      const SizedBox(height: 12),
      _Plan(title: 'Пешбарӣ — 7 рӯз', subtitle: 'Намоиши бештар барои эълон', icon: Icons.bolt_outlined),
      const SizedBox(height: 24),
      Card(child: ListTile(leading: const Icon(Icons.workspace_premium_outlined, color: AppColors.primary), title: const Text(AppStrings.advertisingPremium), subtitle: const Text('Имкониятҳои иловагӣ барои фурӯшандаҳо'))),
      const SizedBox(height: 16),
      const Text(AppStrings.advertisingBackendPending, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondaryLight)),
    ]),
  );
}

class _Plan extends StatelessWidget {
  final String title, subtitle; final IconData icon;
  const _Plan({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title), subtitle: Text(subtitle), trailing: ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.advertisingBackendPending))), child: const Text('Интихоб'))));
}
