import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

/// Middleware to protect routes that require authentication
///
/// Usage: Add to GetPage definition
/// ```dart
/// GetPage(
///   name: Routes.dashboard,
///   page: () => const DashboardView(),
///   binding: DashboardBinding(),
///   middlewares: [AuthMiddleware()],
/// ),
/// ```
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is authenticated
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // Not authenticated, redirect to login
      return const RouteSettings(name: Routes.login);
    }

    // Check if token is expired
    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now >= expiresAt) {
        // Token expired, redirect to login
        Supabase.instance.client.auth.signOut();
        return const RouteSettings(name: Routes.login);
      }
    }

    // Authenticated, allow access
    return null;
  }
}

/// Middleware to prevent authenticated users from accessing auth pages
///
/// Usage: Add to login/signup routes
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check if user is already authenticated
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Already authenticated, redirect to dashboard
      return const RouteSettings(name: Routes.dashboard);
    }

    // Not authenticated, allow access to auth pages
    return null;
  }
}
