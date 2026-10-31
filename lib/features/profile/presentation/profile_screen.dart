import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../BOOK\'S/presentation/books_library_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.navProfile)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 46, backgroundColor: Color(0xFF102A56),
          child: Icon(Icons.auto_stories_rounded, size: 48, color: Color(0xFFFFD166))),
        const SizedBox(height: 16),
        const Center(child: Text("BOOK'S", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        const SizedBox(height: 8),
        const Center(child: Text('Маҷмӯи китобҳо', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondaryLight))),
        const SizedBox(height: 24),
        Card(child: ListTile(
          leading: const Icon(Icons.library_books_rounded),
          title: const Text("BOOK'S"),
          subtitle: const Text('Фарҳангшиносӣ, Python ва китобҳои дигар'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BooksLibraryScreen()),
          ),
        )),
      ],
    ),
  );
}
