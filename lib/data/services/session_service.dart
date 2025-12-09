import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../models/auth_user.dart';

/// Service for secure session and user data storage
///
/// Uses flutter_secure_storage for encrypted storage of:
/// - Access token for API requests
/// - Refresh token for session renewal
/// - User data (role, salonId) for quick access
class SessionService extends GetxService {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserData = 'user_data';
  static const _keyExpiresAt = 'expires_at';

  late final FlutterSecureStorage _storage;

  /// Initialize the storage with platform-specific options
  @override
  void onInit() {
    super.onInit();
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  /// Save the complete session from Supabase
  Future<void> saveSession(Session session) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: session.accessToken),
      _storage.write(key: _keyRefreshToken, value: session.refreshToken),
      _storage.write(
        key: _keyExpiresAt,
        value: session.expiresAt?.toString() ?? '',
      ),
    ]);
  }

  /// Get the stored access token
  Future<String?> getAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Get the stored refresh token
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  /// Check if there's a potentially valid session stored
  Future<bool> hasStoredSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if the stored session is expired
  Future<bool> isSessionExpired() async {
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    if (expiresAtStr == null || expiresAtStr.isEmpty) return true;

    final expiresAt = int.tryParse(expiresAtStr);
    if (expiresAt == null) return true;

    // Add a small buffer (60 seconds) to account for clock skew
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now >= (expiresAt - 60);
  }

  /// Save user data for quick access without network calls
  Future<void> saveUserData(AuthUser user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.write(key: _keyUserData, value: jsonString);
  }

  /// Get stored user data
  Future<AuthUser?> getUserData() async {
    final jsonString = await _storage.read(key: _keyUserData);
    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthUser.fromJson(json);
    } catch (e) {
      // Invalid JSON, clear it
      await _storage.delete(key: _keyUserData);
      return null;
    }
  }

  /// Clear all stored session data (logout)
  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserData),
      _storage.delete(key: _keyExpiresAt),
    ]);
  }

  /// Get all session data for debugging (development only)
  Future<Map<String, String?>> debugGetAllSessionData() async {
    return {
      'accessToken': await getAccessToken(),
      'refreshToken': await getRefreshToken(),
      'expiresAt': await _storage.read(key: _keyExpiresAt),
      'userData': await _storage.read(key: _keyUserData),
    };
  }
}
