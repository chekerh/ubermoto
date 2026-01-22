import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../delivery/screens/delivery_list_screen.dart';
import '../../driver/screens/driver_dashboard_screen.dart';
import '../../../core/navigation/app_router.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // If not authenticated, navigate to login
    if (!authState.isAuthenticated || authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationHelper.navigateToLogin(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to role-based home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationHelper.navigateToRoleBasedHome(context, ref);
    });

    // Show loading while navigating
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Setting up your dashboard...'),
          ],
        ),
      ),
    );
  }
}