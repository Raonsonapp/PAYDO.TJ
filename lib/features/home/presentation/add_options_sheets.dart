import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../advertising/presentation/advertising_screen.dart';

class _AddOption {
  final String label;
  final IconData icon;
  final String phaseNote;

  const _AddOption(this.label, this.icon, this.phaseNote);
}

const _addOptions = [
  _AddOption('Маҳсулот', Icons.add_shopping_cart_outlined, 'PHASE 6'),
  _AddOption('Вакансия (Кор)', Icons.work_outline_rounded, 'PHASE 9'),
  _AddOption('Хизматрасонӣ', Icons.build_outlined, 'PHASE 10'),
  _AddOption('Эълон', Icons.campaign_outlined, 'PHASE 18'),
];

/// Bottom sheet-и тугмаи марказии "➕" дар bottom navigation.
/// Феҳристи имконот аз спецификация (banди 4: маҳсулот/кор/хизмат/эълон).
/// Ҳар гузина ба феҷаи дахлдор мебарад, ки ҳанӯз сохта нашудааст —
/// бинобар ин ҳозир танҳо огоҳинома нишон медиҳем.
Future<void> showAddOptionsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Чӣ илова кардан мехоҳед?',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ..._addOptions.map(
              (opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(opt.icon, color: AppColors.primary),
                ),
                title: Text(opt.label),
                trailing: Text(
                  opt.phaseNote,
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (opt.label == 'Эълон') {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvertisingScreen()));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${opt.label} дар ${opt.phaseNote} дастрас мешавад.')));
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
