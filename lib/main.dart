import 'dart:async';

import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Дар ин марҳила backend/Firebase ҳанӯз пайваст нест.
  // Барнома бояд ҳатман UI-и маҳаллиро нишон диҳад ва ба server
  // ё Firebase ҳангоми startup вобаста набошад.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: AppTheme.light.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'PAYDO TJ\n\nДар оғоз хатои UI ба вуҷуд омад.\nЛутфан барномаро аз нав кушоед.',
            textAlign: TextAlign.center,
            style: AppTheme.light.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () => runApp(const PaydoApp()),
    (error, stack) {
      // Барои release build барнома бо сабаби exception-и startup
      // дар экран танҳо splash/gray background намемонад.
      debugPrint('PAYDO TJ startup error: $error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class PaydoApp extends StatelessWidget {
  const PaydoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // PAYDO TJ дар ин марҳила аз Dark/Light-и системаи телефон
      // пайравӣ намекунад.
      themeMode: ThemeMode.light,
      home: const RootShell(),
    );
  }
}
