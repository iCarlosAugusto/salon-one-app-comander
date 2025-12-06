/// App-wide constants for the Salon One Commander app
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Salon One Commander';
  static const String appVersion = '1.0.0';

  // Default Salon ID (can be changed in settings)
  static const String defaultSalonId = '7e446c70-e87c-4ed3-a288-40171faae563';

  // Pagination
  static const int defaultPageSize = 20;

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayTimeFormat = 'HH:mm';

  // Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Border Radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
}
