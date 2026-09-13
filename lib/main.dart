import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: PaydoApp(),
    ),
  );
}

class PaydoApp extends ConsumerWidget {
  const PaydoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // PAYDO TJ ҳоло theme-и худро истифода мебарад.
      // Аз Dark/Light Mode-и телефон пайравӣ намекунад.
      theme: AppTheme.light,
      themeMode: ThemeMode.light,

      home: const RootShell(),
    );
  }
}
