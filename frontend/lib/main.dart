import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'services/monitoring_service.dart';
import 'stitch/stitch_viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Continue without Firebase for demo purposes
  }

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize monitoring service
  try {
    await MonitoringService.initialize();
  } catch (e) {
    print('Monitoring service initialization failed: $e');
  }

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: const NassibApp(),
      ),
    ),
  );
}

class NassibApp extends StatelessWidget {
  const NassibApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode.toLowerCase() == 'ar';

    const stitchScreens = <String, Map<String, dynamic>>{
      '/splash1': {
        'asset': 'stitch/ubermoto_splash_and_language_select_1/code.html',
        'title': 'Nassib',
        'next': '/login1',
      },
      '/splash2': {
        'asset': 'stitch/ubermoto_splash_and_language_select_2/code.html',
        'title': 'Splash 2',
        'next': '/splash3',
      },
      '/splash3': {
        'asset': 'stitch/ubermoto_splash_and_language_select_3/code.html',
        'title': 'Splash 3',
        'next': '/splash4',
      },
      '/splash4': {
        'asset': 'stitch/ubermoto_splash_and_language_select_4/code.html',
        'title': 'Splash 4',
        'next': '/login1',
      },
      '/login1': {
        'asset': 'stitch/login_and_role_selection_1/code.html',
        'title': 'Login / Role',
      },
      '/login2': {
        'asset': 'stitch/login_and_role_selection_2/code.html',
        'title': 'Login 2',
      },
      '/register1': {
        'asset': 'stitch/user_registration_role_selection_1/code.html',
        'title': 'Register',
      },
      '/register2': {
        'asset': 'stitch/user_registration_role_selection_2/code.html',
        'title': 'Register 2',
      },
      '/customer/home': {
        'asset': 'stitch/customer_home_dashboard/code.html',
        'title': 'Customer Home',
      },
      '/customer/product': {
        'asset': 'stitch/product_details_harissa/code.html',
        'title': 'Product Details',
      },
      '/customer/cart': {
        'asset': 'stitch/cart_and_checkout/code.html',
        'title': 'Cart & Checkout',
      },
      '/customer/checkout-promos': {
        'asset': 'stitch/enhanced_checkout_promo_codes/code.html',
        'title': 'Promos',
      },
      '/customer/ai-order': {
        'asset': 'stitch/ai_smart_ordering_derja/code.html',
        'title': 'AI Ordering',
      },
      '/customer/ai-voice': {
        'asset': 'stitch/ai_voice_command_personalization/code.html',
        'title': 'AI Voice',
      },
      '/customer/filters': {
        'asset': 'stitch/advanced_filters_recommendations/code.html',
        'title': 'Filters & Recs',
      },
      '/customer/live-tracking': {
        'asset': 'stitch/live_order_tracking/code.html',
        'title': 'Live Tracking',
      },
      '/customer/order-confirm': {
        'asset': 'stitch/order_confirmation_cancel/code.html',
        'title': 'Order Confirmation',
      },
      '/customer/notifications': {
        'asset': 'stitch/notification_and_reorder_settings/code.html',
        'title': 'Notifications',
      },
      '/driver/dashboard': {
        'asset': 'stitch/driver_dashboard_online/code.html',
        'title': 'Driver Dashboard',
      },
      '/driver/docs': {
        'asset': 'stitch/driver_document_verification/code.html',
        'title': 'Driver Docs',
      },
      '/driver/rating': {
        'asset': 'stitch/driver_rating_quality_feedback/code.html',
        'title': 'Driver Ratings',
      },
      '/driver/training': {
        'asset': 'stitch/driver_training_hub/code.html',
        'title': 'Driver Training',
      },
      '/driver/sos': {
        'asset': 'stitch/driver_navigation_emergency_sos/code.html',
        'title': 'Driver SOS',
      },
      '/driver/motorcycle-select': {
        'asset': 'stitch/motorcycle_selection_slider/code.html',
        'title': 'Motorcycle Select',
      },
      '/driver/active-job': {
        'asset': 'stitch/active_delivery_job_view/code.html',
        'title': 'Active Delivery',
      },
      '/driver/earnings': {
        'asset': 'stitch/ubermoto_splash_and_language_select_2/code.html',
        'title': 'Driver Earnings',
      },
      '/driver/profile': {
        'asset': 'stitch/ubermoto_splash_and_language_select_3/code.html',
        'title': 'Driver Profile',
      },
      '/admin/catalog': {
        'asset': 'stitch/admin_catalog_management/code.html',
        'title': 'Admin Catalog',
      },
      '/admin/analytics': {
        'asset': 'stitch/admin_analytics_fraud_control/code.html',
        'title': 'Admin Analytics',
      },
      '/admin/console': {
        'asset': 'stitch/admin_management_console/code.html',
        'title': 'Admin Console',
      },
      '/biometric-otp': {
        'asset': 'stitch/biometric_otp_authentication/code.html',
        'title': 'Biometric / OTP',
      },
    };

    return MaterialApp(
      title: 'Nassib',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme(isArabic: isArabic),
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
      routes: {
        for (final entry in stitchScreens.entries)
          entry.key: (_) => StitchViewer(
                assetPath: entry.value['asset'] as String,
                title: entry.value['title'] as String? ?? entry.key,
                nextRoute: entry.value['next'] as String?,
                routeName: entry.key,
              ),
      },
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isInitialized) {
      return const StitchViewer(
        assetPath: 'stitch/ubermoto_splash_and_language_select_1/code.html',
        title: 'Nassib',
        routeName: '/splash1',
      );
    }

    final role = authState.user?.role.toUpperCase();
    if (authState.isAuthenticated) {
      if (role == 'CUSTOMER') {
        return const StitchViewer(
          assetPath: 'stitch/customer_home_dashboard/code.html',
          title: 'Customer Home',
          routeName: '/customer/home',
        );
      }

      if (role == 'DRIVER') {
        return const StitchViewer(
          assetPath: 'stitch/driver_dashboard_online/code.html',
          title: 'Driver Dashboard',
          routeName: '/driver/dashboard',
        );
      }

      if (role == 'ADMIN') {
        return const StitchViewer(
          assetPath: 'stitch/admin_management_console/code.html',
          title: 'Admin Console',
          routeName: '/admin/console',
        );
      }
    }

    return const StitchViewer(
      assetPath: 'stitch/ubermoto_splash_and_language_select_1/code.html',
      title: 'Nassib',
      nextRoute: '/login1',
      routeName: '/splash1',
    );
  }
}
