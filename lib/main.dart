import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/bindings/initial_binding.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'shared/routes/app_pages.dart';
import 'shared/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data (required for Syncfusion Calendar)
  tz.initializeTimeZones();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize bindings
  InitialBinding().dependencies();

  // Determine initial route based on session
  final hasSession = Supabase.instance.client.auth.currentSession != null;
  final initialRoute = hasSession ? Routes.dashboard : Routes.login;

  runApp(SalonOneApp(initialRoute: initialRoute));
}

class SalonOneApp extends StatelessWidget {
  final String initialRoute;

  const SalonOneApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Salon One Commander',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: GetMaterialApp(
        title: 'Salon One Commander',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
      ),
    );
  }
}
