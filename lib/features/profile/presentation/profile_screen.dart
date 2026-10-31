import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../books/presentation/books_library_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.navProfile)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 46, backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, size: 48, color: AppColors.primary)),
        const SizedBox(height: 16),
        const Center(child: Text('Профили PAYDO.TJ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        const Center(child: Text('Пайвастшавии аккаунт ва Firebase баъдтар илова мешавад.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondaryLight))),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_library_outlined),
            title: const Text('Китобхона'),
            subtitle: const Text('Фарҳангшиносӣ ва Python'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BooksLibraryScreen()),
            ),
          ),
        ),
      ],
    ),
  );
}
