import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App text theme following Material 3 type scale with semantic naming
///
/// Uses Inter as the primary font (modern, highly legible)
/// Follows the 8pt grid system for consistent sizing
class AppTextTheme {
  AppTextTheme._();

  // Font family
  static const String _fontFamily = 'Inter';

  // ============================================================================
  // DISPLAY - Large, impactful text for hero sections
  // ============================================================================

  /// Display Large: 57px - Hero headlines, splash screens
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium: 45px - Section headers, major titles
  static TextStyle get displayMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Display Small: 36px - Page titles, card headers
  static TextStyle get displaySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============================================================================
  // HEADLINE - Content section headers
  // ============================================================================

  /// Headline Large: 32px - Page headers
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  /// Headline Medium: 28px - Section titles
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  /// Headline Small: 24px - Card titles, dialog headers
  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============================================================================
  // TITLE - UI element headers
  // ============================================================================

  /// Title Large: 22px - App bar titles, list headers
  static TextStyle get titleLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Title Medium: 16px - Card subtitles, navigation items
  static TextStyle get titleMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Title Small: 14px - List item titles, tab labels
  static TextStyle get titleSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============================================================================
  // BODY - Main content text
  // ============================================================================

  /// Body Large: 16px - Primary body text, paragraphs
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium: 14px - Secondary body text, descriptions
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small: 12px - Tertiary text, timestamps
  static TextStyle get bodySmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============================================================================
  // LABEL - UI control text
  // ============================================================================

  /// Label Large: 14px - Button text, prominent labels
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium: 12px - Input labels, chip text
  static TextStyle get labelMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small: 11px - Captions, helper text
  static TextStyle get labelSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============================================================================
  // SEMANTIC STYLES - Common use cases
  // ============================================================================

  /// Page title style
  static TextStyle get pageTitle => headlineLarge;

  /// Section title style
  static TextStyle get sectionTitle => titleLarge;

  /// Card title style
  static TextStyle get cardTitle => titleMedium;

  /// Card subtitle style
  static TextStyle get cardSubtitle =>
      bodyMedium.copyWith(color: AppColors.mutedForeground);

  /// List item title style
  static TextStyle get listItemTitle => titleSmall;

  /// List item subtitle style
  static TextStyle get listItemSubtitle =>
      bodySmall.copyWith(color: AppColors.mutedForeground);

  /// Button text style
  static TextStyle get button => labelLarge;

  /// Caption style (timestamps, metadata)
  static TextStyle get caption =>
      labelSmall.copyWith(color: AppColors.mutedForeground);

  /// Helper text style (form hints)
  static TextStyle get helper =>
      bodySmall.copyWith(color: AppColors.mutedForeground);

  /// Error text style
  static TextStyle get error => bodySmall.copyWith(color: AppColors.error);

  /// Success text style
  static TextStyle get success => bodySmall.copyWith(color: AppColors.success);

  /// Link text style
  static TextStyle get link => bodyMedium.copyWith(
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );

  /// Monospace style (code, IDs)
  static TextStyle get mono =>
      bodyMedium.copyWith(fontFamily: 'monospace', letterSpacing: 0);

  // ============================================================================
  // MATERIAL TEXT THEME
  // ============================================================================

  /// Get complete Material TextTheme for dark mode
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.foreground),
    displayMedium: displayMedium.copyWith(color: AppColors.foreground),
    displaySmall: displaySmall.copyWith(color: AppColors.foreground),
    headlineLarge: headlineLarge.copyWith(color: AppColors.foreground),
    headlineMedium: headlineMedium.copyWith(color: AppColors.foreground),
    headlineSmall: headlineSmall.copyWith(color: AppColors.foreground),
    titleLarge: titleLarge.copyWith(color: AppColors.foreground),
    titleMedium: titleMedium.copyWith(color: AppColors.foreground),
    titleSmall: titleSmall.copyWith(color: AppColors.foreground),
    bodyLarge: bodyLarge.copyWith(color: AppColors.foreground),
    bodyMedium: bodyMedium.copyWith(color: AppColors.foreground),
    bodySmall: bodySmall.copyWith(color: AppColors.mutedForeground),
    labelLarge: labelLarge.copyWith(color: AppColors.foreground),
    labelMedium: labelMedium.copyWith(color: AppColors.foreground),
    labelSmall: labelSmall.copyWith(color: AppColors.mutedForeground),
  );

  /// Get complete Material TextTheme for light mode
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.lightForeground),
    displayMedium: displayMedium.copyWith(color: AppColors.lightForeground),
    displaySmall: displaySmall.copyWith(color: AppColors.lightForeground),
    headlineLarge: headlineLarge.copyWith(color: AppColors.lightForeground),
    headlineMedium: headlineMedium.copyWith(color: AppColors.lightForeground),
    headlineSmall: headlineSmall.copyWith(color: AppColors.lightForeground),
    titleLarge: titleLarge.copyWith(color: AppColors.lightForeground),
    titleMedium: titleMedium.copyWith(color: AppColors.lightForeground),
    titleSmall: titleSmall.copyWith(color: AppColors.lightForeground),
    bodyLarge: bodyLarge.copyWith(color: AppColors.lightForeground),
    bodyMedium: bodyMedium.copyWith(color: AppColors.lightForeground),
    bodySmall: bodySmall.copyWith(color: AppColors.lightMutedForeground),
    labelLarge: labelLarge.copyWith(color: AppColors.lightForeground),
    labelMedium: labelMedium.copyWith(color: AppColors.lightForeground),
    labelSmall: labelSmall.copyWith(color: AppColors.lightMutedForeground),
  );
}

