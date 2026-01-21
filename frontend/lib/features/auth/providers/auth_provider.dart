import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/storage_service.dart';
import '../../../models/auth_response_model.dart';
import '../../../services/auth_service.dart';

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

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.authResponse,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    AuthResponseModel? authResponse,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      authResponse: authResponse ?? this.authResponse,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await _authService.isAuthenticated();
    state = state.copyWith(isAuthenticated: isAuth);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);
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
}
