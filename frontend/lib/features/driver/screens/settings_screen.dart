import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../services/user_service.dart';
import '../../../services/drivers_service.dart';
import '../../../models/preferences_model.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../customer/screens/change_password_screen.dart';

final driverPreferencesProvider = FutureProvider<PreferencesModel>((ref) async {
  final userService = UserService();
  return userService.getPreferences();
});

final driverAvailabilityProvider = StateProvider<bool>((ref) => true);

class DriverSettingsScreen extends ConsumerStatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  ConsumerState<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends ConsumerState<DriverSettingsScreen> {
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Ignore error
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(driverPreferencesProvider);
    final isAvailable = ref.watch(driverAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: preferencesAsync.when(
        data: (preferences) => _SettingsContent(
          preferences: preferences,
          appVersion: _appVersion,
          isAvailable: isAvailable,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading settings: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(driverPreferencesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends ConsumerStatefulWidget {
  final PreferencesModel preferences;
  final String? appVersion;
  final bool isAvailable;

  const _SettingsContent({
    required this.preferences,
    this.appVersion,
    required this.isAvailable,
  });

  @override
  ConsumerState<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<_SettingsContent> {
  late PreferencesModel _currentPreferences;
  late bool _currentAvailability;

  @override
  void initState() {
    super.initState();
    _currentPreferences = widget.preferences;
    _currentAvailability = widget.isAvailable;
  }

  Future<void> _updatePreferences() async {
    try {
      final userService = UserService();
      await userService.updatePreferences(_currentPreferences);
      ref.invalidate(driverPreferencesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update preferences: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAvailability(bool value) async {
    try {
      final driversService = DriversService();
      await driversService.updateAvailability(value);
      ref.read(driverAvailabilityProvider.notifier).state = value;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Now available for deliveries' : 'Unavailable for deliveries'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update availability: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver-Specific Settings
          _SectionHeader(title: 'Driver Settings'),
          _SettingsCard(
            children: [
              _SwitchItem(
                icon: Icons.schedule,
                title: 'Availability',
                subtitle: _currentAvailability
                    ? 'Available for deliveries'
                    : 'Unavailable for deliveries',
                value: _currentAvailability,
                onChanged: (value) {
                  setState(() {
                    _currentAvailability = value;
                  });
                  _updateAvailability(value);
                },
              ),
              _SwitchItem(
                icon: Icons.auto_awesome,
                title: 'Auto-Accept Deliveries',
                subtitle: 'Automatically accept nearby deliveries',
                value: false, // TODO: Get from backend
                onChanged: (value) {
                  // TODO: Update auto-accept setting
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Section
          _SectionHeader(title: 'Account'),
          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
              _SettingsItem(
                icon: Icons.email,
                title: 'Email Preferences',
                subtitle: 'Manage email notifications',
                onTap: () {
                  // TODO: Navigate to email preferences
                },
              ),
              _SettingsItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                textColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          _SettingsCard(
            children: [
              _SwitchItem(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                value: _currentPreferences.notifications.push,
                onChanged: (value) {
                  setState(() {
                    _currentPreferences = PreferencesModel(
                      notifications: NotificationPreferences(
                        email: _currentPreferences.notifications.email,
                        push: value,
                        sms: _currentPreferences.notifications.sms,
                        deliveryUpdates: _currentPreferences.notifications.deliveryUpdates,
                        promotions: _currentPreferences.notifications.promotions,
                      ),
                      language: _currentPreferences.language,
                      theme: _currentPreferences.theme,
                      currency: _currentPreferences.currency,
                    );
                  });
                  _updatePreferences();
                },
              ),
              _SwitchItem(
                icon: Icons.email,
                title: 'Email Notifications',
                value: _currentPreferences.notifications.email,
                onChanged: (value) {
                  setState(() {
                    _currentPreferences = PreferencesModel(
                      notifications: NotificationPreferences(
                        email: value,
                        push: _currentPreferences.notifications.push,
                        sms: _currentPreferences.notifications.sms,
                        deliveryUpdates: _currentPreferences.notifications.deliveryUpdates,
                        promotions: _currentPreferences.notifications.promotions,
                      ),
                      language: _currentPreferences.language,
                      theme: _currentPreferences.theme,
                      currency: _currentPreferences.currency,
                    );
                  });
                  _updatePreferences();
                },
              ),
              _SwitchItem(
                icon: Icons.delivery_dining,
                title: 'Delivery Updates',
                value: _currentPreferences.notifications.deliveryUpdates,
                onChanged: (value) {
                  setState(() {
                    _currentPreferences = PreferencesModel(
                      notifications: NotificationPreferences(
                        email: _currentPreferences.notifications.email,
                        push: _currentPreferences.notifications.push,
                        sms: _currentPreferences.notifications.sms,
                        deliveryUpdates: value,
                        promotions: _currentPreferences.notifications.promotions,
                      ),
                      language: _currentPreferences.language,
                      theme: _currentPreferences.theme,
                      currency: _currentPreferences.currency,
                    );
                  });
                  _updatePreferences();
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _SectionHeader(title: 'Preferences'),
          _SettingsCard(
            children: [
              _DropdownItem<String>(
                icon: Icons.language,
                title: 'Language',
                value: _currentPreferences.language,
                items: const ['en', 'fr', 'ar'],
                itemLabels: const ['English', 'Français', 'العربية'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentPreferences = PreferencesModel(
                        notifications: _currentPreferences.notifications,
                        language: value,
                        theme: _currentPreferences.theme,
                        currency: _currentPreferences.currency,
                      );
                    });
                    _updatePreferences();
                  }
                },
              ),
              _DropdownItem<String>(
                icon: Icons.palette,
                title: 'Theme',
                value: _currentPreferences.theme,
                items: const ['light', 'dark', 'system'],
                itemLabels: const ['Light', 'Dark', 'System'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentPreferences = PreferencesModel(
                        notifications: _currentPreferences.notifications,
                        language: _currentPreferences.language,
                        theme: value,
                        currency: _currentPreferences.currency,
                      );
                    });
                    _updatePreferences();
                  }
                },
              ),
              _DropdownItem<String>(
                icon: Icons.attach_money,
                title: 'Currency',
                value: _currentPreferences.currency,
                items: const ['TND', 'USD', 'EUR'],
                itemLabels: const ['TND (Tunisian Dinar)', 'USD (US Dollar)', 'EUR (Euro)'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currentPreferences = PreferencesModel(
                        notifications: _currentPreferences.notifications,
                        language: _currentPreferences.language,
                        theme: _currentPreferences.theme,
                        currency: value,
                      );
                    });
                    _updatePreferences();
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About'),
          _SettingsCard(
            children: [
              if (widget.appVersion != null)
                _SettingsItem(
                  icon: Icons.info,
                  title: 'App Version',
                  subtitle: widget.appVersion,
                  onTap: () {},
                ),
              _SettingsItem(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
              _SettingsItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              _SettingsItem(
                icon: Icons.support,
                title: 'Contact Support',
                onTap: () {
                  // TODO: Navigate to support
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final userService = UserService();
      await userService.deleteAccount();

      if (mounted) {
        await ref.read(authStateProvider.notifier).logout();
        NavigationHelper.navigateToLogin(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _DropdownItem<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final T value;
  final List<T> items;
  final List<String> itemLabels;
  final ValueChanged<T?> onChanged;

  const _DropdownItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.itemLabels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: List.generate(
          items.length,
          (index) => DropdownMenuItem(
            value: items[index],
            child: Text(itemLabels[index]),
          ),
        ),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
}
