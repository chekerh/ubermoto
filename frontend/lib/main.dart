import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/delivery/screens/delivery_list_screen.dart';
import 'core/utils/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user is already authenticated
  final isAuthenticated = await StorageService.getToken() != null;
  
  runApp(
    ProviderScope(
      child: MyApp(isAuthenticated: isAuthenticated),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({required this.isAuthenticated, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UberTaxi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isAuthenticated
          ? const DeliveryListScreen()
          : const LoginScreen(),
    );
  }
}
