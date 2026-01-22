import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/storage_service.dart';
import '../../../models/auth_response_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    return AuthNotifier(ref.read(authServiceProvider));
  },
);

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final AuthResponseModel? authResponse;
  final UserModel? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.authResponse,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    AuthResponseModel? authResponse,
    UserModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      authResponse: authResponse ?? this.authResponse,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService = UserService();

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      await _loadUser();
    }
    state = state.copyWith(isAuthenticated: isAuth);
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userService.getProfile();
      state = state.copyWith(user: user);
    } catch (e) {
      print('User profile loading failed: $e');
      // Don't clear auth state immediately - just leave user as null
      // The user can still navigate and the data will be retried later
      state = state.copyWith(user: null);
    }
  }

  Future<void> refreshUser() async {
    await _loadUser();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);
      await _loadUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        authResponse: response,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> registerCustomer(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.registerCustomer(email, password, name);
      await _loadUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        authResponse: response,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> registerDriver(
    String email,
    String password,
    String name,
    String phoneNumber,
    String licenseNumber,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.registerDriver(email, password, name, phoneNumber, licenseNumber);
      await _loadUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        authResponse: response,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  // Keep backward compatibility (deprecated)
  Future<void> register(String email, String password, String name) async {
    await registerCustomer(email, password, name);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  Future<void> clearInvalidAuth() async {
    await _authService.logout();
    state = const AuthState();
  }

  Future<Map<String, String?>> debugAuthState() async {
    final token = await StorageService.getToken();
    final email = await StorageService.getUserEmail();
    return {
      'hasToken': (token != null && token.isNotEmpty).toString(),
      'tokenLength': token?.length.toString() ?? '0',
      'email': email,
      'isAuthenticated': state.isAuthenticated.toString(),
      'hasUser': (state.user != null).toString(),
      'userRole': state.user?.role,
    };
  }
}
