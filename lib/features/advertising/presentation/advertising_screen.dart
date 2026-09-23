import 'package:flutter/material.dart';

class AdvertisingScreen extends StatelessWidget {
  const AdvertisingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пешбарии эълон'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Эълони худро пешбарӣ кунед',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Эълони пешбаришуда дар ҷойҳои намоёнтар нишон дода мешавад.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              _BoostCard(
                title: 'Пешбарӣ — 1 рӯз',
                subtitle: 'Эълони шумо 1 рӯз пешбарӣ мешавад.',
                icon: Icons.flash_on,
                onTap: () {
                  _showPendingMessage(context);
                },
              ),

              const SizedBox(height: 12),

              _BoostCard(
                title: 'Пешбарӣ — 7 рӯз',
                subtitle: 'Эълони шумо 7 рӯз пешбарӣ мешавад.',
                icon: Icons.rocket_launch,
                onTap: () {
                  _showPendingMessage(context);
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'PAYDO Premium',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 34,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'PAYDO Premium',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _PremiumFeature(
                      text: 'Имкониятҳои иловагӣ',
                    ),
                    _PremiumFeature(
                      text: 'Пешбарии эълонҳо',
                    ),
                    _PremiumFeature(
                      text: 'Афзалият дар намоиш',
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showPendingMessage(context);
                        },
                        child: const Text(
                          'Фаъол кардан',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Пардохт ва фаъолсозии воқеии Premium баъд аз пайваст кардани backend ва системаи пардохт илова карда мешавад.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showPendingMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ин имконият баъд аз пайваст кардани backend ва пардохт фаъол мешавад.',
        ),
      ),
    );
  }
}

class _BoostCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _BoostCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final String text;

  const _PremiumFeature({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
