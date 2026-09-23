import 'dart:async';

import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/root_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Агар ҳангоми оғоз хатое шавад, ба ҷойи экрани сиёҳ/хокистарӣ
  // хатои намоён нишон дода мешавад.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'PAYDO.TJ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ҳангоми оғоз кардани барнома хато рӯй дод.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runZonedGuarded(
    () {
      runApp(const PaydoApp());
    },
    (error, stackTrace) {
      debugPrint('PAYDO.TJ ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
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
      themeMode: ThemeMode.light,
      home: const RootShell(),
    );
  }
}
