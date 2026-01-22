import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_router.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;
  final bool requiresAuth;

  const AuthGuard({
    super.key,
    required this.child,
    this.requiresAuth = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Show loading while checking authentication
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If authentication is required but user is not authenticated
    if (requiresAuth && !authState.isAuthenticated) {
      // Navigate to login after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationHelper.navigateToLogin(context);
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If user is authenticated but trying to access auth screens, redirect to home
    if (!requiresAuth && authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationHelper.navigateToRoleBasedHome(context, ref);
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}

// Role-based guard for specific screens
class RoleGuard extends ConsumerWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authState.isAuthenticated || authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationHelper.navigateToLogin(context);
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userRole = authState.user!.role;

    if (!allowedRoles.contains(userRole)) {
      // Show access denied or redirect to appropriate screen
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You don\'t have permission to access this page.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  NavigationHelper.navigateToRoleBasedHome(context, ref);
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}