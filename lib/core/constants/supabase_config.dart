import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration from environment variables
///
/// Values are loaded from .env file at runtime.
/// Create a .env file in the project root with:
/// ```
/// SUPABASE_URL=https://your-project-id.supabase.co
/// SUPABASE_ANON_KEY=your-anon-key
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL from environment
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key from environment
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
