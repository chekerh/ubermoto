import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../delivery/screens/delivery_list_screen.dart';
import '../../driver/screens/driver_dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // If not authenticated, show login
    if (!authState.isAuthenticated || authState.authResponse == null) {
      return const LoginScreen();
    }

    // TODO: Get user role from auth response or user data
    // For now, assume customer (will be updated when user model includes role)
    final userRole = 'CUSTOMER'; // This should come from JWT token or user data

    switch (userRole) {
      case 'DRIVER':
        return const DriverDashboardScreen();
      case 'CUSTOMER':
      default:
        return const DeliveryListScreen();
    }
  }
}