import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppStrings.navProfile)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        CircleAvatar(radius: 46, backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, size: 48, color: AppColors.primary)),
        SizedBox(height: 16),
        Center(child: Text('Профили PAYDO.TJ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 8),
        Center(child: Text('Пайвастшавии аккаунт ва Firebase баъдтар илова мешавад.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondaryLight))),
      ],
    ),
  );
}
