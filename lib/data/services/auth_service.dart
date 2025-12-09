import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../models/auth_user.dart';
import 'session_service.dart';
import 'api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Authentication service wrapping Supabase Auth
///
/// Handles:
/// - Email/password sign in
/// - Session management
/// - User role fetching from backend
/// - Auth state changes
class AuthService extends GetxService {
  final _supabase = Supabase.instance.client;
  final _sessionService = Get.find<SessionService>();

  /// Current authenticated user (observable)
  final Rx<AuthUser?> currentUser = Rx<AuthUser?>(null);

  /// Loading state for auth operations
  final RxBool isLoading = false.obs;

  /// Error message for auth operations
  final RxnString errorMessage = RxnString(null);

  /// Stream subscription for auth state changes
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void onInit() {
    super.onInit();
    _initAuthStateListener();
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    super.onClose();
  }

  /// Initialize listener for Supabase auth state changes
  void _initAuthStateListener() {
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen(
      (data) async {
        final event = data.event;
        final session = data.session;

        switch (event) {
          case AuthChangeEvent.signedIn:
            if (session != null) {
              await _sessionService.saveSession(session);
              await _fetchAndSetUserRole();
            }
            break;
          case AuthChangeEvent.signedOut:
            await _sessionService.clearSession();
            currentUser.value = null;
            break;
          case AuthChangeEvent.tokenRefreshed:
            if (session != null) {
              await _sessionService.saveSession(session);
            }
            break;
          case AuthChangeEvent.userUpdated:
            await _fetchAndSetUserRole();
            break;
          default:
            break;
        }
      },
      onError: (error) {
        errorMessage.value = 'Auth state error: $error';
      },
    );
  }

  /// Get the current access token for API requests
  String? get accessToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  /// Check if user is currently authenticated
  bool get isAuthenticated => currentUser.value != null;

  /// Sign in with email and password
  ///
  /// Returns the authenticated user on success, throws on failure
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session == null) {
        throw Exception('No session returned from authentication');
      }

      // Save session to secure storage
      await _sessionService.saveSession(response.session!);

      // Fetch user role from backend and create AuthUser
      final authUser = await _fetchAndSetUserRole();

      return authUser;
    } on AuthException catch (e) {
      errorMessage.value = _getReadableAuthError(e);
      rethrow;
    } catch (e) {
      errorMessage.value = 'Sign in failed: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _supabase.auth.signOut();
      await _sessionService.clearSession();
      currentUser.value = null;
    } catch (e) {
      errorMessage.value = 'Sign out failed: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore session on app startup
  ///
  /// Returns true if session was restored successfully
  Future<bool> restoreSession() async {
    try {
      // Check if we have a stored session
      final hasStored = await _sessionService.hasStoredSession();
      if (!hasStored) return false;

      // Check current Supabase session (it auto-restores from its own storage)
      final session = _supabase.auth.currentSession;
      if (session == null) {
        await _sessionService.clearSession();
        return false;
      }

      // Try to load cached user data first for quick UI response
      final cachedUser = await _sessionService.getUserData();
      if (cachedUser != null) {
        currentUser.value = cachedUser;
      }

      // Refresh user data from backend in background
      _fetchAndSetUserRole().catchError((e) {
        // Silent fail - we already have cached data
        return currentUser.value ?? cachedUser!;
      });

      return true;
    } catch (e) {
      await _sessionService.clearSession();
      return false;
    }
  }

  /// Fetch user role from backend and update currentUser
  Future<AuthUser> _fetchAndSetUserRole() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) {
      throw Exception('No authenticated user');
    }

    try {
      // Fetch role and tenant info from your backend
      final apiClient = Get.find<ApiClient>();
      final response = await apiClient.getRequest<Map<String, dynamic>>(
        ApiEndpoints.authMe,
        decoder: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final authUser = AuthUser.fromJson({
          'id': supabaseUser.id,
          'email': supabaseUser.email ?? '',
          ...response.data!,
        });

        currentUser.value = authUser;
        await _sessionService.saveUserData(authUser);

        return authUser;
      } else {
        // Backend call failed, create basic user from Supabase data
        // This allows the app to work even if /auth/me is temporarily unavailable
        final basicUser = AuthUser(
          id: supabaseUser.id,
          email: supabaseUser.email ?? '',
          role: UserRole.employee,
          salonId: '',
        );

        currentUser.value = basicUser;
        return basicUser;
      }
    } catch (e) {
      // Create basic user if backend call fails
      final basicUser = AuthUser(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        role: UserRole.employee,
        salonId: '',
      );

      currentUser.value = basicUser;
      return basicUser;
    }
  }

  /// Convert AuthException to user-friendly message
  String _getReadableAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email address';
    }
    if (message.contains('too many requests')) {
      return 'Too many attempts. Please try again later';
    }
    if (message.contains('user not found')) {
      return 'No account found with this email';
    }

    return e.message;
  }

  /// Check if there's a potentially valid session (static method for routing)
  static Future<bool> hasValidSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }
}