// ==============================================================================
// CONTEXT EXTENSION
// ==============================================================================

/// Extension on BuildContext for easy access to text styles
///
/// Usage:
/// ```dart
/// Text('Hello', style: context.appTextTheme.pageTitle);
/// Text('Subtitle', style: context.appTextTheme.cardSubtitle);
/// ```
extension AppTextThemeExtension on BuildContext {
  /// Access app text styles
  AppTextStyles get appTextTheme => AppTextStyles(this);
}

/// Helper class providing themed text styles based on current brightness
class AppTextStyles {
  /// Creates text styles based on the given context's theme brightness
  AppTextStyles(this._context);

  final BuildContext _context;

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;
  Color get _foreground =>
      _isDark ? AppColors.foreground : AppColors.lightForeground;
  Color get _muted =>
      _isDark ? AppColors.mutedForeground : AppColors.lightMutedForeground;

  // Display styles
  TextStyle get displayLarge =>
      AppTextTheme.displayLarge.copyWith(color: _foreground);
  TextStyle get displayMedium =>
      AppTextTheme.displayMedium.copyWith(color: _foreground);
  TextStyle get displaySmall =>
      AppTextTheme.displaySmall.copyWith(color: _foreground);

  // Headline styles
  TextStyle get headlineLarge =>
      AppTextTheme.headlineLarge.copyWith(color: _foreground);
  TextStyle get headlineMedium =>
      AppTextTheme.headlineMedium.copyWith(color: _foreground);
  TextStyle get headlineSmall =>
      AppTextTheme.headlineSmall.copyWith(color: _foreground);

  // Title styles
  TextStyle get titleLarge =>
      AppTextTheme.titleLarge.copyWith(color: _foreground);
  TextStyle get titleMedium =>
      AppTextTheme.titleMedium.copyWith(color: _foreground);
  TextStyle get titleSmall =>
      AppTextTheme.titleSmall.copyWith(color: _foreground);

  // Body styles
  TextStyle get bodyLarge =>
      AppTextTheme.bodyLarge.copyWith(color: _foreground);
  TextStyle get bodyMedium =>
      AppTextTheme.bodyMedium.copyWith(color: _foreground);
  TextStyle get bodySmall => AppTextTheme.bodySmall.copyWith(color: _muted);

  // Label styles
  TextStyle get labelLarge =>
      AppTextTheme.labelLarge.copyWith(color: _foreground);
  TextStyle get labelMedium =>
      AppTextTheme.labelMedium.copyWith(color: _foreground);
  TextStyle get labelSmall => AppTextTheme.labelSmall.copyWith(color: _muted);

  // Semantic styles
  TextStyle get pageTitle => headlineLarge;
  TextStyle get sectionTitle => titleLarge;
  TextStyle get cardTitle => titleMedium;
  TextStyle get cardSubtitle => bodyMedium.copyWith(color: _muted);
  TextStyle get listItemTitle => titleSmall;
  TextStyle get listItemSubtitle => bodySmall.copyWith(color: _muted);
  TextStyle get button => labelLarge;
  TextStyle get caption => labelSmall.copyWith(color: _muted);
  TextStyle get helper => bodySmall.copyWith(color: _muted);
  TextStyle get error => bodySmall.copyWith(color: AppColors.error);
  TextStyle get success => bodySmall.copyWith(color: AppColors.success);
  TextStyle get link => bodyMedium.copyWith(
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
  );
  TextStyle get mono => AppTextTheme.mono.copyWith(color: _foreground);
}
