import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricServiceProvider = Provider((ref) => BiometricService());

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  const FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
      );

      return authenticated;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBiometricSetup() async {
    try {
      final storedEmail = await _storage.read(key: 'biometric_email');
      return storedEmail != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setupBiometrics(String email, String password) async {
    try {
      // First authenticate to ensure user wants to setup biometrics
      final authenticated = await authenticateWithBiometrics(
        localizedReason: 'Setup biometric authentication for quick access',
      );

      if (authenticated) {
        // Store credentials securely for biometric login
        await _storage.write(key: 'biometric_email', value: email);
        await _storage.write(key: 'biometric_password', value: password);
        await _storage.write(key: 'biometric_enabled', value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> disableBiometrics() async {
    try {
      await _storage.delete(key: 'biometric_email');
      await _storage.delete(key: 'biometric_password');
      await _storage.delete(key: 'biometric_enabled');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final email = await _storage.read(key: 'biometric_email');
      final password = await _storage.read(key: 'biometric_password');
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: 'biometric_enabled');
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  Future<String> getBiometricType() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris Scanner';
      } else {
        return 'Biometric';
      }
    } catch (e) {
      return 'Biometric';
    }
  }
}
