import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'core/bindings/initial_binding.dart';
import 'core/theme/app_theme.dart';
import 'shared/routes/app_pages.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize bindings
  InitialBinding().dependencies();

  runApp(const SalonOneApp());
}

class SalonOneApp extends StatelessWidget {
  const SalonOneApp({super.key});

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
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
      ),
    );
  }
}
