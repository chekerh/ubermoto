import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/utils/storage_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/customer_register_screen.dart';
import '../../features/auth/screens/driver_register_screen.dart';
import '../../features/auth/screens/driver_documents_screen.dart';
import '../../features/auth/screens/customer_home_screen.dart';
import '../../features/customer/screens/profile_screen.dart';
import '../../features/delivery/screens/delivery_create_screen.dart';
import '../../features/delivery/screens/delivery_list_screen.dart';
import '../../features/delivery/screens/delivery_tracking_screen.dart';
import '../../features/driver/screens/driver_dashboard_screen.dart';
import '../../features/driver/screens/driver_deliveries_screen.dart';
import '../../features/driver/screens/driver_profile_screen.dart';
import '../../features/driver/screens/driver_availability_screen.dart';
import '../../features/motorcycles/screens/motorcycle_register_screen.dart';
import '../../features/motorcycles/screens/motorcycle_list_screen.dart';

enum AppRoute {
  splash,
  login,
  roleSelection,
  customerRegister,
  driverRegister,
  driverDocuments,
  customerHome,
  deliveryCreate,
  deliveryList,
  deliveryTracking,
  driverDashboard,
  driverDeliveries,
  driverProfile,
  driverAvailability,
  motorcycleRegister,
  motorcycleList,
}

class AppRouter {
  static String getRouteName(AppRoute route) {
    switch (route) {
      case AppRoute.splash:
        return '/';
      case AppRoute.login:
        return '/login';
      case AppRoute.roleSelection:
        return '/role-selection';
      case AppRoute.customerRegister:
        return '/customer-register';
      case AppRoute.driverRegister:
        return '/driver-register';
      case AppRoute.driverDocuments:
        return '/driver-documents';
      case AppRoute.customerHome:
        return '/customer/home';
      case AppRoute.deliveryCreate:
        return '/customer/delivery/create';
      case AppRoute.deliveryList:
        return '/customer/deliveries';
      case AppRoute.deliveryTracking:
        return '/customer/delivery/tracking';
      case AppRoute.driverDashboard:
        return '/driver/dashboard';
      case AppRoute.driverDeliveries:
        return '/driver/deliveries';
      case AppRoute.driverProfile:
        return '/driver/profile';
      case AppRoute.driverAvailability:
        return '/driver/availability';
      case AppRoute.motorcycleRegister:
        return '/motorcycle/register';
      case AppRoute.motorcycleList:
        return '/motorcycle/list';
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/role-selection':
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case '/customer-register':
        return MaterialPageRoute(builder: (_) => const CustomerRegisterScreen());
      case '/driver-register':
        return MaterialPageRoute(builder: (_) => const DriverRegisterScreen());
      case '/driver-documents':
        return MaterialPageRoute(builder: (_) => const DriverDocumentsScreen());
      case '/customer/home':
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case '/customer/profile':
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());
      case '/customer/delivery/create':
        return MaterialPageRoute(builder: (_) => const DeliveryCreateScreen());
      case '/customer/deliveries':
        return MaterialPageRoute(builder: (_) => const DeliveryListScreen());
      case '/customer/delivery/tracking':
        final deliveryId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DeliveryTrackingScreen(deliveryId: deliveryId),
        );
      case '/debug':
        return MaterialPageRoute(builder: (_) => const DebugScreen());
      case '/driver/dashboard':
        return MaterialPageRoute(builder: (_) => const DriverDashboardScreen());
      case '/driver/deliveries':
        return MaterialPageRoute(builder: (_) => const DriverDeliveriesScreen());
      case '/driver/profile':
        return MaterialPageRoute(builder: (_) => const DriverProfileScreen());
      case '/driver/availability':
        return MaterialPageRoute(builder: (_) => const DriverAvailabilityScreen());
      case '/motorcycle/register':
        return MaterialPageRoute(builder: (_) => const MotorcycleRegisterScreen());
      case '/motorcycle/list':
        return MaterialPageRoute(builder: (_) => const MotorcycleListScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Navigation guards and helpers
class NavigationHelper {
  static Future<void> navigateToRoleBasedHome(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authStateProvider);

    if (!authState.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // If user is not loaded yet, try to load it but don't fail if it doesn't work
    if (authState.user == null) {
      try {
        await ref.read(authStateProvider.notifier).refreshUser();
        // Don't check if user was loaded - just continue with navigation
        // The user data will be loaded asynchronously
      } catch (e) {
        // If user loading fails, just continue - user data will be loaded later
        print('User refresh failed during navigation: $e');
      }
    }

    final userRole = authState.user?.role ?? 'CUSTOMER';

    switch (userRole) {
      case 'DRIVER':
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/driver/dashboard');
        }
        break;
      case 'CUSTOMER':
      default:
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/customer/home');
        }
        break;
    }
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static void navigateToDeliveryTracking(BuildContext context, String deliveryId) {
    Navigator.of(context).pushNamed('/customer/delivery/tracking', arguments: deliveryId);
  }
}

// Splash screen to handle initial routing
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Brief splash delay

    if (mounted) {
      // Check if we have a stored token but no authenticated user
      // This indicates a potential authentication issue
      final authState = ref.read(authStateProvider);
      final token = await StorageService.getToken();

      if (token != null && !authState.isAuthenticated) {
        // Clear potentially invalid token
        await StorageService.clearAll();
        await ref.read(authStateProvider.notifier).logout();
      }

      await NavigationHelper.navigateToRoleBasedHome(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delivery_dining,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'UberMoto',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Delivering with style',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  late Future<Map<String, String?>> _debugInfoFuture;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  void _loadDebugInfo() {
    _debugInfoFuture = ref.read(authStateProvider.notifier).debugAuthState();
    _refreshCounter++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Info'),
      ),
      body: FutureBuilder<Map<String, String?>>(
        key: ValueKey(_refreshCounter),
        future: _debugInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Authentication Debug Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value ?? 'null',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).clearInvalidAuth();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authentication data cleared')),
                      );
                      // Refresh the debug info
                      setState(() {
                        _loadDebugInfo();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear All Auth Data'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadDebugInfo();
                          });
                        },
                        child: const Text('Refresh Info'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        child: const Text('Restart App'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}