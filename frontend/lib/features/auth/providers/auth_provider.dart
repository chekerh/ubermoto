import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../core/utils/storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isInitialized;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
    userService: ref.read(userServiceProvider),
  )..init();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final UserService userService;

  AuthNotifier({
    required this.authService,
    required this.userService,
  }) : super(const AuthState());

  Future<void> init() async {
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(isLoading: true, error: null);
      await refreshUser();
      return;
    }
    state = state.copyWith(isInitialized: true);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authService.login(email, password);
      await refreshUser();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> registerCustomer({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authService.registerCustomer(email, password, name);
      await refreshUser();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> registerDriver({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String licenseNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authService.registerDriver(
        email,
        password,
        name,
        phoneNumber,
        licenseNumber,
      );
      await refreshUser();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await userService.getProfile();
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: true,
        user: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    state = const AuthState(
      isAuthenticated: false,
      user: null,
      isLoading: false,
      isInitialized: true,
    );
  }

  Future<Map<String, String?>> debugAuthState() async {
    final token = await StorageService.getToken();
    final email = await StorageService.getUserEmail();
    return {
      'isAuthenticated': state.isAuthenticated.toString(),
      'userId': state.user?.id,
      'userRole': state.user?.role,
      'hasToken': (token != null && token.isNotEmpty).toString(),
      'storedEmail': email,
      'error': state.error,
    };
  }

  Future<void> clearInvalidAuth() async {
    await StorageService.clearAll();
    state = const AuthState(
      isAuthenticated: false,
      user: null,
      isLoading: false,
      isInitialized: true,
    );
  }
}
