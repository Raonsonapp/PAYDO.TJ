import 'package:flutter/material.dart';

import '../../advertising/presentation/advertising_screen.dart';

class AddOptionsSheet extends StatelessWidget {
  const AddOptionsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Илова кардан',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _AddOption(
              icon: Icons.shopping_bag_outlined,
              title: 'Маҳсулот',
              subtitle: 'Маҳсулоти худро фурӯшед',
              onTap: () {
                _showMessage(context, 'Маҳсулот');
              },
            ),

            _AddOption(
              icon: Icons.work_outline,
              title: 'Вакансия (Кор)',
              subtitle: 'Ҷойи кори худро эълон кунед',
              onTap: () {
                _showMessage(context, 'Вакансия');
              },
            ),

            _AddOption(
              icon: Icons.handyman_outlined,
              title: 'Хизматрасонӣ',
              subtitle: 'Хизматрасонии худро пешниҳод кунед',
              onTap: () {
                _showMessage(context, 'Хизматрасонӣ');
              },
            ),

            _AddOption(
              icon: Icons.campaign_outlined,
              title: 'Эълон',
              subtitle: 'Эълон ҷойгир кунед',
              onTap: () {
                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdvertisingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showMessage(
    BuildContext context,
    String title,
  ) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title — ин имконият баъдтар фаъол мешавад.',
        ),
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CircleAvatar(
          radius: 24,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}
