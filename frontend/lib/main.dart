import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear any stored authentication data on app start to avoid stale tokens
  // This fixes the "User not found" errors when database has been reset
  try {
    await StorageService.clearAll();
  } catch (e) {
    // Ignore errors during cleanup
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UberMoto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Support system theme switching
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
