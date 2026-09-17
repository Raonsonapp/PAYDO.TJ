import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Профили воқеӣ баъд аз пайваст кардани Firebase фаъол мешавад.
/// Дар build-и ҳозира экран комилан offline аст, то startup ба backend
/// вобаста набошад ва дар дастгоҳҳои Xiaomi низ UI дуруст намоён шавад.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.person_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Профили ман',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Пайвасти Firebase ва сабти профил дар марҳилаи backend фаъол мешавад.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _InfoRow(icon: Icons.phone_outlined, label: 'Телефон', value: '—'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.location_city_outlined, label: 'Шаҳр', value: '—'),
                  Divider(height: 24),
                  _InfoRow(icon: Icons.cake_outlined, label: 'Синну сол', value: '—'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
