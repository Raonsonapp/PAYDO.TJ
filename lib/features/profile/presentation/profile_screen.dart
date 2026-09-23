import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профил'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Profile avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  size: 54,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Корбар',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Ба аккаунт ворид нашудаед',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              _ProfileItem(
                icon: Icons.person_outline,
                title: 'Маълумоти шахсӣ',
                onTap: () {
                  _showOfflineMessage(context);
                },
              ),

              _ProfileItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Фармоишҳои ман',
                onTap: () {
                  _showOfflineMessage(context);
                },
              ),

              _ProfileItem(
                icon: Icons.favorite_border,
                title: 'Маҳсулотҳои дӯстдошта',
                onTap: () {
                  _showOfflineMessage(context);
                },
              ),

              _ProfileItem(
                icon: Icons.settings_outlined,
                title: 'Танзимот',
                onTap: () {
                  _showOfflineMessage(context);
                },
              ),

              _ProfileItem(
                icon: Icons.help_outline,
                title: 'Кӯмак',
                onTap: () {
                  _showOfflineMessage(context);
                },
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 36,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ҳолати offline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Firebase ва backend баъдтар пайваст карда мешаванд.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
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

  static void _showOfflineMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ин имконият баъд аз пайваст кардани backend фаъол мешавад.',
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
      ),
    );
  }
}
